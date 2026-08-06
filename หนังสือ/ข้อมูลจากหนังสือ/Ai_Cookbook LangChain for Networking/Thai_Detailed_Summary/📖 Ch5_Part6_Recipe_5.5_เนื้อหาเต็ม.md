# 📚 เจาะลึก Ch.5: LangChain for Networking (ส่วนที่ 6 - Recipe 5.5)
> **ที่มา:** AI Networking Cookbook (Packt) | Chapter 5
> **หัวข้อ:** Using Agents with LangChain (การสร้าง AI Agent ให้มีชีวิตและตัดสินใจเองได้)

---

## 🕵️‍♂️ 1. Agent คืออะไร?
ใน Recipe ก่อนหน้า (Chains) เราเป็นคนกำหนดลำดับขั้นตอน A ➔ B ➔ C เอาไว้ตายตัว (Hardcoded) แต่ในโลกแห่งความเป็นจริง ผู้ใช้มักจะถามคำถามที่หลากหลาย การทำ Workflow ตายตัวจึงไม่ตอบโจทย์

**AI Agent** คือการยกระดับ AI จาก "ผู้ตอบคำถาม" ให้กลายเป็น **"ผู้จัดการ (Orchestrator)"** 
เราจะไม่กำหนดขั้นตอนให้มันอีกต่อไป แต่เราจะมอบ **"เครื่องมือ (Tools)"** หลายๆ ชิ้นให้มันวางไว้บนโต๊ะ แล้วเมื่อมีคำถามเข้ามา AI Agent จะ **"คิด วิเคราะห์ และเลือกหยิบ Tool ที่เหมาะสมที่สุด"** มาใช้งานด้วยตัวเอง!

---

## 🧰 2. การสร้าง Tools (อาวุธสำหรับ Agent)
การสร้าง Tool ใน LangChain คือการนำฟังก์ชัน Python ธรรมดาๆ มาห่อหุ้มไว้ สิ่งที่สำคัญที่สุดไม่ใช่โค้ดข้างใน แต่คือ **"Description (คำอธิบาย)"** เพราะ AI จะอ่านคำอธิบายนี้เพื่อตัดสินใจว่าจะเรียกใช้มันตอนไหน

**ตัวอย่างการสร้าง Tool:**
```python
from langchain.tools import Tool
import re

# 1. ฟังก์ชันค้นหา IP Address จากข้อความ
def find_ip_addresses(config_text):
    """Find IP addresses in config"""
    ips = re.findall(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', config_text)
    return f"Found IP addresses: {', '.join(set(ips))}"

# 2. ฟังก์ชันระบุประเภทอุปกรณ์
def identify_device(config_text):
    """Identify device type"""
    if "switchport" in config_text.lower(): return "Switch"
    elif "router" in config_text.lower(): return "Router"

# 3. ห่อฟังก์ชันให้กลายเป็น Tool พร้อมระบุ Description ให้ AI อ่าน
tools = [
    Tool(
        name="IP_Finder",
        description="ใช้เครื่องมือนี้เมื่อต้องการค้นหา IP address ที่ซ่อนอยู่ใน Config",
        func=find_ip_addresses
    ),
    Tool(
        name="Device_ID",
        description="ใช้เครื่องมือนี้เพื่อตรวจสอบว่านี่คือ Router หรือ Switch",
        func=identify_device
    )
]
```

---

## 🧠 3. วิธีคิดของ Agent (Zero-Shot ReAct)
เมื่อเราประกอบ Agent (ใส่ LLM + ใส่ Tools ให้) และกำหนดประเภทเป็น `AgentType.ZERO_SHOT_REACT_DESCRIPTION` สิ่งที่เกิดขึ้นเบื้องหลังคือกระบวนการคิดแบบ **ReAct (Reasoning + Acting)** ดังนี้:

**ตัวอย่างสถานการณ์:** ผู้ใช้ถามว่า *"ช่วยดูหน่อยว่า Config นี้เป็นอุปกรณ์อะไร?"*
1. **Thought (คิด):** AI อ่านคำถาม แล้วคิดว่า *"ฉันต้องระบุประเภทอุปกรณ์ ฉันควรใช้เครื่องมือ Device_ID เพราะคำอธิบายบอกไว้แบบนั้น"*
2. **Action (กระทำ):** AI สั่งเรียกใช้ฟังก์ชัน `identify_device(config_text)`
3. **Observation (สังเกต):** AI ได้รับผลลัพธ์จากฟังก์ชันกลับมาว่า "Switch"
4. **Final Answer (ตอบ):** AI ตอบผู้ใช้ว่า "จากข้อมูล Config อุปกรณ์ตัวนี้คือ Switch ครับ"

---

## 🔗 ถอดบทเรียนประยุกต์ใช้กับ MyNetMate (สำคัญมาก!)
หัวข้อ Agent คือจุดตัดสำคัญที่แบ่งแยก **"Chatbot ธรรมดา"** กับ **"AI Co-pilot ขั้นสูง"** 

ในโครงสร้างสถาปัตยกรรมของ MyNetMate ปัจจุบัน เราใช้ **"Intent Detection (ผ่านโค้ด FastAPI / Keyword Scanning)"** เพื่อตัดสินใจว่าจะทำอะไร ซึ่งก็เป็นวิธีที่ปลอดภัย (Deterministic) และควบคุมง่าย

แต่ถ้าเราต้องการอัปเกรด MyNetMate สู่ **"Agentic AI"** เราสามารถนำแนวคิดนี้มาใช้กับ **Gemini Function Calling (Tools)** ได้ครับ:
1. เราสามารถเขียนฟังก์ชัน `execute_ping(ip)` และ `show_interface_status(device)` เตรียมไว้ใน FastAPI
2. เมื่อผู้ใช้แชทบอกว่า *"ทำไม Network ที่สาขาบางนาถึงช้าจัง?"*
3. **Gemini Agent** จะคิดเองว่า *"อืม... ต้องเช็กสถานะ Interface ก่อน ขอเรียกใช้ `show_interface_status('bangna-sw1')` หน่อย"*
4. เมื่อได้ผลลัพธ์มา Gemini ก็จะวิเคราะห์และตอบผู้ใช้ได้ตรงจุดทันที!

> **⚠️ ข้อควรระวังสูงสุด (Safety First):** 
> ปรัชญาของ MyNetMate คือ **"ใช้ AI เพื่อความเข้าใจ ไม่ใช่ความถูกต้อง (ห้าม AI สั่ง Config เอง)"** 
> ดังนั้น หากเราจะนำ Agent มาใช้ **เราจะอนุญาตให้ Tools เป็นเพียงคำสั่งตระกูล 'Read-only' (เช่น Ping, Show, Trace) เท่านั้น!** ห้ามสร้าง Tool ประเภท `config_vlan()` ให้ Agent เรียกใช้เด็ดขาด เพราะถ้ามัน "หลอน (Hallucination)" ขึ้นมา ระบบพังทั้งบริษัทแน่นอนครับ! การ Config ยังไงก็ต้องผ่านการรีวิวและกดปุ่ม 'Approve' จากวิศวกร (มนุษย์) เสมอครับ!
