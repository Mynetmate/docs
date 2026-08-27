# Component & Flow Diagram - Authentication

## 1. Login Flow

```mermaid
sequenceDiagram
    participant C as Client (Browser)
    participant A as Auth API
    participant DB as Database
    participant L as Audit Log

    C->>A: POST /api/auth/login (Identifier, Password)
    A->>A: Normalize (toLowerCase) Identifier
    A->>DB: Query User by Username or Email
    
    alt User Not Found OR is_active=false
        A->>L: record_auth_event('user.login_failed', 'auth', null, null)
        A-->>C: 401 AUTH_INVALID_CREDENTIALS
    else User Found
        A->>A: Verify Password (Argon2id)
        alt Password Incorrect
            A->>L: record_auth_event('user.login_failed', 'user', user_id, null)
            A-->>C: 401 AUTH_INVALID_CREDENTIALS
        else Password Correct
            A->>A: Generate opaque token (CSPRNG 32 bytes)
            A->>A: SHA-256(token)
            A->>DB: Insert token hash + user_id + expires_at into auth_sessions
            A->>L: record_auth_event('user.login_success', 'auth', null, user_id)
            A-->>C: 200 OK + Set-Cookie (opaque token, HttpOnly)
        end
    end
```

> Token ดิบมีอยู่เฉพาะใน Memory ชั่วคราวระหว่างสร้าง Response และใน Cookie ของ Browser เท่านั้น ห้ามเก็บลง Database, Response JSON หรือ Log

## 2. Protected Request & RBAC Flow

```mermaid
sequenceDiagram
    participant C as Client (Browser)
    participant G as Auth Guard
    participant DB as Database
    participant P as Permission Guard
    participant API as Feature API

    C->>G: Request (Session Cookie if authenticated)
    opt POST / PUT / PATCH / DELETE
        C->>G: Origin + X-CSRF-Protection: 1
        G->>G: Validate exact Origin, custom header, Content-Type
    end
    alt Session Cookie Missing
        G-->>C: 401 AUTH_SESSION_MISSING
    else Session Cookie Present
        G->>G: Validate token format + SHA-256(token)
        G->>DB: Query auth_sessions JOIN users by session_token_hash
        alt Unknown / Revoked / Expired / User Inactive
            G-->>C: 401 AUTH_SESSION_INVALID
        else Active Session
            DB-->>G: user_id + current role + is_active
            G->>P: require_permission(current_role, permission_key)
            alt Permission Denied
                P-->>C: 403 AUTH_FORBIDDEN
            else Permission Granted
                P->>API: Continue Request
                API-->>C: Feature Response
            end
        end
    end
```

Backend ต้องอ่าน Role ปัจจุบันจาก `users` ทุก Request ห้ามเก็บหรือเชื่อ Role จาก Cookie และต้อง Fail Closed หาก Database ใช้งานไม่ได้

## 3. Self-Change Password Flow
เมื่อผู้ใช้ต้องการเปลี่ยนรหัสผ่านของตนเอง

```mermaid
sequenceDiagram
    participant C as Client
    participant A as Auth API
    participant DB as Database
    participant L as Audit Log

    C->>A: POST /api/auth/change-password (current_password, new_password)
    A->>DB: Verify current_password
    alt Valid
        A->>DB: Update password_hash (Argon2id)
        A->>DB: UPDATE auth_sessions SET is_revoked = true WHERE user_id = {id}
        A->>L: record_auth_event('user.password_changed', 'user', user_id, user_id)
        A-->>C: 204 No Content (Clear Cookie / Force Re-login)
    else Invalid
        A-->>C: 400 AUTH_CURRENT_PASSWORD_INVALID
    end
```

## 4. Audit Trail Contract (Reconciled DTO)
ส่วน Authentication จะสร้างข้อมูลส่งให้ระบบ Audit ผ่าน Auth-only wrapper function `record_auth_event()`:

### 4.1 Caller Function Signature (Auth Layer)
Caller (เช่น Login Flow) จะเรียกใช้ด้วย 4 Arguments พื้นฐาน:
```
record_auth_event(
    action:         str,        -- Canonical Action Name (ดูตาราง 4.2)
    resource_type:  str,        -- เช่น 'auth', 'user'
    resource_id:    UUID|null,  -- ID ของเป้าหมาย (nullable)
    actor_id:       UUID|null   -- ID ของผู้กระทำที่ยืนยันตัวตนแล้ว (nullable)
)
```

