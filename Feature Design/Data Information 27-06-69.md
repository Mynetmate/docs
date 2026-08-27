# 🗄️ MyNetMate — Complete Database Schema
> อ้างอิงจาก: `MyNetMate Weight Feature List.md` และ `MyNetMate รายการ Features.md`  
> **12 ตาราง** ครอบคลุมทุก Feature ใน 11 หมวด

---

## 📐 ER Diagram (ภาพรวมความสัมพันธ์)

```
[users] ────────────────────────────────────────────────────────────┐
   │                                                                │
   │ created_by                                            (FK ทุกตาราง → users)
   ▼                                                                │
[devices] ──→ [credentials]                                         │
   │                                                                │
   ├──→ [interfaces]          (P2)                                 │
   │                                                                │
   ├──→ [config_history] ──→ [scan_results] ──→ [cis_overrides] ───┘
   │                                  
   ├──→ [deploy_logs]   (P2)           
   │                                  
   ├──→ [audit_logs]                   
   │
[system_settings]   (Singleton — ไม่ผูกกับ devices)
[cis_rule_settings] (Standalone — กำหนด Rule ที่ใช้)
```

---

## 📋 สรุปตาราง 12 ตาราง

| # | ตาราง | Feature ที่ใช้ | Priority | Sprint |
|---|---|---|---|---|
| 1 | `users` | Auth, RBAC, Audit | 🏗️ P1-INFRA | Sprint 0 |
| 1.1 | `auth_sessions` | Authentication, Server-side Session | 🏗️ P1-INFRA | Sprint 0 |
| 2 | `devices` | Device Inventory, ทุก Feature | 🏆 P1-CORE | Sprint 0 |
| 3 | `credentials` | SSH Deploy, Netmiko | 🏆 P1-CORE | Sprint 0 |
| 4 | `config_history` | Config Gen, Version Control, Snapshot | 🏆 P1-CORE | Sprint 1 |
| 5 | `scan_results` | CIS Benchmark Scanning | 🏆 P1-CORE | Sprint 1 |
| 6 | `cis_overrides` | CIS Override Logging | 🏆 P1-CORE | Sprint 1 |
| 7 | `audit_logs` | Audit Trail ทุก Action | 🏗️ P1-INFRA | Sprint 0 |
| 8 | `deploy_logs` | Plan→Apply, Real-time Logs | 🚀 P2 | Sprint 2 |
| 9 | `interfaces` | Network Topology, Discovery | 🚀 P2 | Sprint 0 (Schema only) |
| 10 | `system_settings` | Settings & Admin, Offline Mode | 🏗️ P1-INFRA | Sprint 0 |
| 11 | `cis_rule_settings` | CIS Rule Toggles | 🏆 P1-CORE | Sprint 1 |

---

## 🔵 ตารางที่ 1: `users`
**Feature:** Authentication & Authorization (หมวด 1) 🏗️ P1-INFRA

| Column          | Type         | Constraint              | ตัวอย่าง              | หมายเหตุ                        |
| --------------- | ------------ | ----------------------- | --------------------- | ------------------------------- |
| `id`            | UUID         | PK, NOT NULL            | `uuid4()`             | Primary Key                     |
| `username`      | VARCHAR(100) | UNIQUE, NOT NULL, CHECK (username = lower(username)), CHECK (username ~ '^[a-z0-9._-]{3,100}$') | `admin_kmitl`         | ใช้ Login, ห้ามมี @               |
| `email`         | VARCHAR(255) | UNIQUE, NULLABLE, CHECK (email = lower(email)) | `admin@kmitl.ac.th`   | Optional                        |
| `password_hash` | VARCHAR(255) | NOT NULL                | `$argon2id$v=...`     | เข้ารหัสด้วย Argon2id เสมอ      |
| `role`          | VARCHAR(50)  | NOT NULL, CHECK (role IN ('admin', 'operator', 'viewer')) | `admin`               | `admin` / `operator` / `viewer` |
| `is_active`     | BOOLEAN      | NOT NULL, DEFAULT TRUE  | `true`                | ปิดบัญชีแทนการลบ                |
| `created_at`    | TIMESTAMP WITH TIME ZONE | NOT NULL, DEFAULT NOW() | -                     | Audit                           |
| `updated_at`    | TIMESTAMP WITH TIME ZONE | NOT NULL, DEFAULT NOW() | -                     | Audit                           |

