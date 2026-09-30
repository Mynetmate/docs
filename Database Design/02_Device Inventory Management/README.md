# Device Inventory Management

[`device_inventory.dbml`](./device_inventory.dbml) คือ diagram ของ Device Inventory database design

## Tables

- `credential_profiles` — credentials ที่เข้ารหัสและพอร์ต SSH/SNMP
- `sites` และ `device_groups` — การจัดกลุ่มอุปกรณ์
- `devices` — device inventory; `management_ip` เป็น address ที่ยืนยันว่า collect ได้ ส่วน `advertised_management_ip` เป็นข้อมูลที่เพื่อนบ้านประกาศผ่าน LLDP
- `device_interfaces` และ `interface_ip_addresses` — interface และ IP addresses ของ interface
- `device_group_members` — many-to-many membership
- `config_versions` — configuration version history

`management_state = unmanaged` รองรับ neighbor ที่พบจาก LLDP แต่ยังไม่มี management address ที่ตรวจสอบได้

ไฟล์นี้ใช้เพื่อแสดงโครงสร้างเท่านั้น; constraints เช่น `CHECK` และ partial indexes ให้ดูจาก backend schema/migrations ซึ่งเป็นพฤติกรรมที่ใช้รันจริง

## Data Dictionary

### `credential_profiles`

| Field | Description |
| --- | --- |
| `id` | Primary key ของ credential profile |
| `name` | ชื่อ profile ที่ไม่ซ้ำกัน |
| `username` | Username สำหรับ login; ต้องมีคู่กับ `password_encrypted` |
| `password_encrypted` | Password ที่เข้ารหัสแล้ว |
| `enable_secret_encrypted` | Privileged/enable secret ที่เข้ารหัสแล้ว |
| `snmp_community_ro_encrypted` | SNMP read-only community ที่เข้ารหัสแล้ว |
| `ssh_port` | TCP port ของ SSH; ค่าเริ่มต้น 22 |
| `snmp_port` | UDP port ของ SNMP; ค่าเริ่มต้น 161 |
| `description` | คำอธิบายสำหรับผู้ดูแล |
| `created_by` | ID ของผู้ที่สร้าง profile |
| `created_at` / `updated_at` | เวลาสร้าง / เวลาแก้ไขล่าสุด |

### `sites` และ `device_groups`

| Table.Field | Description |
| --- | --- |
| `sites.id` | Primary key ของ site |
| `sites.name` | ชื่อ site ที่ไม่ซ้ำกัน |
| `sites.location_detail` | รายละเอียดตำแหน่ง เช่น อาคารหรือห้อง |
| `sites.description` | คำอธิบาย site |
| `sites.created_at` / `updated_at` | เวลาสร้าง / เวลาแก้ไขล่าสุด |
| `device_groups.id` | Primary key ของ device group |
| `device_groups.name` | ชื่อ group ที่ไม่ซ้ำกัน |
| `device_groups.color_tag` | สี hex สำหรับแสดงผลใน UI |
| `device_groups.description` | คำอธิบาย group |
| `device_groups.created_at` / `updated_at` | เวลาสร้าง / เวลาแก้ไขล่าสุด |

### `devices`

| Field | Description |
| --- | --- |
| `id` | Primary key ของ device |
| `management_ip` | IP ที่ยืนยันแล้วว่าใช้ collect device ได้; ว่างได้สำหรับ unmanaged neighbor |
| `advertised_management_ip` | IP ที่เพื่อนบ้านประกาศผ่าน LLDP; ยังไม่ถือว่ายืนยันว่า collect ได้ |
| `hostname` | Hostname ล่าสุดที่ collect ได้ |
| `device_type` | ประเภทอุปกรณ์ เช่น router, switch หรือ firewall |
| `role` | บทบาทในเครือข่าย เช่น core, distribution หรือ access |
| `vendor`, `model`, `os_version`, `serial_number` | ข้อมูล hardware และระบบปฏิบัติการของอุปกรณ์ |
| `chassis_id_subtype` | ประเภทของ LLDP chassis identifier |
| `chassis_id` | LLDP chassis identifier ที่ใช้ระบุตัวตนอุปกรณ์อย่างคงที่ |
| `site_id` | อ้างอิง site ที่อุปกรณ์ตั้งอยู่ |
| `credential_profile_id` | อ้างอิง credential profile สำหรับ collect |
| `platform` | ชื่อ platform/driver ที่ collector ใช้งาน |
| `management_state` | Lifecycle: `active`, `unmanaged`, `maintenance` หรือ `retired` |
| `reachability` | ผลการตรวจล่าสุด: `unknown`, `reachable` หรือ `unreachable` |
| `enrollment_source` | แหล่งที่สร้าง record: manual, discovery หรือ CSV import |
| `last_seen_at` | เวลาที่อุปกรณ์ถูกยืนยันว่า reachable ล่าสุด |
| `reachability_checked_at` | เวลาที่ตรวจ reachability ล่าสุด |
| `last_collected_at` | เวลาที่ collect inventory facts ล่าสุด |
| `notes` | หมายเหตุของผู้ดูแล |
| `created_by` | ID ของผู้สร้าง record |
| `created_at` / `updated_at` | เวลาสร้าง / เวลาแก้ไขล่าสุด |

### `device_group_members`

| Field | Description |
| --- | --- |
| `device_id` | อ้างอิง device ที่เป็นสมาชิก |
| `group_id` | อ้างอิง device group |
| `added_at` | เวลาที่เพิ่มสมาชิกเข้ากลุ่ม |

### `device_interfaces` และ `interface_ip_addresses`

| Table.Field | Description |
| --- | --- |
| `device_interfaces.id` | Primary key ของ interface |
| `device_interfaces.device_id` | อ้างอิง device เจ้าของ interface |
| `device_interfaces.if_index` | SNMP ifIndex; อาจไม่มีในบางแหล่งข้อมูล |
| `device_interfaces.name` | ชื่อ interface |
| `device_interfaces.mac_address` | MAC address ของ interface |
| `device_interfaces.description` | Interface description ที่อุปกรณ์รายงาน |
| `device_interfaces.mode` | Mode: access, trunk, routed, loopback, svi หรือ unknown |
| `device_interfaces.access_vlan_id` | Access VLAN; ใช้ได้เฉพาะ interface mode access |
| `device_interfaces.admin_status` | สถานะที่ configure ไว้ |
| `device_interfaces.oper_status` | สถานะการทำงานที่ตรวจพบ |
| `device_interfaces.speed_bps` | ความเร็ว interface หน่วย bit/s |
| `device_interfaces.collected_at` | เวลาที่ข้อมูล interface ถูก collect |
| `device_interfaces.retired_at` | เวลาที่ interface เก่าเลิกเป็น current record |
| `device_interfaces.updated_at` | เวลาแก้ไขล่าสุด |
| `interface_ip_addresses.interface_id` | อ้างอิง interface |
| `interface_ip_addresses.address` | IP address ที่ผูกกับ interface |

### `config_versions`

| Field | Description |
| --- | --- |
| `id` | Primary key ของ configuration version |
| `device_id` | อ้างอิง device เจ้าของ configuration |
| `version` | เลขลำดับ version |
| `content` | เนื้อหา configuration ที่บันทึก |
| `message` | ข้อความสรุป version |
| `created_at` | เวลาที่บันทึก version |
