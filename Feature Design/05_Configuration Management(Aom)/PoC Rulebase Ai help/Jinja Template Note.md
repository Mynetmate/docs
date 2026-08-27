อ้างอิง https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960/software/release/15-2_2_e/configuration/guide/b_1522e_2960_2960c_2960s_2960sf_2960p_cg.html

Switch : C2960 Software
เลือกวิธีที่ : 2  ใช้ Python API

เลือก Model : Gemini 3.5 Flash Lite
RPM : 15
TPM : 250K
RPD : 500
https://ai.google.dev/gemini-api/docs/models/gemini-3.5-flash-lite

# Basic Config
## 1. VLAN ที่ถูกต้อง

```
! สร้าง VLAN
vlan [VLAN_ID]
 name [VLAN_NAME]

! นำ Port เข้า VLAN Access
interface [INTERFACE_NAME]
 switchport mode access
 switchport access vlan [VLAN_ID]
 no shutdown
```
[โครงสร้างข้อมูล JSON ที่จะรับเข้ามา]

**ขั้นตอนที่ 1: User กรอกฟอร์มที่หน้าเว็บ (Frontend - React)** สมมติว่าคุณกำลังใช้งานระบบ MyNetMate คุณคลิกเข้าไปที่แถบ **"Tab 3: VLANs"** แล้วพิมพ์กรอกข้อมูลลงในช่องฟอร์ม:
- รหัส VLAN: `10`
- ชื่อ VLAN: `IT_DEP`
- รหัส VLAN: `20`
- ชื่อ VLAN: `HR_DEP`

จากนั้นไปที่แถบ **"Tab 2: Interfaces"** แล้วตั้งค่าว่า:

- พอร์ต `GigabitEthernet0/1` ให้อยู่ใน VLAN `10`
- พอร์ต `GigabitEthernet0/2` ให้อยู่ใน VLAN `20`

**ขั้นตอนที่ 2: หน้าเว็บ (Frontend) รวบรวมข้อมูลแพ็คเป็น JSON** เมื่อกรอกเสร็จ โค้ดฝั่งหน้าเว็บ (React/Javascript) จะทำหน้าที่จับข้อมูลในกล่องข้อความทั้งหมดที่คุณเพิ่งกรอก มัดรวมกันให้กลายเป็นก้อนข้อมูล JSON หน้าตาแบบนี้ครับ:

```
{
  "vlans": [
    { "id": 10, "name": "IT_DEP" },
    { "id": 20, "name": "HR_DEP" }
  ],
  "access_ports": [
    { "name": "GigabitEthernet0/1", "vlan_id": 10 },
    { "name": "GigabitEthernet0/2", "vlan_id": 20 }
  ]
}
```

**ขั้นตอนที่ 3: ส่งข้ามมาที่หลังบ้าน (Backend - FastAPI)** พอ User กดปุ่ม `"Preview Config"` บนหน้าเว็บ หน้าเว็บจะยิงก้อน JSON เนี้ย ส่งผ่าน API มาให้ฝั่งหลังบ้าน (Backend)

**ขั้นตอนที่ 4: หลังบ้านเอา JSON ไปคลุกกับ Jinja2** นี่คือจุดที่เรากำลังทำ PoC กันครับ! ฝั่งหลังบ้าน (Python) จะรับก้อน JSON นี้มา แล้วเอาไปป้อนใส่ **Jinja2 Template** (ที่ให้ AI ช่วยแต่งโค้ดให้) ตัว Jinja2 จะใช้ For-loop วนอ่านข้อมูลใน JSON แล้วแปลงร่างมันออกมาเป็นคำสั่ง Cisco CLI (เช่น `vlan 10`, `interface Gig0/1`) ครับ
# VLAN : ผลลัพธ์การรันครั้งที่ 1 , 3.5 Flash Lite

