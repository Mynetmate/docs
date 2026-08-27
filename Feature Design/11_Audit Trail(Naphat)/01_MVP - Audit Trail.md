# MVP Scope - Audit Trail

เอกสารนี้กำหนดขอบเขตของการพัฒนา Feature Audit Trail ในระยะ P1 (MVP) โดยอิงตาม `MyNetMate Weight Feature List.md`

## 🎯 เป้าหมายหลัก (P1-Infra)
Audit Trail ทำหน้าที่เป็นแหล่งเก็บประวัติการกระทำทั้งหมดในระบบ (Source of Truth สำหรับ History) เพื่อความโปร่งใส ตรวจสอบย้อนหลังได้ และสนับสนุนความปลอดภัยของระบบ 

## ✅ In Scope (P1)
- **Centralized Storage:** ใช้ตาราง `audit_logs` ใน Central Schema เป็นตารางเดียวสำหรับเก็บข้อมูลเหตุการณ์ทั้งหมด
- **Append-Only Policy:** ไม่มี API สำหรับแก้ไขหรือลบประวัติ
- **Transaction Bounding:** การเขียน Audit Log ต้องเกาะไปกับ Business Transaction เดียวกัน (เพื่อป้องกันข้อมูลไม่ซิงค์กัน)
- **Redaction at Source:** PII, Password, และ Token ต้องถูกปกปิดหรือตัดออกก่อนที่จะ Insert ลงตาราง `audit_logs` เสมอ
- **Full Audit API:** มี API สำหรับดึงข้อมูลทั้งหมด พร้อม Filter และ Pagination สำหรับ Role **Admin** เท่านั้น
- **Producer Integration:** รองรับการรับข้อมูลจาก Feature หลัก ได้แก่ Auth, Device Inventory, Config Generation, CIS Benchmark และ Settings

## ❌ Out of Scope (P1)
ฟีเจอร์ต่อไปนี้ถูกตัดออกหรือไม่รวมในระยะ MVP P1 เพื่อให้สอดคล้องกับข้อจำกัดด้านเวลา:
- **SIEM Integration:** ไม่มีการส่งต่อ Log ไปยังระบบ SIEM (เช่น Splunk, ELK) แบบ Real-time
- **WORM Storage / Cryptographic Tamper-Proof:** ไม่มีการเข้ารหัสระดับ Block หรือใช้ระบบฐานข้อมูลแบบ Write-Once-Read-Many
- **Advanced Export:** ไม่มีการ Export รายงานเป็น PDF/CSV แบบซับซ้อน
- **Alerting Engine:** ไม่มีระบบแจ้งเตือนอัตโนมัติเมื่อเกิด Log น่าสงสัย (เช่น ล็อกอินผิด 10 ครั้งแจ้งเตือน)
- **Automated Retention:** ไม่มีระบบลบ Log เก่าทิ้งอัตโนมัติที่ซับซ้อน (ให้เก็บสะสมไปก่อนใน P1)
- **Field-level Audit Permission:** ไม่มีการแยกสิทธิ์การดู Log ย่อยระดับฟิลด์
