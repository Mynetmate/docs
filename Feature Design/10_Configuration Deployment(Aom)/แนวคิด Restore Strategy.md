## 💾 Save/Restore Strategy — อะไรเหมาะกับ MyNetMate ที่สุด?

จากที่อาจารย์อธิบายไว้ในไฟล์ มีให้เลือก 3 แนวทาง:

| แนวทาง          | หลักการ                          | ข้อดี                | ข้อเสีย                   |
| --------------- | -------------------------------- | -------------------- | ------------------------- |
| **Save Game**   | กด Save เองทุกครั้ง              | ง่าย ประหยัด Storage | ลืม Save = ข้อมูลหาย      |
| **Time-based**  | Auto ทุก 1-2 ชม.                 | ไม่ต้องคิด           | กิน Resource, Gap ยังมี   |
| **Event-based** | Save ทุกครั้งที่ Deploy ผ่านระบบ | ตรงจุด               | ไม่จับ Out-of-band change |

---

## ✅ สิ่งที่แนะนำสำหรับ MyNetMate: **Hybrid 2 ชั้น**

### ชั้นที่ 1 — Event-triggered (Primary)

ทุกครั้งที่ Deploy Config ผ่าน MyNetMate

        ↓

ระบบ Auto-save snapshot ทันทีก่อน Deploy (Pre-deploy)

        ↓

และ Auto-save อีกครั้งหลัง Deploy สำเร็จ (Post-deploy)

**ทำไมถึงเป็น Primary:**

- จับทุก change ที่ผ่านระบบได้ 100%
- มี Pre/Post snapshot → Rollback ได้ถ้า Deploy แล้วพัง
- ไม่ต้องให้ User คิดเรื่อง Save เลย

---

### ชั้นที่ 2 — Manual Save (Secondary)

Admin ไปแก้ Config ตรงที่อุปกรณ์ผ่าน SSH โดยตรง (Out-of-band)

        ↓

กลับมากด "Save Current Config" ที่ MyNetMate

        ↓

ระบบ SSH ดึง running-config มาเก็บ พร้อม timestamp + "manual" tag

**ทำไมถึงจำเป็น:**

- แก้ปัญหา Gap ที่อาจารย์กังวล
- อาจารย์บอกว่า _"ระบบเราก็ไม่จำเป็นต้องรู้ทุกครั้ง"_ → Manual ก็เพียงพอ

---

### ชั้นที่ 3 — Scheduled (Optional / Phase 2)

ตั้งค่าได้ว่าจะ Auto-pull config ทุกกี่ชั่วโมง

ถ้า Diff เปลี่ยน → เก็บ

ถ้า Diff ไม่เปลี่ยน → ไม่เก็บ (ประหยัด Storage)

**ตัดออกก่อนใน Project 1** เพราะ:

- เพิ่ม Complexity (ต้องทำ Scheduler, Background Job)
- อาจารย์บอก "ทำ Inventory ให้ได้ก่อน" ← Priority หลัก
- ใส่ใน Roadmap Project 2 ได้

---

## 🗄️ Database Schema ที่แนะนำ

```sql

-- ง่ายที่สุด เพียงพอสำหรับ Project 1

CREATE TABLE config_snapshots (

    id              SERIAL PRIMARY KEY,

    device_id       INTEGER REFERENCES devices(id),

    config_text     TEXT NOT NULL,           -- running-config เต็ม

    version_number  INTEGER NOT NULL,        -- auto-increment per device

    source          VARCHAR(20) NOT NULL,    -- 'pre_deploy' | 'post_deploy' | 'manual'

    created_by      VARCHAR(100),            -- username ที่กด save

    created_at      TIMESTAMP DEFAULT NOW(),

    note            TEXT                     -- optional comment

);
```

**ทำไมไม่ใช้ Temporal Table:**

- PostgreSQL Temporal Table ซับซ้อนกว่าที่ต้องการ
- Simple Table + version_number ตอบโจทย์ Project 1 ได้ครบ
- Diff คำนวณ on-the-fly โดยเปรียบเทียบ `config_text` 2 rows

---

## 🔄 Flow ที่ชัดเจนสำหรับ MyNetMate

```
[Deploy Flow]

User กด Deploy

    → System เก็บ Pre-deploy snapshot (source='pre_deploy')

    → Netmiko Push config ไปอุปกรณ์

    → ถ้าสำเร็จ → เก็บ Post-deploy snapshot (source='post_deploy')

    → ถ้าล้มเหลว → Alert + ปุ่ม Rollback อัตโนมัติ

[Manual Save Flow]

User กด "Save Current Config"

    → System SSH ดึง show running-config

    → เก็บ snapshot (source='manual')

    → แสดง Diff เทียบกับ version ล่าสุด

[Rollback Flow]

User เลือก version ที่ต้องการ

    → แสดง Diff ระหว่าง current กับ target

    → User ยืนยัน

    → Push config กลับไปอุปกรณ์

---
```
## สรุป Decision สำหรับไปคุยกับอาจารย์

> **"MyNetMate ใช้ Hybrid 2 ชั้น คือ Event-triggered (Auto-save ทุก Deploy) + Manual Save (สำหรับ Out-of-band change) โดยเก็บเป็น Text Snapshot ใน PostgreSQL พร้อม version number และ source tag เพื่อให้ Rollback และ Diff ได้ง่าย ส่วน Scheduled Backup เลื่อนไป Project 2 เพื่อควบคุม Scope"**

ตอบคำถามอาจารย์ได้ครบทุกข้อที่ถามไว้ในไฟล์ครับ 🎯


## ตัวอย่าง Event-triggered แบบเห็นภาพชัดๆ

---

### 🎬 Scenario: Admin ต้องการเพิ่ม VLAN 50 บน Switch SW-CORE-01