```
 กำลังให้ AI (Gemini) เขียนโค้ด Jinja2 ให้...

✅ AI เขียน Jinja2 เสร็จแล้ว ได้ผลลัพธ์ดังนี้:

----------------------------------------
{% for vlan in vlans %}
vlan {{ vlan.id }}
 name {{ vlan.name }}
{% endfor %}

{% for port in access_ports %}
interface {{ port.name }}
 switchport mode access
 switchport access vlan {{ port.vlan_id }}
 no shutdown
{% endfor %}
----------------------------------------

🔄 กำลังทดสอบเรนเดอร์ (Render) โค้ดที่ AI ให้มา...

✅ Render สำเร็จ! นี่คือ Cisco CLI Config ที่ได้:

========================================
vlan 10
 name IT_DEP

vlan 20
 name HR_DEP

interface GigabitEthernet0/1
 switchport mode access
 switchport access vlan 10
 no shutdown

interface GigabitEthernet0/2
 switchport mode access
 switchport access vlan 20
 no shutdown

```

```
การใช้งาน Token ต่อ 1 รอบ
Gemini 3.5 Flash Lite
RPM : 1 / 15
TPM : 295 / 250K
RPM : 1 / 500
```
### 📊 สรุปผลการทดลอง PoC ครั้งที่ 1: การใช้ AI (Gemini 3.5 Flash Lite) เขียน Rule-based Template (ระดับ Basic - VLAN & Interface)

จากการส่ง JSON Data Schema และ Cisco Blueprint ให้ AI แต่งโค้ด Jinja2 ให้ ได้ผลการประเมินตามตัวชี้วัดดังนี้:

**1. Syntax Accuracy (ความแม่นยำของโค้ด) : รอด ✅**

- **ผลลัพธ์:** โค้ด Jinja2 ที่ AI สร้างขึ้นมา สามารถนำไป Render ใน Python ได้ทันทีโดยไม่เกิด Error (ไม่มีอาการ Syntax ผิดพลาดเลย)
- **การวิเคราะห์:** AI เข้าใจไวยากรณ์ของ Jinja2 (การใช้ `{% for ... %}` และ `{{ variable }}`) ได้อย่างถูกต้อง 100% ตั้งแต่ Prompt แรก

**2. Domain Correctness (ความถูกต้องทาง Network) : รอด ✅**

- **ผลลัพธ์:** CLI Configuration ที่ถูก Render ออกมา ตรงตาม Best Practice ของ Cisco IOS (C2960) ทุกประการ
- **การวิเคราะห์:** AI ไม่ได้แค่ก๊อปปี้ Blueprint มาแปะ แต่มันสามารถวนลูปสร้าง `vlan 10`, `vlan 20` และเชื่อม `interface GigabitEthernet` เข้าคู่กันได้อย่างถูกต้อง ไม่มีคำสั่งแปลกปลอม (Hallucination) โผล่มาให้เห็น

**3. Time-to-Code (ความประหยัดเวลา) : คุ้มค่ามาก ⏱️**

- **ผลลัพธ์:** ใช้เวลาประมวลผลผ่าน API เพียงไม่กี่วินาที (บวกกับเวลาเตรียม Prompt แค่ 1-2 นาที)
- **การวิเคราะห์:** หาก Engineer ต้องมานั่งเขียน Jinja2 For-loop นี้เองตั้งแต่ต้น อาจใช้เวลา 5-10 นาที (รวมเวลาตรวจเช็ค Syntax) การใช้ AI ช่วยลดภาระในส่วนนี้ได้อย่างชัดเจน
4. Prompt Iteration  : 1 Prompt


# Advance Config

สำหรับการทดสอบระดับ **Advanced** สิ่งที่เราต้องการพิสูจน์คือ **"AI สามารถเขียนเงื่อนไข (If-Else) ที่ซับซ้อน และเข้าใจความแตกต่างของอุปกรณ์ได้หรือไม่"** (ไม่ใช่แค่วน Loop ธรรมดาแบบข้อแรก)

จากตารางที่คุณให้มา ผมคัดเลือก **3 หัวข้อที่ดีที่สุด** ที่เหมาะจะเอามาทำ PoC ระดับ Advanced เพื่อโชว์อาจารย์ครับ:

