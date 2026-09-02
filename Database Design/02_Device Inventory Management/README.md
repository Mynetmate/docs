# 🗄️ Database Schema: 02_Device Inventory Management (3NF Normalized)

> **Path**: `Database Design/02_Device Inventory Management/`  
> **DBML**: [`device_inventory.dbml`](./device_inventory.dbml)  
> **Master SQL**: [`device_inventory.sql`](./device_inventory.sql)  
> **Feature Link**: [`Feature Design/02_Device Inventory Management(Tee)`](../../Feature%20Design/02_Device%20Inventory%20Management(Tee)/)  
>
> 📁 **Modular SQL Schemas (`sql/`)**:
> - [`00_enums.sql`](./sql/00_enums.sql) (Enums & Custom Types)
> - [`01_credentials.sql`](./sql/01_credentials.sql) (ตาราง credential_profiles)
> - [`02_sites_and_groups.sql`](./sql/02_sites_and_groups.sql) (ตาราง sites, device_groups, device_group_members)
> - [`03_devices.sql`](./sql/03_devices.sql) (ตาราง devices - Core System of Record)
> - [`04_device_interfaces.sql`](./sql/04_device_interfaces.sql) (ตาราง device_interfaces - Ports L2/L3)
> - [`05_device_enrollment_attempts.sql`](./sql/05_device_enrollment_attempts.sql) (ตาราง device_enrollment_attempts - Audit Log)
> - [`99_seed_data.sql`](./sql/99_seed_data.sql) (ข้อมูล Mock Test Data)

---

## 1. Entity-Relationship Diagram (ERD - 3NF)

```mermaid
erDiagram
    USERS ||--o{ CREDENTIAL_PROFILES : "creates"
    USERS ||--o{ DEVICES : "enrolled_by"
    USERS ||--o{ DEVICE_ENROLLMENT_ATTEMPTS : "initiated_by"
    
    SITES ||--o{ DEVICES : "located_at"
    CREDENTIAL_PROFILES ||--o{ DEVICES : "authenticates"
    CREDENTIAL_PROFILES ||--o{ DEVICE_ENROLLMENT_ATTEMPTS : "tested_with"
    
    DEVICES ||--|{ DEVICE_INTERFACES : "has_ports"
    DEVICES ||--o{ DEVICE_GROUP_MEMBERS : "belongs_to"
    DEVICE_GROUPS ||--o{ DEVICE_GROUP_MEMBERS : "contains"

    CREDENTIAL_PROFILES {
        uuid id PK
        varchar name UK "Cisco Core Profile"
        enum credential_type "ssh_password, snmp_v2c, etc."
        varchar username
        text password_encrypted "AES-256-GCM / KMS"
        text enable_secret_encrypted "Privileged EXEC secret"
        text snmp_community_ro_encrypted "Read-Only Community"
        text snmp_community_rw_encrypted "Read-Write Community"
        int ssh_port "Default 22"
        int snmp_port "Default 161"
        text description
        uuid created_by FK
        timestamptz created_at
        timestamptz updated_at
    }

    SITES {
        uuid id PK
        varchar name UK "HQ Bangkok, Bangna Branch"
        varchar location_detail "Floor 3, Server Room"
        text description
        timestamptz created_at
        timestamptz updated_at
    }

    DEVICE_GROUPS {
        uuid id PK
        varchar name UK "Core Routers, Access Switches"
        varchar color_tag "Hex #3B82F6"
        text description
        timestamptz created_at
        timestamptz updated_at
    }

    DEVICE_GROUP_MEMBERS {
        uuid device_id PK,FK
        uuid group_id PK,FK
        timestamptz added_at
    }

    DEVICES {
        uuid id PK
        inet management_ip UK "Management IP (Candidate Key)"
        varchar hostname "RT-CORE-01"
        varchar domain_name "lab.local"
        text description "SNMP sysDescr"
        enum device_type "router, switch, firewall, etc."
        enum role "core, distribution, access, edge_router"
        enum vendor "cisco, mikrotik, huawei, juniper, arista, unknown"
        varchar model "Catalyst 2960, RB750Gr3"
        varchar os_version "IOS 15.2, RouterOS 7.14"
        varchar serial_number "FCW2345L0P8"
        macaddr chassis_mac "Base MAC Address"
        varchar chassis_id "LLDP Subtype ID"
        uuid site_id FK
        uuid credential_profile_id FK
        varchar platform "Netmiko driver e.g. cisco_ios"
        int management_vlan "99"
        inet default_gateway "192.168.1.254"
        boolean is_managed "true"
        enum status "online, offline, unreachable, maintenance"
        enum enrollment_status "pending, enrolled, failed, rejected"
        enum discovery_method "manual_enrollment, auto_discovery, csv_import"
        timestamptz last_discovered_at
        timestamptz last_seen_at
        timestamptz last_collected_at
        bigint uptime_seconds
        text notes
        uuid created_by FK
        timestamptz created_at
        timestamptz updated_at
    }

    DEVICE_INTERFACES {
        uuid id PK
        uuid device_id FK "Composite AK: (device_id, if_index)"
        int if_index "SNMP ifIndex"
        varchar name "GigabitEthernet0/1, ether1"
        macaddr mac_address "Port MAC"
        inet ip_address "L3 IP"
        inet subnet_mask "255.255.255.0"
        varchar description "Uplink to Core"
        enum mode "access, trunk, routed, loopback, svi, unknown"
        int vlan_id "1-4094"
        enum admin_status "Up, Down, Testing, Unknown"
        enum oper_status "Up, Down, Testing, Unknown"
        bigint speed_bps "1000000000"
        timestamptz updated_at
    }

    DEVICE_ENROLLMENT_ATTEMPTS {
        uuid id PK
        inet target_ip
        uuid credential_profile_id FK
        enum status "pending, authenticating, collecting, succeeded, failed"
        text error_message
        varchar collected_hostname
        varchar collected_vendor
        varchar collected_model
        varchar collected_os_version
        int duration_ms
        uuid initiated_by FK
        timestamptz attempted_at
    }
```

