# API Contracts - Authentication

เอกสารนี้ระบุสเปคของ API เพื่อให้ทีม Frontend และ Backend สามารถทำงานร่วมกันได้ทันที

## 1. Server-side Session & Cookie Specification

### 1.1 Opaque Session Token

- หลังตรวจ Password สำเร็จ Backend ต้องสร้าง Token ใหม่ด้วย CSPRNG ขนาด 32 bytes (256 bits) และ Encode แบบ URL-safe
- Token ต้องเป็น Opaque Value ที่ไม่มี `user_id`, Role, Email หรือข้อมูลธุรกิจอยู่ภายใน
- `auth_sessions.id` เป็น Internal UUID เท่านั้น ห้ามใช้เป็น Cookie Value
- Database เก็บเฉพาะ `SHA-256(token)` ใน `auth_sessions.session_token_hash` และค้นหาด้วยคอลัมน์นี้
- Token ดิบห้ามปรากฏใน Response JSON, URL, Application/Audit Log, `localStorage` หรือ `sessionStorage`
- Session มี Absolute Lifetime 30 นาทีแบบ Non-sliding สำหรับ P1 ไม่มี Refresh Token และ Request ปกติห้ามต่ออายุ `expires_at`

### 1.2 Session Cookie

- **Production Name:** `__Host-mynetmate_session`
- **Development/Test Name:** `mynetmate_session` อนุญาตเฉพาะเมื่อ `APP_ENV` เป็น `development` หรือ `test`
- **Path:** `/`
- **Domain:** ไม่กำหนด
- **HttpOnly:** `true`
- **Secure:** `true` ใน Production; Production ต้อง Fail Closed หาก Config เป็น `false`
- **SameSite:** `Strict`
- **Max-Age / Expires:** ไม่กำหนด เพื่อให้เป็น Browser-session Cookie; `auth_sessions.expires_at` เป็น Source of Truth สำหรับอายุ 30 นาที

ทุก Auth Response ต้องส่ง `Cache-Control: no-store` และ Frontend ต้องเรียก API ด้วย `credentials: "include"` ห้ามให้ JavaScript อ่านหรือจัดการ Session Token โดยตรง

> [!IMPORTANT]
> ห้ามใช้ Starlette/FastAPI `SessionMiddleware` เป็นตัวแทนของสัญญานี้ เพราะ Middleware ดังกล่าวเก็บ Session State ใน Signed Cookie ฝั่ง Client ขณะที่ MyNetMate กำหนดให้ State อยู่ใน Database และ Cookie มีเพียง Opaque Token

### 1.3 Password Hashing & Verification

- ใช้ `Argon2id` Baseline `memory_cost=19456 KiB`, `time_cost=2`, `parallelism=1` กับ Login, Create User, Self-change Password และ Seed User ผ่าน Password Hasher กลางชุดเดียวกัน
- Library ต้องสร้าง Random Salt ใหม่อัตโนมัติทุกครั้งและเก็บผลเป็น PHC String ใน `users.password_hash`; Password เดียวกันที่ Hash สองครั้งต้องได้คนละ String
- Application ต้องสร้าง Dummy Argon2id Hash หนึ่งครั้งตอน Startup ด้วย Hasher ชุดเดียวกัน เมื่อไม่พบบัญชีให้ Verify รหัสผ่านที่รับมากับ Dummy Hash แล้วทิ้งผลก่อนตอบ Generic `401`
- เมื่อพบบัญชีแต่ `is_active=false` ให้ Verify กับ Hash จริงแล้วทิ้งผลก่อนตอบ Generic `401` เพื่อลดความแตกต่างด้านเวลา
- ต้องทำ Manual Benchmark บนเครื่อง/Container ที่ใช้ Demo โดยตั้งเป้าให้การ Verify หนึ่งครั้งต่ำกว่าประมาณ 1 วินาที ห้ามใช้ Timing Test ที่เปราะบางเป็น CI Gate
- ตรวจ Rate Limit ก่อน User Query และ Argon2id Verification เพื่อลดความเสี่ยง Resource Exhaustion

