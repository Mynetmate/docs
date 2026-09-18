# Device Inventory — เจ้าของข้อมูลอุปกรณ์กลาง

แบบปรับปรุง 2026-09-13; อ่าน [สถานะและวิธีใช้](../README.md) ก่อนรัน SQL

| ตาราง | หน้าที่ |
|---|---|
| credential_profiles | ชุด SSH password และ/หรือ SNMP v2c read-only ที่เข้ารหัส |
| sites | สถานที่ |
| device_groups / device_group_members | กลุ่มและสมาชิกแบบหลายต่อหลาย |
| devices | ตัวตนและข้อมูลล่าสุดของเครื่องที่ผ่าน collection/identity validation |
| device_interfaces | Interface ของ Device พร้อม UUID ถาวร |
| interface_ip_addresses | IP พร้อม prefix รองรับหลาย IP ต่อ Interface |

Discovery ใช้ตารางร่วมกันผ่าน Inventory service ไม่สร้างสำเนา
Device อาจยังไม่มี Interface ที่อ่านสำเร็จได้ ความสัมพันธ์จึงเป็น 1 → 0..N

## Device

- ใช้ id เชื่อมข้าม feature ไม่ใช้ IP/hostname เป็น FK เพราะเปลี่ยนได้
- management_ip unique ภายใน lab เดียว; ยังไม่รองรับ IP ซ้ำข้าม VRF/tenant
- hostname/vendor เป็น NULL ได้เมื่อ Collector ไม่คืนค่า ห้ามแต่งข้อมูลขึ้นเอง
- system_description มาจากเครื่อง ส่วน notes ผู้ใช้เขียน
- device_type คือชนิด; role คือหน้าที่; vendor คือผู้ผลิต; platform คือชื่อ driver จึงไม่ซ้ำกัน
- management_state: active / maintenance / retired เป็นนโยบายผู้ใช้
- reachability: unknown / reachable / unreachable เป็นผลตรวจ ไม่ตีความ timeout ว่าเครื่องปิด
- last_seen_at: เวลาตอบสนองสำเร็จล่าสุด; reachability_checked_at: เวลาตรวจล่าสุดทั้งสำเร็จ/ล้มเหลว
- last_collected_at: เวลาเก็บชุด Inventory สำเร็จล่าสุด ส่งเวลาจริง ไม่ default เป็นเวลา insert
- uptime_seconds คู่กับ uptime_observed_at เพราะเป็น snapshot
- enrollment_source: ทางเข้าครั้งแรก ไม่เปลี่ยนทุกครั้งที่สแกนซ้ำ
- created_at/updated_at เป็นเวลาของ record; service ตั้ง updated_at เมื่อแก้ไข ไม่ใช้แทนเวลา collection

เป้าหมายที่เชื่อมต่อไม่ผ่านหรือยังระบุตัวไม่ได้อยู่ collection_runs/neighbor_observations ไม่สร้าง Device ปลอม
NOT NULL timestamp ไม่ได้พิสูจน์ตัวตน ต้อง validate ใน service ก่อน insert
Device retire ต้องประสาน service ให้หยุด collection และคงประวัติ ไม่มีผลแก้ configuration เครื่องจริง

## Credential

หนึ่ง profile เป็นชุด credential ของอุปกรณ์ **ใช้ SSH + SNMP ร่วมกันได้** จึงเอา credential_type ที่ขัดกับ bundle ออก
MVP นี้รองรับ SSH password และ SNMP v2c read-only; SSH key/SNMPv3/API token ต้องเพิ่มแบบเมื่อมี implementation
username/password ต้องเป็นคู่ และ profile ต้องมีอย่างน้อยหนึ่งวิธีเชื่อมต่อ
ไม่มี SNMP write community; คอลัมน์ชื่อ encrypted ไม่ได้เข้ารหัสเอง ต้องทำจริงใน service
FK ห้ามลบ credential ที่มีประวัติอ้าง; rotation/retention ต้องกำหนดเพิ่มก่อน production

## Interface / LLDP

- if_index NULL ได้สำหรับ SSH ที่ไม่คืนค่า ห้ามสร้างเลขแทนเอง
- Normalize ชื่อให้ consistent; current name/current ifIndex ไม่ซ้ำใน Device
- ifIndex ถูกเปลี่ยนหรือใช้ซ้ำได้ ไม่ใช่ตัวตนถาวร: reconcile ก่อน update; replacement retire แถวเก่าและสร้าง UUID ใหม่
- retired_at เก็บ FK หลักฐานเก่าได้ พร้อมยอมรับ ifIndex/name ที่ใช้อีกครั้ง
- admin_status เป็นการตั้งค่า ส่วน oper_status เป็นสภาพจริง; default unknown ทั้งคู่
- access_vlan_id ใช้กับ access port; trunk VLAN list/native VLAN ยังไม่อยู่ในแบบนี้
- interface_ip_addresses.address เช่น 192.168.10.1/24 เก็บ prefix ครั้งเดียว ไม่ต้อง subnet_mask
- chassis_id ต้องคู่ subtype ไม่ถือว่า chassis ID ทุกค่าคือ MAC
- ข้อมูล interface และ IP เป็น snapshot ล่าสุด; collected_at ใช้บอก freshness, failed run ห้ามล้างข้อมูลเก่า

sql/05_device_enrollment_attempts.sql เหลือ reference แจ้งย้ายประวัติไป collection_runs ของ Discovery/Collection