**กฎเรื่อง `actor_id`:** ต้องเป็น ID ของผู้ใช้ที่ **ยืนยันตัวตนสำเร็จแล้ว** เท่านั้น
- Login สำเร็จ → `actor_id = user_id` ของผู้ Login
- Login ล้มเหลว (password ผิด) → `actor_id = null` (ยังไม่รู้ว่าใครคือผู้กระทำจริง) แต่ใช้ `resource_type='user'` + `resource_id=target_user_id` เพื่อชี้ไปที่บัญชีเป้าหมาย
- Login ล้มเหลว (ไม่พบบัญชี) → `actor_id = null`, `resource_id = null`
- Admin ระงับบัญชี → `actor_id = admin_id`, `resource_id = target_user_id`

### 4.2 Canonical Mapping & DTO Translation

ฟังก์ชัน `record_auth_event()` ทำหน้าที่เป็น Registry Map มันจะดึงค่า `result`, `safe_error_category` และ `created_at` (now()) อัตโนมัติจากตารางด้านล่าง หากมีการส่ง Action ที่ไม่อยู่ในตารางนี้เข้ามา ฟังก์ชันต้อง **Reject (โยน Exception) ทันที** (ช่วยป้องกันการส่ง Action ของระบบอื่นเช่น `device` ผิดเข้ามา)

| Action | `resource_type` | `result` | `safe_error_category` |
| :--- | :--- | :--- | :--- |
| `user.login_success` | `auth` | `success` | `null` |
| `user.login_failed` | `user` / `auth` | `failure` | `'authentication_error'` |
| `user.logout` | `auth` | `success` | `null` |
| `user.password_changed` | `user` | `success` | `null` |
| `user.created` | `user` | `success` | `null` |
| `user.updated` | `user` | `success` | `null` |
| `user.deactivated` | `user` | `success` | `null` |
| `auth.permission_denied`| `auth` | `failure` | `'authorization_error'` |

*(หมายเหตุ: ค่า Enum ของ `safe_error_category` สำหรับฝั่ง Auth ที่เปิดให้ใช้งานใน P1 คือ `authentication_error`, `authorization_error`, และ `null` เท่านั้น ส่วน `validation_error` และ `server_error` ถือเป็น Reserved ไว้ก่อน ยังไม่อนุญาตให้ใช้งานจนกว่าจะมีการเพิ่ม Registry Entry ใหม่)*

### 4.3 Data Storage & Consumer API Mapping

เพื่อยุติปัญหาการใช้ชื่อ Field ไม่ตรงกันระหว่าง Database, Auth API และ D&M Contract ระบบกำหนดกฎการ Mapping ดังนี้:

| Auth Function Caller | Central DB Storage (`audit_logs`) | Full Audit API DTO (Admin Only) |
| :--- | :--- | :--- |
| `actor_id` | `user_id` | `actor_user_id` |
| (computed now) | `created_at` | `occurred_at` |
| (mapped) | `result` | `result` |
| (mapped) | `safe_error_category` | `safe_error_category` |

> [!NOTE]
> **สถานะสัญญา (Approved & Reconciled):**
> 1. **D&M Projection (Recent Activity):** D&M จะดึงข้อมูลไปแสดงเฉพาะ `action`, ชื่อผู้กระทำ (`actor display name` หรือ `Unknown`), เป้าหมาย (`resource display`), และ `timestamp` **โดยห้ามส่ง `safe_error_category`, `description`, และ `ip_address` ไปให้ D&M เด็ดขาด** ตามข้อกำหนดเรื่อง Data Privacy
> 2. **Central Schema:** ตาราง `audit_logs` กลางได้รับการอัปเดตเพื่อเพิ่มคอลัมน์ `result` และ `safe_error_category` เรียบร้อยแล้ว รองรับการจัดเก็บค่าที่ `record_auth_event()` คำนวณไว้ได้อย่างสมบูรณ์
