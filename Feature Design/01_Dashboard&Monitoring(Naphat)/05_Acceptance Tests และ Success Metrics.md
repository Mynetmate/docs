### Acceptance Tests

| Test ID | Scenario | Expected Result |
|---|---|---|
| **AT-01** | มีอุปกรณ์ 10 รายการ: Online 8, Offline 2 | `/api/dashboard/summary` คืน Total 10, Online 8, Offline 2 ตรงกับฐานข้อมูล |
| **AT-02** | ผู้ใช้คลิก Critical Validation Failure | ระบบไปหน้า Security Validation พร้อม Pre-filter อุปกรณ์หรือผลสแกนที่เกี่ยวข้อง |
| **AT-03** | เปิด Offline Mode | AI indicator แสดงสถานะ Informational/สีเทา ไม่แสดง Critical error |
| **AT-04** | ข้อมูล Device เกิน Freshness threshold | UI แสดง Stale state และเวลาตรวจล่าสุด |
| **AT-05** | Viewer เปิด Dashboard | Viewer อ่านข้อมูลได้ แต่ Action ที่แก้ไขหรือ Override ถูกซ่อน/ปฏิเสธ |

### Success Metrics

- `GET /api/dashboard/summary` กับข้อมูลจำลอง 1,000 อุปกรณ์ ควรตอบภายใน 1.0 วินาทีตามเป้าหมายเบื้องต้นของรายงาน
- Dashboard API ต้องไม่เรียก Gemini เพื่อคำนวณ Metric
- ค่าบน Dashboard ต้องตรงกับ Source of Truth
- Error และ Stale data ต้องไม่ถูกแสดงเป็นข้อมูลปัจจุบันโดยไม่มีคำเตือน

> ตัวเลข Performance เป็นเป้าหมายสำหรับทดสอบ ไม่ใช่ข้อเท็จจริงที่ยืนยันแล้ว ต้องวัดบนสภาพแวดล้อมของโครงการ

