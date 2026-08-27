# Authentication Architecture Review — MyNetMate P1
> **บทบาทผู้วิเคราะห์:** Architecture Reviewer (วิเคราะห์เชิงสถาปัตยกรรมเท่านั้น — ไม่แก้ไขโค้ด)  
> **วันที่:** 2026-08-27 | **อ้างอิงเอกสารจริง:** canonical files `00`–`07` ใน `02_feature/00_Authentication(Naphat)/`

---

## 1. Executive Conclusion

เอกสารโครงการฉบับ canonical ปัจจุบัน ([`01_MVP - Authentication & RBAC.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/01_MVP%20-%20Authentication%20&%20RBAC.md) บรรทัด 16–20, [`02_Database Schema.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/02_Database%20Schema.md) บรรทัด 1–2 และ [`Data Information 27-06-69.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/Data%20Information%2027-06-69.md) บรรทัด 76) ได้ปิดประเด็นเป็น **Opaque Server-side Session** อย่างชัดเจนและสอดคล้องกันแล้ว เหตุผลสั้นที่สุดคือ: ทั้งสองแบบต้องทำ DB Query ทุก Protected Request เพื่อรองรับ Immediate Revoke/Deactivate/Role Change — เมื่อ JWT ไม่ได้เซฟ DB Round-trip ใน Context นี้ มันจึงเพิ่มเฉพาะ Surface ของความซับซ้อน (Signing Key, `jti` management, JWKS rotation) โดยไม่ได้ประโยชน์ด้าน Stateless Scalability ใด ๆ ใน P1 อย่างไรก็ตาม การตัดสินใจนี้ **มีเงื่อนไข** — หากโครงการขยายเป็น Multi-service ใน P2+ ข้อได้เปรียบของ JWT จะเปลี่ยนน้ำหนักตาราง Trade-off อย่างมีนัยสำคัญ

---

## 2. Request Flow เปรียบเทียบ

### Option A: JWT + `auth_sessions` (Variant ที่ต้อง DB Check ทุก Request)

```
Browser → FastAPI Auth Guard
  1. อ่าน Cookie (ค่า JWT)
  2. Verify Signature (HMAC-SHA256 หรือ RS256) → ถ้า invalid ปฏิเสธทันที
  3. Parse Claims: sub, role, exp, jti
  4. Query auth_sessions WHERE jti = ? AND is_revoked = false
         ↳ ถ้าพบ: อ่าน user_id ออก
  5. Query users WHERE id = ? AND is_active = true
         ↳ อ่าน role ปัจจุบัน (ต้องอ่านจาก DB เพราะ JWT role อาจเก่า)
  6. require_permission(current_role, permission_key)
  7. ส่งต่อไปยัง Feature API
```

**สังเกต:** มี Query DB 2 ครั้ง และยังต้องการ Signature Verification ก่อนด้วย

> [!NOTE]
> **JWT Variant ที่ไม่ตรวจ DB ทุก Request** (Stateless แท้จริง) ทำ Immediate Revoke/Deactivate ไม่ได้เลย จนกว่า Token จะหมดอายุเอง (`exp`) ซึ่งอาจใช้เวลา 30 นาทีหรือมากกว่า — Variant นี้ไม่ตอบโจทย์ Acceptance Test ข้อ 5 และ 8 ([`05_Acceptance Tests.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/05_Acceptance%20Tests.md) บรรทัด 25–28, 40–41)

---

### Option B: Opaque Server-side Session (ที่เลือกใช้)

```
Browser → FastAPI Auth Guard
  1. อ่าน Cookie (ค่า Opaque Token)
  2. Validate format + SHA-256(token)
  3. Query auth_sessions JOIN users
         WHERE session_token_hash = ?
           AND is_revoked = false
           AND expires_at > now()
           AND users.is_active = true
         ↳ ได้ user_id, current_role, is_active ครั้งเดียว
  4. require_permission(current_role, permission_key)
  5. ส่งต่อไปยัง Feature API
```

**สังเกต:** Query DB **1 ครั้ง** (JOIN) ได้ข้อมูลครบพร้อมกัน ไม่ต้องทำ Signature Verification แยก

