# MVP Scope - Authentication & RBAC

เอกสารนี้กำหนดขอบเขต (Scope) การทำงานขั้นต่ำ (MVP) ของฟีเจอร์ Authentication และการควบคุมสิทธิ์ (RBAC) สำหรับ MyNetMate (Phase 1)

## 1. Core Architecture
- **Authentication:** ใช้ **Database-backed Opaque Server-side Session** โดยส่ง Session Token แบบสุ่มผ่าน `HttpOnly` Cookie
- **Session Token:** สร้างด้วย CSPRNG ขนาด 32 bytes (256 bits) ทุกครั้งที่ Login สำเร็จ และเก็บเฉพาะ SHA-256 Hash ใน Database ห้ามเก็บหรือ Log Token ดิบ
- **Password Hashing:** ใช้ `Argon2id` Baseline `m=19456 KiB`, `t=2`, `p=1` ผ่าน Password Hasher กลางชุดเดียวกัน และใช้ Dummy Hash เมื่อไม่พบบัญชีเพื่อลด Timing-based User Enumeration
- **Session Management:** ตาราง `auth_sessions` เป็น Source of Truth สำหรับ Session รองรับ Expiry, Logout, Revoke, Deactivate, Password Change และ Role Change แบบมีผลทันที
- **Authorization:** ทุก Protected Request ต้องอ่าน `is_active` และ Role ปัจจุบันจากตาราง `users` แล้วบังคับ Permission ที่ Backend แบบ Default Deny; การซ่อนปุ่มใน Frontendเป็นเพียง UX
- **Cookie & Browser Security:** ใช้ `HttpOnly`, `Secure` ใน Production, `SameSite=Strict`, ไม่กำหนด `Domain`, ไม่เก็บ Credential ใน `localStorage`/`sessionStorage` และป้องกัน CSRF สำหรับทุก State-changing Request
- **XSS Safe Rendering:** P1 ไม่รับหรือ Render HTML, Rich Text หรือ Markdown ดิบ ข้อมูลจากผู้ใช้หรือ API ต้องแสดงเป็นข้อความผ่าน React JSX ตามปกติ และห้ามใช้ Unsafe HTML Sink กับข้อมูลที่ไม่น่าเชื่อถือ

> [!IMPORTANT]
> สถาปัตยกรรมนี้ไม่ใช่ Starlette/FastAPI `SessionMiddleware` ซึ่งเก็บ Session State ไว้ใน Signed Cookie ฝั่ง Client แต่เป็น Custom Auth Guard ที่ Hash Cookie Token แล้ว Query `auth_sessions` และ `users` จาก Database

### 1.1 Architecture Decision

MyNetMate เลือก Server-side Session แทน JWT สำหรับ P1 เพราะระบบเป็น Web Application แบบ React + FastAPI ที่มีผู้ใช้น้อย, Backend และ Database เป็นศูนย์กลางเดียว และต้องบังคับ Logout/Deactivate/Role Change ให้มีผลทันที เดิม Stateful JWT ก็ต้อง Query `auth_sessions` และ `users` ทุก Protected Request อยู่แล้ว จึงไม่ได้ประโยชน์ด้าน Stateless Scalability แต่ยังเพิ่มภาระด้าน Signature, Claims, Signing Key และ `jti`

การตัดสินใจนี้ไม่ได้หมายความว่า Session ปลอดภัยกว่า JWT โดยอัตโนมัติ แต่เป็นการเลือกกลไกที่เรียบง่ายกว่าและตรงกับ Threat Model ของ MyNetMate โดยยังคงบังคับใช้ Cookie Security, CSRF Protection, HTTPS, Session Expiry และ Backend RBAC อย่างครบถ้วน

**Security References:** [OWASP Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) และ [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)

### 1.2 Browser Security Boundary (P1)

- **CSRF:** ใช้ FastAPI/Starlette `CORSMiddleware` ร่วมกับ CSRF Guard กลางของ Backend โดยทุก `POST`, `PUT`, `PATCH`, `DELETE` ต้องผ่าน Exact `Origin`/`Referer` และ `X-CSRF-Protection: 1` ก่อนทำ Business Action รวมถึง `POST /api/auth/login` ซึ่งยังไม่มี Session
- **Request Body:** ตรวจ `Content-Type: application/json` เฉพาะ Endpoint ที่มี Request Body เท่านั้น ดังนั้น `POST /api/auth/logout` ซึ่งไม่มี Body ต้องทำงานได้โดยไม่ต้องส่ง `Content-Type` เมื่อผ่าน Origin และ CSRF Header แล้ว
- **XSS:** ข้อมูลจากผู้ใช้หรือ API ต้อง Render เป็น Text ด้วย React JSX ห้ามนำไปใช้กับ `dangerouslySetInnerHTML`, `innerHTML`, `outerHTML`, `insertAdjacentHTML` หรือ `document.write` หากไม่มี Security Review และ Sanitization ที่ได้รับอนุมัติ
- **Session Impact:** `HttpOnly` ลดโอกาสขโมย Token แต่ไม่หยุด Script อันตรายจากการเรียก API ใน Browser ของเหยื่อ จึงยังต้องป้องกัน XSS ที่จุด Render และบังคับ Authorization ที่ Backend
- **Library Decision:** P1 ไม่เพิ่ม Third-party CSRF Library เพราะ Contract ปัจจุบันไม่ใช้ Synchronizer/Double-submit Token และสามารถบังคับด้วย CORS Middleware กับ Guard กลางได้โดยตรง หากรูปแบบ Deployment หรือ Form เปลี่ยนในอนาคตต้องทบทวนการตัดสินใจนี้
- **Future Hardening:** Content Security Policy (CSP) ยังไม่ใช่ข้อบังคับของ P1 และห้ามใช้เป็นตัวแทน Safe Rendering; หากนำมาใช้ภายหลังต้องออกแบบและทดสอบแยกต่างหาก