## 2. API Endpoints

### 2.1 Login
- **URL:** `POST /api/auth/login`
- **Rate Limit Enforcement:** ใช้ Sliding Window 15 นาที อนุญาต Login ล้มเหลว 5 ครั้งต่อ **Client IP** และปฏิเสธ Request ครั้งที่ 6 ก่อน User Query/Argon2id ด้วย `429 AUTH_LOGIN_RATE_LIMITED`
- **P1 Storage:** ใช้ Bounded In-memory TTL Store ค่าเริ่มต้นสูงสุด 10,000 Keys ใน FastAPI Process เดียว การ Restart ทำให้ Counter หายเป็นข้อจำกัดที่ยอมรับใน P1; หากใช้หลาย Worker/Instance ต้องเปลี่ยนเป็น Shared Store และทบทวน Contract ก่อน
- **Identifier Privacy:** Normalize Username/Email แล้ว HMAC ด้วย Environment Secret `AUTH_RATE_LIMIT_HMAC_KEY` ก่อนเก็บ Counter ชั่วคราว ห้ามเก็บ Raw Identifier; Counter นี้ใช้สำหรับ Security Telemetry/Test เท่านั้นและไม่ทำ Account Lockout ใน P1
- **Client IP Source:** ค่าเริ่มต้นใช้ Peer IP จาก Connection หากอยู่หลัง Reverse Proxy ให้ใช้ Proxy Header Processing ของ Server เฉพาะเมื่อกำหนด Trusted Proxy IP Allowlist แล้ว ห้ามตั้ง Trust เป็น Wildcard หรือเชื่อ `X-Forwarded-For` จาก Client โดยตรง
- **Request Body:**
  ```json
  {
    "identifier": "admin",
    "password": "Password123!"
  }
  ```
  *(Validation: `identifier` ต้องยาว 3-255 ตัวอักษร, ถ้าไม่มี `@` จะถือว่าเป็น Username ซึ่งต้องผ่าน Regex `^[a-z0-9._-]{3,100}$` / Backend จะจับ toLowerCase() ก่อนเสมอ)*
- **Response Success (200 OK):**
  ```json
  {
    "message": "Login successful"
  }
  ```
  *(Header จะแนบ `Set-Cookie` ตามข้อ 1.2 โดยไม่มี Token ใน JSON Body และต้องสร้าง Token ใหม่ทุกครั้งหลัง Login สำเร็จเพื่อป้องกัน Session Fixation)*
- **Response Error:**
  - `401 AUTH_INVALID_CREDENTIALS` — Username/Email หรือ Password ผิด (ไม่ระบุว่าอันไหน)
  - `429 AUTH_LOGIN_RATE_LIMITED` — เกิน Rate Limit

### 2.2 Get Current User (Me)
- **URL:** `GET /api/auth/me`
- **Request:** (แนบ Cookie อัตโนมัติ)
- **Response Success (200 OK):**
  ```json
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "username": "demo_admin",
    "email": "admin@kmitl.ac.th",
    "role": "admin",
    "is_active": true
  }
  ```
  *(หมายเหตุ: `email` อาจเป็น `null` หากผู้ใช้ไม่ได้ระบุ)*

### 2.3 Logout
- **URL:** `POST /api/auth/logout`
- **Response Success (204 No Content):** (ไม่มี Body)
  *(Backend จะอัปเดต Session ปัจจุบันเป็น `is_revoked=true` และบันทึก `user.logout` ใน Database Transaction เดียวกัน จากนั้นจึงส่ง `Set-Cookie` เพื่อลบ Cookie ด้วย `Max-Age=0` โดยใช้ชื่อเดิม, `Path=/` และไม่กำหนด `Domain` ให้ตรงกับ Cookie เดิม หาก Mandatory Audit Write ล้มเหลวต้อง Rollback Session Revoke และตอบ `503 AUTH_SERVICE_UNAVAILABLE`)*
  *(หมายเหตุ: Cookie ถูกระบุตัวหลักด้วย Name + Domain + Path; Production ต้องใส่ `Secure` เพื่อให้ Cookie ชื่อ `__Host-mynetmate_session` ผ่านข้อกำหนดของ Prefix และควรใช้ `HttpOnly`/`SameSite` ตาม Policy เดิมอย่างสม่ำเสมอ)*