---

## 3. Trade-off Table

| มิติ | JWT + `auth_sessions` (DB Check ทุก Request) | Opaque Server-side Session | หมายเหตุ/แหล่งอ้างอิง |
|---|---|---|---|
| **Immediate Revoke / Deactivate** | ✅ ทำได้ (แต่ต้องตรวจ `auth_sessions` ทุก Request) | ✅ ทำได้ (ตรวจ `is_revoked` + `is_active` ทุก Request) | กรณีที่ JWT ไม่ตรวจ DB จะทำไม่ได้เลย — ไม่อยู่ใน Scope P1 |
| **Immediate Role Change** | ⚠️ ทำได้เฉพาะเมื่ออ่าน Role จาก `users` ทุกครั้ง (ไม่ใช้ Role จาก JWT Claim) | ✅ ทำได้ เพราะ Role มาจาก `users` JOIN ทุกครั้ง | [`04_API Contracts.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/04_API%20Contracts.md) บรรทัด 97 |
| **Security / Privacy** | ⚠️ JWT Payload อาจรั่ว Claims ถ้า Decode ได้ฝั่ง Client (ส่วนใหญ่ Base64 ไม่ Encrypted); ต้องจัดการ Signing Key ให้ปลอดภัย | ✅ Cookie มีแค่ Opaque Token ที่ไม่มี Semantic; DB เก็บแค่ Hash — ป้องกัน DB Dump ได้ชั้นหนึ่ง | OWASP Session Management Cheat Sheet §Token Properties |
| **Frontend Burden** | เท่ากันทั้งสองแบบ: ต้องเรียก `/api/auth/me`, handle `401/403`, route guard, logout | เท่ากันทั้งสองแบบ: ต้องเรียก `/api/auth/me`, handle `401/403`, route guard, logout | HttpOnly Cookie → JS ไม่สัมผัส Token ทั้งสองแบบ |
| **Backend Complexity** | ⚠️ สูงกว่า: ต้องจัดการ Signature, Claims, Signing Key Rotation, `jti`, JWKS endpoint (ถ้าใช้ RS256) | ✅ ต่ำกว่า: CSPRNG + SHA-256 + DB Query เท่านั้น ไม่มี Cryptographic Key Material ให้จัดการ | [`01_MVP - Authentication & RBAC.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/01_MVP%20-%20Authentication%20&%20RBAC.md) บรรทัด 18 |
| **Database Load** | ⚠️ DB Query 2 ครั้งต่อ Protected Request (auth_sessions + users) + Signature Verification | ✅ DB Query 1 ครั้ง (JOIN auth_sessions + users) ต่อ Protected Request | ดู Flow ข้อ 2 ด้านบน |
| **Auditability** | ⚠️ `jti` ใช้ Track Session ได้ แต่ต้องระวังไม่ Log Token ดิบ; มีชั้นพิเศษที่ต้อง Audit เพิ่ม (Key rotation events) | ✅ `auth_sessions.id` (UUID) ใช้ Track ได้เหมือนกัน; Audit events ชัดเจนตาม canonical map ใน [`03_Component Diagram.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/03_Component%20Diagram.md) บรรทัด 119–128 | ห้าม Log Token Hash ลง Audit Log ทั้งสองแบบ |
| **Testing** | ⚠️ ต้อง Mock/Setup: Token generation, Signature validation, Key loading, Claims parsing + DB state | ✅ Setup เฉพาะ DB state: Insert `auth_sessions` row + ตั้ง `is_revoked`, `expires_at` ก็พอ | [`05_Acceptance Tests.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/05_Acceptance%20Tests.md) บรรทัด 7–89 |
| **Operational / Key Management** | ⚠️ ต้องมี Signing Key Secret, Rotation Policy, Revocation ถ้าใช้ Public Key (RS256), ต้องระวัง Key ไม่โผล่ใน Log/Env | ✅ ไม่มี Signing Key เลย; ความลับมีแค่ DB connection — ลด Attack Surface | OWASP JWT Security Cheat Sheet |
| **Future Multi-service Scale** | ✅ JWT ให้ประโยชน์ชัดเจนเมื่อมีหลาย Service — แต่ละ Service Verify Signature ได้โดยไม่ต้องโทรกลับ Auth Service | ⚠️ Session ต้องโทรกลับ Auth/DB ทุกครั้ง — เป็น Bottleneck ถ้ามี Service ลูก | **ข้อได้เปรียบนี้ยังไม่เกิดขึ้นจริงใน P1 เพราะระบบเป็น Monolith** |

