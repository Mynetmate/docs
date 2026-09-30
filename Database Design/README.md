# MyNetMate Database Design

โฟลเดอร์นี้เก็บ Database Markup Language (DBML) สำหรับดูโครงสร้างฐานข้อมูลผ่าน dbdiagram หรือ DBML-compatible viewer เท่านั้น ไม่มี SQL DDL หรือ seed data อยู่ในชุดเอกสารนี้

Schema ที่ใช้งานจริงอยู่ใน backend migrations และ SQLAlchemy table definitions. เมื่อ schema เปลี่ยน ต้องปรับ DBML ที่เกี่ยวข้องในโฟลเดอร์นี้ให้ตรงกันใน change เดียวกัน

คำอธิบายราย field อยู่ใน README ของ feature ที่เป็นเจ้าของตาราง เพื่อไม่ให้คำอธิบายของตาราง shared ซ้ำกันหลายจุด

## Diagrams

- [02 Device Inventory Management](./02_Device%20Inventory%20Management/device_inventory.dbml) — inventory, credentials, sites, groups, interfaces และ config versions
- [04 Network Discovery](./04_Network%20Discovery/network_discovery.dbml) — scan history, collection runs, LLDP observations และ default-route topology evidence

## Ownership

`02_Device Inventory Management` เป็นเจ้าของ persistent inventory: `devices`, `credential_profiles`, `device_interfaces` และตารางที่เกี่ยวข้อง

`04_Network Discovery` เป็นเจ้าของข้อมูล discovery history. Diagram นี้ขยายตาราง inventory ที่ discovery อ้างอิงเพื่อให้เห็นความสัมพันธ์ครบเมื่อเปิดไฟล์เดียว
