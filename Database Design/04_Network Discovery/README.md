# Network Discovery / Collection — อ้าง Inventory

แบบปรับปรุง 2026-09-13; อ่าน [สถานะและวิธีใช้](../README.md)

| ตารางเจ้าของ | หนึ่งแถวหมายถึง |
|---|---|
| discovery_scans | งานค้นหาหนึ่งครั้งจาก seed IP พร้อมขีดจำกัด |
| collection_runs | ความพยายามเก็บข้อมูลหนึ่ง IP หนึ่งครั้ง รวม enrollment, CSV, discovery, recollect |
| neighbor_observations | หลักฐาน LLDP หนึ่งรายการที่ต้นทางรายงานในรอบนั้น |

devices, device_interfaces, credential_profiles อ้าง [Inventory](<../02_Device Inventory Management/README.md>) เท่านั้น
ไม่มี CREATE TABLE ข้อมูลร่วม และ Discovery seed ไม่สร้าง Device ซ้ำ

## Scan / Collection

- Scan เป็นงานทั้งเครือข่าย ส่วน Collection เป็นผลรายเครื่อง จึงแยกความล้มเหลวบางเครื่องได้
- purpose=discovery ต้องมี discovery_scan_id; enrollment/recollect ไม่สร้าง scan เปล่า
- target_ip คือเป้าหมาย ณ เวลารัน ต่างจาก IP ปัจจุบันใน devices และบันทึกได้แม้ยังไม่มี Device
- device_id NULL ได้ตอน queued/failed/cancelled; succeeded/partial ต้องมี Device ที่ยืนยันแล้ว
- status: queued → running → succeeded / partial / failed / cancelled; service บังคับ transition และห้ามเปิดงานที่ปิดแล้วกลับมาแก้
- requested_at คือรับงาน, started_at คือเริ่มทำ, finished_at คือจบ; duration คำนวณไม่เก็บซ้ำ
- neighbor_status=succeeded กับ 0 observations คืออ่านตารางสำเร็จแล้วว่าง ต่างจาก failed/unsupported/not_attempted
- อ่าน identity ได้แต่ neighbor ล้มเหลว: partial + neighbor_status=failed ห้ามถือว่า link หาย
- Scan credential เป็นค่าเริ่มต้น; Collection credential/transport เป็นสิ่งที่ใช้จริงกับเครื่องนั้น
- max_depth/max_devices ต้องกำหนดก่อน scan; service ตรวจ allowlist กลางกับทุก neighbor ที่จะตามต่อ
- environment เป็น physical/emulated ณ เวลารัน ไม่เดาจากชื่อเครื่อง
- devices_count คำนวณ COUNT(DISTINCT device_id); จำนวน attempts นับ runs; links_count เป็นข้อสรุป NTV ไม่เก็บใน Discovery

## หลักฐาน ไม่ใช่ข้อสรุป Link

SNMP คือวิธีอ่านข้อมูล; LLDP คือแหล่งหลักฐาน จึงมี transport กับ protocol คนละหน้าที่
CDP/default_route/manual ไม่ใช่ physical/L2 evidence ของ MVP นี้

Observation เก็บ raw remote identity แม้ยังไม่มี remote Device; ไม่สร้าง unmanaged Device ปลอม
NTV จับคู่ endpoint สร้าง current topology link/evidence เอง การ resolve ภายหลังห้ามแก้ observation เดิม

- observation_key คือ key แถวจาก collector ภายใน run เช่น canonical LLDP MIB row key ไม่ใช้คู่ Device เพื่อรักษา parallel links/หลาย neighbor ต่อพอร์ต
- ส่งผล run เดิมซ้ำต้องใช้ key เดิม; เก็บใหม่สร้าง run ใหม่
- local_device_id ซ้ำโดยตั้งใจสำหรับ composite FK พิสูจน์ว่า run และ local interface อยู่เครื่องเดียวกัน
- remote chassis/port ID คู่ subtype; hostname/management IP อาจไม่มี
- remote_management_ip คือ address จากหลักฐาน ไม่ใช่ IP ที่รับรองแล้ว; ถ้า collector คืนหลาย address ให้เพิ่ม child table ก่อน ingest ห้ามทิ้งเงียบ ๆ
- observed_at คือเวลาอ่าน ไม่ใช่เวลาที่เปลี่ยนสายจริง
- Observation append-only ตาม service/DB permission contract; DDL นี้ยังไม่สร้าง role/trigger บังคับ
- FK RESTRICT ป้องกันลบ Device/Interface/Scan แล้วหลักฐานหายตาม

## Ingestion transaction

1. สร้าง run แล้วเชื่อมต่อจริง
2. Identity ไม่ผ่าน: failed + error ที่กรอง secret; ไม่สร้าง Device
3. Identity ผ่าน: Inventory upsert Device/Interface และผูก run กับ Device
4. บันทึก Observation พร้อม stable key และ finalize run ใน transaction เดียวกับผล Inventory
5. Local interface จับคู่ไม่ได้: partial/error พร้อม diagnostics ที่กรอง secret ไม่สร้าง verified link
6. NTV อ่านเฉพาะงานปิดผลแล้ว และไม่แก้ raw data

## ไฟล์

- network_discovery.dbml เป็น fragment อ้าง Inventory; เปิด [DBML รวม](../mynetmate.dbml) เพื่อแสดงภาพทันที
- network_discovery.sql เรียง dependency แล้ว ใช้หลัง Inventory
- sql/01_devices.sql และ sql/02_device_interfaces.sql เหลือ reference
- sql/03_topology_links.sql คงชื่อเพื่อให้ตาม diff ได้ แต่สร้าง neighbor_observations
- รันไฟล์แยกตาม 00 → 01 → 02 → **04 → 05 → 03**
- NTV ใช้ชื่อ conceptual interfaces ในบางเอกสาร ให้ map เป็น device_interfaces กลาง ไม่สร้างอีกตาราง
- รอบนี้เตรียม contract ไม่ได้ยืนยัน scope NTV เต็มระบบ
