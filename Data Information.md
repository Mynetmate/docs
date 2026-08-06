Feature List ดูดีมากครับ! มาคิดเรื่อง Device Information กัน
## 📦 Device Information ควรเก็บอะไรบ้าง?
แบ่งออกเป็น **6 กลุ่ม** 

###  1. Core Identity (ข้อมูลตัวตน)
| Field           | ตัวอย่าง                          | ทำไมต้องเก็บ?                         |
| --------------- | --------------------------------- | ------------------------------------- |
| `hostname`      | `BKK-CORE-SW1`                    | ชื่อที่แสดงในทุกหน้า UI               |
| `management_ip` | `192.168.1.1`                     | Netmiko ใช้ SSH เข้าอุปกรณ์           |
| `device_type`   | `switch` / `router` / `firewall`  | แบ่งหมวดหมู่ + ไอคอนบน Topology       |
| `vendor`        | `cisco` / `mikrotik` / `huawei`   | เลือก Jinja2 Template + Prompt ให้ AI |
| `model`         | `Catalyst 9300` / `RB750Gr3`      | AI ใช้เป็น Context ตอนตอบคำถาม        |
| `os_version`    | `IOS-XE 17.9.4` / `RouterOS 7.14` | เช็คความเข้ากัน + Security patch      |
| `serial_number` | `FCW2345L0P8`                     | ใช้ยืนยันตัวตน + รายงาน Inventory     |

###  2. Connection (สำหรับ Netmiko เชื่อมต่อ)
| Field           | ตัวอย่าง                                         | หมายเหตุ                                                |
| --------------- | ------------------------------------------------ | ------------------------------------------------------- |
| `platform`      | `cisco_ios` / `mikrotik_routeros` / `huawei_vrp` | **ค่าที่ Netmiko ต้องใช้ตรงๆ**                          |
| `ssh_port`      | `22` (default)                                   | บาง Device ใช้พอร์ตอื่น                                 |
| `protocol`      | `ssh` / `telnet`                                 | ส่วนใหญ่ SSH แต่ของเก่าอาจยัง Telnet                    |
| `credential_id` | FK → Credentials table                           | **ไม่ควรเก็บ password ตรงนี้!** แยกตารางเก็บ + เข้ารหัส |

###  3. Network Info (ข้อมูลเครือข่าย)
| Field             | ตัวอย่าง            | ทำไมต้องเก็บ?                  |
| ----------------- | ------------------- | ------------------------------ |
| `mac_address`     | `AA:BB:CC:DD:EE:FF` | ระบุตัวตนที่ไม่ซ้ำ + Discovery |
| `management_vlan` | `99`                | รู้ว่าต้อง SSH ผ่าน VLAN ไหน   |
| `gateway`         | `192.168.1.254`     | Troubleshoot connectivity      |

###  4. Location & Role (ตำแหน่งและบทบาท)
| Field | ตัวอย่าง | ทำไมต้องเก็บ? |
|---|---|---|
| `site` | `สาขาบางนา` / `HQ กรุงเทพ` | จัดกลุ่มใน Dashboard + Filter |
| `location_detail` | `ชั้น 3 ห้อง Server` | ส่งคนไปดูหน้างานถูกจุด |
| `role` | `core` / `distribution` / `access` | **AI ใช้ทำ Impact Analysis** ถ้า Core พังผลกระทบเยอะ |
| `tags` | `["production", "critical"]` | Filter/Search แบบ Flexible |

###  5. Status (สถานะปัจจุบัน)
| Field | ตัวอย่าง | ทำไมต้องเก็บ? |
|---|---|---|
| `status` | `online` / `offline` / `maintenance` | Dashboard แสดงสถานะ real-time |
| `last_seen` | `2026-07-30 12:00:00` | รู้ว่าข้อมูลเก่าแค่ไหน |
| `uptime` | `45 days, 3:22:10` | ดูว่า Reboot บ่อยไหม (สุขภาพ) |

###  6. Metadata (ข้อมูลบริหารจัดการ)
| Field | ตัวอย่าง | ทำไมต้องเก็บ? |
|---|---|---|
| `discovery_method` | `manual` / `lldp` / `cdp` / `snmp` | รู้ว่า Device นี้มาจากไหน |
| `notes` | `"อุปกรณ์เก่า รอเปลี่ยน Q4"` | วิศวกรเอาไว้จดบันทึก |
| `created_at` | `2026-07-30 12:00:00` | Audit Trail |
| `updated_at` | `2026-07-30 15:30:00` | Audit Trail |
| `created_by` | FK → Users table | Audit Trail — ใครเพิ่มเข้าระบบ |

