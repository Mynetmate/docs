## สรุปสั้นที่สุด

Audit Trail ของ MyNetMate คือ “สมุดประวัติกลางของระบบ” ที่บันทึกว่า **ใครทำอะไร กับข้อมูลใด เมื่อไร และสำเร็จหรือล้มเหลว** โดยเป็น **P1-INFRA ที่ต้องมีตั้งแต่ Sprint 0**

สถานะปัจจุบันคือ:

- ด้าน Scope, Schema และ Contract: **ออกแบบเสร็จและ Reconciled แล้ว**
- ด้านโค้ดจริง: **ยังไม่พบการ Implement Audit Trail ใน Backend ปัจจุบัน**

กล่าวง่าย ๆ คือ **เอกสารพร้อมให้เริ่มเขียน แต่ระบบ Audit Trail ยังไม่ได้ทำงานจริง**

## Audit Trail คืออะไร

ทุก Feature ที่เกิดเหตุการณ์สำคัญต้องส่ง Event ผ่านฟังก์ชันกลาง `record_audit_event()` แล้วบันทึกลงตาราง `audit_logs` เพียงตารางเดียว

ข้อมูลหลัก 9 ฟิลด์ ได้แก่:

- `id`
- `user_id` — ผู้กระทำ อาจเป็น `null` สำหรับเหตุการณ์ไม่ทราบตัวตน
- `action` — เช่น `device.create`
- `resource_type`
- `resource_id`
- `result` — `success` หรือ `failure`
- `safe_error_category`
- `description` — ต้องผ่านการกรองความลับแล้ว
- `created_at`

Audit Trail เป็น **Append-only** คือเพิ่มรายการได้อย่างเดียว ไม่มี API สำหรับแก้ไขหรือลบประวัติ

## มีไว้ทำไม

1. **ตรวจสอบย้อนหลัง:** รู้ว่าใครเพิ่ม แก้ หรือลบข้อมูล
2. **รองรับ Security และ Compliance:** ตรวจสอบ Login ล้มเหลว การข้ามสิทธิ์ และการ Override กฎ CIS
3. **หาสาเหตุเมื่อเกิดปัญหา:** เชื่อมเหตุการณ์กับผู้ใช้และข้อมูลที่ได้รับผลกระทบ
4. **ป้อนข้อมูลให้ Dashboard:** ใช้แสดง Recent Activity
5. **รักษาความถูกต้องของระบบ:** หาก Business Action สำเร็จแต่ Audit เขียนไม่ได้ ต้องไม่ปล่อยให้ข้อมูลเปลี่ยนโดยไม่มีหลักฐาน

Audit Trail นี้ไม่ใช่ AI Audit และไม่ใช่ Version Control มันบันทึก “เหตุการณ์” แต่ไม่ได้เก็บความสามารถ Rollback Config

## เจ้าของและหน้าที่

| ส่วน                       | หน้าที่                                                                       |
| -------------------------- | ----------------------------------------------------------------------------- |
| Central Schema Owner       | กำหนดโครงสร้าง `audit_logs`                                                   |
| Audit Owner                | ดูแล `record_audit_event()` และ `GET /api/audit-logs`                         |
| Auth Producer              | ส่งเหตุการณ์ Auth ผ่าน `record_auth_event()` โดยส่งเฉพาะ 4 Business Arguments |
| Device/Config/CIS/Settings | เป็น Producer เรียก Writer กลางเมื่อเกิดเหตุการณ์                             |
| Dashboard & Monitoring     | เป็น Read-only Consumer อ่าน Recent Activity เท่านั้น                         |

Producer ห้ามเขียน `audit_logs` โดยตรง และ Auth ห้ามส่ง Client IP หรือ `description` จาก Request เข้า Audit Writer

## กฎ Transaction สำคัญ

มีสองกรณี:

- **Business Mutation สำเร็จ:** เช่นแก้ Device หรือเปลี่ยน Password ต้องเขียนข้อมูลธุรกิจกับ Audit ใน Transaction เดียวกัน หาก Audit ล้มเหลวต้อง Rollback ทั้งหมด
- **Request ถูกปฏิเสธโดยตั้งใจ:** เช่น `user.login_failed` หรือ `auth.permission_denied` ต้องใช้ Audit Transaction แยก เพื่อให้ประวัติยังถูกบันทึกแม้ Request หลักได้ `401` หรือ `403`

ถ้า Mandatory Audit Write ล้มเหลว ระบบต้อง Fail Closed และตอบ `503 AUTH_SERVICE_UNAVAILABLE`

## P1 ของ Audit Trail มีอะไรบ้าง

### Event ที่อนุญาตใน P1

Auth และ User Management:

- `user.login_success`
- `user.login_failed`
- `user.logout`
- `user.password_changed`
- `user.created`
- `user.updated`
- `user.deactivated`
- `auth.permission_denied`

Feature อื่น:

- `device.create`
- `device.update`
- `device.delete`
- `config.generate`
- `scan.run`
- `scan.override`
- `settings.update`

