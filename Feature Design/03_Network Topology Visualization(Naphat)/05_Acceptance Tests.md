# Acceptance Tests — NTV MVP แบบ Visualization-only

> [!NOTE]
> Test เหล่านี้เป็นเกณฑ์ยอมรับของ Candidate NTV MVP หากทีมอนุมัติให้พัฒนา ไม่ใช่หลักฐานว่า NTV ถูก Commit สำหรับเทอมนี้

## MVP Acceptance Tests

| Test ID | Acceptance Test | Priority |
|---|---|---|
| `AT-NTV-R01` | การกรอก IP อย่างเดียวโดยยังเชื่อมต่อหรือเก็บข้อมูลไม่สำเร็จต้องไม่สร้าง Verified Topology Node | Must |
| `AT-NTV-R02` | เมื่อ Manual Enrollment เชื่อมต่ออุปกรณ์สำเร็จ Node ต้องอ้าง `device_id` และข้อมูลที่ Collector เก็บจริง | Must |
| `AT-NTV-R03` | Discovery Candidate ที่ตอบ Ping แต่ Authentication/Collection ล้มเหลวต้องแสดงเป็น Candidate/Error ไม่ใช่ Managed Topology Node | Must |
| `AT-NTV-R04` | เมื่อมี LLDP Observation ที่ Resolve Endpoint ได้ ระบบต้องแสดง Link อัตโนมัติโดยไม่รอ Confirm พร้อม Source, Port, Collection Run และเวลาตรวจล่าสุด | Must |
| `AT-NTV-R05` | การลาก Node แล้ว Reload ต้องคงตำแหน่งเดิมและต้องไม่เปลี่ยน Device, Interface, Observation หรือ Current Link | Must |
| `AT-NTV-R06` | Raw Observation ต้องแก้ Endpoint ไม่ได้ และ NTV MVP ต้องไม่มี API สำหรับสร้างหรือแก้ Link ด้วยมือ | Must |
| `AT-NTV-R07` | หากอุปกรณ์ไม่ให้ LLDP Data ระบบต้องแสดง Collection/Parser Status หรือ Empty State โดยไม่สร้าง Link สมมติ | Must |
| `AT-NTV-R08` | การเปลี่ยนสายจริงและ Re-collect ต้องทำให้ Link ใหม่ปรากฏ และ Link เดิมเป็น Stale/Conflict ตาม Policy โดยยังตรวจหลักฐานย้อนหลังได้ | Must |
| `AT-NTV-R09` | One-sided Observation ที่ Resolve Endpoint ได้ต้องแสดงเป็น Link พร้อมป้าย One-sided โดยไม่สร้าง Review หรือรอผู้ใช้ยืนยัน | Must |
| `AT-NTV-R10` | เมื่ออุปกรณ์ทั้งสองฝั่งรายงาน Endpoint คู่เดียวกัน ระบบต้องรวมเป็น Link เดียวและแสดง Corroborated โดยไม่ให้ผู้ใช้ Confirm | Must |
| `AT-NTV-R11` | Observation ที่จับคู่ Remote Device/Interface ไม่ได้ต้องอยู่ใน Pending/Warning List และห้ามสร้าง Verified Node สมมติ | Must |
| `AT-NTV-R12` | Viewer ดู Topology, Evidence Assessment และ Warning ได้ แต่สั่ง Re-collect หรือเปลี่ยน Shared Layout ไม่ได้ | Must |
| `AT-NTV-R13` | Collection/Discovery นอก Allowlist ของ Isolated Lab ต้องถูกปฏิเสธและบันทึก Audit | Must |
| `AT-NTV-R14` | เมื่อ Observation ใหม่ขัดกับ Current Link ระบบต้องแสดง Conflict Warning และไม่เขียนทับ Raw Evidence แบบเงียบ ๆ | Must |
| `AT-NTV-R15` | หน้า NTV MVP ต้องไม่มีคำสั่ง Confirm/Reject Link, Manual Override, Report Incorrect หรือ Resolve Conflict | Must |

## Future Enhancement Acceptance Tests

รายการต่อไปนี้ยังไม่ใช่เกณฑ์ส่งมอบ MVP:

| Future Test ID | Acceptance Test | สถานะ |
|---|---|---|
| `AT-NTV-F01` | Manual Override เลือกได้เฉพาะ Interface ที่เก็บจากอุปกรณ์จริง | Future |
| `AT-NTV-F02` | Manual Override ต้องมีเหตุผล หลักฐาน ผู้สร้าง เวลา Lifecycle และ Audit Log | Future |
| `AT-NTV-F03` | Verify/Reject Override ต้องผ่าน RBAC และนโยบายผู้ตรวจ | Future |
| `AT-NTV-F04` | Observation ใหม่ที่ขัดกับ Override ต้องไม่เขียนทับหลักฐานฝ่ายใดอัตโนมัติ | Future |