---
### 🏆 อันดับ 1: หมวด Routing (ทดสอบ "ความฉลาดในการแยกแยะ Device Type")

**โจทย์: การทำ Inter-VLAN Routing (Subinterface VS SVI)**

- **ทำไมถึงควรเลือก:** จากตารางจะเห็นว่า 
	- Router ใช้ `Subinterface` 
	- ส่วน L3 Switch ใช้ `SVI` และต้องเปิด `ip routing` ด้วย หัวข้อนี้คือ "ตัวปราบเซียน" ของคนเขียน Jinja2 ครับ
- **สิ่งที่จะใช้ทดสอบ AI:** เราจะโยน JSON ที่มีข้อมูล VLAN/IP ไปให้ AI ก้อนเดียว แต่บอกมันว่าจงเขียน Jinja2 ให้รองรับทั้ง Router และ L3 Switch
- **ความคาดหวัง:** โค้ด Jinja2 ของ AI จะต้องมี 
	- `{% if device_type == 'router' %}` เพื่อคลอดคำสั่ง `interface Gig0/1.10` และ 
	- `encapsulation dot1q` ... และ
	- มี `{% elif device_type == 'l3_switch' %}` เพื่อคลอดคำสั่ง `ip routing` และ `interface Vlan10`
- **สรุป:** โชว์ให้อาจารย์เห็นว่า AI เข้าใจ Logic โครงสร้าง Network จริงๆ ไม่ใช่แค่ก๊อปแปะ

### 🥈 อันดับ 2: หมวด ACL (ทดสอบ "ความซับซ้อนของตัวแปรเสริม")

**โจทย์: Extended ACL และการ Apply เข้า Interface**

- **ทำไมถึงควรเลือก:** Extended ACL มีตัวแปรจุกจิกเยอะมาก (permit/deny, tcp/udp/ip, source, destination, eq port) การมานั่งเขียน Rule-based If-Else ดักทุกกรณีใน Jinja2 เป็นฝันร้ายของโปรแกรมเมอร์ครับ
- **สิ่งที่จะใช้ทดสอบ AI:** โยน JSON ที่เป็น Rule ของ Firewall ไปให้ AI สร้าง `ip access-list extended` และต้องนำไปผูกกับ Interface (`ip access-group IN/OUT`)
- **ความคาดหวัง:** AI ต้องสามารถเขียน Jinja2 ที่เช็คได้ว่า "ถ้ามี port ให้ใส่ eq port", "ถ้าเป็น any ให้ใส่ any" ได้อย่างสมบูรณ์
- **สรุป:** โชว์ให้อาจารย์เห็นว่า AI ช่วยลด "เวลา (Time-to-Code)" ในการเขียน Logic น่าปวดหัวได้มหาศาล

### 🥉 อันดับ 3: หมวด Routing (OSPF + Loopback)

**โจทย์: การตั้งค่า OSPF ที่มี Dependency**

- **ทำไมถึงควรเลือก:** OSPF เป็นเรื่องที่มีความสัมพันธ์ (Dependency) ระหว่างกัน เช่น จากตารางบอกว่า OSPF ต้องการ **Loopback** เพื่อใช้เป็น Router-ID
- **สิ่งที่จะใช้ทดสอบ AI:** โยน JSON ข้อมูล OSPF พื้นฐานไปให้
- **ความคาดหวัง:** AI ต้องรู้ตัวว่าถ้าใน JSON มีระบุ Loopback IP มาให้ มันจะต้องเอาไปใส่เป็น `router-id` ใน OSPF process ด้วย (ผ่าน `{% if loopback %}`)
- **สรุป:** โชว์การเขียน Template ที่คำนึงถึงความเชื่อมโยงของ Network Features

---

### 💡 แนะนำสำหรับทำ PoC ถัดไป:

ผมแนะนำให้เลือก **อันดับ 1 (Inter-VLAN Routing: Subinterface vs SVI)** ครับ เพราะอธิบายให้อาจารย์เห็นภาพได้ง่ายที่สุดว่า "ความซับซ้อนของ If-Else" มันลดภาระเราได้อย่างไร