**RBAC Permissions:**

| Role | สิทธิ์ |
|---|---|
| `admin` | Full access — จัดการ User, Settings, สร้าง Deployment Plan (P1), Override CIS |
| `operator` | สร้าง Config, สร้าง Deployment Plan (P1), สแกน CIS ได้ — Override CIS ไม่ได้ |
| `viewer` | ดูอย่างเดียว — ห้าม Create/Edit/Deploy |

---

## 🟣 ตารางที่ 1.1: `auth_sessions`
**Feature:** Authentication (Database-backed Opaque Server-side Session) 🏗️ P1-INFRA

> **Architecture Update (2026-08-27):** เปลี่ยนจาก Stateful JWT เพราะเดิมต้อง Query ตารางนี้ทุก Request อยู่แล้ว จึงเก็บ Opaque Session Token แบบ Hash เพื่อลดความซับซ้อนและยัง Revoke ได้ทันที

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | Internal Session ID เท่านั้น ห้ามใช้เป็น Cookie Token |
| `session_token_hash` | CHAR(64) | UNIQUE, NOT NULL | SHA-256 lowercase hex | เก็บเฉพาะ Hash ของ Opaque Token สุ่ม 256-bit ห้ามเก็บ Token ดิบ |
| `user_id` | UUID | FK → users (ON DELETE CASCADE), NOT NULL | - | เจ้าของ Session |
| `is_revoked` | BOOLEAN | NOT NULL, DEFAULT FALSE | `false` | True = บังคับเตะออก |
| `expires_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | - | วันหมดอายุของ Session ฝั่ง Server |
| `created_at` | TIMESTAMP WITH TIME ZONE | NOT NULL, DEFAULT NOW() | - | แทน last_login_at |
| `ip_address` | VARCHAR(45) | NULLABLE | `10.0.0.5` | |
| `user_agent` | TEXT | NULLABLE | `"Mozilla/5.0..."` | |

---

## 🟢 ตารางที่ 2: `devices`
**Feature:** Device Inventory & Management (หมวด 3) 🏆 P1-CORE ← **ศูนย์กลางของทุกอย่าง**

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `hostname` | VARCHAR(100) | UNIQUE, NOT NULL | `BKK-CORE-SW1` | แสดงทุกหน้า UI |
| `management_ip` | VARCHAR(45) | UNIQUE, NOT NULL | `192.168.1.1` | IPv4/IPv6 — Netmiko SSH |
| `device_type` | ENUM | NOT NULL | `switch` | `switch` / `router` / `firewall` |
| `vendor` | ENUM | NOT NULL | `cisco` | `cisco` / `mikrotik` / `huawei` |
| `model` | VARCHAR(100) | NOT NULL | `Catalyst 9300` | เลือก Jinja2 Template |
| `os_version` | VARCHAR(50) | NULLABLE | `IOS-XE 17.9.4` | CIS Scan เช็ค Compatibility |
| `serial_number` | VARCHAR(100) | NULLABLE | `FCW2345L0P8` | Inventory Report |
| `platform` | ENUM | NOT NULL | `cisco_ios` | ค่าที่ Netmiko ใช้ตรงๆ |
| `ssh_port` | INTEGER | NOT NULL, DEFAULT 22 | `22` | Port SSH |
| `protocol` | ENUM | NOT NULL, DEFAULT `ssh` | `ssh` | `ssh` / `telnet` |
| `credential_id` | UUID | FK → credentials, NULLABLE | - | NULL = ยังไม่ได้ตั้ง |
| `mac_address` | VARCHAR(17) | NULLABLE | `AA:BB:CC:DD:EE:FF` | Discovery ใช้ |
| `management_vlan` | INTEGER | NULLABLE | `99` | SSH ผ่าน VLAN ไหน |
| `gateway` | VARCHAR(45) | NULLABLE | `192.168.1.254` | Troubleshoot |
| `site` | VARCHAR(100) | NULLABLE | `HQ กรุงเทพ` | จัดกลุ่ม Dashboard |
| `location_detail` | VARCHAR(255) | NULLABLE | `ชั้น 3 ห้อง Server` | ตำแหน่งจริง |
| `role` | ENUM | NULLABLE | `core` | `core` / `distribution` / `access` |
| `tags` | JSON | NULLABLE | `["production"]` | Filter/Search |
| `status` | ENUM | NOT NULL, DEFAULT `unknown` | `online` | `online` / `offline` / `maintenance` / `unknown` |
| `last_seen` | TIMESTAMP | NULLABLE | `2026-08-06 12:00:00` | อัปเดตตอน Ping |
| `uptime` | VARCHAR(50) | NULLABLE | `45 days, 3:22:10` | ดึงจาก SSH |
| `discovery_method` | ENUM | NOT NULL, DEFAULT `manual` | `manual` | `manual` / `lldp` / `cdp` / `snmp` |
| `notes` | TEXT | NULLABLE | `"อุปกรณ์เก่า รอเปลี่ยน Q4"` | บันทึกของวิศวกร |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | `true` | Soft Delete |
| `created_by` | UUID | FK → users, NOT NULL | - | ใครเพิ่มเข้าระบบ |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |
| `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |

