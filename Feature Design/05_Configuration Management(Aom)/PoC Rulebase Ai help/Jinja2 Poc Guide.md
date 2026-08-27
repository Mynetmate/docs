# 🧪 การเตรียม Environment สำหรับทดสอบใช้ AI เขียน Jinja2 (Proof of Concept)

ตามเอกสาร `AI ช่วยลดภาระการเขียนโค้ด Rule-based (Jinja2) ได้จริงหรือไม่.md` เป้าหมายคือการทำ A/B Testing เพื่อดูว่า AI (Gemini) สามารถเขียนโค้ด Jinja2 เพื่อสร้าง Cisco Config จาก JSON ได้แม่นยำแค่ไหน และลดเวลาเราได้จริงไหม

นี่คือสิ่งที่คุณต้องเตรียมครับ เราจะใช้ **Python** พร้อมกับ **Gemini API** ในการทดสอบนี้


### ## วิธีที่ 1: ใช้หน้าแชท AI (ChatGPT, Claude, Gemini Web) — ไม่ต้องใช้ API Key

วิธีนี้ตรงตามเอกสารมากที่สุดและง่ายที่สุดครับ แค่ก๊อปปี้ข้อความ (Prompt) ไปแปะในหน้าเว็บแชท AI ที่คุณใช้งานอยู่เป็นประจำได้เลย

### ขั้นตอนการทดสอบผ่านแชท:

1. เปิดเว็บ ChatGPT, Claude หรือ Gemini
2. **ก๊อปปี้ Prompt ด้านล่างนี้ทั้งหมด ไปแปะแล้วกดส่ง:**

```text
คุณเป็น Senior Network Engineer
จงเขียนโค้ด Jinja2 Template อย่างเดียวเท่านั้น เพื่อสร้าง Cisco IOS Configuration โดยอ้างอิงจาก Blueprint และ JSON ข้อมูลนี้

[Blueprint คำสั่งที่ถูกต้อง]
! สร้าง VLAN
vlan [VLAN_ID]
 name [VLAN_NAME]

! นำ Port เข้า VLAN (Access)
interface [INTERFACE_NAME]
 switchport mode access
 switchport access vlan [VLAN_ID]
 no shutdown

[โครงสร้างข้อมูล JSON ที่จะรับเข้ามา]
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

คำสั่ง: ให้ตอบกลับมาเป็นโค้ด Jinja2 เพียวๆ ห้ามอธิบาย
```

3. **นำผลลัพธ์มาตรวจสอบ:** ดูว่า AI เขียน for-loop และ if-else ใน Jinja2 ได้ถูกต้องไหม และนำโค้ดนั้นไปทดสอบเรนเดอร์ใน Python (ดูวิธีทดสอบในหัวข้อ "วิธีประเมินผล")

---

### ## วิธีที่ 2 :  ## ใช้ Python API (สำหรับผู้ที่อยากเห็นว่าระบบจริงทำงานยังไง)
## 🛠️  การเตรียม Environment (บนเครื่องของคุณ)

คุณสามารถทดสอบเรื่องนี้ได้ในเครื่องคอมพิวเตอร์ของคุณเองเลย ไม่ต้องพึ่งเซิร์ฟเวอร์ หรือ GNS3 ในขั้นตอนนี้ (GNS3 จะใช้แค่ตอนท้ายเพื่อลองเอา Config ไปรันดูว่าพังไหม)

สิ่งที่ต้องเตรียมมีดังนี้:
### 1.1 ติดตั้งไลบรารีที่จำเป็น
เปิด Terminal หรือ Command Prompt ในโฟลเดอร์โปรเจกต์ของคุณ แล้วรันคำสั่งเหล่านี้:

