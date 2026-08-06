# 📚 บทสรุปเจาะลึก Ch.12: Automation Tools (ส่วนที่ 3 - Nornir)
> **ที่มา:** Network Programmability and Automation (2nd Ed.) | Chapter 12
> **เป้าหมาย:** ทำความรู้จัก Nornir ซึ่งเป็น Framework ที่มี **สถาปัตยกรรมใกล้เคียงกับโปรเจกต์ MyNetMate ของเรามากที่สุด**

---

## 🐍 ทำไมถึงต้องมี Nornir?
แม้ Ansible จะใช้งานง่ายด้วยภาษา YAML แต่จุดอ่อนสำคัญคือ **"มันแก้ปัญหาที่ซับซ้อนได้ยาก (Complex Logic) และ Debug หาจุดผิดพลาดลำบากมาก"** เพราะ YAML ไม่ใช่ภาษาโปรแกรมมิ่ง

**Nornir** จึงถูกสร้างขึ้นมาเพื่อแก้ปัญหานี้ โดยมัน **"ไม่ใช่ภาษาใหม่"** และไม่ใช่แอปพลิเคชันแบบ Ansible แต่มันคือ **"Python Framework (Pure Python)"** 
แปลว่า ถ้าคุณเขียน Python เป็น คุณก็ใช้งาน Nornir ได้เลย! คุณมีอิสระในการเขียน `if-else`, `for-loop`, จัดการ Exception และใช้ไลบรารี Python ทุกตัวบนโลกมาเชื่อมต่อกันได้อย่างไร้ขีดจำกัด

---

## 🚀 จุดเด่นและสถาปัตยกรรมของ Nornir

### 1. ความเร็วระดับปีศาจด้วย Multithreading (Concurrency)
โดยปกติถ้าคุณเขียน Python (เช่น ใช้ Netmiko) ยิงไปหา Router 100 ตัว มันจะทำทีละตัว (Sequential) กว่าจะเสร็จอาจใช้เวลาครึ่งชั่วโมง
แต่ **Nornir รองรับ Multithreading เป็นค่าเริ่มต้น (By Default)!** เมื่อคุณกดสั่งงาน 1 ครั้ง Nornir จะแตก Thread วิ่งไปคุยกับ Router 100 ตัวพร้อมกันทันที ทำให้ประหยัดเวลาอย่างมหาศาล

### 2. โครงสร้างการทำงาน (Inventory & Tasks)
- **Inventory (คลังอุปกรณ์):** Nornir จัดการข้อมูลผ่านปลั๊กอิน แบ่งเป็น 3 ส่วนคล้าย Ansible คือ `config.yaml`, `hosts.yaml` (บัญชีอุปกรณ์), และ `groups.yaml` (ตัวแปรกลุ่ม)
- **Task & Result:** โครงสร้างหลักคือคุณเขียนฟังก์ชัน Python (Task) โง่ๆ 1 ฟังก์ชันที่รับหน้าที่จัดการงาน 1 อย่าง แล้วส่งเข้า Nornir ไปรัน (Run) Nornir จะทำหน้าที่โยนฟังก์ชันนั้นไปจัดการกับ Host ทุกตัว แล้วคืนผลลัพธ์กลับมาเป็น Object `Result` ที่เป็นระเบียบสวยงาม

### 3. ระบบ Plugins (ต่อยอดได้ไม่รู้จบ)
Nornir ตัวเปล่าๆ ทำอะไรไม่ได้มาก แต่มันเก่งขึ้นได้ด้วยระบบ Plugin เช่น:
- **Inventory Plugin:** ไปดึงรายชื่ออุปกรณ์จาก NetBox หรือ Nautobot มาแทนการอ่านไฟล์ `.yaml`
- **Connection Plugin:** ปลั๊กอินยอดฮิตคือ `nornir-netmiko` (ใช่ครับ! ตัวเดียวกับที่เราใช้) และ `nornir-napalm`
- **Processor Plugin:** จัดการผลลัพธ์ก่อนปริ้นต์ออกหน้าจอ

---

## 🌐 พระเอกขี่ม้าขาว: NAPALM
ในระบบเครือข่าย ปัญหาโลกแตกคือ "แต่ละยี่ห้อใช้คำสั่งไม่เหมือนกัน" (Cisco ใช้ `show ip bgp summary` ส่วน Juniper ใช้ `show bgp summary`)