---

## 4. Demo Scenarios ที่แสดงผลต่างจริง

### Scenario 1: Admin Deactivate Operator ที่กำลังใช้งานอยู่

**กรณี A1 — JWT ไม่ตรวจ DB ทุก Request (Stateless Pure):**
```
T=0:00  Operator login → ได้ JWT มีอายุ 30 นาที
T=0:05  Admin เรียก PATCH /api/admin/users/op_id {is_active: false}
          → DB: users.is_active = false ✓
T=0:06  Operator ยังใช้ JWT เดิม → ผ่าน Signature แล้วอ่าน Claim: is_active ไม่มีใน JWT
          → FastAPI ไม่ Query DB → Request สำเร็จ ❌ (ยังเข้าได้!)
T=0:30  JWT หมดอายุ → ถึงจะถูกปฏิเสธ
```
➜ **Acceptance Test ข้อ 5 ล้มเหลว** — ไม่ตอบโจทย์โปรเจกต์

**กรณี A2 — JWT ตรวจ DB ทุก Request:**
```
T=0:05  Admin deactivate → users.is_active = false + Revoke all sessions (set is_revoked=true)
T=0:06  Operator ส่ง JWT มา → Verify Signature ✓ → Query auth_sessions: is_revoked=true
          → 401 AUTH_SESSION_INVALID ✓
```
➜ ทำได้ แต่ทำ 2 DB queries แทน 1

**กรณี B — Opaque Session:**
```
T=0:05  Admin deactivate → users.is_active = false + auth_sessions.is_revoked = true (Atomic TX)
T=0:06  Operator ส่ง Cookie มา → SHA-256(token) → JOIN Query: is_revoked=true → 401 ✓
```
➜ ทำได้ใน 1 DB Query ([`04_API Contracts.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/04_API%20Contracts.md) บรรทัด 135–139)

---

### Scenario 2: Admin เปลี่ยน Role Operator → Viewer

**กรณี A2 — JWT อ่าน Role จาก JWT Claim (ไม่ Query users):**
```
T=0:00  Operator login → JWT มี claim: "role": "operator"
T=0:10  Admin เรียก PATCH → users.role = "viewer" + Revoke sessions
T=0:11  Operator ส่ง JWT ใหม่หลัง Re-login → ได้ JWT role: "viewer" ✓
```
➜ ถ้า Revoke ทันที ก็ทำได้ — แต่ถ้าลืม Revoke หรือ Token ยังมีอายุเหลือ Role เก่าใช้งานต่อได้

**กรณี A2 — JWT อ่าน Role จาก DB ทุก Request (ไม่เชื่อ Claim):**
```
T=0:10  Admin เปลี่ยน Role → ถ้าไม่ Revoke session แต่อ่าน Role จาก users ทุกครั้ง
         → Role ใหม่มีผลทันทีจริง แต่ JWT มี claim role เก่าในตัวซึ่งไม่ได้ใช้ → ซ้ำซ้อน
```
➜ เอกสาร Auth ระบุชัดว่า "ห้ามเชื่อ Role จาก Cookie" ([`04_API Contracts.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/04_API%20Contracts.md) บรรทัด 97) → JWT `role` Claim จึงไม่ได้ใช้งาน เป็นน้ำหนักส่วนเกิน

**กรณี B — Opaque Session:**
```
T=0:10  Admin เปลี่ยน Role → users.role = "viewer"; Revoke sessions (ตาม Contract)
T=0:11  Request ถัดไป: SHA-256(token) → ไม่พบ Session ที่ Active → 401 ✓
         หรือถ้าไม่ได้ Revoke: JOIN Query → อ่าน users.role = "viewer" → เห็นสิทธิ์ใหม่ทันที
```
➜ Role change มีผลทันทีทั้งสองทาง ไม่ต้องพึ่งพา Claim ใน Cookie

