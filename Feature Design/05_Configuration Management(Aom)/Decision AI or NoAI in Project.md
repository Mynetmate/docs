หลักการตัดสินใจมีแค่ 1 คำถามครับ:

> **"งานนี้มีคำตอบที่ถูกต้องเพียง 1 คำตอบไหม?"**
> 
> - ถ้า **ใช่** → ใช้ Rule-based / Template / Algorithm
> - ถ้า **ไม่ใช่** → พิจารณาใช้ AI

## 🔴 ส่วนที่ **ไม่ควรใช้ AI** (ใช้ Rule-based / Template แทน)

### 1. Config Generation จาก Form (Template-based)

**เหตุผล:**

```
User กรอก: VLAN ID = 10, Name = MGMT, SVI IP = 10.0.0.1/24

Template ตอบได้ 100% แม่น ทุกครั้ง:

  vlan 10

   name MGMT

  interface Vlan10

   ip address 10.0.0.1 255.255.255.0

   no shutdown

ถ้าให้ AI ตอบ:

  - บางครั้งอาจใส่ "description" ที่ไม่ได้ขอ

  - บางครั้งลืม "no shutdown"

  - บางครั้ง syntax ผิดเล็กน้อย

  → Config ที่ Push ไปอุปกรณ์จริงพัง!
```

**กฎเหล็ก:** อะไรที่ Push ไปอุปกรณ์จริง **ห้ามใช้ AI เป็น Primary** ครับ
### 2. CIS Benchmark Validation (Security Rules)

```
CIS Rule #1: "SSH v2 ต้องเปิด"
→ แค่ grep หา "ip ssh version 2" ใน config → True/False

AI ถ้าถามว่า config นี้ปลอดภัยไหม:
→ อาจตอบ "ดูโอเค" ทั้งที่ Telnet ยังเปิดอยู่
→ False Positive/Negative rate สูงกว่า Regex มาก
→ ไม่ Deterministic (ถามซ้ำได้คำตอบต่างกัน)
```

### 3. PII Masking (ก่อนส่ง AI)

```
# Password มี Pattern ชัดเจน → Regex จัดการได้ 100%
pattern_password = r'(enable secret|password|key)\s+\S+'
pattern_ip       = r'\b\d{1,3}(\.\d{1,3}){3}\b'
pattern_snmp     = r'(community)\s+\S+'

# ถ้าใช้ AI ตรวจ PII:
# - ต้องส่งข้อมูลที่มี sensitive data ออกไปก่อน = แพ้แต่แรก!
# - ขัดกับวัตถุประสงค์หลัก (ห้าม password ออกไป LLM)
```

**กฎเหล็ก:** PII Masking ต้องเกิดก่อนส่ง AI เสมอ จะใช้ AI ทำ PII Masking ไม่ได้

### 4. Network Discovery
```
ARP Sweep, Ping Sweep, SNMP Walk, LLDP/CDP

= Protocol มาตรฐาน IEEE/RFC ที่มีวิธีทำชัดเจน

= ไม่มีความคลุมเครือ อุปกรณ์ตอบหรือไม่ตอบ

AI ไม่ได้ช่วยอะไรในการ "ส่ง Packet ไปถามอุปกรณ์"
```

### 5. Config Diff (Version Control)
```
**เหตุผล:**

Myers Diff Algorithm → แม่น 100% บอกบรรทัดที่เปลี่ยนทุกบรรทัด

AI → อาจสรุป Diff ให้ Human อ่านง่าย แต่ไม่ควรใช้คำนวณ Diff จริง
```

### 6. Deploy via SSH (Push Config ไปอุปกรณ์จริง)

**เหตุผล:**

Netmiko ส่ง CLI command ไปทีละบรรทัด

→ ต้อง Exact Match กับ Vendor Syntax 100%

→ ผิดแม้แต่ช่องว่าง 1 ตัว → อุปกรณ์ Error หรือพัง

AI ห้ามอยู่ใน Loop นี้โดยเด็ดขาด

---

## 🟢 ส่วนที่ **ควรใช้ AI** (AI เพิ่มมูลค่าได้จริง)

### 1. Config Generation จาก Natural Language (Free-text)

**เหตุผล:**

User พิมพ์: "ตั้งค่า OSPF ระหว่าง R1 กับ R2 ให้ใช้ Area 0 

             และ Summarize subnet 10.0.0.0/8 ออกไป"

Template ทำไม่ได้ เพราะ:

- ต้องตีความว่า R1 กับ R2 คือตัวไหนใน Inventory

- ต้องรู้ว่า Summarization syntax ของ IOS คืออะไร

- ต้องดึง Context จาก Inventory มาประกอบ

AI (Gemini + Context จาก Inventory) ทำได้ดีกว่า Template

แต่ต้อง Flag ว่า "⚠️ AI-generated — Review before deploy"

---

### 2. Security Audit / Review (หลัง Config ถูก Generate แล้ว)

**เหตุผล:**

หลัง Template Gen Config ออกมาแล้ว:

→ CIS Rule-based ตรวจ 24 กฎ (Pass/Fail)

→ AI ตรวจเพิ่มเติมในเชิง "ความเหมาะสมโดยรวม"

ตัวอย่างที่ AI ทำได้แต่ Rule ทำไม่ได้:

- "ACL นี้กว้างเกินไป อาจเปิดช่อง Lateral Movement"

