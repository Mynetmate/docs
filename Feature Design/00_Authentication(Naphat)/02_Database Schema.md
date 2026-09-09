> [!IMPORTANT]
> **APPROVED & RECONCILED SCHEMA (อัปเดต 2026-08-27):** Authentication และ Central Schema (`../Data Information 27-06-69.md`) ใช้ Database-backed Opaque Server-side Session ตรงกันแล้ว โดย `auth_sessions` ต้องมี `session_token_hash` และห้ามใช้ Internal UUID เป็น Cookie Token

# Authentication Database Schema

เอกสารนี้ระบุโครงสร้างฐานข้อมูลเฉพาะส่วนที่เกี่ยวข้องกับ Authentication & RBAC

## 1. Table: `users`
เก็บข้อมูลผู้ใช้งานระบบ (แก้ไขให้ตรงกับ Central Schema ในส่วนของ UUID และ Email Optional)

```sql
-- ต้องเปิด Extension นี้ก่อนเพื่อใช้ gen_random_uuid()
-- Alembic migration ต้องรัน CREATE EXTENSION ก่อน CREATE TABLE
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL 
        CHECK (username = lower(username)) 
        CHECK (username ~ '^[a-z0-9._-]{3,100}$'),
    email VARCHAR(255) UNIQUE 
        CHECK (email = lower(email)),
    password_hash VARCHAR(255) NOT NULL, -- ต้องเข้ารหัสด้วย Argon2id เสมอ
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'operator', 'viewer')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
**Database Guards & Validations:**
- `id` ใช้ `UUID` เพื่อให้สอดคล้องกับตาราง `devices` และ `audit_logs` ใน Central Schema
- `updated_at` ควบคุมโดย Application Layer (Backend กำหนดเวลาใหม่ทุกครั้งที่มีการแก้ไข) ไม่ต้องใช้ Database Trigger เพื่อความเรียบง่าย
- `email` เป็น Optional (ไม่บังคับ) ตามที่ระบุไว้ใน Central Schema
- `username` ถูกจำกัดความปลอดภัยระดับ Database ด้วย `CHECK (username ~ '^[a-z0-9._-]{3,100}$')` (ไม่อนุญาตให้มี `@` ป้องกันการสับสนกับ Email)
- `last_login_at` ถูก **ตัดออก** เนื่องจากสามารถ Query จาก `auth_sessions.created_at` ได้โดยตรง
- `must_change_password` ถูก **ตัดออก** ในระยะ P1 เนื่องจากไม่มีฟีเจอร์ Admin Reset Password

## 2. Table: `auth_sessions` (Central Schema หมายเลข 1.1; หนึ่งใน 12 ตารางของระบบ)
ตารางนี้เป็น Source of Truth ของ Server-side Session ใน P1 รองรับการตรวจ Session, Logout, Expiry, Revoke และการบังคับใช้การเปลี่ยนสิทธิ์ทันที

```sql
CREATE TABLE auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_token_hash CHAR(64) UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    CHECK (expires_at > created_at)
);

-- Index สำหรับ Performance ในการค้นหา Session
CREATE INDEX idx_auth_sessions_user_id ON auth_sessions(user_id);
CREATE INDEX idx_auth_sessions_expires_at ON auth_sessions(expires_at);
CREATE INDEX idx_auth_sessions_active_user
    ON auth_sessions(user_id, expires_at)
    WHERE is_revoked = FALSE;
```

**Session Token Storage Rules:**

- `id` เป็น Internal UUID สำหรับ Foreign Key/Audit เท่านั้น **ห้ามนำไปใส่ Cookie หรือใช้เป็น Bearer Secret**
- หลัง Login ให้ Backend สร้าง Opaque Token ด้วย CSPRNG ขนาด 32 bytes (256 bits) แล้ว Encode แบบ URL-safe
- Cookie เก็บ Token ดิบเพียงที่ Browser ส่วน Database เก็บเฉพาะ `SHA-256(token)` แบบ Lowercase Hex จำนวน 64 ตัวอักษรใน `session_token_hash`
- ห้ามบันทึก Token ดิบ, Cookie Header หรือ Token Hash ลง Application Log/Audit Log และห้ามส่ง Token ใน Response JSON
- `expires_at` ใน Database เป็นแหล่งตัดสินวันหมดอายุหลัก แม้ Browser ยังส่ง Cookie เก่ามา Backend ต้องตอบ `401 AUTH_SESSION_INVALID`
- `ip_address` และ `user_agent` ใช้วิเคราะห์ Session ภายใน Auth เท่านั้น ห้ามใช้ผูก Session แบบตายตัวและห้ามคัดลอกเข้า `record_auth_event()`/`audit_logs` เพราะค่าอาจเปลี่ยนจาก DHCP, Proxy หรือ Browser Update และ `audit_logs` P1 ไม่เก็บ Client IP
- Job Cleanup สามารถลบ Session ที่หมดอายุหรือถูก Revoke แล้วตาม Retention Policy ได้ แต่การตรวจสิทธิ์ห้ามพึ่งพาว่า Cleanup รันสำเร็จ
