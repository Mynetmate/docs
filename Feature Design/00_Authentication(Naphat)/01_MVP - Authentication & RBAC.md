# MVP Scope - Authentication & RBAC

เอกสารนี้กำหนดขอบเขต (Scope) การทำงานขั้นต่ำ (MVP) ของฟีเจอร์ Authentication และการควบคุมสิทธิ์ (RBAC) สำหรับ MyNetMate (Phase 1)

## 1. Core Architecture
- **Authentication:** ใช้ **Database-backed Opaque Server-side Session** โดยส่ง Session Token แบบสุ่มผ่าน `HttpOnly` Cookie
- **Session Token:** สร้างด้วย CSPRNG ขนาด 32 bytes (256 bits) ทุกครั้งที่ Login สำเร็จ และเก็บเฉพาะ SHA-256 Hash ใน Database ห้ามเก็บหรือ Log Token ดิบ
- **Password Hashing:** บังคับใช้อัลกอริทึม `Argon2id` เพื่อความปลอดภัยสูงสุดสำหรับระบบใหม่
- **Session Management:** ตาราง `auth_sessions` เป็น Source of Truth สำหรับ Session รองรับ Expiry, Logout, Revoke, Deactivate, Password Change และ Role Change แบบมีผลทันที
- **Authorization:** ทุก Protected Request ต้องอ่าน `is_active` และ Role ปัจจุบันจากตาราง `users` แล้วบังคับ Permission ที่ Backend แบบ Default Deny; การซ่อนปุ่มใน Frontendเป็นเพียง UX
- **Cookie & Browser Security:** ใช้ `HttpOnly`, `Secure` ใน Production, `SameSite=Strict`, ไม่กำหนด `Domain`, ไม่เก็บ Credential ใน `localStorage`/`sessionStorage` และป้องกัน CSRF สำหรับทุก State-changing Request

> [!IMPORTANT]
> สถาปัตยกรรมนี้ไม่ใช่ Starlette/FastAPI `SessionMiddleware` ซึ่งเก็บ Session State ไว้ใน Signed Cookie ฝั่ง Client แต่เป็น Custom Auth Guard ที่ Hash Cookie Token แล้ว Query `auth_sessions` และ `users` จาก Database

### 1.1 Architecture Decision

MyNetMate เลือก Server-side Session แทน JWT สำหรับ P1 เพราะระบบเป็น Web Application แบบ React + FastAPI ที่มีผู้ใช้น้อย, Backend และ Database เป็นศูนย์กลางเดียว และต้องบังคับ Logout/Deactivate/Role Change ให้มีผลทันที เดิม Stateful JWT ก็ต้อง Query `auth_sessions` และ `users` ทุก Protected Request อยู่แล้ว จึงไม่ได้ประโยชน์ด้าน Stateless Scalability แต่ยังเพิ่มภาระด้าน Signature, Claims, Signing Key และ `jti`

การตัดสินใจนี้ไม่ได้หมายความว่า Session ปลอดภัยกว่า JWT โดยอัตโนมัติ แต่เป็นการเลือกกลไกที่เรียบง่ายกว่าและตรงกับ Threat Model ของ MyNetMate โดยยังคงบังคับใช้ Cookie Security, CSRF Protection, HTTPS, Session Expiry และ Backend RBAC อย่างครบถ้วน

**Security References:** [OWASP Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) และ [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)

## 2. Role-Based Access Control (RBAC)
ระบบกำหนดสิทธิ์ผู้ใช้งานเป็น 3 ระดับ (Roles) เพื่อรักษาสมดุลระหว่าง Operation และ Security Compliance:

1. **Admin:** เจ้าของระบบ ดูแลเรื่อง Security และ User Management 
2. **Operator:** วิศวกรหน้างาน จัดการอุปกรณ์ และสร้าง Config Plan ได้ (ส่วนการสั่ง Push Config ลงอุปกรณ์จริงผ่าน SSH จะอยู่ในระยะ P2) แต่ยุ่งกับ User/Security ไม่ได้
3. **Viewer:** ผู้เยี่ยมชม ดู Dashboard และ Topology ได้อย่างเดียว ป้องกัน Human Error

## 3. User Management Scope (P1)
ระบบรองรับฟังก์ชันจัดการผู้ใช้ขั้นพื้นฐาน ดังนี้:
- ✅ Admin สามารถ **สร้างผู้ใช้ใหม่** (Create User) ได้
- ✅ Admin สามารถ **ระงับผู้ใช้** (Deactivate/Disable) ได้
- ✅ Admin สามารถ **เปลี่ยน Role** ของผู้ใช้อื่นได้
- ✅ ผู้ใช้งานสามารถ **เปลี่ยนรหัสผ่านของตนเอง** (Self-change Password) ได้
- ❌ **ไม่รองรับ** ระบบ Admin รีเซ็ตรหัสผ่านให้ผู้ใช้อื่น (Admin Reset Password / Temporary Password) เพื่อลดความซับซ้อนของ Flow ในระยะ P1
- ❌ **ไม่รองรับ** ระบบสมัครสมาชิกเอง (Self-Registration) และระบบลืมรหัสผ่าน (Forgot Password via Email)
