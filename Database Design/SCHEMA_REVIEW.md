# เหตุผลการปรับ Inventory / Discovery

2026-09-13 — schema design revision ไม่ใช่การเปลี่ยน Backend

ปัญหาหลักคือสอง module CREATE TABLE ชื่อเดียวกันแต่คอลัมน์/enum/default ไม่ตรงกัน และ IF NOT EXISTS ทำให้ผลขึ้นกับลำดับรัน
อีกส่วนคือ status ปนผลเชื่อมต่อกับนโยบายผู้ใช้ และไม่มีหลักฐานรายรอบเชื่อมกลับจาก link

| เดิม | แบบใหม่ | เหตุผล / ข้อควรทำตอน migrate |
|---|---|---|
| devices/interfaces สองชุด | Inventory นิยามเดียว | Merge record/UUID เดิมก่อนย้ายจริง |
| is_managed + enrollment_status | Device เฉพาะที่ยืนยัน; management_state | Pending/failed อยู่ runs; unmanaged เก่าต้องแยกตรวจ |
| status | reachability + management_state | Timeout ไม่พิสูจน์ offline; maintenance เป็นนโยบาย |
| device_enrollment_attempts | collection_runs + purpose | ใช้ประวัติการเก็บข้อมูลร่วมกัน; collected_* snapshot เก่าต้อง archive |
| chassis_mac + chassis_id | chassis_id + subtype | ถ้า chassis_mac เก่าเป็น base MAC คนละความหมายต้อง archive ไม่เดาว่าเป็น LLDP |
| discovery_method | enrollment_source | ทางเข้าครั้งแรก ไม่ใช่การตรวจล่าสุด |
| last_discovered_at | query collection_runs | ลด cache ที่ซ้ำกับผลเก็บข้อมูล |
| last_seen_at / last_collected_at | คงทั้งคู่ + reachability_checked_at | ตอบ probe ได้ไม่เท่ากับอ่าน inventory สำเร็จ |
| uptime_seconds | คงพร้อม uptime_observed_at | มี consumer ในโค้ดจริง แต่ต้องรู้เวลา snapshot |
| credential_type + SSH/SNMP ในแถวเดียว | profile เป็น credential bundle | สอดคล้องกับการใช้ร่วมกันจริง |
| snmp_community_rw_encrypted | พักจาก read-only MVP | ค่าเก่าต้องเก็บตาม secret retention policy ไม่ทิ้งทันที |
| domain_name, management_vlan, default_gateway | พักจาก Inventory MVP | ยังไม่มี collector/consumer contract ชัดใน scope นี้; default route ไม่พิสูจน์ physical link |
| ip_address + subnet_mask | interface_ip_addresses.address พร้อม prefix | ไม่ซ้ำ mask และรองรับหลาย IP |
| vlan_id | access_vlan_id | ไม่สื่อว่า integer เดียวอธิบาย trunk VLAN ได้ |
| default switch/access/cisco_ios/online/Up | unknown หรือ NULL | ไม่สร้างข้อเท็จจริงจาก default |
| admin_status / oper_status | คงแยก | การตั้งค่ากับสภาพจริงต่างกัน |
| vendor/platform/device_type/role | คงแยก | ผู้ผลิต/driver/ชนิด/หน้าที่ต่างกัน |
| duration_ms, devices_count, links_count | query เวลา/runs; link ให้ NTV | ลดค่าซ้ำที่ไม่รู้วิธี sync |
| topology_links ใน Discovery | neighbor_observations | หลักฐานกับข้อสรุปต่างกัน; link เก่าไม่มี evidence ห้ามปลอมย้อนเป็น LLDP |
| CDP/default_route/manual | LLDP ใน Observation | ตาม baseline ปัจจุบัน; archive ข้อมูลเดิมตามแหล่งจริง |
| enum ซ้ำข้าม module | CHECK ในเจ้าของตาราง | ไม่ประกาศ type ชื่อเดียวกันหลายแบบ |
| unique index ซ้ำ UNIQUE/PK | ตัด index ซ้ำ | เหลือ FK/query indexes ที่ต้องใช้ |

## ความซ้ำที่ต้องเก็บ

- Inventory คือปัจจุบัน ส่วน Observation/Collection คืออดีต IP/identity จึงคล้ายกันแต่ห้ามแก้ตามกัน
- local_device_id ใน Observation ใช้ composite FK ป้องกันอ้างพอร์ตคนละเครื่องกับ run
- devices.last_collected_at เป็น cache ต้อง update ใน transaction ผล collection สำเร็จ; failed ห้ามเลื่อนเวลา
- created_at/updated_at/collected_at คนละความหมาย แก้ notes ไม่ใช่เก็บข้อมูลใหม่

## สมมติฐาน / ข้อจำกัด

- หนึ่ง isolated lab ไม่มี management IP ซ้ำข้าม VRF/tenant
- การยังไม่มี consumer ใน scope ที่อ่านไม่ได้พิสูจน์ว่า feature อื่นไม่ใช้ จึงพัก field และไม่เปลี่ยน Backend รอบนี้
- Collector ต้องคืน observation row key และ LLDP subtype; ถ้า oxian_py คืนแค่ graph ต้องเพิ่ม adapter ห้ามสร้าง raw evidence ย้อนจาก resolved link
- actor UUID ยังไม่มี FK จนรวม Auth; encryption, status transition, updated_at และ immutable observation ต้องบังคับใน implementation
- Local endpoint ที่ resolve ไม่ได้ให้ partial พร้อม diagnostics ไม่ทิ้งข้อผิดพลาดและไม่สร้าง verified link
- NTV interfaces ในเอกสาร map เป็น device_interfaces; ไม่สร้าง layout/current link/reconciliation/future override ในรอบนี้

## ย้ายฐานจริงในงานถัดไป

สำรอง → เพิ่มตาราง/คอลัมน์ใหม่ → backfill ตามหลักฐาน → ตรวจ UUID/FK/จำนวน → ปรับ ORM/API/ingestion → ตรวจ lab → จึงเลิกใช้คอลัมน์เก่า
แถวที่ไม่รู้เวลา collection/subtype ให้เก็บ legacy รอ re-collect ไม่ตั้ง NOW/subtype เพื่อให้ผ่าน constraint