---

## 🗄️ แนะนำ: แยกเป็นตารางที่เกี่ยวข้อง (ไม่ยัดลงตารางเดียว)

```
┌──────────────┐     ┌──────────────────┐
│   devices    │────→│   credentials    │
│              │     │ (username, pw    │
│  hostname    │     │  encrypted)      │
│  vendor      │     └──────────────────┘
│  model       │
│  role        │     ┌──────────────────┐
│  site        │────→│   interfaces     │
│  ...         │     │ (name, ip, vlan, │
└──────────────┘     │  status, speed)  │
       │              └──────────────────┘
       │
       ├─────────────→┌──────────────────┐
       │              │   config_history  │
       │              │ (config_text,     │
       │              │  snapshot_type,   │
       │              │  changed_by)      │
       │              └──────────────────┘
       │
       ├─────────────→┌──────────────────┐
       │              │   scan_results   │
       │              │ (rule_id, passed,│
       │              │  severity,       │
       │              │  scanned_at)     │
       │              └────────┬─────────┘
       │                       │
       │              ┌────────▼─────────┐
       │              │  cis_overrides   │
       │              │ (reason,         │
       │              │  overridden_by,  │
       │              │  overridden_at)  │
       │              └──────────────────┘
       │
       └─────────────→┌──────────────────┐
                      │    audit_logs    │
                      │ (action, target, │
                      │  user_id, at)    │
                      └──────────────────┘
```

**เหตุผลที่ต้องแยก:**
- **Credentials:** แยกเพราะหลาย Device อาจใช้ Credential ชุดเดียวกัน + ต้องเข้ารหัสแยก
- **Interfaces:** แยกเพราะ 1 Device มีหลาย Interface (1-to-many) → **Topology ต้องใช้ตารางนี้**
- **Config History:** แยกเพราะเก็บหลายเวอร์ชัน → **Version Control ต้องใช้ตารางนี้**
- **Scan Results:** แยกเพราะ 1 Device มีหลาย Rule และสแกนได้หลายครั้ง (1-to-many) → **CIS Scan ต้องใช้**
- **CIS Overrides:** แยกเพราะ 1 ผลสแกนมีได้ไม่เกิน 1 Override (1-to-1) + ต้องเก็บว่าใครอนุมัติ → **Audit Trail ของการ Override**
- **Audit Logs:** แยกเพราะทุก Action ในระบบต้องบันทึกไว้ (Action Log กลาง)

---

##  7. Scan Results (ผลการสแกน CIS)
*ตารางนี้เก็บผลสแกนของแต่ละ Rule ต่อ Device แต่ละครั้ง — Feature: CIS Benchmark Scanning (8 Rules) 🏆 P1-CORE*

| Field | ตัวอย่าง | ทำไมต้องเก็บ? |
|---|---|---|
| `id` | `UUID` | Primary Key |
| `device_id` | FK → devices | รู้ว่าสแกน Device ไหน |
| `rule_id` | `CIS-01` ถึง `CIS-08` | อ้างอิง Rule ที่สแกน |
| `rule_name` | `"Enable Secret Must Exist"` | แสดงผลบนหน้า UI |
| `severity` | `critical` / `warning` / `info` | จัดลำดับความสำคัญ |
| `passed` | `true` / `false` | ผลสแกนผ่านหรือไม่ |
| `evidence` | `"no enable secret found"` | ข้อความอธิบายว่าพบอะไร |
| `scanned_at` | `2026-08-06 14:00:00` | Timestamp ของการสแกน |
| `scanned_by` | FK → users | ใครสั่งสแกน |
| `config_snapshot_id` | FK → config_history | Config เวอร์ชันไหนที่ถูกสแกน |

---

##  8. CIS Overrides (บันทึกการ Override ผลสแกน)
*ตารางนี้เก็บการที่ Admin ยืนยันว่า "รู้แล้ว ยอมรับความเสี่ยงนี้" — Feature: CIS Override Logging 🏆 P1-CORE*

| Field            | ตัวอย่าง                     | ทำไมต้องเก็บ?                          |
| ---------------- | ---------------------------- | -------------------------------------- |
| `id`             | `UUID`                       | Primary Key                            |
| `scan_result_id` | FK → scan_results            | Override ผลสแกนข้อไหน                  |
| `reason`         | `"อุปกรณ์รุ่นเก่าไม่รองรับ"` | Admin ต้องอธิบายเหตุผล (บังคับกรอก)    |
| `overridden_by`  | FK → users                   | ใคร Override (ต้องเป็น Admin เท่านั้น) |
| `overridden_at`  | `2026-08-06 14:30:00`        | Timestamp เพื่อ Audit                  |
| `expires_at`     | `2026-12-31`                 | กำหนดวันหมดอายุ Override (Optional)    |

