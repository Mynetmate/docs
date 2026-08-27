# Test Users and Environment Policy

เพื่อป้องกันการ Hardcode รหัสผ่านลงใน Source Code และรองรับการทำ MVP Demo/Dev ระบบ MyNetMate กำหนดให้ใช้ Seed Script สร้างผู้ใช้งานทดสอบ (Test Users) ภายใต้เงื่อนไขความปลอดภัยดังนี้

## 1. Test Users Definition
สคริปต์จะต้องสร้างผู้ใช้งานเริ่มต้น 3 บัญชีเฉพาะเมื่อบัญชีนั้นยังไม่เคยถูกสร้างมาก่อน (ป้องกันการรีเซ็ตรหัสผ่านหากผู้ใช้เคยเปลี่ยนไปแล้ว):

| Username | Role | Environment Variable สำหรับรับรหัสผ่าน |
| :--- | :--- | :--- |
| `demo_admin` | `admin` | `MYNETMATE_SEED_ADMIN_PASSWORD` |
| `demo_operator` | `operator` | `MYNETMATE_SEED_OPERATOR_PASSWORD` |
| `demo_viewer` | `viewer` | `MYNETMATE_SEED_VIEWER_PASSWORD` |

*(หมายเหตุ: ระบบจะดึงรหัสผ่านจาก Environment Variable มาเข้ารหัสด้วย `Argon2id` ก่อนบันทึกลง Database เสมอ)*

## 2. Seed Script Requirements

โปรแกรมเมอร์ที่จะเขียนสคริปต์ Database Seed สำหรับฟีเจอร์นี้ จะต้องปฏิบัติตามกฎ 2 ข้ออย่างเคร่งครัด:

### 2.1 Idempotency (ทำงานซ้ำได้ไม่พัง และไม่เขียนทับ)
สคริปต์จะต้องใช้ลอจิก `ON CONFLICT DO NOTHING` หรือเช็ค `IF NOT EXISTS` เสมอ เพื่อให้สามารถรันคำสั่ง Seed ซ้ำกี่ครั้งก็ได้โดยไม่ทำให้ Database Error และ **ห้าม** นำรหัสผ่านตั้งต้นไปเขียนทับรหัสผ่านเดิม หากผู้ใช้ทดสอบนั้นเคยเปลี่ยนรหัสผ่านไปแล้ว

### 2.2 Production Guard (ป้องกันรันบนโปรดักชัน / Fail-Closed)
ห้ามให้บัญชี `demo_*` ปรากฏบนเครื่อง Production เด็ดขาด สคริปต์ Seed จะต้องบรรทัดแรกที่ทำหน้าที่ตรวจสอบตัวแปร `APP_ENV` (ตัวแปรเดียวเท่านั้นเพื่อความสม่ำเสมอ)

- หาก `APP_ENV` มีค่าเป็น `development` หรือ `test` 👉 อนุญาตให้สคริปต์ทำงานต่อ
- หาก `APP_ENV` มีค่าเป็น `production`, เป็นค่าว่างเปล่า (Empty/Null), หรือเป็นค่าที่ไม่รู้จัก 👉 **สคริปต์จะต้องทำงานแบบ Fail-Closed โดยสั่ง `exit non-zero` ทันที** เพื่อยกเลิกคำสั่ง Seed โดยไม่ทำให้ Backend Service ตัวหลักล่ม (Crash)

### 2.3 Password Validation (Fail-Closed)
หากค่า Environment Variable สำหรับ Password ของ Seed User ใดๆ มีค่าว่าง (Empty), ไม่มีการตั้งค่า (Undefined), หรือไม่ผ่าน Password Policy (สั้นกว่า 12 ตัวอักษร) สคริปต์ต้อง **`exit non-zero` ทันทีก่อนแตะฐานข้อมูล** พร้อมแสดง Error Message ระบุว่าตัวแปรใดหายไป
