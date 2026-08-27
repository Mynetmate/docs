import os
from google import genai
from google.genai import types
from jinja2 import Template
import json

# 1. ตั้งค่า Gemini API
# แนะนำให้ใช้ gemini-2.5-flash สำหรับงานนี้เพราะเร็วและเก่งพอ
client = genai.Client(api_key="YOUR_GEMINI_API_KEY_HERE") 

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