### 2.4 Self-Change Password
- **URL:** `POST /api/auth/change-password`
- **Request Body:**
  ```json
  {
    "current_password": "OldPassword123!",
    "new_password": "NewPassword456!"
  }
  ```
  *(Validation: `new_password` ต้องยาว 12-128 ตัวอักษร)*
- **Response Success (204 No Content):** (ไม่มี Body)
  *(Backend จะ Revoke Session ทั้งหมดของผู้ใช้นี้ทิ้งทันที และลบ Cookie เพื่อบังคับให้ผู้ใช้ล็อกอินใหม่ โดยการ Update Password Hash, Revoke Sessions, และบันทึก Audit Log ต้องเกิดขึ้นภายใน Database Transaction เดียวกันแบบ Atomic)*
- **Response Error:**
  - `400 AUTH_CURRENT_PASSWORD_INVALID` — รหัสผ่านปัจจุบันไม่ถูกต้อง

### 2.5 Authentication & Authorization Guard (Backend)
- อ่าน Session Token จาก Cookie ที่กำหนดไว้เท่านั้น ห้ามรับจาก URL, Request Body หรือ `Authorization: Bearer`
- ตรวจรูปแบบและความยาว Token ก่อน Hash เพื่อป้องกัน Input ที่ผิดปกติ
- คำนวณ `SHA-256(token)` แล้ว Query `auth_sessions JOIN users` ด้วย `session_token_hash`
- Session ต้องตรงครบทุก Predicate: พบแถว, `is_revoked=false`, `expires_at > now()` และ `users.is_active=true`
- อ่าน Role ปัจจุบันจาก `users` แล้วเรียก `require_permission()` ด้วย Permission Catalog แบบ Default Deny ห้ามเก็บหรือเชื่อ Role จาก Cookie
- หาก Database หรือ Session Store ใช้งานไม่ได้ ต้อง Fail Closed และไม่อนุญาต Protected Request
- เมื่อ Session Token ไม่รู้จัก, หมดอายุ, ถูก Revoke หรือผูกกับ User ที่ Inactive ให้ตอบ `401 AUTH_SESSION_INVALID` พร้อม `Set-Cookie` เพื่อลบ Session Cookie ด้วย Policy เดียวกับ Logout เพราะ JavaScript ไม่สามารถลบ `HttpOnly` Cookie เองได้
- Frontend Route Guard และการซ่อนปุ่มเป็นเพียง UX; Backend Guard เป็น Security Boundary จริง

### 2.6 Admin User Management
- **Authorization:** ต้องมี Permission `user.manage` (เฉพาะ Admin)
- **GET `/api/admin/users` (List Users):**
  - **Query Params:** `?page=1&limit=50&status=active` (Optional)
  - **Response (200 OK):**
    ```json
    {
      "data": [
        { "id": "uuid", "username": "operator_1", "email": null, "role": "operator", "is_active": true }
      ],
      "meta": { "total": 1, "page": 1, "limit": 50 }
    }
    ```
- **POST `/api/admin/users` (Create User):**
  - **Request Body:**
    ```json
    {
      "username": "new_op",
      "email": "new_op@kmitl.ac.th",
      "password": "InitialPassword123!",
      "role": "operator"
    }
    ```
    *(Validation: Username format, `email` เป็น Optional (ส่งได้หรือไม่ส่งก็ได้), `password` ต้องยาว 12-128 ตัวอักษร, `role` ∈ [admin, operator, viewer])*
  - **Response (201 Created):** คืนค่า User Object ที่เพิ่งสร้าง (ไม่มี Password)
  - *(Side Effect: ต้องบันทึก Audit Log `user.created` โดย `actor_id` = Admin, `resource_id` = User ใหม่)*