---

### Scenario 3 (โบนัส): Database หยุดทำงานระหว่าง Session กำลังใช้งาน

**ทั้ง A2 และ B:** ต้อง Fail Closed — ปฏิเสธ Request ทันที  
([`04_API Contracts.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/04_API%20Contracts.md) บรรทัด 98, [`05_Acceptance Tests.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/05_Acceptance%20Tests.md) ข้อ 22)

**กรณี A1 (Stateless JWT):** อาจ Fail Open โดยไม่ตั้งใจ — Verify Signature สำเร็จโดยไม่ต้องแตะ DB แล้วอนุญาต Protected Request ต่อ  
➜ ความเสี่ยงนี้หายไปทันทีเมื่อใช้ Opaque Session เพราะ DB เป็น Gatekeeper เสมอ

---

## 5. เหตุผลเชิงสถาปัตยกรรมที่ Opaque Session เหมาะกว่า "เฉพาะ MyNetMate P1"

> [!IMPORTANT]
> เหตุผลทั้งหมดด้านล่างมีเงื่อนไขเฉพาะ Context ของ MyNetMate P1 — Single-service FastAPI Monolith, ผู้ใช้น้อย, ไม่มี External Service ที่ต้องรับ JWT

### 5.1 DB Query เป็น Unavoidable ในทุกกรณีที่รองรับ Immediate Revoke

เมื่อ Business Requirement กำหนดว่า "Admin deactivate → บล็อกทันที" ([`05_Acceptance Tests.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/05_Acceptance%20Tests.md) ข้อ 5) ทั้ง JWT และ Opaque Session ต้องทำ DB Query ทุก Protected Request เท่ากัน ประโยชน์หลักของ JWT ในระบบ Stateless (ไม่ต้อง Round-trip DB) จึงหายไปใน Context นี้

### 5.2 JWT เพิ่ม Complexity โดยไม่มี Return ใน P1

เมื่อ DB เป็น Source of Truth อยู่แล้ว JWT ยังเพิ่ม:
- Signing Key Management (Rotation, Storage, Environment Variable)
- Signature Verification Code Path (Library Dependency)
- `jti` มีสถานะอีก Layer (ต้อง Sync กับ `auth_sessions`)
- Role Claim ใน Token ที่ไม่ได้ใช้งาน (ต้องอ่าน DB อยู่ดี)

สิ่งเหล่านี้เพิ่มพื้นที่สำหรับ Bug โดยไม่ได้เพิ่ม Security หรือ Performance  
([`01_MVP - Authentication & RBAC.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/01_MVP%20-%20Authentication%20&%20RBAC.md) บรรทัด 18–20 อ้างถึงเหตุผลนี้ตรง ๆ)

### 5.3 Security Properties เทียบเท่าหรือดีกว่าใน Threat Model ของ MyNetMate

Cookie `HttpOnly` + `Secure` + `SameSite=Strict` + CSRF Double-Submit ป้องกัน XSS/CSRF ได้เทียบเท่า JWT ใน `HttpOnly` Cookie  
— แต่ Opaque Token ที่ไม่มี Semantic เพิ่มชั้นป้องกันในกรณี DB Dump: ผู้โจมตีเห็นแค่ Hash ไม่เห็น Token ดิบ  
(อ้างอิง: OWASP Session Management Cheat Sheet §Token Properties, §Sensitive Information Transmission)

### 5.4 Testing ง่ายกว่าสำหรับทีมนักศึกษา 4 คน

Test Fixture สำหรับ Opaque Session = `INSERT INTO auth_sessions (session_token_hash, user_id, expires_at)` 
Test Fixture สำหรับ JWT = Generate Token ด้วย Key + Setup Key loading + ตรวจ Claims + ตรวจ Signature

