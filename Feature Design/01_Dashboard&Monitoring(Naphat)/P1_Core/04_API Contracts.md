# API Contracts

| Endpoint                             | สิทธิ์                | Input                     | Output หลัก                                                    | Cache/Error behavior                                                              |
| ------------------------------------ | --------------------- | ------------------------- | -------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `GET /api/dashboard/summary`         | Viewer/Operator/Admin | `site_id` (optional)      | Device counts, Security summary, `last_checked_at`, `is_stale` | อาจ Cache ระยะสั้น เช่น 30 วินาที; หากใช้ค่าค้างต้องส่ง `is_stale: true`          |
| `GET /api/dashboard/recent-activity` | `activity.read_summary` | `limit` (Default 10, Max 50), `cursor` (สำหรับ Pagination) | รายการกิจกรรมล่าสุด **(กฎการทำงาน: 1. อ่านข้อมูลผ่าน SQLAlchemy ORM จากตาราง `audit_logs` โดยตรง 2. Query เฉพาะ Event ใน Positive Allowlist 3. เรียงลำดับ `ORDER BY created_at DESC, id DESC` (เพื่อเป็น Tie-breaker ป้องกันข้อมูลข้าม/ซ้ำ) 4. รองรับ Pagination โดย Response ต้องส่งกลับเป็น `{ data: [...], next_cursor: "<created_at>_<id>" }` 5. Redaction: หาก actor เป็น null หรือหาไม่พบ ให้ใช้ `actor_display_name: "Unknown"` ห้ามเผย identifier ดิบ, และห้ามแสดง IP, User-Agent, Error Detail, Secret, หรือ Full Audit Description)** | ไม่จำเป็นต้อง Cache หาก Index `created_at` และ `action` เหมาะสม |
| `GET /api/system/health`             | Viewer/Operator/Admin | ไม่มี                     | Backend, Database, AI mode/status                              | Dependency ภายนอกต้องมี Timeout และ Offline Mode ต้องไม่ถูกส่งเป็น Critical error |

### ตัวอย่าง Response: Dashboard Summary

```json
{
  "devices": {
    "total": 10,
    "online": 8,
    "offline": 1,
    "unknown": 0,
    "maintenance": 1
  },
  "security": {
    "critical_failures": 2
  },
  "last_checked_at": "2026-08-09T10:00:00+07:00",
  "is_stale": false
}
```
