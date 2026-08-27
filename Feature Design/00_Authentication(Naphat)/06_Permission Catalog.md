# Permission Catalog - Authentication & RBAC

เอกสารนี้ระบุรายการ Permission Keys (Catalog) ที่ใช้สำหรับตรวจสอบสิทธิ์ในฟังก์ชัน `require_permission()` 

## Permission Keys

รายการด้านล่างนี้คือคีย์ที่ระบบ Backend จะใช้อ้างอิงเพื่อตรวจสอบสิทธิ์ (Fine-grained mapping จาก 3 Roles หลัก)

| Permission Key | คำอธิบาย | Role ที่มีสิทธิ์นี้ | Phase |
| :--- | :--- | :--- | :--- |
| `dashboard.read` | ดู Dashboard และ System Health ทั่วไป | Admin, Operator, Viewer | P1 |
| `activity.read_summary` | ดู Recent Activity แบบจำกัดเนื้อหาบน Dashboard **ข้อมูลที่ส่งกลับจะถูกจำกัดอย่างเข้มงวด:** <br>1. ห้ามแสดง IP Address, User-Agent, Error Detail, Secret, หรือ Full Audit Description แก่ทุก Role (ให้แสดงเฉพาะ Action, Username ของผู้กระทำ (หากเป็น null หรือ User ถูกลบหายไปจาก DB ให้แสดง `Unknown` ห้ามดึง identifier ดิบ), Resource Type/Name, Timestamp)<br>2. **Event Allowlist (สำหรับทุก Role):** เพื่อประสิทธิภาพและความเป็นมาตรฐาน หน้า Dashboard จะอนุญาตให้แสดงเฉพาะ **Positive Events 5 อย่าง ได้แก่ `user.login_success`, `user.logout`, `user.password_changed`, `user.created`, `user.updated`** เท่านั้น (รวมถึง Admin ก็จะเห็นแค่นี้บนหน้า Dashboard) ห้ามแสดงเหตุการณ์เชิงลบหรือ Security-sensitive (เช่น `user.login_failed`, `auth.permission_denied`, `user.deactivated`) เด็ดขาด โดยสงวนเหตุการณ์เหล่านี้ให้เข้าไปดูผ่านหน้า Full Audit Trail เท่านั้น | Admin, Operator, Viewer | P1 |
| `audit.read` | ดูข้อมูลประวัติการทำงานทั้งหมดในระบบ (Full Audit Trail) | Admin | P1 |
| `device.read` | ดูข้อมูลอุปกรณ์และสถานะ | Admin, Operator, Viewer | P1 |
| `device.manage` | เพิ่ม ลบ หรือแก้ไขข้อมูลอุปกรณ์ (Metadata/Enrollment) | Admin, Operator | P1 |
| `credential.use` | นำ Credential Profile ไปใช้กับอุปกรณ์ได้ (แต่ไม่เห็น Secret) | Admin, Operator | P1 |
| `credential.manage` | สร้าง Profile, อัปเดตข้อมูล, ตั้งรหัสผ่านอุปกรณ์ใหม่ (Overwrite) และลบ Profile ได้ **(ระบบจะไม่มี API คืนค่า Secret แบบ Plaintext กลับมาเด็ดขาด - Write-only)** | Admin | P1 |
| `config.read` | ดู Config Plan, Diff, และผล CIS Scan ที่สร้างขึ้นแล้ว **(สำหรับ Viewer ระบบ API ต้อง Redact ข้อมูล Secret ออกจาก Raw Config ก่อนเสมอ)** | Admin, Operator, Viewer | P1 |
| `config.generate` | สั่งสร้าง (Generate) Config, สแกน CIS และสร้าง Plan ใหม่ | Admin, Operator | P1 |
| `cis.scan` | สั่งรันการสแกนความปลอดภัย CIS Benchmark | Admin, Operator | P1 |
| `cis.override` | กดยอมรับการข้ามกฎ CIS พร้อมระบุเหตุผลได้ | Admin | P1 |
| `user.manage` | จัดการผู้ใช้งาน (เพิ่ม, ระงับบัญชี, เปลี่ยน Role) | Admin | P1 |
| `settings.manage` | ปรับตั้งค่าระบบ เปิด/ปิด กฎ CIS หรือโหมด Offline | Admin | P1 |
| `topology.read` | ดูหน้า Network Topology (NTV) | Admin, Operator, Viewer | **P2** |
| `topology.collect` | สั่ง Re-collect อุปกรณ์ หรือสแกน Topology ใหม่ | Admin, Operator | **P2** |
| `topology.layout` | บันทึกการจัดวาง Layout ที่ใช้ร่วมกัน (Shared Layout) | Admin, Operator | **P2** |
| `deploy.execute` | สั่ง Push Config ลงอุปกรณ์จริงผ่าน SSH (ต้องกดยืนยัน) | Admin, Operator | **P2** |

*(หมายเหตุ: Viewer จะมีสิทธิ์เฉพาะคีย์ที่ลงท้ายด้วย `.read` หรือ `read_summary` เท่านั้น)*
