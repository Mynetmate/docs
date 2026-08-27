# คำศัพท์และแนวคิดสำคัญ (Glossary) สำหรับ Audit Trail

เอกสารนี้รวบรวมคำศัพท์และแนวคิดที่เกี่ยวข้องกับระบบ Audit Trail ของโปรเจกต์ MyNetMate เพื่อให้ทุก Feature สื่อสารตรงกัน

| คำศัพท์ / แนวคิด | คำอธิบาย |
| :--- | :--- |
| **Action (Canonical Name)** | ชื่อเหตุการณ์มาตรฐานในรูปแบบ `resource.action` เช่น `device.create`, `user.login_success` ใช้เพื่อให้ระบบสามารถค้นหาและจัดกลุ่มได้ง่าย |
| **Resource Type** | ประเภทของข้อมูลหรือระบบที่ถูกกระทำ เช่น `user`, `device`, `config`, `scan`, `settings`, `auth` |
| **Result** | ผลลัพธ์ของการกระทำ มีเพียง 2 ค่าคือ `success` (สำเร็จ) และ `failure` (ล้มเหลว) |
| **Safe Error Category** | หมวดหมู่ความผิดพลาดที่ผ่านการคัดกรองแล้วว่าปลอดภัย ไม่มีข้อมูลความลับหรือ PII เช่น `authentication_error`, `validation_error`, `server_error` |
| **Redaction (การปกปิดข้อมูล)** | กระบวนการคัดกรองและลบข้อมูลที่เป็นความลับ (Secrets, Passwords, Tokens) หรือ PII ที่ไม่จำเป็นออกจาก `description` ก่อนที่จะบันทึกลงฐานข้อมูล |
| **Append-Only Policy** | นโยบายการเขียนข้อมูลลง Audit Log ที่อนุญาตให้ **เพิ่ม (Insert) ข้อมูลใหม่เท่านั้น** ห้ามมี API หรือฟังก์ชันสำหรับแก้ไข (Update) หรือลบ (Delete) ข้อมูลในตาราง `audit_logs` โดยเด็ดขาด เพื่อรักษาความน่าเชื่อถือของประวัติ |
| **Transaction Boundary** | ขอบเขตของการทำงานร่วมกับฐานข้อมูล การบันทึก Audit Log ต้องอยู่ใน Database Transaction เดียวกันกับ Business Action หลักเสมอ (หาก Action หลัก Rollback, Audit Log ต้องไม่ถูกบันทึกเพื่อป้องกัน False Positive, ยกเว้นกรณีบันทึกความล้มเหลวเฉพาะเจาะจง) |
| **Nullability ของ Actor** | `user_id` ของผู้กระทำสามารถเป็น `NULL` ได้ในกรณีที่เป็น Anonymous Action (เช่น การล็อกอินล้มเหลวของ User ที่ไม่มีในระบบ) หรือ System Cron |