```bash
# ติดตั้งไลบรารีสำหรับเรียกใช้ Gemini API
pip install google-genai

# ติดตั้ง Jinja2 สำหรับการ Render Template ทดสอบ
pip install jinja2

# ติดตั้ง Pydantic สำหรับทำ Structured Data
pip install pydantic
```
#### เตรียม API Key
คุณต้องมี Gemini API Key ก่อน:
1. ไปที่ [Google AI Studio](https://aistudio.google.com/)
2. สร้าง API Key ใหม่
3. เตรียม Key นี้ไว้ใส่ในสคริปต์ Python ของเรา

## 📄 2. เตรียมเอกสาร 3 อย่าง (Prerequisites) ตามคำแนะนำอาจารย์

คุณไม่ต้องไปหาเอกสารเหล่านี้ที่ไหนไกล ผมเตรียมชุดทดสอบระดับ "พื้นฐาน (Basic)" ไว้ให้คุณก๊อปปี้ไปรันได้เลยครับ

### 🎯 สิ่งที่ 1: Target Vendor
เราจะทดสอบด้วย **Cisco IOS**

### 📐 สิ่งที่ 2: Command Blueprint (คู่มือคำสั่งที่ถูกต้อง)
เราจะทดสอบเรื่องการสร้าง **VLAN และ Access Port** นี่คือ Blueprint ที่ถูกต้อง:

```text
! สร้าง VLAN
vlan [VLAN_ID]
 name [VLAN_NAME]

! นำ Port เข้า VLAN (Access)
interface [INTERFACE_NAME]
 switchport mode access
 switchport access vlan [VLAN_ID]
 no shutdown
```

### 📦 สิ่งที่ 3: Data Schema (ข้อมูลสมมติที่หน้าเว็บจะส่งมา)
บันทึกข้อมูลนี้ไว้ในไฟล์ชื่อ `mock_data.json`

```json
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

---

## 🚀 3. สคริปต์ Python สำหรับรัน PoC ทดสอบ AI

ให้คุณสร้างไฟล์ชื่อ `poc_ai_jinja.py` แล้วก๊อปปี้โค้ดนี้ไปวาง (อย่าลืมเปลี่ยน `YOUR_API_KEY`):

```python
import os
from google import genai
from google.genai import types
from jinja2 import Template
import json

# 1. ตั้งค่า Gemini API
# แนะนำให้ใช้ gemini-2.5-flash สำหรับงานนี้เพราะเร็วและเก่งพอ
client = genai.Client(api_key="YOUR_API_KEY_HERE") 

# 2. โหลด Mock Data (สิ่งที่ 3)
mock_data = {
  "vlans": [
    { "id": 10, "name": "IT_DEP" },
    { "id": 20, "name": "HR_DEP" }
  ],
  "access_ports": [
    { "name": "GigabitEthernet0/1", "vlan_id": 10 },
    { "name": "GigabitEthernet0/2", "vlan_id": 20 }
  ]
}

# 3. เตรียม Blueprint (สิ่งที่ 2)
blueprint = """
! สร้าง VLAN
vlan [VLAN_ID]
 name [VLAN_NAME]

! นำ Port เข้า VLAN (Access)
interface [INTERFACE_NAME]
 switchport mode access
 switchport access vlan [VLAN_ID]
 no shutdown
"""

# 4. สั่งงาน AI ให้แต่งโค้ด Jinja2
prompt = f"""
คุณเป็น Senior Network Engineer
จงเขียนโค้ด Jinja2 Template เท่านั้น เพื่อสร้าง Cisco IOS Configuration
โดยอ้างอิงจาก Blueprint และ JSON ข้อมูลนี้ เป็นอุปกรณ์ Switch : C2960 Software

[Blueprint คำสั่งที่ถูกต้อง]
{blueprint}

[โครงสร้างข้อมูล JSON ที่จะรับเข้ามา]
{json.dumps(mock_data, indent=2)}

คำสั่ง: ให้ตอบกลับมาเป็นโค้ด Jinja2 เพียวๆ ห้ามมีคำอธิบาย ห้ามมี Markdown block (```)
"""

print("⏳ กำลังให้ AI (Gemini) เขียนโค้ด Jinja2 ให้...")
response = client.models.generate_content(
    model='gemini-3.5-flash-lite',
    contents=prompt,
    config=types.GenerateContentConfig(
        temperature=0.1, # ลดความมโน (Hallucination)
    )
)

ai_jinja_code = response.text.strip()
print("\n✅ AI เขียน Jinja2 เสร็จแล้ว ได้ผลลัพธ์ดังนี้:\n")
print("-" * 40)
print(ai_jinja_code)
print("-" * 40)

# 5. ทดสอบรันโค้ดที่ AI ให้มา (Validation)
print("\n🔄 กำลังทดสอบเรนเดอร์ (Render) โค้ดที่ AI ให้มา...")
try:
    template = Template(ai_jinja_code)
    # ใส่ mock_data เข้าไปใน template ที่ AI เพิ่งเขียน
    final_cisco_config = template.render(mock_data) 
    
    print("\n✅ Render สำเร็จ! นี่คือ Cisco CLI Config ที่ได้:\n")
    print("=" * 40)
    print(final_cisco_config)
    print("=" * 40)
    
except Exception as e:
    print(f"\n❌ การ Render ล้มเหลว AI น่าจะเขียน Jinja2 ผิด Syntax: {e}")
```

---

## 📊 4. วิธีประเมินผล (สำหรับรายงานอาจารย์)

เมื่อคุณรันสคริปต์ข้างต้นเสร็จ ให้จดบันทึก 3 อย่างนี้ครับ:

1. **Syntax Accuracy:** โค้ด Jinja2 รันผ่านไหม (ไม่ขึ้น `Render ล้มเหลว`)
2. **Domain Correctness:** ผลลัพธ์ `final_cisco_config` หน้าตาออกมาถูกต้องตาม Cisco IOS ไหม 
3. **Time-to-Code:** คุณใช้เวลาเตรียมน้อยกว่าไปนั่งพิมพ์ Jinja2 For-loop เองไหม?

ลองเอาไปรันดูครับ ถ้า AI ทำงานได้ดีในระดับ Basic นี้ คุณค่อยขยับไปลองทดสอบความซับซ้อนระดับ OSPF หรือ BGP ใน PoC รอบถัดไปครับ!
