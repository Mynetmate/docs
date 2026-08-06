# 📚 เจาะลึก Ch.5: LangChain for Networking (ส่วนที่ 3 - Recipe 5.2)
> **ที่มา:** AI Networking Cookbook (Packt) | Chapter 5
> **หัวข้อ:** Creating a Network Configuration Analyzer (สร้างระบบ AI วิเคราะห์ Config)

---

## 🧠 1. แนวคิด: AI ผู้ช่วยตรวจสอบความถูกต้อง (Configuration Analyzer)
ในชีวิตจริง วิศวกรเครือข่ายต้องปวดหัวกับการไล่อ่าน Config หลายร้อยบรรทัดเพื่อหาจุดผิดพลาด (Troubleshooting) หรือประเมินระบบเก่า
Recipe นี้เสนอแนวคิดสุดล้ำ: **"ทำไมไม่โยน Config ดิบๆ ไปให้ AI ช่วยอ่านแล้วสรุปปัญหาออกมาให้เลยล่ะ?"**

ขั้นตอนการทำงานมีเพียง 3 สเต็ปง่ายๆ:
1. **Load:** อ่านไฟล์ Config (Text file) จากโฟลเดอร์ในเครื่อง
2. **Prompt:** นำ Config นั้นไปต่อท้ายคำสั่ง (Prompt) ที่เขียนสั่งให้ AI สวมบทบาทเป็นผู้ตรวจสอบ
3. **Analyze:** ส่งข้อความทั้งหมดให้ AI และรับรายงานสรุปกลับมา

---

## 📝 2. การออกแบบ Prompt ที่ทรงพลัง (Prompt Design)
เพื่อให้ AI ตอบได้ตรงประเด็นและเป็นประโยชน์ต่อวิศวกรมากที่สุด ไม่ใช่แค่โยน Config เข้าไปเฉยๆ แต่ต้องเขียน Prompt บังคับทิศทางให้ชัดเจน ดังตัวอย่างในหนังสือ:

```text
Analyze this network configuration:
{config_text}

Please tell me:
1. What type of device is this? (อุปกรณ์นี้คืออะไร Router หรือ Switch?)
2. What is its main function? (หน้าที่หลักของมันทำอะไร?)
3. Any obvious issues or concerns? (มีจุดที่ผิดพลาด หรือน่าเป็นห่วงด้านความปลอดภัยไหม?)
Keep your response clear and practical for a network engineer.
```
*(สังเกตว่ามีการย้ำในบรรทัดสุดท้ายว่า ให้ตอบแบบกระชับ ใช้งานได้จริงสำหรับวิศวกร)*

---

## ⚠️ 3. ตัวอย่างปัญหาที่ AI สามารถสแกนเจอได้ทันที
เมื่อรันสคริปต์นี้กับ Config จำลอง ผลลัพธ์ที่ AI (แม้จะเป็นตัวเล็กอย่าง Llama2) สามารถตรวจพบได้ เช่น:
- **Missing default gateway:** ลืมตั้งค่า Gateway ทำให้ออกเน็ตไม่ได้
- **Incomplete OSPF:** ประกาศ OSPF แต่ Network statement ผิดพลาด หรือขาดหาย
- **Inconsistent IP addressing:** ขา Interface กับ Subnet mask ไม่สอดคล้องกัน
- **Security Risks:** 
  - ใช้พาสเวิร์ดเดาง่าย (เช่น `cisco123`) หรือเก็บพาสเวิร์ดแบบ Plain-text (`enable password` แทน `enable secret`)
  - เปิดใช้ `Telnet` (ไม่มีการเข้ารหัส) แทนที่จะใช้ `SSH`
  - Access-list (ACL) หละหลวมเกินไป เช่น `permit ip any any`

---

## 🔗 ถอดบทเรียนประยุกต์ใช้กับ MyNetMate
Recipe นี้คือ **"ฟีเจอร์หลัก (Core Feature)"** ของโปรเจกต์ MyNetMate เลยครับ! แต่ระบบของเราล้ำหน้ากว่าตัวอย่างในหนังสือมาก:

1. **เหนือกว่าเรื่อง Data Source:** หนังสือใช้วิธีโหลดไฟล์ Config `.txt` จากโฟลเดอร์ แต่ MyNetMate ของเราใช้ **Netmiko วิ่งเข้าไปดึง Config จริงจากอุปกรณ์ (Real-time)** หรือดึงประวัติ Config จาก PostgreSQL Database!
2. **Context-Aware Prompt:** ก่อนที่เราจะยัด Config ลงใน Prompt เรามีข้อมูลชั้นดีจาก Database (Vendor=Cisco, Role=Core Switch) เราจึงสามารถดัดแปลง Prompt ให้ AI แม่นยำขึ้นได้ เช่น *"ตรวจสอบ Config OSPF ของอุปกรณ์ Core Switch ยี่ห้อ Cisco รุ่น C3560 ตัวนี้..."*
3. **หน้าตาการใช้งาน (UI/UX):** แทนที่จะแสดงผลบน Command Line สีดำๆ หน้าเว็บ React ของเราจะสามารถนำข้อเสนอแนะจาก AI มาแบ่งเป็น หัวข้อสีแดง (Critical), สีเหลือง (Warning) ให้ดูสวยงามและใช้งานง่ายกว่ามากครับ!