ในโปรเจกต์ที่มี Acceptance Test 22 ข้อ ([`05_Acceptance Tests.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/05_Acceptance%20Tests.md)) และข้อจำกัดด้านเวลาตาม AGENTS.md §3 ความง่ายของ Test Setup มีผลต่อ Velocity จริง

### 5.5 Audit Trail สอดคล้องกันโดยไม่ต้องแปลงข้อมูลพิเศษ

`auth_sessions.id` (UUID) ทำหน้าที่เป็น Session Reference ใน Audit Log ได้โดยตรง  
ไม่ต้องแมป `jti` → `auth_sessions.id` → `audit_logs.resource_id` เพิ่ม  
([`03_Component Diagram.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/03_Component%20Diagram.md) §4.1–4.3, [`11_Audit Trail(Naphat)/02_Data Ownership`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit%20Trail(Naphat)/02_Data%20Ownership%20and%20Event%20Catalog.md))

---

## 6. เงื่อนไขที่ JWT + `auth_sessions` จะคุ้มค่ากว่าในอนาคต

JWT จะเป็นตัวเลือกที่เหมาะสมกว่า **เมื่อทุกข้อต่อไปนี้เป็นจริงพร้อมกัน:**

| เงื่อนไข | คำอธิบาย |
|---|---|
| **ระบบมีหลาย Service** | P2 เพิ่ม Service ใหม่ (เช่น Network Discovery กลายเป็น Microservice) ที่ต้องการ Verify สิทธิ์โดยไม่โทรกลับ Auth Service |
| **Immediate Revoke ยอมรับ Delay ได้** | ยอมรับ Window เล็ก ๆ เช่น 5 นาที หรือมีระบบ Token Blocklist เพิ่มเติม |
| **DB Load เป็นปัญหาจริง** | จำนวน Request สูงมากจนต้อง Offload DB Query ออกจาก Auth Path |
| **Team มี Expertise** | สมาชิกมีประสบการณ์ JWT Security ครบ (Key Rotation, `alg` header attack, `none` alg attack) |
| **ไม่ต้อง Role อัปเดตทันที** | ยอมรับว่า Role เปลี่ยนมีผลหลัง Token หมดอายุ (ใช้ Short-lived Token + Refresh Token Pattern) |

> [!NOTE]
> ถ้า P2 เพิ่ม Service ลูก แนะนำให้พิจารณา **ออก Auth Token สั้น (เช่น 5 นาที) จาก Session** แทนการเปลี่ยนทั้งระบบ — ทำให้ได้ประโยชน์ JWT ในส่วน Service-to-Service โดยไม่ต้อง Refactor Auth Core ทั้งหมด

---

## 7. รายการเอกสารที่ต้อง Reconcile ก่อน Implement

### 7.1 ✅ Resolved — ปิดแล้ว (ไม่ต้อง Action เพิ่ม)

| ประเด็น | สถานะ | หลักฐาน |
|---|---|---|
| JWT vs Opaque Session | ✅ Resolved — ใช้ Opaque Session | [`02_Database Schema.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/02_Database%20Schema.md) บรรทัด 1–2, [`Data Information 27-06-69.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/Data%20Information%2027-06-69.md) บรรทัด 76 |
| `session_token_hash` Column | ✅ Reconciled — CHAR(64) SHA-256 lowercase hex | [`02_Database Schema.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/02_Database%20Schema.md) บรรทัด 44 |
| Cookie Name (Production) | ✅ กำหนดแล้ว — `__Host-mynetmate_session` | [`04_API Contracts.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/04_API%20Contracts.md) บรรทัด 18 |
| Audit DTO Field Mapping | ✅ Reconciled — `user_id` → `actor_user_id`, `created_at` → `occurred_at` | [`03_Component Diagram.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/03_Component%20Diagram.md) §4.3 |
| D&M ห้ามรับ `ip_address` / `safe_error_category` | ✅ กำหนดแล้ว | [`P1 ให้คนอ่าน.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/P1%20ให้คนอ่าน.md) บรรทัด 47–48 |

### 7.2 ⚠️ Open — ยังไม่มีความชัดเจน (ต้อง Resolve ก่อน Implement)

