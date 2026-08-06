# 📚 บทสรุปเจาะลึก Ch.12: Automation Tools (ส่วนที่ 1 - ภาพรวม)
> **ที่มา:** Network Programmability and Automation (2nd Ed.) | Chapter 12
> **เป้าหมาย:** ทำความเข้าใจภาพรวมของเครื่องมือ Automation ทั้ง 3 ตัว และมิติความแตกต่างของสถาปัตยกรรม เพื่อนำมาเทียบเคียงกับโปรเจกต์ MyNetMate

---

## 🗺️ ภาพรวมของ Automation Tools
ในอดีต เครื่องมือ Automation ถูกสร้างมาเพื่อจัดการฝั่ง Server เป็นหลัก แต่ปัจจุบันได้ถูกพัฒนาให้รองรับ Network Devices ได้อย่างสมบูรณ์แบบ ในบทนี้จะเน้นไปที่ 3 เครื่องมือหลักซึ่งเป็น Open Source ที่ได้รับความนิยมสูงสุด ได้แก่:

1. **Ansible:** เน้นเรื่องการตั้งค่า (Configuration Management) ใช้งานง่าย ไม่ต้องลงโปรแกรมที่ปลายทาง (Agentless)
2. **Nornir:** เป็น Framework สำหรับเขียน Python โดยตรง ยืดหยุ่นสูงและทำงานแบบขนาน (Multithreading) ได้รวดเร็ว
3. **Terraform:** เน้นเรื่องการสร้างโครงสร้างพื้นฐาน (Infrastructure Provisioning / IaC) บน Cloud เป็นหลัก

---

## 🏗️ 7 มิติความแตกต่างของสถาปัตยกรรม (Architectural Differences)

การจะเลือกใช้ Tool ตัวไหน ต้องเข้าใจปรัชญาเบื้องหลังของมันก่อนครับ:

### 1. Configuration Management vs. Infrastructure Provisioning
- **Infrastructure Provisioning (Day 0):** คือการ "สร้าง" สิ่งที่ยังไม่มีให้มีขึ้นมา เช่น สร้าง VM สร้าง Database สร้าง VPC (Terraform เก่งเรื่องนี้)
- **Configuration Management (Day 1):** คือการ "ตั้งค่า" สิ่งที่มีอยู่แล้วให้ทำงานตามที่ต้องการ เช่น สั่ง Config OSPF, อัปเดต Firmware (Ansible เก่งเรื่องนี้)
- **เทียบกับ MyNetMate:** โปรเจกต์เราเน้นไปที่ Day 1 เป็นหลักครับ คือการเข้าไปจัดการและตั้งค่า Network Device ที่เปิดใช้งานอยู่แล้ว

### 2. Agent-based vs. Agentless
- **Agent-based:** ต้องเอาโปรแกรมเล็กๆ (Agent) ไปติดตั้งฝั่งอุปกรณ์ปลายทางก่อนถึงจะสั่งงานได้ (ซึ่ง Network Device มักจะทำไม่ได้)
- **Agentless:** ไม่ต้องลงโปรแกรมปลายทาง แค่ใช้ Protocol มาตรฐานอย่าง SSH เข้าไปสั่งงานก็พอ
- **เทียบกับ MyNetMate:** เราใช้แนวทาง **Agentless** ผ่าน Netmiko (SSH) ซึ่งถูกต้องและเหมาะสมกับ Network Automation ที่สุดครับ

### 3. Push vs. Pull vs. Event-driven
- **Push:** เราเป็นคนส่งคำสั่งจากศูนย์กลางผลักออกไปยังอุปกรณ์ปลายทาง (Ansible, Nornir ใช้แบบนี้)
- **Pull:** อุปกรณ์ปลายทางจะตั้งเวลาวิ่งมาถามศูนย์กลางเองว่ามีอัปเดตไหม แล้วดึงไปปรับใช้ (มักใช้ในฝั่ง Server)
- **Event-driven:** ทำงานเมื่อมีเหตุการณ์มากระตุ้น เช่น ทราฟฟิกเกินลิมิต ให้สั่งรันสคริปต์ทันที
- **เทียบกับ MyNetMate:** เราทำงานแบบ **Push Model** เป็นหลัก (User กดสั่งจากเว็บ แล้วส่งไปที่อุปกรณ์)

### 4. Declarative vs. Imperative
- **Declarative (บอกผลลัพธ์):** บอกแค่ว่า "อยากได้อะไร" เดี๋ยวเครื่องมือไปหาวิธีทำมาให้เอง (เช่น Terraform)
- **Imperative (บอกขั้นตอน):** บอกแบบทีละสเต็ป 1..2..3.. (เช่น การเขียน Python script ทั่วไป)
- **เทียบกับ MyNetMate:** เราใช้แนวทาง **Imperative** (Netmiko สั่งทีละบรรทัด) แต่อนาคตสามารถปรับลอจิกให้คล้าย Declarative ได้โดยเช็กสถานะก่อน Config

### 5. Mutable vs. Immutable
- **Mutable:** เปลี่ยนแปลงค่าทับของเดิมไปเรื่อยๆ (Network Device ส่วนใหญ่เป็นแบบนี้)
- **Immutable:** ห้ามแก้ของเดิม ถ้าจะแก้ให้ทิ้งแล้วสร้างใหม่เลย (นิยมในฝั่ง Cloud/Docker)

### 6. State Management
- เครื่องมือบางตัว (เช่น Terraform) จะมีการเก็บ State (สถานะล่าสุด) ไว้เป็นไฟล์ เพื่อเปรียบเทียบว่าปัจจุบันระบบหน้าตาเป็นยังไง ถ้าใครไปแอบแก้ manual มันจะรู้ทันที
- เครื่องมือฝั่ง Network ส่วนใหญ่ (เช่น Ansible) มักจะไม่ค่อย track state ลึกขนาดนั้น
- **เทียบกับ MyNetMate:** การที่เราใช้ **PostgreSQL** เป็น Source of Truth คือการทำ State Management ที่ยอดเยี่ยมมากครับ!

---

## 🎯 สรุปจุดเด่น 3 เครื่องมือเทียบกับ MyNetMate

| Tool | จุดเด่น | ความเชื่อมโยงกับ MyNetMate |
|------|---------|---------------------------|
| **Ansible** | เขียนด้วย YAML อ่านง่าย, ใช้ SSH (Push) | เป็นคู่แข่ง/กรณีศึกษาที่ดี ในแง่ของการจัดการ Config และ Inventory |
| **Nornir** | Pure Python, เร็วมากด้วย Multithreading | **ใกล้เคียงเราที่สุด!** Architecture ของเราที่เป็น FastAPI + Netmiko ให้อิสระคล้าย Nornir |
| **Terraform** | Declarative, จัดการ State ได้ดีเยี่ยม | เรานำไอเดียเรื่อง "State Management (PostgreSQL)" และ "Preview ก่อน Deploy (Plan/Apply)" มาใช้ได้ |

> **💡 ข้อคิดสำหรับโปรเจกต์:** MyNetMate เดินมาถูกทางแล้วด้วยการใช้ Python เป็นแกนหลัก (เหมือน Nornir) แบบ Agentless (ผ่าน SSH) และมี Database เก็บ State (คล้ายแนวคิด Terraform) แถมเรายังมี **AI Co-pilot (Gemini)** ซึ่งเป็นจุดเด่นที่ 3 เครื่องมือในอดีตนี้ไม่มีครับ!
