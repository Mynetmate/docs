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

## 2. API Endpoints

### 2.1 Login
- **URL:** `POST /api/auth/login`
- **Rate Limit:** อนุญาตให้พยายาม Login ล้มเหลวได้ 5 ครั้งต่อ **Client IP** ภายใน 15 นาที หากกระทำครั้งที่ 6 จะถูกปฏิเสธทันที (`429 AUTH_LOGIN_RATE_LIMITED`) ระบบจะนับ Identifier (Username/Email) ควบคู่ด้วยโดยแปลงเป็น HMAC ก่อนเก็บลง Cache เพื่อใช้ทำ Alert
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
  *(Backend จะอัปเดต Session ปัจจุบันเป็น `is_revoked=true` และตั้งค่า Header ลบ Cookie ด้วย `Max-Age=0` โดยใช้ Name, Path, Domain, Secure และ SameSite ให้ตรงกับตอนสร้าง)*
  *(หมายเหตุ: การสั่งลบ Cookie ของ Browser จำเป็นต้องระบุแอตทริบิวต์ Name, Path, Domain, Secure, SameSite ให้ตรงกับตอนที่สร้างทุกประการ ไม่เช่นนั้น Browser จะไม่ยอมลบ)*

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

## 3. Error Response Matrix

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

## 4. CORS & CSRF
- **CORS Allowed Origins:** ระบุ Exact URL (เช่น `https://mynetmate.app`) ห้ามใช้ `*`
- **CORS Credentials:** `Access-Control-Allow-Credentials: true`
- **Frontend Credential Mode:** React ต้องใช้ `credentials: "include"` กับทุก Request ที่ต้องใช้ Session
- **CSRF Check:** คำขอประเภท State-changing (`POST`, `PUT`, `PATCH`, `DELETE`) ต้องผ่านทุกเงื่อนไขต่อไปนี้:
  1. `Origin` ต้องตรงกับ Exact Allowlist; หากไม่มี `Origin` ให้ตรวจ Exact Origin จาก `Referer`; หากไม่มีทั้งคู่ให้ Reject
  2. ต้องมี Custom Header `X-CSRF-Protection: 1` เพื่อบังคับให้ Cross-origin JavaScript ผ่าน CORS Preflight
  3. Auth API ที่มี Request Body ต้องรับเฉพาะ `Content-Type: application/json` และห้ามมี State-changing `GET`
- **SameSite:** `SameSite=Strict` เป็น Defense in Depth เท่านั้น ไม่ใช้แทน Origin/Referer และ Custom-header Check
- **Production Topology:** แนะนำให้ Reverse Proxy React และ FastAPI อยู่ภายใต้ Site เดียวกัน แล้วใช้ `/api` เป็น Backend Path; Dev Origin ต้องระบุแบบ Exact รวม Scheme, Host และ Port
