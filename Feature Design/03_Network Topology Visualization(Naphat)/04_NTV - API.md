# Candidate API สำหรับ NTV MVP แบบ Visualization-only

> [!WARNING]
> Endpoint ในไฟล์นี้ยังเป็น **Candidate Contract** ไม่ใช่ Final API และไม่ใช่คำยืนยันว่า NTV จะถูกพัฒนาในเทอมนี้ Endpoint Enrollment และ Collection เป็นของ Feature เจ้าของข้อมูลเดิม ส่วน NTV เป็นผู้เรียกใช้ตาม Contract เท่านั้น

> Link จาก LLDP แสดงอัตโนมัติโดยไม่ต้องเรียก Confirm API ระบบคำนวณ `one_sided`, `corroborated`, `unresolved`, `conflict` และ `stale` จาก Observation ที่มี ผู้ใช้ไม่สามารถสร้างหรือแก้ Link ด้วยมือใน MVP

## API ใน MVP

| API | หน้าที่ |
|---|---|
| `GET /topologies/{topology_id}` | โหลด Managed Node, Current Link, Evidence Assessment, Warning, Layout และ Freshness |
| `GET /topologies/{topology_id}/warnings` | โหลด Unresolved Neighbor, Conflict และ Stale Link สำหรับแสดง Pending/Warning List |
| `POST /devices/enroll` | ระบุ Known Device และ Credential Profile เพื่อเริ่ม Read-only Collection; อยู่ในขอบเขต Inventory |
| `POST /devices/{device_id}/collections` | สั่ง Re-collect แบบ Read-only |
| `GET /device-collections/{collection_id}` | อ่านสถานะและผลของ Collection Job |
| `PATCH /topologies/{topology_id}/nodes/{device_id}/position` | แก้เฉพาะตำแหน่ง Node บน Shared View |

## API ที่ไม่มีใน MVP

- ไม่มี `confirm` หรือ `reject` สำหรับ LLDP Link
- ไม่มี `POST/PATCH/DELETE /topologies/{id}/links` สำหรับสร้างหรือแก้ Link ด้วยมือ
- ไม่มี API แก้ Source/Destination Endpoint ของ Raw Observation
- ไม่มี `Report Incorrect` หรือ `Resolve Conflict` Workflow
- ไม่มี Create/Verify/Reject/Archive Manual Override

เมื่อข้อมูลไม่ครบหรือขัดกัน MVP จะแสดง Warning และให้ผู้ใช้ตรวจอุปกรณ์/สายจริงหรือสั่ง Re-collect เท่านั้น

## Future Enhancement API

Endpoint ต่อไปนี้เป็นเพียง Candidate หากทีมอนุมัติ Manual Override หลัง MVP:

- `POST /topology-link-overrides`
- `POST /topology-link-overrides/{override_id}/verify`
- `POST /topology-link-overrides/{override_id}/reject`
- `POST /topology-link-overrides/{override_id}/archive`
- `POST /topology-link-observations/{observation_id}/incorrect-reports`
- `POST /topology-link-conflicts/{conflict_id}/resolve`

ห้ามนำ Candidate เหล่านี้ไปนับเป็น MVP Acceptance Criteria หรือ Implementation Task จนกว่าจะมีมติเปิด Future Scope
