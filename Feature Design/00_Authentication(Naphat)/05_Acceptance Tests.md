# Acceptance Tests - Authentication

เอกสารนี้ระบุเงื่อนไขการยอมรับ (Acceptance Criteria / Tests) สำหรับฟีเจอร์ Authentication & RBAC

## Test Cases

1. **Successful Login & Session Creation:**
   - การ Login ที่ถูกต้องต้องสร้าง Opaque Session Token ใหม่จาก CSPRNG ขนาด 32 bytes (256 bits)
   - Response ต้องคืน Session Token ผ่าน Cookie ที่เป็น `HttpOnly`, `SameSite=Strict`, Path `/`, ไม่กำหนด Domain และเป็น `Secure` ใน Production
   - Database ต้องมีเฉพาะ `SHA-256(token)` ใน `auth_sessions.session_token_hash` โดย Token ดิบต้องไม่ตรงกับค่าที่เก็บใน Database
   - สามารถใช้ Cookie นั้นเรียก API `/api/auth/me` และได้ข้อมูลตนเองกลับมา
   - **Case Normalization:** ระบบต้องทำ Case Normalization สำหรับ Username/Email (บังคับให้ระบบแปลงตัวอักษรเป็นพิมพ์เล็ก `lowercase` เสมอ) และอนุญาตให้ Username มีเฉพาะตัวอักษร ตัวเลข `._-` เท่านั้น (ห้ามมี `@`)
2. **Password & Session Token Security:**
   - รหัสผ่านที่เก็บใน Database ต้องไม่ใช่ Plaintext และใช้ `Argon2id`
   - PHC String ต้องระบุ Argon2id Baseline `m=19456`, `t=2`, `p=1` และ Password เดียวกันที่ Hash สองครั้งต้องได้คนละ String เพราะมี Random Salt คนละค่า
   - Login, Create User, Self-change Password และ Seed User ต้องใช้ Password Hasher Configuration ชุดเดียวกัน
   - เมื่อไม่พบบัญชี Backend ต้องเรียก Argon2id Verify กับ Dummy Hash ที่สร้างหนึ่งครั้งตอน Startup แล้วทิ้งผล; เมื่อบัญชี Inactive ต้อง Verify กับ Hash จริงแล้วทิ้งผล ทั้งสองกรณีต้องตอบ `401 AUTH_INVALID_CREDENTIALS` แบบเดียวกับรหัสผ่านผิด
   - ต้องมีผล Manual Benchmark จากเครื่อง/Container Demo ว่าการ Verify หนึ่งครั้งต่ำกว่าประมาณ 1 วินาที โดยไม่ใช้ Timing Assertion เป็น CI Gate
   - **ห้าม** มี Session Token, Cookie Header หรือ `session_token_hash` ปรากฏใน Response JSON, Application Log หรือ Audit Log
   - Frontend ต้องไม่เก็บ Authentication Credential ใน `localStorage` หรือ `sessionStorage`
3. **Session Validation:**
   - หากไม่มี Cookie ต้องตอบ `401 AUTH_SESSION_MISSING`
   - หาก Token รูปแบบผิด, Token สุ่มที่ไม่อยู่ในระบบ, Session หมดอายุ หรือ Session ถูก Revoke ต้องตอบ `401 AUTH_SESSION_INVALID`
   - Backend ต้องรับ Session Token จาก Cookie เท่านั้น และปฏิเสธ Token ที่ส่งผ่าน URL, Request Body หรือ `Authorization: Bearer`
4. **Failed Login Handling:**
   - หาก Login ผิด ระบบต้อง **ไม่ระบุ** ว่า Username/Email หรือรหัสผ่านกันแน่ที่มีปัญหา (ตอบ `401 AUTH_INVALID_CREDENTIALS` เหมือนกันหมด)
   - บันทึก Audit Log `user.login_failed` (ต้องไม่เก็บ Username/Email ดิบที่กรอกผิดลงไป เพราะเป็น PII)
   - `user.login_failed` ต้องเขียนผ่าน Intentional Audit Transaction แยกและ Commit สำเร็จก่อนตอบ `401`; หาก Audit Commit ล้มเหลวต้องตอบ `503 AUTH_SERVICE_UNAVAILABLE`
   - Auth Caller ต้องไม่มี Argument สำหรับ Client IP หรือ `description`; Wrapper/Audit Writer เป็นผู้กำหนด `description=null` หรือ Fixed Safe Template ภายในเท่านั้น
