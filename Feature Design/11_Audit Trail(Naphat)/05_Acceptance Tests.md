# Acceptance Tests - Audit Trail

เอกสารนี้ระบุเงื่อนไขการทดสอบ (Acceptance Criteria) เพื่อให้มั่นใจว่าฟีเจอร์ Audit Trail ทำงานได้ตาม MVP Scope อย่างถูกต้องและปลอดภัย

## Test Case 1: Transaction Bounding (Rollback)
- **สถานการณ์:** ผู้ใช้พยายามแก้ไขอุปกรณ์ (Device Update) แต่เกิด Error ที่ระดับฐานข้อมูล (เช่น Unique constraint ของ IP ซ้ำ) ทำให้ Business Action ถูก Rollback
- **สิ่งที่คาดหวัง:** Audit Log เหตุการณ์ `device.update` จะต้องไม่ปรากฏในฐานข้อมูล (ต้องถูก Rollback ไปพร้อมกับ Business Action ยกเว้นกรณีที่เป็นการตั้งใจดักจับ Error และบันทึกเป็น `failure` ใหม่)

## Test Case 2: Append-Only Policy
- **สถานการณ์:** มีผู้ไม่หวังดีหรือมีโค้ดบั๊กพยายามยิงคำสั่ง `UPDATE audit_logs SET...` หรือเรียกใช้ `session.delete(audit_log_entry)`
- **สิ่งที่คาดหวัง:**
  - ระบบ Backend ไม่ส่งออก API สำหรับการแก้ไข (PATCH/PUT) หรือลบ (DELETE) `audit-logs`
  - การใช้งานในระดับ Application Layer ไม่มีฟังก์ชันลบหรือแก้

## Test Case 3: Admin Full Read Access
- **สถานการณ์:** Admin เรียกใช้ `GET /api/audit-logs`
- **สิ่งที่คาดหวัง:** 
  - ได้รับ HTTP 200 OK
  - ข้อมูลที่ตอบกลับมีฟิลด์ครบถ้วน ได้แก่ `safe_error_category`, `description` (ไม่มี `ip_address` ตามข้อตกลง P1)
  - สามารถใช้ Filter เช่น ค้นหาเฉพาะ `action=user.login_failed` ได้อย่างถูกต้อง

## Test Case 4: Operator and Viewer Denied Access
- **สถานการณ์:** Operator หรือ Viewer พยายามเรียก `GET /api/audit-logs`
- **สิ่งที่คาดหวัง:** ได้รับ HTTP 403 Forbidden 

## Test Case 5: Secret and PII Redaction
- **สถานการณ์:** Admin เรียกใช้ `GET /api/audit-logs` เพื่อดูประวัติการเข้าสู่ระบบที่ล้มเหลว หรือประวัติการแก้ไขข้อมูลสำคัญ
- **สิ่งที่คาดหวัง:**
  1. หลัง Auth เปลี่ยนเป็น Opaque Session ฟิลด์ `description` ของ API Response ต้องไม่มี Password (Plaintext/Hash), Session Token, Cookie Header, Session Token Hash, Credential Secret หรือ Raw Failed-login Identifier (เช่น string username ที่พิมพ์ผิด) หลุดรอดมาแสดงผล
  2. เมื่อใช้ Database Client Query ตรวจสอบ row ในตาราง `audit_logs` โดยตรง ฟิลด์ `description` จะต้องถูก Redact ข้อมูลสำคัญเหล่านี้ออกไปแล้วก่อนทำการ Write (เพื่อพิสูจน์ว่า Redact ที่ Server-side ก่อนลง DB จริงๆ) หากพยายามตรวจหาด้วย Regex หรือ String matching ต้องไม่พบ

## Test Case 6: Null Actor on Anonymous Action
- **สถานการณ์:** มีการพยายามล็อกอินด้วย Username ที่ไม่เคยมีในระบบ
- **สิ่งที่คาดหวัง:**
  - สร้าง Audit Log ที่มี `action = user.login_failed`
  - ฟิลด์ `user_id = null`
  - ฟิลด์ `result = failure`
  - ฟิลด์ `safe_error_category = authentication_error`

## Test Case 7: Pagination Validity
- **สถานการณ์:** มีข้อมูล Audit Log 1,000 แถว Admin เรียกดูทีละ 50 แถวโดยระบุ cursor
- **สิ่งที่คาดหวัง:** จำนวนข้อมูลที่ถูกตอบกลับไม่เกิน 50 แถว และเมื่อเรียกหน้าถัดไป ข้อมูลต้องถูกต้อง ไม่ข้ามและไม่ซ้ำ โดยบังคับใช้การ Sort และ Tie-breaker แบบ `created_at DESC, id DESC` ทั้งคู่ตาม API Contract

## Test Case 8: Row-level Check for Permission Denied
- **สถานการณ์:** ผู้ใช้ที่มีสิทธิ์ Viewer พยายามเรียกใช้ API ที่ต้องใช้สิทธิ์ Operator ขึ้นไป (เช่น POST /api/devices)
- **สิ่งที่คาดหวัง:**
  - ได้รับ HTTP 403 Forbidden
  - ฐานข้อมูลและ API `GET /api/audit-logs` จะต้องมีข้อมูล Row ใหม่ที่ระบุ:
    - `action = auth.permission_denied`
    - `resource_type = auth`
    - `result = failure`
    - `safe_error_category = authorization_error`
    - `actor_user_id` ตรงกับ ID ของ Viewer คนนั้น

## Test Case 9: No IP Address in Audit Trail
- **สถานการณ์:** จำลองส่ง Request ด้วย Client IP `198.51.100.42` แล้วตรวจสอบ Database Schema และ API
- **สิ่งที่คาดหวัง:**
  - ตาราง `audit_logs` ไม่มีคอลัมน์ `ip_address`
  - เมื่อ Query ดูข้อมูลดิบ (Raw Row) ในตาราง `audit_logs` โดยตรง ค่า `198.51.100.42` ต้องไม่ถูกฝังอยู่ในคอลัมน์ `description` หรือคอลัมน์อื่นๆ เพื่อรับรองกฎ Redaction at Source
  - `GET /api/audit-logs` ไม่มีคีย์ `ip_address` ในข้อมูลที่ตอบกลับ และค่า `198.51.100.42` ต้องไม่ปรากฏในข้อความ Response (รวมถึงห้ามแฝงใน `description`)
  - `GET /api/dashboard/recent-activity` ไม่มีคีย์ `ip_address` และไม่มีค่า `198.51.100.42` หลุดรอดออกไปเด็ดขาด