---

**สถานะเริ่มต้น** — Config ปัจจุบันบน SW-CORE-01:

```cisco
! Version 3 (ล่าสุด)

hostname SW-CORE-01

vlan 10

 name MGMT

vlan 20

 name DATA

vlan 30

 name VOICE
```

---

### ขั้นตอนที่ 1 — Admin กรอก Form ใน MyNetMate

```
VLAN Tab:

  VLAN ID  : 50

  Name     : SECURITY

  SVI IP   : 10.5.0.1/24
```
---

### ขั้นตอนที่ 2 — Admin กดปุ่ม "Deploy"

**ทันทีที่กด Deploy → ระบบทำงานอัตโนมัติ:**
```
🔵 STEP A: Pre-deploy Snapshot

   ├── SSH เข้า SW-CORE-01

   ├── รัน: show running-config

   ├── เก็บลง DB:

   │     device_id     = 1

   │     version       = 4        ← version ใหม่

   │     source        = 'pre_deploy'

   │     config_text   = "...vlan 10, 20, 30..."

   │     created_at    = 2026-07-10 09:35:00

   │     note          = "Before adding VLAN 50"

   └── ✅ Snapshot เก็บแล้ว

🟡 STEP B: Generate Config จาก Template (Jinja2)

   └── Output:

         vlan 50

          name SECURITY

         interface Vlan50

          ip address 10.5.0.1 255.255.255.0

          no shutdown

🟡 STEP C: Security Validation (CIS Rules)

   └── ✅ Pass 24/24 กฎ

🟡 STEP D: PII Masking (Presidio)

   └── ไม่มี Sensitive Data ใน VLAN config → ผ่านปกติ

🔵 STEP E: Push ไปอุปกรณ์ (Netmiko SSH)

   └── ส่ง Command ทีละบรรทัด:

         configure terminal

         vlan 50

          name SECURITY

         interface Vlan50

          ip address 10.5.0.1 255.255.255.0

          no shutdown

         end

         write memory     ← save ที่ตัวอุปกรณ์ด้วย

🔵 STEP F: Post-deploy Snapshot

   ├── SSH เข้า SW-CORE-01 อีกครั้ง

   ├── รัน: show running-config

   ├── เก็บลง DB:

   │     device_id     = 1

   │     version       = 5        ← version ใหม่

   │     source        = 'post_deploy'

   │     config_text   = "...vlan 10, 20, 30, 50..."

   │     created_at    = 2026-07-10 09:35:12

   │     note          = "After adding VLAN 50"

   └── ✅ Deploy สำเร็จ!
```
---

### ขั้นตอนที่ 3 — UI แสดงผล
```
┌─────────────────────────────────────┐

│  ✅ Deploy Successful               │

│                                     │

│  Device: SW-CORE-01                 │

│  Time: 12 seconds                   │

│                                     │

│  [View Diff]  [Rollback if needed]  │

└─────────────────────────────────────┘
```
---

### ขั้นตอนที่ 4 — ถ้ากด "View Diff"ง
```

Version 4 (Pre)  →  Version 5 (Post)

  hostname SW-CORE-01

  vlan 10

   name MGMT

  vlan 20

   name DATA

  vlan 30

   name VOICE

+ vlan 50

+  name SECURITY

+

+ interface Vlan50

+  ip address 10.5.0.1 255.255.255.0

+  no shutdown
```
---

### 🚨 กรณีพิเศษ — Deploy แล้วอุปกรณ์ Error
```
STEP E: Push ไปอุปกรณ์

   └── ❌ ERROR: "Invalid input detected at '^' marker"

       (syntax ผิดบางอย่าง)

→ ระบบ:

   1. ไม่เก็บ Post-deploy Snapshot

   2. แจ้งเตือน: "Deploy Failed"

   3. แสดงปุ่ม "Auto Rollback"

→ Admin กด "Auto Rollback":

   - ระบบดึง Version 4 (Pre-deploy) มา

   - Push กลับไปอุปกรณ์ทันที

   - อุปกรณ์กลับสู่สถานะเดิม ✅
```
---

### 📊 สิ่งที่อยู่ใน DB หลังเหตุการณ์นี้
```
config_snapshots table:

┌────┬───────────┬─────────┬──────────────┬─────────────────────┐

│ id │ device_id │ version │ source       │ created_at          │

├────┼───────────┼─────────┼──────────────┼─────────────────────┤

│ 1  │ 1         │ 1       │ manual       │ 2026-07-01 08:00:00 │

│ 2  │ 1         │ 2       │ pre_deploy   │ 2026-07-05 14:00:00 │

│ 3  │ 1         │ 3       │ post_deploy  │ 2026-07-05 14:00:15 │

│ 4  │ 1         │ 4       │ pre_deploy   │ 2026-07-10 09:35:00 │ ← ก่อน VLAN 50

│ 5  │ 1         │ 5       │ post_deploy  │ 2026-07-10 09:35:12 │ ← หลัง VLAN 50

└────┴───────────┴─────────┴──────────────┴─────────────────────┘

---
```
> **สรุปในประโยคเดียว:** Event-triggered = **"ระบบถ่ายรูป Config ก่อนและหลังทุกครั้งที่มีการแก้ไขผ่าน MyNetMate โดยอัตโนมัติ ไม่ต้องให้ Admin คิดเรื่อง Backup เลย"** ครับ 📸

```

Admin กด Deploy ใน MyNetMate

ระบบถ่ายรูป Config ก่อน

↓

แก้ Config ที่ Switch จริง

↓

ระบบถ่ายรูป Config หลัง

ถ้ามีปัญหา → กด Rollback → ใช้รูปก่อนหน้าคืนค่า
```