5. **Inactive Account & Immediate Role Effect:**
   - ผู้ใช้ที่มีสถานะ `is_active=false` จะ Login ไม่ได้
   - **Immediate Effect:** ในทุกการเรียก API ตรวจสอบสิทธิ์ ระบบต้องอ่านค่า `is_active` และ Role จาก Database เสมอ
   - เมื่อ Admin เปลี่ยน Role หรือ Deactivate ผู้ใช้อื่น Backend ต้อง Revoke Session ทั้งหมดของผู้ใช้เป้าหมายแบบ Atomic และ Session เดิมต้องถูกปฏิเสธด้วย `401 AUTH_SESSION_INVALID`
6. **Session Expiry & Revocation:**
   - Session ที่ `expires_at <= now()` หรือถูกตั้ง `is_revoked=true` ต้องตอบ `401 AUTH_SESSION_INVALID` แม้ Browser ยังส่ง Cookie เดิม
   - เมื่อผู้ใช้ทำการ Logout สำเร็จ (`POST /api/auth/logout`) ต้อง Revoke Session ปัจจุบันและบันทึก Audit Log action: `user.logout` ใน Transaction เดียวกัน หาก Audit Write ล้มเหลวต้อง Rollback Session Revoke และตอบ `503 AUTH_SERVICE_UNAVAILABLE`
   - Logout ต้อง Revoke เฉพาะ Session ปัจจุบันและลบ Cookie หลัง Transaction สำเร็จ โดยใช้ Name/Path/Secure/SameSite ตรงกับตอนสร้าง
7. **Change Password Lifecycle (Self-change):**
   - การเรียกเปลี่ยนรหัสผ่านด้วยตนเอง ต้องส่ง `current_password` มาด้วยเสมอ
   - หาก `current_password` ผิด ต้องตอบ `400 AUTH_CURRENT_PASSWORD_INVALID`
   - เมื่อเปลี่ยนรหัสผ่านสำเร็จ **ต้อง Revoke Sessions เดิมทั้งหมด** ของผู้ใช้คนนั้น (รวมถึงตัวเอง) เพื่อบังคับให้ล็อกอินใหม่
8. **Admin User Management & Safety Guard:**
   - `Admin` สามารถสร้าง User ใหม่ ระงับบัญชี และเปลี่ยน Role ได้
   - **Password Policy:** Admin สร้าง User ใหม่ต้องใช้ Password Policy เดียวกับ Self-change (ยาว 12-128 ตัวอักษร)
   - หาก Operator หรือ Viewer พยายามเรียกใช้ Endpoints กลุ่ม `/api/admin/users/*` ต้องถูกปฏิเสธด้วยสถานะ `403 AUTH_FORBIDDEN` ทันที
   - **Deactivate → Revoke:** เมื่อตั้ง `is_active=false` ให้ผู้ใช้ ระบบต้อง Revoke ทุก Session ของผู้ใช้เป้าหมายทันทีแบบ Atomic (ภายใน Transaction เดียวกัน)
   - **Reactivate ≠ Restore Session:** เมื่อเปิดบัญชีกลับมา (`is_active=true`) ห้ามคืน Session เก่า ผู้ใช้ต้อง Login ใหม่
   - **Fallback Prevention:** ระบบต้องปฏิเสธ (`409 AUTH_LAST_ADMIN_PROTECTED`) การ Demote หรือ Deactivate บัญชี Admin หากนั่นคือ Admin ที่ `is_active=true` คนสุดท้ายของระบบ
9. **Role Restrictions Enforcement:**
   - การเข้าถึง API ที่ผู้ใช้ไม่มีสิทธิ์ (เช่น Viewer เข้าไปแก้ Config) ต้อง Commit Audit Log action `auth.permission_denied` แล้วตอบ `403 AUTH_FORBIDDEN`; หาก Mandatory Audit Write ล้มเหลวต้อง Fail Closed และตอบ `503 AUTH_SERVICE_UNAVAILABLE` แทน
   - `Viewer` ไม่สามารถสร้าง/แก้ไข Device, CIS, Settings (ตามที่ระบุใน Permission Catalog)
   - `Operator` ไม่สามารถดึง Secret ดิบออกจาก Credential Profile ได้ (ระบบ API ห้ามคืนค่า Plaintext กลับมาเด็ดขาด)
