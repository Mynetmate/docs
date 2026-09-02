# 🗄️ MyNetMate Database Design

โฟลเดอร์นี้เก็บ **Database Schemas (SQL DDL / DBML / ERD Documentation)** ของระบบ MyNetMate ทั้งหมด โดยแบ่งตามแต่ละ Feature Module:

## 📁 โครงสร้างโฟลเดอร์ตาม Feature

```text
Database Design/
├── 00_Authentication/
├── 01_Dashboard&Monitoring/
├── 02_Device Inventory Management/
│   ├── README.md
│   ├── device_inventory.dbml
│   ├── device_inventory.sql
│   └── sql/
│       ├── 00_enums.sql
│       ├── 01_credentials.sql
│       ├── 02_sites_and_groups.sql
│       ├── 03_devices.sql
│       ├── 04_device_interfaces.sql
│       ├── 05_device_enrollment_attempts.sql
│       └── 99_seed_data.sql
├── 03_Network Topology Visualization/
├── 04_Network Discovery/
│   ├── README.md
│   ├── network_discovery.dbml
│   └── sql/
│       ├── 00_enums.sql
│       ├── 01_devices.sql
│       ├── 02_device_interfaces.sql
│       ├── 03_topology_links.sql
│       ├── 04_discovery_scans.sql
│       └── 99_seed_data.sql
├── 05_Configuration Management/
├── 07_AI Component/
├── 09_Security & Validation/
├── 10_Configuration Deployment/
└── 11_Audit Trail/
```

## 🔗 ความสัมพันธ์กับ Feature Design
โครงสร้างโฟลเดอร์ของ Database Design จะสอดคล้องกับ [Feature Design/](../Feature%20Design/) ของโปรเจกต์โดยตรง
