# MyNetMate — Inventory และ Discovery schema design

ปรับแบบวันที่ 2026-09-13 ตามขอบเขต Inventory → Discovery/Collection → NTV

**สถานะ: แบบเสนอสำหรับฐานข้อมูลใหม่ ยังไม่ใช่ migration และยังไม่ตรงกับ ORM/API ปัจจุบัน**
อย่ารัน SQL นี้ทับฐานข้อมูลเดิม การปรับ Backend และย้ายข้อมูลต้องทำเป็นงานถัดไป

## เจ้าของข้อมูล

| ข้อมูล | เจ้าของ | ฟีเจอร์อื่นใช้ผ่าน |
|---|---|---|
| Device, Interface, IP ของ Interface | [Inventory](<02_Device Inventory Management/README.md>) | UUID/FK และ Inventory service |
| Site, Group, Credential Profile | Inventory | Reference; Secret ให้เฉพาะ service เชื่อมต่ออุปกรณ์ |
| งานสแกน, ผลเก็บข้อมูลรายเครื่อง, หลักฐาน LLDP | [Discovery/Collection](<04_Network Discovery/README.md>) | collection_runs / neighbor_observations |
| Link ที่จับคู่แล้ว, Evidence Assessment, Layout | NTV ตามเอกสารฟีเจอร์ | อ่าน Inventory/Collection; ไม่รวม NTV DDL ในรอบนี้ |
| Users / Permissions / Audit | Auth / Audit | UUID ผู้กระทำและ service contract |

มี devices และ device_interfaces **อย่างละตารางเดียวในฐานข้อมูลเดียวกัน** โฟลเดอร์แบ่งความรับผิดชอบ ไม่ใช่ฐานข้อมูลคนละชุด

## เปิดอ่าน / แก้แบบ

- [รายการฟิลด์และเหตุผลที่เปลี่ยน](SCHEMA_REVIEW.md)
- [ERD รวม DBML](mynetmate.dbml) เปิดได้โดยไม่ต้องประกอบตารางเอง
- [Inventory SQL](<02_Device Inventory Management/device_inventory.sql>)
- [Discovery SQL](<04_Network Discovery/network_discovery.sql>) อ้าง Inventory โดยตรง
- [rebuild_design.py](rebuild_design.py) เป็นนิยามต้นทางสำหรับสร้าง SQL/DBML ให้ตรงกัน

หลังแก้นิยาม รัน python "docs/Database Design/rebuild_design.py" จาก repository root
SQL แสดง CHECK, FK, delete policy และ partial unique index ครบกว่า DBML ซึ่งใช้สื่อสารภาพรวม
Seed และ README แก้แยกจากตัวสร้าง

## ลำดับทดลองบนฐานข้อมูลใหม่

1. 02_Device Inventory Management/device_inventory.sql
2. 04_Network Discovery/network_discovery.sql
3. 02_Device Inventory Management/sql/99_seed_data.sql
4. 04_Network Discovery/sql/99_seed_data.sql

เลือก master SQL **หรือ** SQL แยกไฟล์เท่านั้น ไม่รันทั้งสองแบบ
ใช้ CREATE TABLE โดยไม่กลบข้อผิดพลาดด้วย IF NOT EXISTS เพื่อไม่ให้เข้าใจผิดว่าฐานเดิมถูกปรับแล้ว
Seed เป็นข้อมูลจำลอง ไม่มี credential ใช้งานจริง ใช้กับฐานทดสอบใหม่เท่านั้น

## ก่อนใช้งานจริง

ต้องทำ migration พร้อม mapping ข้อมูลเดิม, ปรับ ORM/API/ingestion, เชื่อม actor UUID กับ Auth และตรวจรับบน lab จริง
actor UUID เป็น logical reference ยังไม่มี FK ไป users เพราะ DDL นี้ไม่ได้สร้าง Auth
Service ต้องบังคับ allowlist, identity validation, encryption, status transition, updated_at และ transaction
Observation ต้อง append-only ผ่าน DB permissions/application contract; DDL นี้ยังไม่ได้สร้าง application role หรือ trigger

## ผลตรวจแบบ (2026-09-13)

- SQL รวมทั้งสอง module และ seed โหลดผ่านใน PGlite (embedded PostgreSQL) รวม 10 ตาราง
- ผ่าน 21 behavioral checks เช่น IP ซ้ำ, credential ว่าง, composite FK ผิดเครื่อง, duplicate observation, เวลาไม่ถูกต้อง, การรักษาประวัติ และการใช้ ifIndex ซ้ำหลัง retire
- DBML รวมและการต่อ Inventory + Discovery fragment parse ผ่าน
- ตรวจ diff ผ่านตาม line ending configuration ของ repository
- ยังไม่ได้รันกับ PostgreSQL server ของโปรเจกต์ (Docker daemon ไม่ได้เปิด) และไม่ได้ทดสอบ migration หรือ Backend integration

ตรวจซ้ำด้วย [verify_schema.cjs](verify_schema.cjs) ซึ่งสร้างฐานในหน่วยความจำ ไม่เชื่อมต่อฐานจริง:

~~~powershell
$schemaValidationDir = Join-Path $env:TEMP 'mynetmate-schema-validation'
npm install --prefix $schemaValidationDir --no-audit --no-fund @electric-sql/pglite @dbml/core
node "docs/Database Design/verify_schema.cjs" $schemaValidationDir
~~~