---

## 🔐 ตารางที่ 3: `credentials`
**Feature:** Config Deployment / SSH (หมวด 7) 🏆 P1-CORE

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `name` | VARCHAR(100) | NOT NULL | `"Cisco Lab Default"` | ชื่อชุด Credential |
| `username` | VARCHAR(100) | NOT NULL | `admin` | SSH Username |
| `password_encrypted` | TEXT | NOT NULL | `gAAAAAB...` | เข้ารหัสด้วย Fernet/AES |
| `enable_password_encrypted` | TEXT | NULLABLE | `gAAAAAB...` | Cisco `enable` password |
| `created_by` | UUID | FK → users, NOT NULL | - | |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |
| `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |

> ⚠️ **Security Rule:** ห้ามเก็บ Password เป็น plain text เด็ดขาด ต้องเข้ารหัสก่อนทุกครั้ง

---

## 📄 ตารางที่ 4: `config_history`
**Feature:** Config Generation (หมวด 5), Version Control (หมวด 9) 🏆 P1-CORE

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `device_id` | UUID | FK → devices, NOT NULL | - | Config ของ Device ไหน |
| `config_text` | TEXT | NOT NULL | `hostname BKK-SW1\n...` | เนื้อหา Config ทั้งหมด |
| `snapshot_type` | ENUM | NOT NULL | `generated` | `generated` / `pre_deploy` / `post_deploy` / `manual_pull` / `uploaded` |
| `version_number` | INTEGER | NOT NULL | `3` | ลำดับเวอร์ชัน Auto Increment ต่อ Device |
| `vendor` | ENUM | NOT NULL | `cisco` | บันทึก Vendor ตอนสร้าง |
| `template_used` | VARCHAR(100) | NULLABLE | `cisco_basic_vlan.j2` | Template ที่ใช้ Render |
| `form_data_snapshot` | JSON | NULLABLE | `{"vlan_id": 10, ...}` | ข้อมูลฟอร์มที่กรอก (เพื่อ Diff) |
| `is_deployed` | BOOLEAN | NOT NULL, DEFAULT FALSE | `false` | เคย Deploy แล้วหรือยัง |
| `deployed_at` | TIMESTAMP | NULLABLE | - | เวลาที่ Deploy สำเร็จ |
| `created_by` | UUID | FK → users, NOT NULL | - | ใครสร้าง/ดึง Config |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |

---

## 🔴 ตารางที่ 5: `scan_results`
**Feature:** CIS Benchmark Scanning (หมวด 8) 🏆 P1-CORE

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `device_id` | UUID | FK → devices, NOT NULL | - | สแกน Device ไหน |
| `config_snapshot_id` | UUID | FK → config_history, NULLABLE | - | Config เวอร์ชันที่ถูกสแกน |
| `rule_id` | VARCHAR(20) | NOT NULL | `CIS-01` | รหัส Rule (CIS-01 ถึง CIS-08) |
| `rule_name` | VARCHAR(200) | NOT NULL | `"Enable Secret Must Exist"` | ชื่อ Rule แสดงบน UI |
| `severity` | ENUM | NOT NULL | `critical` | `critical` / `warning` / `info` |
| `passed` | BOOLEAN | NOT NULL | `false` | ผ่านหรือไม่ |
| `evidence` | TEXT | NULLABLE | `"no enable secret found"` | หลักฐานที่ Regex พบ |
| `remediation` | TEXT | NULLABLE | `"Add: enable secret <pw>"` | วิธีแก้ไข |
| `is_overridden` | BOOLEAN | NOT NULL, DEFAULT FALSE | `false` | ถูก Override หรือยัง |
| `scanned_by` | UUID | FK → users, NOT NULL | - | ใครสั่งสแกน |
| `scanned_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |

---

## 🟡 ตารางที่ 6: `cis_overrides`
**Feature:** CIS Override Logging (หมวด 9) 🏆 P1-CORE

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `scan_result_id` | UUID | FK → scan_results, UNIQUE, NOT NULL | - | 1-to-1 กับ scan_results |
| `reason` | TEXT | NOT NULL | `"อุปกรณ์รุ่นเก่าไม่รองรับ"` | บังคับกรอก ห้ามว่าง |
| `overridden_by` | UUID | FK → users, NOT NULL | - | ต้องเป็น Admin เท่านั้น |
| `overridden_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |
| `expires_at` | TIMESTAMP | NULLABLE | `2026-12-31` | วันหมดอายุ Override |
| `revoked_at` | TIMESTAMP | NULLABLE | - | ถ้ายกเลิกก่อนหมดอายุ |
| `revoked_by` | UUID | FK → users, NULLABLE | - | ใคร Revoke |

---

## 📝 ตารางที่ 7: `audit_logs`
**Feature:** Audit Trail (หมวด 9) 🏗️ P1-INFRA

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `user_id` | UUID | FK → users, NULLABLE | - | NULL ถ้าเป็น System Action หรือ Anonymous failed login |
| `action` | VARCHAR(100) | NOT NULL | `device.create` | Canonical Dotted Event Format (อ้างอิง 02_Data Ownership and Event Catalog.md) |
| `resource_type` | VARCHAR(50) | NOT NULL | `device` | `device` / `config` / `scan` / `user` / `settings` / `auth` |
| `resource_id` | UUID | NULLABLE | - | ID ของ Record ที่ถูกกระทำ |
| `result` | VARCHAR(20) | NOT NULL, CHECK (result IN ('success', 'failure')) | `success` | สถานะของเหตุการณ์ |
| `safe_error_category` | VARCHAR(100) | NULLABLE | `authentication_error` | หมวดหมู่ Error ที่ปลอดภัย |
| `description` | TEXT | NULLABLE | `"Added device BKK-SW1"` | รายละเอียดเพิ่มเติม |
| `ip_address` | VARCHAR(45) | NULLABLE | `10.0.0.5` | IP ของ Client |
| `created_at` | TIMESTAMP WITH TIME ZONE | NOT NULL, DEFAULT NOW() | - | |

**ตัวอย่าง action values:** `device.create`, `device.update`, `device.delete`, `config.generate`, `config.deploy`, `scan.run`, `scan.override`, `user.login_success`, `user.login_failed`, `user.logout`, `settings.update`

---

## 🚀 ตารางที่ 8: `deploy_logs`
**Feature:** Configuration Deployment (หมวด 7) 🚀 P2

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `device_id` | UUID | FK → devices, NOT NULL | - | Deploy ไปที่ Device ไหน |
| `config_snapshot_id` | UUID | FK → config_history, NOT NULL | - | Config เวอร์ชันที่ Deploy |
| `status` | ENUM | NOT NULL | `success` | `pending` / `running` / `success` / `failed` / `rolled_back` |
| `output_log` | TEXT | NULLABLE | `"Building config...\n..."` | Raw SSH Output จาก Netmiko |
| `error_message` | TEXT | NULLABLE | `"Timeout after 30s"` | Error ถ้า Deploy ล้มเหลว |
| `deployed_by` | UUID | FK → users, NOT NULL | - | |
| `started_at` | TIMESTAMP | NOT NULL | - | |
| `finished_at` | TIMESTAMP | NULLABLE | - | NULL ถ้ายังรันอยู่ |

---

## 🔗 ตารางที่ 9: `interfaces`
**Feature:** Device Inventory, Network Discovery และ Network Topology — เก็บข้อมูลประจำ Interface เท่านั้น ไม่เก็บ Link Destination

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `device_id` | UUID | FK → devices, NOT NULL | - | Interface เป็นของ Device ไหน |
| `name` | VARCHAR(100) | NOT NULL, UNIQUE (`device_id`, `name`) | `GigabitEthernet0/1` | ชื่อ Port จริงบนอุปกรณ์ |
| `if_index` | INTEGER | NULLABLE | `10101` | Interface Index เมื่ออุปกรณ์รายงาน |
| `mac_address` | VARCHAR(17) | NULLABLE | `00:11:22:33:44:55` | MAC ของ Interface เมื่อมี |
| `ip_address` | VARCHAR(45) | NULLABLE | `10.0.0.1` | IP บน Interface |
| `subnet_mask` | VARCHAR(45) | NULLABLE | `255.255.255.0` | Subnet |
| `vlan_id` | INTEGER | NULLABLE | `10` | VLAN ที่ Port สังกัด |
| `admin_status` | ENUM | NULLABLE | `up` | สถานะที่กำหนดบนอุปกรณ์ |
| `oper_status` | ENUM | NULLABLE | `down` | สถานะการทำงานจริงที่อุปกรณ์รายงาน |
| `speed` | VARCHAR(20) | NULLABLE | `1Gbps` | ความเร็ว Port |
| `description` | VARCHAR(255) | NULLABLE | `"Uplink to Core"` | คำอธิบาย |
| `last_collected_at` | TIMESTAMP | NULLABLE | - | เวลาเก็บข้อมูล Interface ล่าสุด |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |

> **Topology Rule:** ความสัมพันธ์ Interface-to-Interface ต้องอยู่ใน NTV-owned Entities และอ้าง `interfaces.id` ห้ามเพิ่ม `connected_to_*` กลับเข้าตารางนี้

---

## ⚙️ ตารางที่ 10: `system_settings`
**Feature:** Settings & Administration (หมวด 11) 🏗️ P1-INFRA — Singleton (มีแค่ 1 Row)

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | INTEGER | PK, NOT NULL | `1` | Singleton |
| `gemini_api_key_encrypted` | TEXT | NULLABLE | `gAAAAAB...` | เข้ารหัสก่อนเก็บ |
| `gemini_model` | VARCHAR(50) | NOT NULL, DEFAULT `gemini-flash` | `gemini-flash` | เลือก Flash หรือ Pro |
| `token_budget_monthly` | INTEGER | NULLABLE | `100000` | จำกัด Token/เดือน |
| `token_used_this_month` | INTEGER | NOT NULL, DEFAULT 0 | `12345` | นับ Token ที่ใช้ไป |
| `offline_mode` | BOOLEAN | NOT NULL, DEFAULT FALSE | `false` | ปิด AI → Template อย่างเดียว |
| `updated_by` | UUID | FK → users, NULLABLE | - | ใคร Update ล่าสุด |
| `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |

