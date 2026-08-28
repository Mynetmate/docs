# 🗄️ MyNetMate Database Design

โฟลเดอร์นี้เก็บ **Database Schemas (SQL DDL / DBML / ERD Documentation)** ของระบบ MyNetMate ทั้งหมด โดยแบ่งตามแต่ละ Feature Module:

## 📁 โครงสร้างโฟลเดอร์ตาม Feature

```text
Database Design/
├── 00_Authentication/
├── 01_Dashboard&Monitoring/
├── 02_Device Inventory Management/
│   ├── device_inventory.sql
│   ├── device_inventory.dbml
│   └── README.md
├── 03_Network Topology Visualization/
├── 04_Network Discovery/
│   ├── network_discovery.sql
│   ├── network_discovery.dbml
│   └── README.md
├── 05_Configuration Management/
├── 07_AI Component/
├── 09_Security & Validation/
├── 10_Configuration Deployment/
└── 11_Audit Trail/
```

## 🔗 ความสัมพันธ์กับ Feature Design
โครงสร้างโฟลเดอร์ของ Database Design จะสอดคล้องกับ [Feature Design/](../Feature%20Design/) ของโปรเจกต์โดยตรง