- "OSPF ไม่มี Authentication อาจถูก Spoofing"

- "VLAN 1 ยังเปิดอยู่บน Trunk — Security Risk"

= นี่คือ "Ask AI to review" ปุ่มใน Mockup ของเพื่อน

---

### 3. RAG (Retrieval Augmented Generation) สำหรับเอกสาร Vendor

**เหตุผล:**

กรณี: User ถามว่า "ตั้งค่า MACsec บน Cisco IOS XE 17.9 ยังไง"

Template ไม่มี → AI ปกติอาจ Hallucinate Syntax ผิด

RAG ช่วย:

→ ดึง Cisco IOS XE 17.9 Config Guide มา

→ หน้าที่เกี่ยวกับ MACsec

→ ใช้เป็น Context ให้ AI Gen Config ที่ถูกต้อง

= ตอบคำถามอาจารย์ว่า "ถ้ามีอุปกรณ์ใหม่ล่าสุดทำยังไง"

→ แค่เพิ่ม Document ใน Vector DB ไม่ต้องแก้ Code

---

### 4. Auto-summary / Documentation

**เหตุผล:**

Config ที่เก็บใน Inventory → AI สรุปเป็น Human-readable:

"Router R1 มี 4 Interface, ต่อกับ R2 ผ่าน OSPF Area 0,

มี ACL ป้องกัน Management Subnet และ NTP sync กับ 1.th.pool.ntp.org"

Rule-based ทำได้แค่แสดง Raw Config → อ่านยาก

AI ทำให้ Network Engineer ใหม่ onboard ได้เร็วขึ้น

แต่ต้องมี Human ใส่ Business Context เพิ่ม

เช่น "VLAN 10 = แผนก HR" AI ไม่รู้เอง

---

### 5. Natural Language Query บน Version History

**เหตุผล:**

User ถามว่า: "ใครแก้ Config R1 ในสัปดาห์ที่แล้ว และเปลี่ยนอะไรบ้าง"

SQL Query ทำได้ แต่ต้องรู้ว่าจะ Query ยังไง

AI รับ Natural Language → แปลงเป็น Query → แสดงผล

= ช่วย IT Admin ที่ไม่ถนัด SQL ใช้ระบบได้

---

## 📊 ตารางสรุปทั้งโปรเจกต์
```

Feature                        │ Template/Rule │ AI      │ เหตุผลหลัก

───────────────────────────────┼───────────────┼─────────┼─────────────────────────

Config Gen (Form-based)        │ ✅ PRIMARY    │ ❌      │ ต้อง 100% แม่น ก่อน Deploy

Config Gen (Free-text)         │ ❌            │ ✅      │ ต้องตีความ Natural Language

CIS Validation                 │ ✅ PRIMARY    │ ❌      │ Deterministic 24 กฎ

Security Audit (holistic)      │ ❌            │ ✅      │ ต้องมอง Context รวม

PII Masking                    │ ✅ PRIMARY    │ ❌      │ ต้องทำก่อนส่ง AI เสมอ

Network Discovery              │ ✅ PRIMARY    │ ❌      │ Protocol-based ไม่มี gray area

Config Diff                    │ ✅ PRIMARY    │ ❌      │ Algorithm แม่นกว่า AI

Version Control Storage        │ ✅ PRIMARY    │ ❌      │ Pure DB operation

Deploy via SSH                 │ ✅ PRIMARY    │ ❌      │ Exact syntax → ห้าม AI ใน loop

RAG (Vendor Docs)              │ ❌            │ ✅      │ ดึงความรู้ที่ Template ไม่มี

Auto-documentation             │ ❌            │ ✅      │ Human-readable summary

NL Query บน History            │ ❌            │ ✅      │ ตีความภาษาธรรมชาติ

---

## 🏗️ สรุปเป็น Architecture

                    ┌─────────────────────────────┐

                    │         User Request         │

                    └──────────────┬──────────────┘

                                   │

              ┌────────────────────▼────────────────────┐

              │          มีค่าที่แน่นอนในใจอยู่แล้วไหม?          │

              └────────────────────┬────────────────────┘

                      │                        │

                    ใช่                       ไม่ใช่

                      │                        │

          ┌───────────▼──────────┐  ┌──────────▼───────────┐

          │  Template / Rule /   │  │     AI Layer          │

          │  Algorithm           │  │  (Gemini + RAG)       │

          │                      │  │                       │

          │  - Jinja2 Template   │  │  - Free-text Config   │

          │  - CIS Rule Engine   │  │  - Security Audit     │

          │  - Myers Diff        │  │  - Auto-doc           │

          │  - Presidio (PII)    │  │  - NL Query           │

          │  - Netmiko (SSH)     │  │                       │

          │  - SNMP/ARP          │  │  ⚠️ Flag: AI-generated │

          └──────────────────────┘  │  ⚠️ PII Masked ก่อน   │

                                    └───────────────────────┘

---
```

> **สรุปหลักการ 1 ประโยค:** _"ใช้ AI เมื่อต้องการ 'ความเข้าใจ' ไม่ใช้ AI เมื่อต้องการ 'ความถูกต้อง'"_
> 
> เพราะในระบบ Network Automation ถ้า Config ผิด 1 บรรทัด = เน็ตเวิร์กล่มทั้งองค์กรครับ

