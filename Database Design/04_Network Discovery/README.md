# Network Discovery

[`network_discovery.dbml`](./network_discovery.dbml) คือ diagram ของข้อมูล Network Discovery

## Tables owned by Discovery

- `discovery_scans` — คำขอและสถานะของ network scan
- `collection_runs` — การ collect แต่ละ target ใน scan หรือการ collect โดยตรง
- `neighbor_observations` — LLDP observations ต่อ collection run และ local interface
- `topology_default_routes` — default-route evidence สำหรับ topology; gateway ไม่ถูกสร้างเป็น inventory device

Diagram นี้ขยาย `devices`, `credential_profiles` และ `device_interfaces` จาก Device Inventory เพื่อให้เห็น foreign-key relationships ครบเมื่อเปิดเพียงไฟล์นี้ ตารางเหล่านั้นยังมี owner คือ [Device Inventory Management](../02_Device%20Inventory%20Management/README.md)

ไฟล์ DBML มีไว้เพื่อแสดง design; validation constraints และ partial indexes ที่บังคับใช้จริงอยู่ใน backend schema/migrations.

คำอธิบาย field ของ `devices`, `credential_profiles` และ `device_interfaces` ดูที่ [Device Inventory Data Dictionary](../02_Device%20Inventory%20Management/README.md#data-dictionary) เพราะเป็น shared tables ที่มี owner เดียว

## Data Dictionary

### `discovery_scans`

| Field | Description |
| --- | --- |
| `id` | Primary key ของ scan |
| `seed_ip` | IP เริ่มต้นของการค้นหา |
| `credential_profile_id` | Credential ที่ใช้กับ scan |
| `status` | สถานะ scan: queued, running, succeeded, partial, failed หรือ cancelled |
| `timeout_seconds` | timeout ต่อการติดต่อ target |
| `max_depth` | จำนวน hop สูงสุดในการตาม topology |
| `max_devices` | จำนวนอุปกรณ์สูงสุดที่อนุญาตให้พบ |
| `environment` | สภาพแวดล้อม: physical หรือ emulated |
| `initiated_by` | ID ของผู้เริ่ม scan |
| `error_message` | รายละเอียดข้อผิดพลาด ถ้ามี |
| `requested_at`, `started_at`, `finished_at` | เวลาที่ขอ เริ่ม และสิ้นสุด scan |

### `collection_runs`

| Field | Description |
| --- | --- |
| `id` | Primary key ของ collection run |
| `discovery_scan_id` | Scan ต้นทาง; มีเฉพาะ run ที่มาจาก discovery |
| `device_id` | Inventory device ที่ผูกกับผลลัพธ์ เมื่อ resolve ได้ |
| `target_ip` | IP ที่ collector ติดต่อในรอบนั้น |
| `credential_profile_id` | Credential ที่ใช้ collect |
| `purpose` | เหตุผลของ run: enrollment, import, discovery หรือ recollect |
| `transport` | Protocol ที่ใช้: SNMP หรือ SSH |
| `environment` | สภาพแวดล้อม: physical หรือ emulated |
| `status` | สถานะ collection run |
| `neighbor_status` | ผลการเก็บ neighbor information |
| `initiated_by` | ID ของผู้เริ่ม run |
| `error_message` | รายละเอียดข้อผิดพลาด ถ้ามี |
| `requested_at`, `started_at`, `finished_at` | เวลาที่ขอ เริ่ม และสิ้นสุด run |

### `neighbor_observations`

| Field | Description |
| --- | --- |
| `id` | Primary key ของ observation |
| `collection_run_id` | Collection run ที่ให้ข้อมูล LLDP นี้ |
| `local_device_id` | Device ฝั่ง local ที่พบ neighbor |
| `local_interface_id` | Interface ฝั่ง local ที่พบ neighbor |
| `observation_key` | Key ที่ไม่ซ้ำต่อ collection run สำหรับ deduplicate observation |
| `protocol` | Protocol ของ observation; ปัจจุบันคือ LLDP |
| `remote_chassis_id_subtype`, `remote_chassis_id` | ประเภทและค่า LLDP chassis identifier ของ neighbor |
| `remote_port_id_subtype`, `remote_port_id` | ประเภทและค่า LLDP port identifier ของ neighbor |
| `remote_system_name` | ชื่อระบบที่ neighbor ประกาศ |
| `remote_port_description` | คำอธิบาย port ที่ neighbor ประกาศ |
| `remote_management_ip` | Management IP ที่ neighbor ประกาศ; เป็น evidence ไม่ใช่ verified address |
| `observed_at` | เวลาที่พบ observation |

### `topology_default_routes`

| Field | Description |
| --- | --- |
| `source_device_id` | Device ที่รายงาน default route; เป็น primary key หนึ่ง route ต่อ device |
| `gateway_ip` | Next-hop gateway IP; ว่างได้สำหรับ route ที่อ้างอิง interface อย่างเดียว |
| `gateway_hostname` | ชื่อที่ใช้แสดง gateway; ค่าเริ่มต้น `Default Gateway` |
| `source_interface_name` | ชื่อ local interface ที่ route ออกไป |
| `observed_at` | เวลาที่พบ default route |