**NAPALM (Network Automation and Programmability Abstraction Layer with Multivendor support)** ถูกสร้างมาแก้ปัญหานี้โดยเฉพาะ! 
มันคือเครื่องมือ (มักใช้คู่กับ Nornir) ที่ทำหน้าที่เป็น **"ล่ามแปลภาษา (Abstraction Layer)"** 
เพียงคุณสั่ง `get_bgp_neighbors()` NAPALM จะไปหาวิธีคุยกับอุปกรณ์แต่ละยี่ห้อเอง แล้วคืนผลลัพธ์ออกมาเป็นโครงสร้าง Dictionary/JSON มาตรฐานหน้าตาเหมือนกันเป๊ะ ไม่ว่าอุปกรณ์นั้นจะเป็นยี่ห้อไหนก็ตาม

### การทำ Configuration Management ด้วย NAPALM
NAPALM มีความสามารถในการ Deploy Config ได้ 2 แบบ:
1. **Configuration Merge:** ส่งโค้ดบางส่วนไป "แปะเพิ่ม" (คล้ายที่ทำใน CLI ทั่วไป)
2. **Configuration Replace (Declarative):** ส่งโค้ด Config แบบเต็มรูปแบบไป "ทับ" ของเดิมทั้งหมด (เหมาะกับ DevOps/IaC)

นอกจากนี้ยังมีฟีเจอร์ **Dry Run (ทดสอบก่อนรันจริง)** เพื่อดูความแตกต่าง (Diff) ระหว่าง Config เก่าและใหม่ก่อนจะสั่ง Commit ด้วย

---

## 🔗 ถอดบทเรียนประยุกต์ใช้กับ MyNetMate

หัวข้อนี้เปรียบเสมือน **"กระจกสะท้อนโปรเจกต์ MyNetMate"** ของเราเลยครับ! สถาปัตยกรรมของเรากับ Nornir แทบจะเป็นแฝดกัน:

1. **Pure Python Architecture:** MyNetMate ใช้ FastAPI + Netmiko ซึ่งเป็น Python ล้วนๆ เหมือนกับที่ Nornir ทำ การใช้ Python ทำให้เราสามารถเชื่อมต่อกับ AI (Gemini) และจัดการ Database (PostgreSQL) ได้ง่ายกว่าการใช้ Ansible
2. **แนวคิด Multivendor Abstraction:** เราไม่ได้ใช้ไลบรารี NAPALM ตรงๆ แต่ **"เรากำลังสร้าง NAPALM ของเราเอง"** ด้วยการใช้ TextFSM ปรับแต่งผลลัพธ์ของ Cisco, MikroTik และ Huawei ให้กลายเป็น JSON กลาง (Normalized Data) ส่งให้หน้าเว็บ React นำไปแสดงผล
3. **ฟีเจอร์ Dry Run & Configuration Replace:** นี่คือไอเดียฟีเจอร์เด็ด! ก่อนที่เราจะให้ AI (Gemini) สั่ง Config ลงอุปกรณ์จริง เราอาจจะเขียน Backend ให้รับคำสั่งมาทำเป็น "แผน (Plan/Preview)" ส่งให้ผู้ใช้รีวิวก่อน แล้วค่อยกด Commit จริง (คล้ายๆ ฟีเจอร์ Impact Analysis)
4. **Multithreading (จุดที่ต้องพัฒนาต่อ):** ในอนาคต ถ้า MyNetMate ต้องดูแลเครือข่ายที่ใหญ่ขึ้น เราควรนำแนวคิด Multithreading หรือ Async (ของ FastAPI/asyncssh) มาปรับใช้ เพื่อให้ระบบสแกนตรวจสอบสถานะอุปกรณ์ทั้งหมดได้พร้อมกันอย่างรวดเร็ว

> **💡 บทสรุป:** การเรียนรู้ Nornir ช่วยยืนยันว่าการใช้ Python + Netmiko ควบคุม Network อย่างที่เรากำลังทำ เป็นวิธีของโปรแกรมเมอร์ยุคใหม่ (DevOps/NetDevOps) ที่ต้องการอิสระและความยืดหยุ่นระดับสูงครับ!