- **PATCH `/api/admin/users/{user_id}` (Update User):**
  - **Request Body:**
    ```json
    {
      "role": "viewer",
      "is_active": false
    }
    ```
  - **Side Effects (ต้องทำแบบ Atomic ภายใน Transaction เดียวกัน):**
    - หากตั้ง `is_active` เป็น `false` → Backend ต้อง **Revoke ทุก Session ของผู้ใช้เป้าหมาย** ทันที เพื่อไม่ให้มี Session ค้าง
    - หาก Reactivate (`is_active` เปลี่ยนจาก `false` เป็น `true`) → **ห้ามคืน Session เก่า** ผู้ใช้ต้องล็อกอินใหม่เท่านั้น
    - หากเปลี่ยน Role → Backend ต้อง **Revoke ทุก Session ของผู้ใช้เป้าหมาย** เพื่อบังคับให้ยืนยันตัวตนใหม่ก่อนรับสิทธิ์ชุดใหม่
    - ระบบจะต้องบันทึก Audit Log `user.deactivated` หรือ `user.updated` เสมอ
  - **Response (200 OK):** คืนค่า User Object ที่อัปเดตแล้ว

### 2.7 Audit Logs API
- **Authorization:** ต้องมี Permission `audit.read` (เฉพาะ Admin เท่านั้น Operator/Viewer ต้องไปใช้ API หมวด Dashboard แยกต่างหากเพื่อดูสรุป Activity)
- **GET `/api/audit-logs`:**
  - *หมายเหตุ: API เส้นนี้มี Feature Audit Trail เป็นเจ้าของ (Source of Truth) กรุณาอ้างอิง Request/Response DTO และระบบ Cursor Pagination แบบเต็มจากเอกสาร `02_feature/11_Audit Trail(Naphat)/04_API Contracts.md` เพื่อป้องกันความขัดแย้งของเอกสาร*

## 3. Error Response Contract

### 3.1 Standard Envelope

Auth Error ทุกตัวต้องตอบ JSON รูปแบบเดียวกัน:

```json
{
  "error": {
    "code": "AUTH_SESSION_INVALID",
    "message": "Your session is invalid or has expired."
  }
}
```

- `error.code` เป็น Stable Machine-readable Contract ที่ Frontend ใช้ตัดสินพฤติกรรม ห้าม Parse `message`
- `error.message` ต้องเป็นข้อความ Generic ที่ปลอดภัย ห้ามมี Stack Trace, SQL/Driver Error, Raw Request Input, Password, Token, Cookie หรือ Secret
- P1 ใช้เฉพาะ `code` และ `message`; ยังไม่เพิ่ม Field-level Error Array หรือระบบแปลข้อความหลายภาษาใน Backend
- Response `204 No Content` ต้องไม่มี Body และ Error ที่เกิดจาก Database/Session/Audit Store ใช้งานไม่ได้ต้อง Fail Closed ด้วย `503 AUTH_SERVICE_UNAVAILABLE`

### 3.2 Error Matrix

| สถานการณ์ | HTTP Status | Error Code |
| :--- | :--- | :--- |
| Login ผิด (ไม่ระบุว่าอันไหน) | `401` | `AUTH_INVALID_CREDENTIALS` |
| Session Token ไม่รู้จัก, รูปแบบผิด, หมดอายุ หรือถูก Revoke | `401` | `AUTH_SESSION_INVALID` |
| ไม่มี Session Cookie แนบมา | `401` | `AUTH_SESSION_MISSING` |
| ไม่มีสิทธิ์ (Role ไม่พอ) | `403` | `AUTH_FORBIDDEN` |
| Origin ไม่อยู่ใน Allowlist | `403` | `AUTH_ORIGIN_REJECTED` |
| ขาดหรือส่ง CSRF Protection Header ผิด | `403` | `AUTH_CSRF_REJECTED` |
| Current password ผิด (เปลี่ยนรหัส) | `400` | `AUTH_CURRENT_PASSWORD_INVALID` |
| Rate Limit (Login ครั้งที่ 6+) | `429` | `AUTH_LOGIN_RATE_LIMITED` |
| สร้างบัญชีแต่ Username/Email ซ้ำ | `409` | `AUTH_USER_ALREADY_EXISTS` |
| อ้างอิง User ID ที่ไม่มีอยู่จริง | `404` | `AUTH_USER_NOT_FOUND` |
| Demote/Deactivate Admin คนสุดท้าย | `409` | `AUTH_LAST_ADMIN_PROTECTED` (ต้องใช้ DB Lock เช่น `SELECT ... FOR UPDATE` หรือ Serializable Transaction เพื่อกัน Race Condition) |
| Request Body/Field ไม่ผ่าน Validation | `422` | `AUTH_REQUEST_INVALID` |
| Database, Session Store หรือ Mandatory Audit Write ใช้งานไม่ได้ | `503` | `AUTH_SERVICE_UNAVAILABLE` |