| ประเด็น | ความเสี่ยง | Action ที่ต้องทำ |
|---|---|---|
| **Owner ของ Auth Frontend** | ถ้าไม่มี Owner ชัดเจน Login Page, Route Guard และ Auth State Manager จะไม่มีใครรับผิดชอบ | ระบุ Owner และ Commit ก่อน Sprint 0 |
| **Owner ของ Alembic Migration** | `auth_sessions` Migration ต้อง Merge กับ `devices`, `audit_logs` — ถ้าไม่มี Owner กลางจะชนกัน | ระบุ Migration Owner และ Review Process |
| **Audit Writer ส่งมอบก่อน Auth Integration Test** | Auth Tests ข้อ 16 (Atomic Rollback) ต้อง Mock หรือรอ `record_audit_event()` จริง | ตกลง Interface Contract ล่วงหน้าหรือใช้ Stub ชั่วคราว |
| **API Prefix: `/api` vs `/api/v1`** | Auth Contract ใช้ `/api/auth/login` แต่ Backend Skeleton อาจกำหนด `api_v1_prefix` | เลือกค่าเดียวก่อนเริ่มเชื่อม Frontend — ดู [`P1 ให้คนอ่าน.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/P1%20ให้คนอ่าน.md) บรรทัด 74 |
| **Rate Limit Store** | In-memory (single instance OK สำหรับ Demo) vs Redis — ต้องชัดก่อนเพื่อกำหนด Dependency | กำหนดให้ชัดใน Sprint 0 |
| **Production Environment Values** | CORS Origin, Cookie Domain, Argon2id Parameters ยังไม่มีค่าจริงในเอกสาร | ต้องมีก่อนทำ Acceptance Test ข้อ 11 |
| **`user.deactivated` vs `user.updated` Audit** | [`06_Permission Catalog.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/06_Permission%20Catalog.md) และ [`04_API Contracts.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/04_API%20Contracts.md) บรรทัด 139 ระบุ "บันทึก `user.deactivated` หรือ `user.updated`" — ยังเปิดกว้างว่าส่ง Action ไหนเมื่อเปลี่ยน Role พร้อมกัน | ชี้แจงในเอกสาร Audit Catalog ว่า PATCH เดียวที่มีทั้ง Role และ `is_active` ส่ง Action อะไร |

### 7.3 📝 Documentation Conflict (ระบุตามกติกาข้อ 7)

ไม่พบ Conflict หลักระหว่าง JWT กับ Opaque Session แล้ว ณ วันที่วิเคราะห์ — เอกสาร canonical `00`–`07` สอดคล้องกันในประเด็นสถาปัตยกรรมหลักหลังการอัปเดต 2026-08-27  
ประเด็นเปิดที่เหลือ (ข้อ 7.2) เป็น **Undefined Gap** ไม่ใช่ Conflict ระหว่างเอกสาร

---

## อ้างอิงหลัก

| แหล่ง | บท/หัวข้อ |
|---|---|
| OWASP Session Management Cheat Sheet | §Token Properties, §Sensitive Information in Requests, §Binding the Session ID to Other User Properties |
| OWASP JWT Security Cheat Sheet | §None Algorithm Attack, §Key Confusion Attack |
| OWASP CSRF Prevention Cheat Sheet | §Custom Request Headers |
| RFC 6265bis | §4.1.3 The `__Host-` Prefix |
| [`01_MVP - Authentication & RBAC.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/01_MVP%20-%20Authentication%20&%20RBAC.md) | §1, §1.1 Architecture Decision |
| [`02_Database Schema.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/02_Database%20Schema.md) | §2 auth_sessions |
| [`04_API Contracts.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/04_API%20Contracts.md) | §1–2.7 |
| [`05_Acceptance Tests.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat)/05_Acceptance%20Tests.md) | ข้อ 5, 8, 16, 17, 22 |
| [`Data Information 27-06-69.md`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/Data%20Information%2027-06-69.md) | §Table 1.1: auth_sessions |
| [`11_Audit Trail/02_Data Ownership`](file:///e:/CEPP%20Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit%20Trail(Naphat)/02_Data%20Ownership%20and%20Event%20Catalog.md) | §1–4 |
