# 📚 Chapter 14 — Network Automation Architecture (NAA)
> **ที่มา:** Network Programmability and Automation (2nd Edition) | หน้า 739–805
> **ภาษา:** สรุปเป็นภาษาไทย เน้นเนื้อหาที่เกี่ยวข้องกับโปรเจกต์ MyNetMate

---

## 🗂️ สารบัญบทนี้

| ไฟล์ | หัวข้อ | เนื้อหา |
|------|--------|---------|
| 1 | [บทนำ — ทำไมต้องมี Architecture?](#1-บทนำ--ทำไมต้องมี-architecture) | ปัญหา Domain Isolation |
| 2 | [6 ส่วนประกอบหลัก](#2-6-ส่วนประกอบหลักของ-architecture) | ภาพรวม Architecture |
| 3 | [Overview + แนวทางเลือกเครื่องมือ](#3-overview--แนวทางเลือกเครื่องมือ) | Build vs Buy, ADR |
| 4 | [User Interactions](#4-user-interactions-การปฏิสัมพันธ์กับผู้ใช้งาน) | GUI, ITSM, ChatOps, CLI |
| 5 | [Source of Truth](#5-source-of-truth-แหล่งข้อมูลความจริงหลัก) | Inventory, Data Quality, DCIM, API |
| 6 | [Automation Engine](#6-automation-engine-ตัวสั่งงานอัตโนมัติ) | Backup, Rendering, Compliance, Deployment |
| 7 | [Telemetry & Observability](#7-telemetry-and-observability-โทรมาตรและการสังเกตระบบ) | Metrics, Logs, Flows, Stack, Orchestration |

---

## 1. บทนำ — ทำไมต้องมี Architecture?

### 🔴 ปัญหาที่หนังสือชี้ให้เห็น

การสร้าง Automation แบบเดิมมักทำแยกกันตามโดเมน เช่น Campus / Data Center / Security / Cloud แต่ละทีมทำของตัวเองโดยไม่เชื่อมกัน ผลที่ตามมา:

- **เกิด Silos** — ทีมไม่แชร์เครื่องมือหรือความรู้กัน
- **ซับซ้อนขึ้นเรื่อยๆ** — แต่ละโซลูชันมี Pattern ต่างกัน
- **นำกลับมาใช้ไม่ได้** — ทีม A ทำไปแล้ว ทีม B ต้องเริ่มใหม่

### ✅ สถาปัตยกรรมช่วยได้อย่างไร?

> **"คุณไม่สามารถเปลี่ยนสิ่งที่คุณไม่เข้าใจให้เป็นระบบอัตโนมัติได้"**
> — NPA2e, Chapter 14

Architecture ช่วยให้:
1. **มองเห็นภาพรวม** ก่อนลงมือทำ
2. **ระบุ Requirements** และ Dependencies ระหว่างระบบ
3. **ตัดสินใจออกแบบ** แต่ละส่วนได้อย่างมีเหตุผล
4. **นำกลับมาใช้ซ้ำ** ระหว่างทีมได้

> 💡 **โยงกับ MyNetMate:** เราออกแบบ Architecture ของระบบ (FastAPI + PostgreSQL + Jinja2 + AI) โดยอิง Framework ของบทนี้พอดี

---

## 2. 6 ส่วนประกอบหลักของ Architecture

สถาปัตยกรรมนี้แบ่งออกเป็น **6 Building Blocks** (Figure 14-1):

```
┌──────────────────────────────────────────────────────────┐
│                    Network Infrastructure                │
│          (Physical / Virtual / Cloud devices)            │
└──────────────────────┬───────────────────────────────────┘
                       │ APIs
┌──────────────────────▼───────────────────────────────────┐
│                    Automation Engine                     │
│         (Ansible / Nornir / Custom Scripts)              │
└───┬─────────────┬──────────────┬────────────────┬────────┘
    │             │              │                │
    ▼             ▼              ▼                ▼
┌───────┐  ┌──────────┐  ┌───────────┐  ┌─────────────────┐
│ User  │  │ Source   │  │ Telemetry │  │  Orchestration  │
│Interact│  │of Truth  │  │&Observab. │  │  (Workflow)     │
└───────┘  └──────────┘  └───────────┘  └─────────────────┘
```

| # | ส่วนประกอบ | หน้าที่หลัก | ตัวอย่างเครื่องมือ |
|---|-----------|-----------|-----------------|
| 1 | **Network Infrastructure** | อุปกรณ์จริง/เสมือน | Router, Switch, VM, Cloud |
| 2 | **User Interactions** | ช่องทางที่มนุษย์ใช้สั่งงาน | CLI, Web UI, ChatOps, ITSM |
| 3 | **Source of Truth** | ข้อมูลสถานะที่ "ควรจะเป็น" | NetBox, YAML Files, Database |
| 4 | **Automation Engine** | ตัวสั่งงานอุปกรณ์จริง | Ansible, Nornir, Custom Script |
| 5 | **Telemetry & Observability** | ดูสถานะจริงแบบ Read-only | Grafana, Prometheus, ELK |
| 6 | **Orchestration** | กาวเชื่อมทุกส่วนเข้าด้วยกัน | Prefect, Airflow, Nautobot |

> 💡 **ข้อสำคัญ:** ทุกส่วนสื่อสารกันผ่าน **APIs** (แสดงเป็นลูกศรเส้นประใน Figure 14-1)

---

## 3. Overview + แนวทางเลือกเครื่องมือ

### 🛒 Build vs Buy — คำถามสำคัญก่อนเริ่ม

หนังสือแนะนำ **"Reuse ก่อนเสมอ"** เพราะการสร้างเองใช้ทรัพยากรมาก:

```
ลำดับการพิจารณา:
1. มีเครื่องมือสำเร็จรูปที่ทำได้ไหม?  → ใช้เลย
2. มีแต่ไม่ครบ?                       → เพิ่ม Config / Plugin
3. ไม่มีเลย?                           → สร้างเอง (พิจารณาผลกระทบระยะยาว)
```

### 📝 Architectural Decision Record (ADR)

หนังสือแนะนำให้บันทึกการตัดสินใจทุกครั้ง (GitHub ใช้วิธีนี้) เพื่อ:
- ให้คนอื่นเข้าใจว่าทำไมถึงเลือกแบบนี้
- บันทึกข้อจำกัดที่นำมาพิจารณา
- ใช้อ้างอิงในอนาคต

> 💡 **โยงกับ MyNetMate:** เรามีไฟล์ `Save-Restore Decision.md` ที่บันทึกการตัดสินใจแบบ ADR อยู่แล้ว

---

## 4. User Interactions (การปฏิสัมพันธ์กับผู้ใช้งาน)

### 🎯 หลักการสำคัญ: ออกแบบตาม Persona ของผู้ใช้

หนังสือเน้นว่า **"สิ่งเลวร้ายที่สุดคือสร้างอินเทอร์เฟซที่ไม่มีใครใช้"**

| กลุ่มผู้ใช้ | ต้องการอะไร | Interface ที่เหมาะ |
|-----------|-----------|-----------------|
| Network Engineer | ควบคุมได้มาก ยืดหยุ่น | CLI / API |
| NOC / Help Desk | ทำงานได้ทันที ไม่ต้องรู้ลึก | Web UI / Dashboard |
| Manager | เห็นภาพรวม | Dashboard / Report |
| End User ทั่วไป | ง่ายมาก Self-service | Service Portal |

### 📊 4 รูปแบบ Interface หลัก

#### 4.1 Graphical UI (GUI)

- **Web Portal** — Self-service สำหรับ Non-technical users
- **Dashboard** — แสดงสถานะแบบ Read-only (Grafana, Kibana, Power BI)
- **เครื่องมือที่มี UI ในตัว** — เช่น NetBox, Ansible Tower/AWX

#### 4.2 IT Service Management (ITSM)

ระบบออกตั๋ว (Ticketing) เชื่อมกับ Automation:

```
ผู้ใช้กรอก Form ใน ServiceNow
         ↓
ระบบสร้าง Ticket + รอ Approve
         ↓
Trigger → Ansible Playbook ทำงานอัตโนมัติ
         ↓
อัปเดตสถานะ Ticket กลับมาให้ผู้ใช้
```

**ตัวอย่างจากหนังสือ:** ServiceNow รับคำร้อง VLAN ใหม่ (VLAN 316) → Trigger Ansible job 3723 → Config อุปกรณ์จริง

**คุณสมบัติ ITSM ที่ดีต้องมี:**
- ✅ Validation ข้อมูลขาเข้า (เช่น ตรวจสอบ IPv6 format)
- ✅ Notification แจ้งขอ Approve
- ✅ Integration กับระบบภายนอกผ่าน API
- ✅ บันทึก Audit Trail

> ⚠️ **สำคัญ:** การใช้ ITSM ≠ มี Automation อัตโนมัติ ยังต้องสร้าง Logic Automation เพิ่ม

#### 4.3 ChatOps

ใช้แอปแชท (Slack, Teams, Webex) เป็น Interface สั่งงาน Automation:

```
วิศวกรพิมพ์ใน Slack:
/netops find ip 10.1.1.3

Bot ตอบกลับ:
→ พบ: sw-core-01 / GigabitEthernet0/5
→ MAC: aa:bb:cc:dd:ee:ff
```

**ประโยชน์:** ความรู้ของทีมสะสมอยู่ใน Bot ไม่หายเมื่อคนลาออก

#### 4.4 CLI / Text-based

เหมาะกับวิศวกรเครือข่ายที่คุ้นเคย CLI อยู่แล้ว:
- **GitOps Workflow** — Push ไปที่ Git → Trigger Automation
- **Shell Scripts** — สำหรับงาน Ad hoc ขนาดเล็ก

### ⚠️ ความท้าทาย: Data In vs Data Out

| ด้าน | ความท้าทาย | แนวทางแก้ |
|------|-----------|----------|
| **Data In** | ข้อมูลที่ผู้ใช้ป้อนต้องถูกต้อง | Validation + Schema |
| **Data In** | ผู้ใช้ป้อนข้อมูลมากเกินจำเป็น | ขอเฉพาะสิ่งจำเป็น |
| **Data Out** | แต่ละ Role ต้องการข้อมูลต่างกัน | ออกแบบ Output ตาม Persona |
| **Data Out** | ต้องการรู้ความคืบหน้าระหว่างทาง | Progress notification |

> 💡 **โยงกับ MyNetMate:** Frontend React ของเราคือ User Interaction Layer — ควรออกแบบ Form ให้ง่าย ขอแค่ข้อมูลที่จำเป็น และแสดง Progress ให้ผู้ใช้เห็น

---

## 5. Source of Truth (แหล่งข้อมูลความจริงหลัก)

### หน้าที่หลัก

**Source of Truth (SoT)** คือแหล่งข้อมูลที่บอกว่าเครือข่าย **"ควรจะเป็นอย่างไร"** (Intended State) ไม่ใช่สถานะจริงในขณะนั้น
- โซลูชันเครือข่ายอัตโนมัติจะประสบความสำเร็จได้ต่อเมื่อใช้กลยุทธ์ SoT (Data-first strategy)
- SoT อาจประกอบจากระบบเดียวหรือหลายระบบทำงานร่วมกัน
- ข้อมูลที่กรอกโดยมนุษย์หรือดึงจาก 3rd-party ต้องผ่านกระบวนการ ETL (Extract-Transform-Load) เพื่อรักษาคุณภาพ

### 6 มิติของคุณภาพข้อมูล (Data Quality)
ข้อมูลที่ดีต้องเชื่อถือได้ โดยประเมินจาก 6 มิติ:
1. **Completeness (ความครบถ้วน):** ข้อมูลครอบคลุมที่จำเป็นทั้งหมด
2. **Consistency (ความสอดคล้องกัน):** ไม่ขัดแย้งกันเอง จับคู่กันได้พอดี
3. **Validity (ความถูกต้อง):** ตรงตามรูปแบบ (เช่น IPv4 ต้องถูกต้อง)
4. **Usability (ความสามารถในการใช้งาน):** ง่ายต่อการนำไปใช้ต่อผ่าน API
5. **Relevance (ความตรงประเด็นตามเวลา):** สอดคล้องในจังหวะที่เหมาะสม (ใช้ดูย้อนหลังได้)
6. **Accuracy (ความแม่นยำ):** สะท้อนเจตนาของเครือข่ายได้จริง (เช่น ASN และ IP ตรงกับหน่วยงาน)

### Data Use Cases และเครื่องมือ
- **Single use case:** NIPAP (จัดการ IP), Peering Manager (จัดการ BGP)
- **Multiple data use cases:** Nautobot, NetBox (มี Data models สำเร็จรูปพร้อมใช้งาน)

### Network Inventory
แอตทริบิวต์ 5 ประการที่ควรมีในคลังข้อมูลอุปกรณ์เครือข่าย:
1. **Name:** ชื่อระบุอุปกรณ์
2. **Location:** ตำแหน่งที่ตั้ง (ตู้ Rack หรือ Region บน Cloud)
3. **Type:** ประเภทบริการหรือรุ่นอุปกรณ์
4. **Connection details:** วิธีและ Credential ในการเชื่อมต่อ (IP/API)
5. **Status:** สถานะที่ต้องการ (Active/Planned)

### Data Center Infrastructure Management (DCIM)
เก็บข้อมูลกายภาพ เช่น ตู้แร็ค, สายเคเบิล, พลังงาน
- **Cable tracing:** หาว่า Interface ฝั่งนึงต่อกับอีกฝั่งนึงอย่างไร
- **Mismatch checking:** นำข้อมูลเจตนาไปเทียบกับข้อมูล LLDP ของจริงเพื่อหาข้อขัดแย้ง

### REST API vs GraphQL
- **REST API:** ต้องส่ง Request หลายครั้ง (เช่น `/api/site` → `/api/device` → `/api/interface`) แล้วนำมาประกอบเอง
- **GraphQL:** ยิง Request เดียว ระบุ Query ชัดเจน ได้ข้อมูลครบถ้วนแบบ Nested (ลดจำนวน Request ลงมหาศาล)

> 💡 **โยงกับ MyNetMate:** PostgreSQL ของเราทำหน้าที่เป็น Source of Truth (Inventory, VLAN, Template DB) เราอาจไม่ได้ใช้ GraphQL แต่เราออกแบบ API ฝั่ง Backend ให้ดึงข้อมูลครบในครั้งเดียวได้ถ้าจำเป็น

---

## 6. Automation Engine (ตัวสั่งงานอัตโนมัติ)

Automation Engine เปลี่ยนสถานะเครือข่ายโดยตรง จึงต้องทำอย่างระมัดระวัง แบ่งเป็น 4 ขั้นตอนการจัดการการตั้งค่า:

### 1. Configuration Backup (สำรองข้อมูล)
สำรองข้อมูลการตั้งค่าจริง (Actual state) เพื่อใช้อ้างอิงหรือ Rollback
- **เครื่องมือ:** RANCID หรือเก็บใน Git (Version Control)
- **ข้อควรระวัง:** ต้องลบข้อมูลความลับ (Secrets) เช่น MD5 keys หรือรหัสผ่าน ก่อนจัดเก็บเสมอ

### 2. Configuration Rendering (เรนเดอร์เทมเพลต)
แปลง Intent เป็นไฟล์การตั้งค่า (Configuration artifacts) โดยเอา "ข้อมูล" จาก SoT มารวมกับ "เทมเพลต"
- **กฎเหล็ก (Data Hierarchy):** The more specific wins (ข้อมูลที่เฉพาะเจาะจงกว่าย่อมชนะ เช่น NTP ของ Site ชนะ NTP ส่วนกลาง)
- **คำเตือน:** เครือข่ายที่ไม่มีมาตรฐานเฉพาะตัว (Snowflake) จะทำให้เกิดโค้ดสปาเกตตี

### 3. Configuration Compliance (ตรวจสอบความสอดคล้อง)
เปรียบเทียบ "ตั้งค่าจริง" กับ "ตั้งค่าที่ควรจะเป็น" เพื่อหาความคลาดเคลื่อน (Drift)
- **เครื่องมือ:** Batfish, Cisco pyATS/Genie, NTC Templates

### 4. Configuration Deployment (นำไปใช้งานจริง)
ดัน Config ขึ้นอุปกรณ์จริง
- **การลดความเสี่ยง:** ต้องมี Dry-run, ทดสอบใน Lab (Emulation), และมี Rollback (เช่น commit-confirm)
- **เครื่องมือ:**
  - *Custom:* Netmiko, NAPALM, ncclient, Scrapli
  - *Multipurpose:* Ansible, Terraform
  - *Vendor:* Cisco Crosswork NSO, Juniper Apstra

### Operations (การปฏิบัติการ)
งานที่ไม่เกี่ยวกับการเปลี่ยน Config เช่น Reboot, Ping, Traceroute, File Transfer, OS Upgrade

> 💡 **โยงกับ MyNetMate:** FastAPI ทำตัวเป็น Automation Engine รัน Jinja2 เพื่อทำ Rendering (ขั้นตอน 2) และใช้ Netmiko ดัน Config ไปอุปกรณ์ (ขั้นตอน 4) และยังช่วยทำ Backup (ขั้นตอน 1) ได้ด้วย

---

## 7. Telemetry and Observability (โทรมาตรและการสังเกตระบบ)

เปลี่ยนจากการ Monitor ธรรมดา เป็นการหาคำตอบว่า "ทำไมถึงพัง" และ "กระทบธุรกิจอย่างไร"

### ประเภทของข้อมูล Operational State (Data is King)
1. **Metrics (มาตรวัด):** ข้อมูลตัวเลข + Timestamp + Labels (เช่น จำนวน Octets, CPU%)
2. **Logs (บันทึกเหตุการณ์):** ข้อความ Syslog ที่ต้องถูก Parse ก่อน เช่น Logstash (grok)
3. **Traces (ร่องรอย):** ติดตามคำขอตั้งแต่ต้นจนจบ (End-to-end) ในระบบ Microservices (เช่น OpenTelemetry, Cisco AppDynamics)
4. **Flows (กระแสข้อมูล):** สื่อสารระหว่าง IP แบบหลายมิติ (NetFlow, sFlow, IPFIX)
5. **Packet Capture:** ละเอียดสุด แต่กินทรัพยากร/Memory หนักสุด (tcpdump, Wireshark)

### การรวบรวมข้อมูล
- **SNMP / CLI:** แบบ Pull ดั้งเดิม (⚠️ *คำเตือนจากหนังสือ:* การดึงข้อมูลด้วยการ Scrape CLI (ขูดข้อความ) เปราะบาง ช้า และบำรุงรักษายาก ควรหลีกเลี่ยง)
- **Syslog / Flow:** ส่งออกแบบ UDP (Push) ไปหา Collector (ไม่รับประกันการถึง)
- **API / Streaming:** ทันสมัย ยืดหยุ่น และมีโครงสร้าง

### โครงสร้าง Stack ของ Observability
1. **Collector:** ดึงและแปลงข้อมูลให้เป็นมาตรฐาน (Telegraf, Logstash, Fluentd)
2. **SoT Enrichment:** เติม Metadata (เช่น Site, Role) ให้ข้อมูลดิบ
3. **Data Distribution:** กระจายข้อมูลด้วย Message queues สำหรับรับ Load มหาศาล (Kafka, MQTT/Mosquitto)
4. **Storage:**
   - *Time-Series (TSDB):* สำหรับ Metrics (InfluxDB, Prometheus, TimescaleDB)
   - *Search Engines (NoSQL):* สำหรับ Log/Flow (Elasticsearch)
5. **Visualization:** Dashboards (Grafana, Kibana)
6. **Alerting:** แจ้งเตือนกระตุ้นคนหรือ Workflow
7. **Orchestration:** วางคิวเชื่อมกระบวนการอัตโนมัติ

**ชุดเครื่องมือยอดนิยม:**
- **TPG:** Telegraf + Prometheus + Grafana
- **TIG:** Telegraf + InfluxDB + Grafana
- **ELK:** Elasticsearch + Logstash + Kibana

### Synthetic Monitoring
การจำลองพฤติกรรมผู้ใช้ ยิงทราฟฟิกทดสอบ (ICMP, IP SLA, DNS, HTTP) เพื่อทดสอบ Delay / Loss ในมุมมองคนใช้งานจริง

---

## 8. Orchestration (ระบบควบคุมสั่งการ) + Closed-loop

**Orchestration** ทำหน้าที่กำหนดลำดับและเงื่อนไขของ Workflow เป็น "กาว" เชื่อมต่อระบบทั้งหมดเข้าด้วยกัน
- รองรับการทำ **Closed-loop Automation** (ระบบแก้ปัญหาเองอัตโนมัติ)
  - *ตัวอย่างที่ทรงพลังที่สุด:* Telemetry ตรวจพบปัญหา (เช่น CPU สูงมากผิดปกติ) -> Orchestrator รับ Alert -> สั่ง Automation Engine รีสตาร์ท BGP Session -> Telemetry ยืนยันว่าหายพัง -> ทั้งหมดนี้ทำโดยที่ไม่มีมนุษย์เข้ามาแทรกแซง!

---

## 🏗️ Architecture ของ MyNetMate เทียบกับ Chapter 14

| Component (Ch.14) | สิ่งที่ MyNetMate ใช้ |
|-------------------|----------------------|
| **Network Infrastructure** | Cisco IOS, MikroTik RouterOS, Huawei VRP |
| **User Interactions** | React Frontend (Web UI) |
| **Source of Truth** | PostgreSQL (Inventory + VLAN + Template DB) |
| **Automation Engine** | FastAPI + Jinja2 + Netmiko/NAPALM |
| **Telemetry** | Pull Config via SSH → Security Audit (เรายังใช้ CLI Scrape บ้างเพราะยังใช้ Netmiko) |
| **Orchestration** | FastAPI Scheduler + Event-triggered Backup |

```
React UI (User Interactions)
    ↓
FastAPI (Automation Engine + Orchestration)
    ├── PostgreSQL (Source of Truth)
    ├── Jinja2 (Template Engine)
    ├── Netmiko (Network Connection)
    ├── Presidio (PII Masking)
    └── Gemini API (AI Assist — 20%)
    ↓
Network Devices (Infrastructure)
```

---

## 🏆 Best Practices จากบทนี้

| #   | หลักการ                      | รายละเอียด                                                               |
| --- | ---------------------------- | ------------------------------------------------------------------------ |
| 1   | **เข้าใจก่อน Automate**      | ต้องรู้ Process เดิมก่อนจะทำให้เป็น Automation                           |
| 2   | **ออกแบบตาม Persona**        | UI ต้องเหมาะกับผู้ใช้แต่ละกลุ่ม                                          |
| 3   | **Single Source of Truth**   | ข้อมูลต้องมีที่เดียว ไม่ซ้ำซ้อน และต้องมี Data Quality 6 มิติ            |
| 4   | **Reuse ก่อน Build**         | ใช้เครื่องมือที่มีอยู่ก่อนสร้างเอง                                       |
| 5   | **บันทึก Decisions (ADR)**   | เหตุผลการตัดสินใจต้องบันทึกไว้                                           |
| 6   | **The more specific wins**   | ข้อมูลที่เจาะจงกว่า ย่อมมีความสำคัญกว่า Global                           |
| 7   | **เลี่ยง Scrape CLI**        | การขูด Text จาก CLI เปราะบาง พังง่าย (ควรไปใช้ API/NETCONF ถ้าเป็นไปได้) |
| 8   | **Closed-loop เป็นเป้าหมาย** | ระยะยาวต้องการให้ระบบแก้ปัญหาเองได้ (Self-healing)                       |
|     |                              |                                                                          |