## 4. CORS & CSRF
- **Origin Definition:** Origin ประกอบด้วย Scheme + Host + Port เช่น `http://localhost:5173`; ค่าที่ Port ต่างกันถือเป็นคนละ Origin
- **CORS Allowed Origins:** ระบุ Exact URL จาก Environment Configuration (เช่น Production Frontend Origin ที่ทีมกำหนด) ห้ามใช้ `*`
- **CORS Credentials:** `Access-Control-Allow-Credentials: true`
- **CORS Methods/Headers:** กำหนด Method Allowlist แบบชัดเจนอย่างน้อย `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS` และ Header Allowlist อย่างน้อย `Content-Type`, `X-CSRF-Protection`; ห้ามใช้ Wildcard กับ CORS Configuration ที่อนุญาต Credentials
- **Frontend Credential Mode:** React ต้องใช้ `credentials: "include"` กับทุก Request ที่ต้องใช้ Session
- **Central CSRF Guard:** คำขอประเภท State-changing (`POST`, `PUT`, `PATCH`, `DELETE`) ทุกเส้นต้องผ่าน Guard กลางก่อนทำ Business Action รวมถึง Public Endpoint เช่น `POST /api/auth/login` โดยมีเงื่อนไขดังนี้:
  1. `Origin` ต้องตรงกับ Exact Allowlist; หากไม่มี `Origin` ให้ Parse Scheme + Host + Port จาก `Referer` แล้วเปรียบเทียบกับ Allowlist; หากไม่ตรงหรือไม่มีทั้งคู่ให้ตอบ `403 AUTH_ORIGIN_REJECTED`
  2. ต้องมี Custom Header `X-CSRF-Protection: 1`; หากไม่มีหรือค่าผิดให้ตอบ `403 AUTH_CSRF_REJECTED`
  3. Endpoint ที่มี Request Body ต้องรับเฉพาะ `Content-Type: application/json` ส่วน Endpoint ที่ไม่มี Body เช่น `POST /api/auth/logout` ห้ามบังคับว่าต้องมี `Content-Type`
  4. ห้ามมี State-changing `GET`; `GET` และ `HEAD` ต้องไม่มี Side Effect ส่วน `OPTIONS` ให้ CORS Middleware จัดการเป็น Preflight และไม่ต้องผ่าน Session/CSRF Validation ของ Route
- **Custom Header Purpose:** `X-CSRF-Protection: 1` ไม่ใช่ Secret หรือ CSRF Token แต่ใช้บังคับให้ Cross-origin JavaScript ผ่าน CORS Preflight จึงต้องตรวจร่วมกับ Exact Origin/Referer เสมอ
- **Guard Order:** State-changing Request ต้องผ่าน CORS/CSRF Guard ก่อน จากนั้น Protected Endpoint จึงผ่าน Session Guard และ Permission Guard ก่อนถึง Handler; Public Endpoint ข้ามเฉพาะ Session/Permission Guard
- **CORS Boundary:** CORS เป็นนโยบายของ Browser และไม่ใช่ Authorization หรือ CSRF Protection ที่เพียงพอด้วยตัวเอง Backend ยังต้องบังคับ Origin/Referer และ Custom Header
- **SameSite:** `SameSite=Strict` เป็น Defense in Depth เท่านั้น ไม่ใช้แทน Origin/Referer และ Custom-header Check
- **Production Topology:** แนะนำให้ Reverse Proxy React และ FastAPI อยู่ภายใต้ Site เดียวกัน แล้วใช้ `/api` เป็น Backend Path; Dev Origin ต้องระบุแบบ Exact รวม Scheme, Host และ Port
- **P1 Library Decision:** ไม่เพิ่ม Third-party CSRF Library เพราะ Contract นี้ไม่ใช้ Synchronizer Token หรือ Double-submit Cookie; ใช้ `CORSMiddleware` และ CSRF Guard กลางที่มี Test ครบ หาก Deployment หรือ Request Model เปลี่ยนต้องทำ Security Review ใหม่

