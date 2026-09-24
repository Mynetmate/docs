# ADR — Lean P1 Login Rate Limiter Decisions

> **Status:** Accepted by Auth Owner (Naphat)  
> **Scope:** Authentication P1, one FastAPI process/worker  
> **Canonical contracts:** `00_Authentication(Naphat)/03_Component Diagram.md`, `04_API Contracts.md`, `05_Acceptance Tests.md` และ `07_Test Users and Environment Policy.md`

## Context

MyNetMate ต้องจำกัด Brute-force Login และงาน Argon2id ที่เกิดพร้อมกันโดยไม่เพิ่ม Redis, Database Table, Distributed Limiter, CAPTCHA หรือ Account Lockout ใน P1 เดิมมีข้อเสนอเก็บ Identifier Telemetry ด้วย HMAC แต่ข้อมูลดังกล่าวไม่ใช้ตัดสิน Admission และยอมให้ Drop ได้ จึงสร้างความซับซ้อนเกินประโยชน์ของ Lean P1

## Decision

Rate Limiter เก็บและบังคับใช้เฉพาะ Canonical Client IP ใน Bounded In-memory Sliding-window TTL Store ไม่รับหรือเก็บ Username, Email, Raw Identifier, HMAC Digest หรือ Identifier Counter Request field `identifier` ยังคงใช้ค้นหา Username/Email ใน Authentication Service และกฎห้าม Raw Failed-login Identifier ปรากฏใน Application/Audit Log ยังคงมีผล

Capacity Contract ของ Lean P1 คือค่าเริ่มต้น 10,000 Canonical Client IP Keys เมื่อ Store เต็มต้อง Prune Expired Reclaimable Keys ให้ครบก่อน หากยังเต็มด้วย Active IP Keys ให้ปฏิเสธ IP Key ใหม่ด้วย `503 AUTH_SERVICE_UNAVAILABLE` โดยห้าม Evict Active Failure State ข้อกำหนดนี้แทน Decision D8–D9 เดิมทั้งชุด

### Active decisions

| Decision | Accepted behavior |
| :--- | :--- |
| D3 — Concurrent attempts | ใช้ Reservation โดยอนุญาตให้เริ่มเมื่อ `Failures ที่ยังอยู่ใน Window + In-flight Attempts < 5`; ตรวจ Capacity และจองแบบ Atomic ก่อน User Query/Argon2id |
| D4 — Successful login | คืน Reservation แต่ไม่ล้าง Failure เก่าที่ยังอยู่ใน Window |
| D5 — Blocked request | Request ที่ถูกปฏิเสธไม่เพิ่ม Failure และไม่ต่ออายุ Window |
| D6 — Window boundary | Failure หมดอายุเมื่อ `age >= 900` วินาที |
| D7 — Failure timestamp | ใช้เวลาที่ทราบผลตรวจ Credential ว่าล้มเหลว |
| D11 — Pruning | เวลาปกติ Prune Key ที่แตะ; ก่อนปฏิเสธเพราะ Capacity ต้อง Prune Expired Reclaimable Keys ให้ครบเพื่อป้องกัน False-full |
| D12 — Concurrency boundary | ใช้ Async Core และ `asyncio.Lock` บน Event Loop เดียว Lock ครอบเฉพาะ State Transition และห้ามครอบ User Query, Argon2id, Audit หรืองาน I/O |
| D13 — Missing/invalid Client IP | Fail Closed ด้วย `503 AUTH_SERVICE_UNAVAILABLE`; ห้ามใช้ Bucket `unknown` |
| D14 — Trusted proxy | ให้ Uvicorn ประมวลผล Proxy Header จุดเดียวจาก Exact Trusted Proxy IP Allowlist การเชื่อม Startup/Deployment ต้องให้ Foundation ยืนยัน |
| D15 — Attempt lifecycle | ใช้ Async Context Manager ที่รับผลตรวจอย่างชัดเจนและ Cleanup แบบ Idempotent ตาม State Table ด้านล่าง |
| D16 — Memory per IP | แต่ละ IP เก็บ Failure Timestamp ที่ยังมีผลได้สูงสุด 5 รายการและ In-flight Count แบบมีขอบเขต |
| D17 — Capacity error | Capacity เต็มไม่ใช้ `429` เพราะ IP ใหม่ไม่ได้เกิน Threshold ให้ Map เป็น `503 AUTH_SERVICE_UNAVAILABLE` |
| D18 — IP canonicalization | Parse ด้วยมาตรฐาน IP Address และ Normalize IPv4-mapped IPv6 เป็น IPv4 ก่อนใช้เป็น Key |

