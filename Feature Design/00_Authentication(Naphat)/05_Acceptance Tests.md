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
   - **ห้าม** มี Session Token, Cookie Header หรือ `session_token_hash` ปรากฏใน Response JSON, Application Log หรือ Audit Log
   - Frontend ต้องไม่เก็บ Authentication Credential ใน `localStorage` หรือ `sessionStorage`
3. **Session Validation:**
   - หากไม่มี Cookie ต้องตอบ `401 AUTH_SESSION_MISSING`
   - หาก Token รูปแบบผิด, Token สุ่มที่ไม่อยู่ในระบบ, Session หมดอายุ หรือ Session ถูก Revoke ต้องตอบ `401 AUTH_SESSION_INVALID`
   - Backend ต้องรับ Session Token จาก Cookie เท่านั้น และปฏิเสธ Token ที่ส่งผ่าน URL, Request Body หรือ `Authorization: Bearer`
4. **Failed Login Handling:**
   - หาก Login ผิด ระบบต้อง **ไม่ระบุ** ว่า Username/Email หรือรหัสผ่านกันแน่ที่มีปัญหา (ตอบ `401 AUTH_INVALID_CREDENTIALS` เหมือนกันหมด)
   - บันทึก Audit Log `user.login_failed` (ต้องไม่เก็บ Username/Email ดิบที่กรอกผิดลงไป เพราะเป็น PII)
5. **Inactive Account & Immediate Role Effect:**
   - ผู้ใช้ที่มีสถานะ `is_active=false` จะ Login ไม่ได้
   - **Immediate Effect:** ในทุกการเรียก API ตรวจสอบสิทธิ์ ระบบต้องอ่านค่า `is_active` และ Role จาก Database เสมอ
   - เมื่อ Admin เปลี่ยน Role หรือ Deactivate ผู้ใช้อื่น Backend ต้อง Revoke Session ทั้งหมดของผู้ใช้เป้าหมายแบบ Atomic และ Session เดิมต้องถูกปฏิเสธด้วย `401 AUTH_SESSION_INVALID`
6. **Session Expiry & Revocation:**
   - Session ที่ `expires_at <= now()` หรือถูกตั้ง `is_revoked=true` ต้องตอบ `401 AUTH_SESSION_INVALID` แม้ Browser ยังส่ง Cookie เดิม
   - เมื่อผู้ใช้ทำการ Logout สำเร็จ (`POST /api/auth/logout`) ต้องบันทึก Audit Log action: `user.logout` เสมอ
   - Logout ต้อง Revoke เฉพาะ Session ปัจจุบันและลบ Cookie โดยใช้ Name/Path/Secure/SameSite ตรงกับตอนสร้าง
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
   - การเข้าถึง API ที่ผู้ใช้ไม่มีสิทธิ์ (เช่น Viewer เข้าไปแก้ Config) ระบบต้องตอบ `403 AUTH_FORBIDDEN` และต้องบันทึก Audit Log action: `auth.permission_denied` เสมอ
   - `Viewer` ไม่สามารถสร้าง/แก้ไข Device, CIS, Settings (ตามที่ระบุใน Permission Catalog)
   - `Operator` ไม่สามารถดึง Secret ดิบออกจาก Credential Profile ได้ (ระบบ API ห้ามคืนค่า Plaintext กลับมาเด็ดขาด)
10. **Rate Limiting:**
    - ระบบอนุญาตให้พยายาม Login ล้มเหลวได้สูงสุด 5 ครั้งต่อ **Client IP** ภายใน 15 นาที หากกระทำ**ครั้งที่ 6** ระบบต้องปฏิเสธคำขอจาก Client IP นั้นทันที (ตอบ `429 AUTH_LOGIN_RATE_LIMITED`)
    - ระบบจะนับ Identifier (Username/Email) ควบคู่ด้วยโดยแปลงเป็น HMAC ก่อนเก็บลง Cache เพื่อใช้ทำ Alert หรือจำกัด Threshold ที่สูงกว่า
    - ระบบจะปลดล็อกอัตโนมัติเมื่อครบ 15 นาที
11. **CORS / Origin Protection:**
    - CORS ต้องใช้ Exact Origin Allowlist และ `Access-Control-Allow-Credentials: true`; ห้ามใช้ `*`
    - State-changing Request (`POST`, `PUT`, `PATCH`, `DELETE`) ต้องมี Exact `Origin`; หากไม่มีให้ตรวจ Exact `Referer`; หากไม่ตรงหรือไม่มีทั้งคู่ให้ตอบ `403 AUTH_ORIGIN_REJECTED`
    - State-changing Request ต้องมี `X-CSRF-Protection: 1`; หากไม่มีหรือค่าผิดให้ตอบ `403 AUTH_CSRF_REJECTED`
    - Auth API ที่มี Body ต้องปฏิเสธ Content Type ที่ไม่ใช่ `application/json` และต้องไม่มี State-changing `GET`
12. **Audit Log Data Integrity & Privacy Policy:**
    - เหตุการณ์ต้องระบุ `action` (ใช้ Canonical Action Names: `user.login_success`, `user.login_failed`, `user.logout`, `user.password_changed`, `user.created`, `user.updated`, `user.deactivated`, `auth.permission_denied`) และ `resource_type`
    - ระบบเก็บข้อมูลลงตารางกลางด้วยคอลัมน์ `user_id`, `created_at` แต่ตอนตอบกลับ API `/api/audit-logs` จะต้อง Map ชื่อเป็น `actor_user_id` และ `occurred_at` เสมอ
    - กรณีที่เข้าถึงโดยไม่ทราบตัวตน (เช่น Login ผิดพลาดของ Hacker) ค่า `actor_user_id` และ `resource_id` จะต้องยอมรับค่า **NULL** ได้
    - **Strict Privacy Rule:** ห้ามฝั่ง Auth ส่งข้อมูล Password (Plaintext/Hash), Session Token, Cookie Header, Session Token Hash, Credential Secret หรือ Raw Failed-login Identifier (เช่น string username ที่พิมพ์ผิด) แทรกลงมาในฟิลด์ `description` ก่อนเรียกเขียน Log เด็ดขาด ข้อมูลต้องถูก Redact ตั้งแต่ต้นทาง
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
    - หากระบบสามารถ Update Password Hash และ Revoke Sessions ได้สำเร็จ แต่ไม่สามารถเขียน Audit Log ลง Database ได้ ระบบจะต้อง Rollback การกระทำทั้งหมดใน Transaction นั้น กลับสู่สถานะเดิม และตอบ `500 Internal Server Error`
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
    - หาก Database/Session Store ใช้งานไม่ได้ Protected API ต้อง Fail Closed และห้ามอนุญาต Request จากข้อมูล Cookie เพียงอย่างเดียว