---

## 2. การวิเคราะห์ความถูกต้องตามมาตรฐาน 3NF (Normalization Analysis)

| Table | 1NF (Atomic Data) | 2NF (No Partial Dependency) | 3NF (No Transitive Dependency) | Functional Dependencies ($X \to Y$) |
| :--- | :--- | :--- | :--- | :--- |
| **`credential_profiles`** | ผ่าน: ทุก Attribute เป็นค่าเดี่ยว | ผ่าน: PK คือ `id`, AK คือ `name` (Single-column keys) | ผ่าน: Non-prime attributes ทุกตัวขึ้นตรงกับ `id` โดยตรง | `id` $\to$ `name, credential_type, username, password_encrypted, ...`<br>`name` $\to$ `id, ...` |
| **`sites`** | ผ่าน: Atomic strings | ผ่าน: PK คือ `id`, AK คือ `name` | ผ่าน: ทุก Attribute ขึ้นกับ `id` โดยตรง | `id` $\to$ `name, location_detail, description...` |
| **`device_groups`** | ผ่าน: Atomic strings | ผ่าน: PK คือ `id`, AK คือ `name` | ผ่าน: ทุก Attribute ขึ้นกับ `id` โดยตรง | `id` $\to$ `name, color_tag, description...` |
| **`device_group_members`** | ผ่าน: Atomic UUIDs | ผ่าน: PK เป็น Composite `(device_id, group_id)` และ `added_at` ขึ้นตรงกับทั้งสองค่าพร้อมกัน | ผ่าน: ไม่มี Non-key attribute อื่น | `(device_id, group_id)` $\to$ `added_at` |
| **`devices`** | ผ่าน: แตก Group เป็น Many-to-Many แยก | ผ่าน: PK คือ `id`, Candidate Key คือ `management_ip` (Single-column) | ผ่าน: ข้อมูล Site และ Credential ถูกอ้างผ่าน FK (`site_id`, `credential_profile_id`) ไม่เก็บ redundant attributes ซ้ำซ้อน | `id` $\to$ `management_ip, hostname, vendor, model, os_version, site_id, ...`<br>`management_ip` $\to$ `id, ...` |
| **`device_interfaces`** | ผ่าน: ข้อมูลพอร์ตเป็นค่าเดี่ยว | ผ่าน: Composite Candidate Key คือ `(device_id, if_index)` | ผ่าน: `name`, `mac_address`, `admin_status`, `mode` ขึ้นตรงกับ `(device_id, if_index)` เท่านั้น | `id` $\to$ `device_id, if_index, name, mac_address, mode, ...`<br>`(device_id, if_index)` $\to$ `id, ...` |
| **`device_enrollment_attempts`** | ผ่าน: ข้อมูล Log ของแต่ละการลองเชื่อมต่อ | ผ่าน: PK คือ `id` | ผ่าน: บันทึกข้อมูลเฉพาะของ Event แต่ละรอบ | `id` $\to$ `target_ip, status, error_message, duration_ms, ...` |

---

## 3. การแบ่งขอบเขตและเชื่อมโยงกับ `04_Network Discovery`

- **`04_Network Discovery`**: รับผิดชอบการสแกนอัตโนมัติ (Discovery Engine / Oxian) เพื่อค้นหา Topology Graph, Links ระหว่างพอร์ต, และตรวจพบเพื่อนบ้าน (Neighbor Discovery)
- **`02_Device Inventory Management`**: เป็น **Master Inventory Core** สำหรับการลงทะเบียนอุปกรณ์ด้วยมือ (Manual Enrollment), บริหารจัดการ Credential Profiles (Encrypted), จัดกลุ่มตาม Site และ Device Group, ตลอดจนเก็บ Audit Log ความพยายามนำเข้าอุปกรณ์