### D15 explicit attempt lifecycle

| เหตุการณ์ | ผลต่อ Reservation และ Failure Counter |
| :--- | :--- |
| ถูก Rate-limit ก่อนเริ่ม | ไม่สร้าง Reservation และไม่เพิ่ม Failure |
| ไม่พบบัญชี, Password ผิด หรือบัญชี Inactive | เปลี่ยน Reservation เป็น Failure ของ IP แบบ Atomic หนึ่งครั้ง |
| Credential ถูกต้อง | คืน Reservationและไม่ล้าง Failure เก่า |
| Database/System Error ก่อนทราบผลตรวจ | คืน Reservationหลังงานตรวจที่เริ่มแล้วหยุดจริงและไม่เพิ่ม Credential Failure |
| Credential ถูกต้อง แต่ Session/Audit ขั้นถัดไปล้มเหลว | คืน Reservationและไม่เพิ่ม Credential Failure |
| ทราบผลล้มเหลวแล้ว แต่ Audit/System ขั้นถัดไปล้มเหลว | คง Failure เดิม ห้ามเพิ่มซ้ำหรือย้อนคืน |
| Cancel ก่อนทราบผล | คืน Reservationต่อเมื่องานตรวจที่เริ่มแล้วหยุดจริงและไม่เพิ่ม Failure |
| Cancel หลังทราบผลล้มเหลว | คง Failure เดิม; Cleanup ห้ามลบผลนั้น |

หาก Argon2id ถูกส่งไปทำใน Thread การ Cancel Coroutine ที่รอผลห้ามคืน Reservation จนงานตรวจจริงจบ Context Manager ห้ามอนุมาน Outcome จาก Normal Exit หรือ Exception แต่ต้องรับผลตรวจที่ผู้เรียกระบุชัดเจน

## Superseded by Lean P1 decision

| Decision | Status and reason |
| :--- | :--- |
| D1 — HMAC algorithm | **Superseded by Lean P1 decision:** ไม่มี Identifier Digest |
| D2 — Domain-separation prefix | **Superseded by Lean P1 decision:** ไม่มี Identifier HMAC |
| D8 — Capacity allocation ระหว่าง IP/Identifier | **Superseded by Lean P1 decision:** เลิกแบ่ง Capacity ระหว่าง Key สองชนิด; Capacity Contract ใหม่ใช้เฉพาะ Canonical Client IP Keys |
| D9 — Store-full choices เดิม | **Superseded by Lean P1 decision:** ไม่มี Identifier Telemetry ให้ Drop; ใช้ Capacity Contract ใหม่ที่ Prune ก่อนและตอบ `503` หาก Active IP Store ยังเต็ม |
| D10 — Identifier Telemetry admission | **Superseded by Lean P1 decision:** ตัด Identifier Telemetry ออกจาก P1 |
| D16 ส่วน Identifier | **Superseded by Lean P1 decision:** Memory Bound เหลือเฉพาะ Failure Timestamp และ In-flight Count ต่อ IP |

## Consequences

- ลด Runtime Secret โดยไม่ต้องมี HMAC Secret สำหรับ Identifier Telemetry
- ลด State, Capacity interaction และ Tests ที่ไม่มีผลต่อ Admission
- Per-IP Limiting ยังมีผลกับผู้ใช้หลายคนหลัง NAT เดียวกัน และ In-flight Reservation อาจทำให้เกิด `429` ชั่วคราวก่อนมี Failure ครบ 5 ครั้ง
- `429` ไม่ได้หมายความว่าต้องรอ 15 นาทีเต็มทุกกรณี เพราะ In-flight Attempt อาจจบและคืน Reservation ก่อน
- Counter หายเมื่อ Process Restart และต้องเปลี่ยน Architecture หากใช้หลาย Worker/Instance

## Non-goals

- Identifier/Account-based Rate Limit
- Account Lockout
- Persistent Security Telemetry
- Redis หรือ Distributed Rate Limiter
- CAPTCHA