## 5. Frontend Authentication State Contract

- Frontend ต้องเรียก API ที่ใช้ Session ด้วย `credentials: "include"` และเก็บเฉพาะ Current User Summary ใน Zustand ห้ามเก็บ Session Token
- `AUTH_INVALID_CREDENTIALS` บนหน้า Login: อยู่หน้าเดิมและแสดงข้อความ Generic
- `AUTH_SESSION_MISSING` จาก Protected API: ล้าง Auth State/User-scoped Query Cache แล้วไปหน้า Login โดยไม่แสดงข้อความ Session Expired
- `AUTH_SESSION_INVALID` จาก Protected API: ล้าง Auth State/User-scoped Query Cache แล้วไปหน้า Login พร้อมข้อความ “Session หมดอายุหรือถูกยกเลิก กรุณาเข้าสู่ระบบอีกครั้ง”
- `AUTH_FORBIDDEN`: ห้าม Logout ให้คง Session เดิมและแสดง Access Denied หรือกลับไปหน้าที่ผู้ใช้มีสิทธิ์
- `AUTH_ORIGIN_REJECTED` และ `AUTH_CSRF_REJECTED`: ห้าม Logout และห้าม Retry State-changing Request อัตโนมัติ ให้แสดง Generic Security Error
- `AUTH_LOGIN_RATE_LIMITED`: อยู่หน้า Login และแจ้งให้รอก่อนลองใหม่
- Global Error Handler ต้องทำงานแบบ Idempotent เพื่อไม่ให้ Concurrent `401` หลาย Request Redirect หรือแสดงข้อความซ้ำหลายครั้ง
- TanStack Query/Mutation และ API Client ต้องไม่ Retry `401`, `403` หรือ `429` อัตโนมัติ เพื่อป้องกัน Redirect Loop, Audit Noise และการยืดเวลาของ Rate Limit
- Frontend Route Guard/การซ่อนเมนูเป็นเพียง UX Backend Permission Guard ยังคงเป็น Security Boundary

## 6. XSS & Frontend Rendering Contract

- P1 ไม่รับหรือ Render User-supplied HTML, Rich Text หรือ Markdown ดิบ
- ข้อมูลจากผู้ใช้, Database หรือ API ต้องแสดงเป็นข้อความด้วย React JSX ตามปกติเพื่อใช้การ Escape ของ Framework
- ห้ามนำข้อมูลที่ไม่น่าเชื่อถือไปใช้กับ `dangerouslySetInnerHTML`, `innerHTML`, `outerHTML`, `insertAdjacentHTML` หรือ `document.write`
- หาก Feature ในอนาคตจำเป็นต้อง Render HTML หรือ Markdown ต้องผ่าน Security Review และใช้ Sanitization Library ที่เหมาะสมก่อน Render
- `HttpOnly` ป้องกัน JavaScript อ่าน Session Token โดยตรง แต่ไม่หยุด XSS Execution หรือ Same-origin Script จากการเรียก API ด้วย Session ของเหยื่อ ดังนั้น Backend RBAC และ CSRF ไม่ใช่สิ่งทดแทน Safe Rendering
- Content Security Policy (CSP) เป็น Future Hardening ไม่ใช่ P1 Acceptance Requirement และห้ามใช้แทน Output Encoding/Sanitization