---

## 🛡️ ตารางที่ 11: `cis_rule_settings`
**Feature:** CIS Rule Toggles (หมวด 11) 🏆 P1-CORE — Seed 8 Rules ตั้งแต่ Sprint 1

| Column | Type | Constraint | ตัวอย่าง | หมายเหตุ |
|---|---|---|---|---|
| `id` | UUID | PK, NOT NULL | `uuid4()` | |
| `rule_id` | VARCHAR(20) | UNIQUE, NOT NULL | `CIS-01` | รหัส Rule |
| `rule_name` | VARCHAR(200) | NOT NULL | `"Enable Secret Must Exist"` | ชื่อแสดงบน UI |
| `description` | TEXT | NULLABLE | `"Checks if enable secret..."` | อธิบาย Rule |
| `severity` | ENUM | NOT NULL | `critical` | `critical` / `warning` / `info` |
| `is_enabled` | BOOLEAN | NOT NULL, DEFAULT TRUE | `true` | Admin เปิด/ปิด Rule ได้ |
| `regex_pattern` | TEXT | NOT NULL | `r"enable secret \S+"` | Regex ที่ใช้สแกน Config |
| `vendor` | ENUM | NOT NULL | `cisco` | Rule นี้ใช้กับยี่ห้อไหน |
| `remediation_guide` | TEXT | NULLABLE | `"Add: enable secret <pw>"` | วิธีแก้ |
| `updated_by` | UUID | FK → users, NULLABLE | - | |
| `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | - | |

**8 CIS Rules ที่ต้อง Seed ตั้งแต่แรก:**

| Rule ID | Rule Name | Severity |
|---|---|---|
| `CIS-01` | Enable Secret Must Exist | critical |
| `CIS-02` | Service Password-Encryption Enabled | critical |
| `CIS-03` | SSH Version 2 Only | critical |
| `CIS-04` | No Telnet on VTY Lines | warning |
| `CIS-05` | Banner MOTD Must Exist | info |
| `CIS-06` | Console Exec-Timeout Set | warning |
| `CIS-07` | VTY Exec-Timeout Set | warning |
| `CIS-08` | HTTP Server Disabled | warning |

---

## 📊 Feature → Table Mapping (Quick Reference)

| Feature (หมวด) | ตารางที่ใช้ |
|---|---|
| **1. Auth & RBAC** | `users`, `auth_sessions` |
| **2. Dashboard** | `devices` (status, last_seen), `audit_logs` (recent activity) |
| **3. Device Inventory** | `devices`, `credentials`, `interfaces` (P2) |
| **4. Network Topology** | `devices`, `interfaces` + NTV-owned Entities ที่กำหนดใน `02_Database Schema.md` |
| **5. Config Generation** | `devices` (vendor, platform), `config_history` |
| **6. PII Masking** | ไม่มีตารางแยก — เป็น Middleware Logic ใน Backend |
| **7. Config Deployment** | `config_history`, `credentials`, `deploy_logs` (P2) |
| **8. CIS Scanning** | `scan_results`, `cis_rule_settings`, `config_history` |
| **9. Version Control** | `config_history` (Diff/Rollback), `cis_overrides`, `audit_logs` |
| **10. AI Architecture** | `config_history` (Context Injection), `system_settings` (API Key) |
| **11. Settings & Admin** | `system_settings`, `cis_rule_settings`, `users` |

---

## 🚀 Sprint Planning — ลำดับการสร้างตาราง

```
Sprint 0 — Foundation (ก่อนเขียน Feature ใดๆ):
  ✅ users              ← Login ต้องใช้ก่อน
  ✅ auth_sessions      ← จัดการ Session
  ✅ devices            ← ทุก Feature ผูกอยู่กับนี้
  ✅ credentials        ← ใส่ตั้งแต่ต้นก่อน Device ใช้
  ✅ audit_logs         ← Log ทุก Action ตั้งแต่วันแรก
  ✅ system_settings    ← Seed ค่า Default ก่อน Run App
  ✅ interfaces         ← สร้าง Schema เก็บไว้ แต่ยังไม่ใส่ข้อมูล (P2)