Event ที่ไม่อยู่ใน Registry หรือส่ง `resource_type`, `result` หรือ Error Category ไม่ตรง Contract ต้องถูกปฏิเสธก่อน Insert

### API ใน P1

- `GET /api/audit-logs`
    - เฉพาะ Admin ที่มีสิทธิ์ `audit.read`
    - Filter ตาม Action, Resource, Actor, Result และช่วงเวลา
    - ใช้ Cursor Pagination เท่านั้น
- `GET /api/dashboard/recent-activity`
    - D&M อ่านจาก `audit_logs` แบบ Read-only
    - แสดงเฉพาะ Event ใน Positive Allowlist
    - ไม่ส่ง IP, Error Detail, Secret หรือ Full Description
    - ถ้าไม่ทราบผู้กระทำ แสดง `Unknown`

### Privacy ใน P1

- ไม่มีคอลัมน์ `ip_address` ใน `audit_logs`
- ห้ามเก็บ Password, Hash, Session Token, Cookie, Credential Secret และ Username ดิบจาก Failed Login
- ต้อง Redact ก่อนเขียนลงฐานข้อมูล ไม่ใช่รอกรองตอนส่ง API
- Validation Error หรือ HTTP 400/422 ทั่วไปยังไม่บันทึกใน P1 เพื่อลด Log Noise และความเสี่ยงข้อมูลดิบรั่ว

## สิ่งที่ไม่ใช่ P1

- `config.deploy` เป็น **P2** เพราะ SSH Push จริงอยู่ใน P2
- Version Control และ Rollback เป็น P2
- SIEM Integration
- PDF/CSV Export ขั้นสูง
- Automatic Alert
- Automatic Retention
- Cryptographic/WORM Tamper-proof Storage
- Field-level Audit Permission
- Auto-Rollback ถูกตัดออกจาก Scope ถาวร

## ทำถึงไหนแล้ว

|งาน|สถานะ|
|---|---|
|นิยาม MVP และขอบเขต P1|เสร็จ|
|Central Schema `audit_logs`|ออกแบบเสร็จ|
|Global Action Registry|เสร็จ|
|Transaction และ Privacy Rules|เสร็จ|
|Auth Contract|Reconciled|
|Dashboard Consumer Contract|Reconciled|
|Acceptance Tests ในเอกสาร|กำหนดแล้ว|
|Database Model/Migration จริง|ยังไม่พบ|
|`record_audit_event()` จริง|ยังไม่พบ|
|Full Audit API|ยังไม่พบ|
|Recent Activity API|ยังไม่พบ|
|Automated Tests|ยังไม่พบ|

ดังนั้น Verdict ที่เหมาะสมคือ:

> **Audit Trail ของ MyNetMate อยู่ในสถานะ Design-ready / Approved & Reconciled สำหรับ P1 แต่ยังไม่ Implementation-ready ในความหมายว่าโค้ดเสร็จแล้ว**

เอกสารอ้างอิงหลัก: [MVP Audit Trail](<../01_MVP - Audit Trail.md>), [Event Registry](<../02_Data Ownership and Event Catalog.md>), [API Contracts](<../04_API Contracts.md>), [Integration Matrix](<../06_Integration Contract Matrix.md>) และ [Central Schema](<../../Data Information 27-06-69.md>)


# Outcome
Outcome ของ Audit Trail คือ:

> **MyNetMate สามารถแสดงหลักฐานย้อนหลังได้อย่างน่าเชื่อถือว่า ใครทำอะไร กับข้อมูลใด เมื่อไร และผลเป็นอย่างไร โดยไม่เปิดเผยข้อมูลลับ**

เมื่อ P1 เสร็จ ผู้ใช้ควรเห็นผลลัพธ์ดังนี้:

- ทุก Action สำคัญถูกบันทึกลง `audit_logs` อัตโนมัติ
- Admin เปิดดูประวัติทั้งหมดและกรองข้อมูลได้
- Dashboard แสดงกิจกรรมล่าสุดแบบย่อได้
- การแก้ไขข้อมูลกับ Audit Log สำเร็จหรือ Rollback พร้อมกัน
- Login ล้มเหลวและ Permission Denied ยังมีหลักฐาน แม้คำขอถูกปฏิเสธ
- ไม่มี Password, Token, Credential Secret หรือ Client IP หลุดเข้า Log
- ไม่มีใครแก้ไขหรือลบ Audit Log ผ่าน Application API ได้
- ทีมสามารถใช้ Log สืบหาสาเหตุและรองรับการตรวจสอบด้าน Security/Compliance

ตัวชี้วัดความสำเร็จหลักคือ:

> **ทุก P1 Action ที่อยู่ใน Event Registry ต้องมี Audit Log ที่ถูกต้องครบถ้วน 100% และไม่มีข้อมูลลับรั่วไหล**

หมายเหตุ: ใน Schema ปัจจุบันไม่มีฟิลด์ชื่อ `outcome` แล้ว แต่ใช้ `result = success | failure` ร่วมกับ `safe_error_category` แทน เพื่อระบุผลของแต่ละเหตุการณ์อย่างเป็นมาตรฐานครับ