**XSS Reference:** [OWASP Cross Site Scripting Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)

### 1.3 Lean P1 Implementation Decisions

- **Rate Limiting:** ใช้ Bounded In-memory Sliding-window TTL Store ใน FastAPI Process เดียว จำกัด Login ล้มเหลว 5 ครั้งต่อ Client IP ใน 15 นาทีและปฏิเสธครั้งที่ 6 ก่อนทำ Argon2id; P1 ไม่เพิ่ม Redis, Database Table, Distributed Limiter, CAPTCHA หรือ Account Lockout
- **Client IP:** ค่าเริ่มต้นใช้ Peer IP จาก Connection หาก Deployment มี Reverse Proxy จึงเปิด Proxy Header Processing โดยกำหนด Trusted Proxy Allowlist แบบชัดเจน ห้ามเชื่อ Forwarded Header จาก Client ทั่วไป
- **Error Contract:** Auth Error ทุกตัวใช้ `{ "error": { "code", "message" } }`; P1 ไม่ทำระบบ Field-level Error ที่ซับซ้อน และ Frontend ต้องตัดสินพฤติกรรมจาก `code` ไม่ Parse `message`
- **Frontend Session State:** `AUTH_SESSION_MISSING`/`AUTH_SESSION_INVALID` จาก Protected API ต้องล้าง User State และ User-scoped Query Cache แล้วกลับหน้า Login ส่วน `AUTH_FORBIDDEN`, `AUTH_ORIGIN_REJECTED` และ `AUTH_CSRF_REJECTED` ห้าม Logout ผู้ใช้
- **Audit Transaction Boundary:** Auth Action ที่เปลี่ยนข้อมูลต้องเขียน Audit ใน Business Transaction เดียวกัน ส่วน `user.login_failed` และ `auth.permission_denied` ต้องใช้ Intentional Audit Transaction แยกที่ Commit ได้แม้ Request ถูกปฏิเสธ Auth Caller ส่งเฉพาะ 4 Business Arguments และไม่ส่ง Client IP หรือ `description`
- **Availability Policy:** หาก Database, Session Store หรือ Audit Write ที่ Contract กำหนดว่า Mandatory ใช้งานไม่ได้ ระบบต้อง Fail Closed, ห้ามออก Session และตอบ `503 AUTH_SERVICE_UNAVAILABLE` แบบ Generic

## 2. Role-Based Access Control (RBAC)
ระบบกำหนดสิทธิ์ผู้ใช้งานเป็น 3 ระดับ (Roles) เพื่อรักษาสมดุลระหว่าง Operation และ Security Compliance:

1. **Admin:** เจ้าของระบบ ดูแลเรื่อง Security และ User Management 
2. **Operator:** วิศวกรหน้างาน จัดการอุปกรณ์ และสร้าง Config Plan ได้ (ส่วนการสั่ง Push Config ลงอุปกรณ์จริงผ่าน SSH จะอยู่ในระยะ P2) แต่ยุ่งกับ User/Security ไม่ได้
3. **Viewer:** ผู้เยี่ยมชม ดูข้อมูล P1 แบบ Read-only ตาม Permission Catalog เพื่อป้องกัน Human Error ส่วนการดู Topology เป็นสิทธิ์ในระยะ P2

## 3. User Management Scope (P1)
ระบบรองรับฟังก์ชันจัดการผู้ใช้ขั้นพื้นฐาน ดังนี้:
- ✅ Admin สามารถ **สร้างผู้ใช้ใหม่** (Create User) ได้
- ✅ Admin สามารถ **ระงับผู้ใช้** (Deactivate/Disable) ได้
- ✅ Admin สามารถ **เปลี่ยน Role** ของผู้ใช้อื่นได้
- ✅ ผู้ใช้งานสามารถ **เปลี่ยนรหัสผ่านของตนเอง** (Self-change Password) ได้
- ❌ **ไม่รองรับ** ระบบ Admin รีเซ็ตรหัสผ่านให้ผู้ใช้อื่น (Admin Reset Password / Temporary Password) เพื่อลดความซับซ้อนของ Flow ในระยะ P1
- ❌ **ไม่รองรับ** ระบบสมัครสมาชิกเอง (Self-Registration) และระบบลืมรหัสผ่าน (Forgot Password via Email)