10. **Rate Limiting:**
    - ระบบอนุญาตให้พยายาม Login ล้มเหลวได้สูงสุด 5 ครั้งต่อ **Client IP** ภายใน 15 นาที หากกระทำ**ครั้งที่ 6** ระบบต้องปฏิเสธคำขอจาก Client IP นั้นทันที (ตอบ `429 AUTH_LOGIN_RATE_LIMITED`)
    - ครั้งที่ 6 ต้องถูกปฏิเสธก่อน User Query และ Argon2id Verify โดย Test Double ต้องยืนยันว่า Password Verifier ไม่ถูกเรียก
    - P1 ต้องใช้ Bounded In-memory Sliding-window TTL Store ค่าเริ่มต้นสูงสุด 10,000 Keys และรัน FastAPI หนึ่ง Process/Worker; Restart แล้ว Counter หายเป็นข้อจำกัดที่ยอมรับและต้องมีคำอธิบายใน Deployment Configuration
    - ระบบจะนับ Identifier (Username/Email) ควบคู่ด้วยโดย Normalize แล้วแปลงเป็น HMAC ด้วย `AUTH_RATE_LIMIT_HMAC_KEY` ก่อนเก็บชั่วคราว การตรวจ State/Key ของ Rate-limit Store, Application Log และ Audit Log ต้องไม่พบ Raw Identifier และ P1 ห้ามใช้ Counter นี้ทำ Account Lockout
    - หาก `AUTH_RATE_LIMIT_HMAC_KEY` ไม่มีค่า หรือมีความยาวน้อยกว่า 32 bytes Application Startup ต้อง Fail Closed ก่อนเปิดรับ Request
    - การตรวจและเพิ่ม Counter ต้อง Atomic ภายใน Process; Concurrent Failed Attempts ต้องไม่ทำให้จำนวนครั้งสูญหายหรือปล่อย Request เกิน Threshold
    - เมื่อไม่เปิด Trusted Proxy ให้ Client ส่ง `X-Forwarded-For` ปลอมแล้วค่าที่ใช้ Rate Limit ต้องยังเป็น Peer IP; เมื่อเปิด Proxy Header Processing ต้องยอมรับ Header เฉพาะ Connection จาก Trusted Proxy Allowlist และห้ามใช้ Wildcard Trust
    - ระบบจะปลดล็อกอัตโนมัติเมื่อครบ 15 นาที
11. **CORS / Origin Protection:**
    - CORS ต้องใช้ Exact Origin Allowlist และ `Access-Control-Allow-Credentials: true`; ห้ามใช้ `*` กับ Origin, Method หรือ Header เมื่ออนุญาต Credentials
    - CORS ต้องระบุ Method Allowlist และ Header Allowlist ที่รองรับ `Content-Type` กับ `X-CSRF-Protection` อย่างชัดเจน
    - State-changing Request (`POST`, `PUT`, `PATCH`, `DELETE`) ต้องมี Exact `Origin`; หากไม่มีให้ตรวจ Exact `Referer`; หากไม่ตรงหรือไม่มีทั้งคู่ให้ตอบ `403 AUTH_ORIGIN_REJECTED`
    - State-changing Request ต้องมี `X-CSRF-Protection: 1`; หากไม่มีหรือค่าผิดให้ตอบ `403 AUTH_CSRF_REJECTED`
    - `POST /api/auth/login` ต้องผ่าน CSRF Guard แม้ Request ยังไม่มี Session: Origin/Header ผิดต้องได้ `403`; เมื่อ Origin/Header ถูกต้องแต่ Credential ผิดจึงได้ `401 AUTH_INVALID_CREDENTIALS`
    - Auth API ที่มี Body ต้องปฏิเสธ Content Type ที่ไม่ใช่ `application/json` แต่ `POST /api/auth/logout` ที่ไม่มี Body และมี Origin/Header ถูกต้องต้องสำเร็จได้โดยไม่ส่ง `Content-Type`
    - `GET` และ `HEAD` ต้องไม่มี State-changing Side Effect ส่วน `OPTIONS` ต้องถูกจัดการเป็น CORS Preflight โดยไม่เรียก Business Action
12. **Audit Log Data Integrity & Privacy Policy:**
    - เหตุการณ์ต้องระบุ `action` (ใช้ Canonical Action Names: `user.login_success`, `user.login_failed`, `user.logout`, `user.password_changed`, `user.created`, `user.updated`, `user.deactivated`, `auth.permission_denied`) และ `resource_type`
    - ระบบเก็บข้อมูลลงตารางกลางด้วยคอลัมน์ `user_id`, `created_at` แต่ตอนตอบกลับ API `/api/audit-logs` จะต้อง Map ชื่อเป็น `actor_user_id` และ `occurred_at` เสมอ
    - กรณีที่เข้าถึงโดยไม่ทราบตัวตน (เช่น Login ผิดพลาดของ Hacker) ค่า `actor_user_id` และ `resource_id` จะต้องยอมรับค่า **NULL** ได้
    - **Strict Privacy Rule:** Auth Caller ไม่มี `description` หรือ Client IP Argument และส่งเฉพาะ 4 Business Arguments เท่านั้น Wrapper/Audit Writer กำหนด `description` เป็น `null` หรือ Fixed Safe Template ภายใน โดยห้ามมี Password (Plaintext/Hash), Session Token, Cookie Header, Session Token Hash, Credential Secret หรือ Raw Failed-login Identifier