> **หมายเหตุสำคัญ:** ตาราง `cis_overrides` มีความสัมพันธ์แบบ 1-to-1 กับ `scan_results` เพราะ 1 ผลสแกนมีได้ไม่เกิน 1 Override เท่านั้น และต้องมีการบันทึก Reason ทุกครั้ง ห้าม Override แบบไม่มีเหตุผล

---

## 🎯 สรุป: Field ไหนใช้กับ Feature ไหน (อัปเดตครบ 8 ตาราง)

| Feature | ตาราง / Fields ที่ต้องพึ่งพา |
|---|---|
| **Authentication** | `users` (username, password_hash, role) |
| **Dashboard** | `devices` (status, last_seen, uptime, site, role) |
| **Device Inventory** | `devices` (Core Identity ทั้งหมด + Location) |
| **Network Discovery** | `devices` (management_ip, mac_address, platform, discovery_method) |
| **Network Topology** | `devices` (hostname, device_type, role) + `interfaces` (port connections) |
| **Config Generate (Rule-Based)** | `devices` (vendor, platform, model) → เลือก Jinja2 Template |
| **Config Generate (AI)** | `devices` (vendor, model, role, os_version, site) → inject เป็น Context |
| **Config Deployment** | `devices` (management_ip, platform, credential_id) → Netmiko SSH |
| **CIS Benchmark Scanning** | `scan_results` (rule_id, passed, severity, evidence) + `devices` (os_version, vendor) |
| **CIS Override Logging** | `cis_overrides` (reason, overridden_by) + `scan_results` (scan_result_id) |
| **Version Control (Diff/Rollback)** | `config_history` (config_text, snapshot_type, timestamp) |
| **Audit Trail** | `audit_logs` (action, target, user_id, created_at) |

---

## 📋 สรุปตารางทั้งหมด 8 ตาราง

| # | ตาราง | ใช้กับ Feature | Priority |
|---|---|---|---|
| 1 | `devices` | ทุก Feature (ศูนย์กลาง) | 🏆 P1-CORE |
| 2 | `credentials` | Config Deployment, SSH | 🏆 P1-CORE |
| 3 | `users` | Authentication, RBAC, Audit | 🏗️ P1-INFRA |
| 4 | `config_history` | Version Control, Snapshot | 🏆 P1-CORE |
| 5 | `scan_results` | CIS Benchmark Scanning | 🏆 P1-CORE |
| 6 | `cis_overrides` | CIS Override Logging | 🏆 P1-CORE |
| 7 | `audit_logs` | Audit Trail ทุก Action | 🏗️ P1-INFRA |
| 8 | `interfaces` | Network Topology (P2) | 🚀 P2 |

> **หมายเหตุ:** ตาราง `interfaces` ควรสร้าง Schema ไว้ตั้งแต่ Sprint 0 แม้จะยังไม่ใส่ข้อมูลใน P1 เพื่อป้องกัน Migration ที่ซับซ้อนใน P2

---

### 🚀 Next Step: เมื่อจะเริ่มเขียนโค้ด

เอกสารนี้สมบูรณ์แล้วในแง่ของ "ตรรกะ" ขั้นตอนต่อไปคือระบุ **Physical Data Types** เพิ่มลงไปก่อนเขียนโค้ด:

- **กำหนด Data Type:** `hostname` → `String(255)`, `management_ip` → `String(45)`, `created_at` → `DateTime`
- **กำหนด Constraint:** `hostname` และ `management_ip` ต้องเป็น **UNIQUE** + **NOT NULL**
- **กำหนด Nullable:** `mac_address`, `serial_number`, `notes` สามารถเป็น NULL ได้ตอน Manual Entry
- **สร้าง Enum:** `vendor`, `platform`, `status`, `severity`, `role` ทำเป็น Enum เพื่อป้องกันพิมพ์ผิด

**สรุป:** ไฟล์นี้คือ "คัมภีร์ฐานข้อมูล" ของโปรเจกต์ครับ ทีม Backend เปิดไฟล์นี้วางไว้จอซ้าย เปิด `models.py` ที่จอขวา แล้วเขียน Alembic Migration ได้เลยทันที!