Sprint 1 — P1-CORE Features:
  ✅ config_history     ← ต้องมีก่อน Config Gen ทำงานได้
  ✅ cis_rule_settings  ← Seed 8 Rules พร้อมกับสร้างตาราง
  ✅ scan_results       ← CIS Scan ต้องการ
  ✅ cis_overrides      ← Override Logging

Sprint 2 / P2:
  🚀 deploy_logs        ← SSH Deploy จริงๆ
```

---

## 📌 Developer Notes

1. **ใช้ UUID เป็น PK** — ป้องกัน Enumeration Attack (ห้ามเดา ID)
2. **Soft Delete** — ห้ามลบ `devices` และ `users` จริงๆ ให้ใช้ `is_active = false` แทน
3. **Encryption** — `credentials.password_encrypted` และ `system_settings.gemini_api_key_encrypted` ต้องเข้ารหัสด้วย Fernet ก่อนบันทึกเสมอ
4. **Alembic** — ทุกการเปลี่ยน Schema ต้องสร้าง Migration File ห้าม `ALTER TABLE` ตรงๆ
5. **Enum** — กำหนดค่า Enum ใน Python (SQLAlchemy) และ Database ให้ตรงกัน
6. **Singleton Settings** — `system_settings` มีแค่ 1 Row เสมอ ใช้ `upsert` ไม่ใช่ `insert`