13. **Environment Policy (Test Users):**
    - ข้อมูลผู้ใช้ทดสอบ (Seed Test Users) ทั้ง 3 Roles จะถูกสร้างตามไฟล์ `07_Test Users and Environment Policy.md`
    - ถ้ารันคำสั่ง Seed บน `APP_ENV=production` หรือ `APP_ENV` ว่าง/ไม่มีค่า โปรแกรม Seed ต้อง `exit non-zero` ทันที
    - ถ้า Environment Variable สำหรับ Password ว่างหรือไม่ผ่าน Policy (สั้นกว่า 12 ตัวอักษร) โปรแกรม Seed ต้อง `exit non-zero` ทันที
14. **Failed Login Target Binding:**
    - หากมีการพยายาม Login เข้าบัญชีที่มีอยู่จริงแต่รหัสผ่านผิด Audit Log ต้องบันทึกว่า `actor_id = null` (เนื่องจากผู้กระทำยังยืนยันตัวไม่ได้) แต่ต้องบันทึก `resource_id` เป็น ID ของบัญชีเป้าหมายนั้น
15. **Dashboard Recent Activity Redaction:**
    - การดึงข้อมูลผ่าน API `/api/dashboard/recent-activity` หากเหตุการณ์นั้นมี `actor_user_id = null` ข้อมูลที่ตอบกลับต้องแสดงคำว่า `Unknown` แทน
    - ต้องไม่มีการหลุด PII หรือข้อมูลลับใดๆ ทั้งสิ้น (ได้แก่: ห้ามแสดง IP Address, ห้ามแสดง User-Agent, ห้ามแสดง Error Detail, ห้ามแสดง Secret, ห้ามแสดง Full Audit Description)
16. **Password Change Atomic Rollback:**
    - หากระบบสามารถ Update Password Hash และ Revoke Sessions ได้สำเร็จ แต่ไม่สามารถเขียน Audit Log ลง Database ได้ ระบบจะต้อง Rollback การกระทำทั้งหมดใน Transaction นั้น กลับสู่สถานะเดิม และตอบ `503 AUTH_SERVICE_UNAVAILABLE`
17. **Concurrent Last-Admin Lock:**
    - หาก Admin 2 คน พยายามทำการ Deactivate หรือ Demote อีกฝ่ายหนึ่ง **ในเวลาเดียวกัน** ระบบจะต้อง Serialize การทำงานด้วย Database Lock และต้องมีอย่างน้อยหนึ่งคนที่ถูกปฏิเสธด้วย `409 AUTH_LAST_ADMIN_PROTECTED` เพื่อให้ระบบเหลือ Admin ที่ `is_active=true` อย่างน้อย 1 คนเสมอ
18. **Audit Writer Registry Rules:**
    - ฟังก์ชัน `record_auth_event()` ต้องรับข้อมูลเพียง 4 พารามิเตอร์ และสามารถหาค่า `result`, `safe_error_category` และ `created_at` ออกมาเขียนลง DB ได้อย่างถูกต้องตาม Mapping Table
    - หากมีการเรียก `record_auth_event()` โดยใส่ Action ที่ไม่ได้อยู่ใน Canonical Action Names (เช่น ส่ง Action ของระบบ Device) ฟังก์ชันต้อง Reject และโยน Exception ทันที
19. **Topology View `[P2 Integration Test]`:**
    - *หมายเหตุ: นำไปทดสอบในระยะ P2 เท่านั้น ไม่บังคับสำหรับการส่งมอบ P1*
    - `Viewer` สามารถดู Topology (NTV) ได้
    - `Viewer` พยายามเรียก `POST collection` หรือ `PATCH position` ของ NTV จะต้องได้สถานะ `403 Forbidden`
20. **Session Fixation Prevention:**
    - Backend ต้องสร้าง Session Token ใหม่หลัง Login สำเร็จทุกครั้ง และต้องไม่ยอมรับค่าที่ Client กำหนดล่วงหน้า
    - การ Login สองครั้งต้องได้ Token คนละค่า และ Session แต่ละรายการต้อง Revoke แยกกันได้
21. **Environment-specific Cookie Safety:**
    - Production ต้องใช้ Cookie ชื่อ `__Host-mynetmate_session` พร้อม `Secure=true`, `Path=/`, ไม่มี `Domain` และต้อง Fail Closed หาก Config ไม่ครบ
    - ชื่อ `mynetmate_session` และ `Secure=false` ใช้ได้เฉพาะ `APP_ENV=development` หรือ `test`
22. **Session Store Failure:**
    - หาก Database/Session Store ใช้งานไม่ได้ Protected API ต้อง Fail Closed, ตอบ `503 AUTH_SERVICE_UNAVAILABLE` และห้ามอนุญาต Request จากข้อมูล Cookie เพียงอย่างเดียว
23. **XSS Safe Rendering:**
    - P1 ต้องไม่มี Flow ที่รับหรือ Render User-supplied HTML, Rich Text หรือ Markdown ดิบ
    - Frontend Component ที่แสดงข้อมูลจากผู้ใช้หรือ API ต้องผ่าน Test Fixture เช่น `<img src=x onerror=alert(1)>` แล้วแสดงเป็นข้อความเท่านั้น ต้องไม่สร้าง `<img>` จากข้อความนั้นและต้องไม่มี Script/Event Handler ทำงาน
    - Code Review หรือ Automated Check ต้องไม่พบการส่งข้อมูลที่ไม่น่าเชื่อถือเข้า `dangerouslySetInnerHTML`, `innerHTML`, `outerHTML`, `insertAdjacentHTML` หรือ `document.write`
    - การตั้ง `HttpOnly` ต้องถูกทดสอบใน Cookie Contract แต่ห้ามอ้างว่า `HttpOnly` ป้องกัน XSS Execution หรือการเรียก API จาก Script ที่รันใน Origin เดียวกันได้
24. **Standard Error Response Contract:**
    - Error ของ Auth ทุกตัวต้องใช้ `{ "error": { "code": "...", "message": "..." } }`; Frontend ห้าม Parse `message` เพื่อตัดสิน Logic
    - `422` ต้องใช้ `AUTH_REQUEST_INVALID` โดย P1 ไม่มี Field-level Error Array และ Response ห้าม Echo Raw Input
    - `401 AUTH_INVALID_CREDENTIALS` ต้องใช้ Message เดียวกันสำหรับไม่พบบัญชี, รหัสผ่านผิด และบัญชี Inactive
    - `500/503` ห้ามมี Stack Trace, SQL/Driver Error, Token, Cookie หรือ Secret ใน Response
25. **Frontend 401/403 Behavior:**
    - เมื่อ Protected API ตอบ `AUTH_SESSION_MISSING` หรือ `AUTH_SESSION_INVALID` Frontend ต้องล้าง Zustand Auth State และ User-scoped TanStack Query Cache แล้ว Redirect ไปหน้า Login; เฉพาะ `AUTH_SESSION_INVALID` จึงแสดงข้อความ Session สิ้นสุด
    - เมื่อ API ตอบ `AUTH_FORBIDDEN` Frontend ต้องไม่ Logout ผู้ใช้และต้องแสดง Access Denied หรือกลับไปหน้าที่มีสิทธิ์
    - เมื่อ API ตอบ `AUTH_ORIGIN_REJECTED` หรือ `AUTH_CSRF_REJECTED` Frontend ต้องไม่ Logout และห้าม Retry State-changing Request อัตโนมัติ
    - Concurrent Protected Requests ที่ได้ `401` พร้อมกันต้องทำให้เกิดการ Clear/Redirect/Notification เพียงหนึ่งรอบ
    - TanStack Query/Mutation และ API Client ต้องไม่ Retry `401`, `403` หรือ `429` อัตโนมัติ
    - เมื่อ Backend ตอบ `AUTH_SESSION_INVALID` ต้องส่ง Cookie-deletion Header ด้วย Name/Path/Domain/Secure Policy เดียวกับ Logout เพื่อให้ Browser ลบ `HttpOnly` Cookie
26. **Audit Transaction Boundaries:**
    - Login สำเร็จต้อง Insert `auth_sessions` และ `user.login_success` ใน Transaction เดียวกัน หาก Audit Write ล้มเหลวต้องไม่มี Session Row/Cookie และตอบ `503 AUTH_SERVICE_UNAVAILABLE`
    - Login ล้มเหลวต้องไม่มี Business Mutation แต่ต้อง Commit `user.login_failed` ด้วย Intentional Audit Transaction แยกก่อนตอบ `401`
    - `auth.permission_denied` ต้องถูก Commit แม้ Business Request ถูกปฏิเสธด้วย `403`; หาก Mandatory Audit Store ใช้งานไม่ได้ต้อง Fail Closed ด้วย `503 AUTH_SERVICE_UNAVAILABLE`
