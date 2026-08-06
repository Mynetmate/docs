# 📚 เจาะลึก Ch.5: LangChain for Networking (ส่วนที่ 4 - Recipe 5.3)
> **ที่มา:** AI Networking Cookbook (Packt) | Chapter 5
> **หัวข้อ:** Using Prompt Templates for Reusability (การใช้ Prompt Template เพื่อนำกลับมาใช้ซ้ำ)

---

## ♻️ 1. ทำไมต้องใช้ Prompt Templates?
ใน Recipe ก่อนหน้า เราเขียนข้อความ Prompt ต่อท้ายด้วยตัวแปร (Raw String) ตรงๆ ในโค้ด ซึ่งวิธีนี้เหมาะกับการทดสอบสั้นๆ แต่สำหรับการทำ Production System มันมีข้อเสียคือ "แก้ไขยากและนำไปใช้ซ้ำไม่ได้"

**Prompt Template** คือการสร้าง "แม่พิมพ์ (Blueprint)" ของคำสั่งเตรียมเอาไว้ โดยมีการเว้นช่องว่าง (Placeholders) ไว้สำหรับเติมข้อมูลทีหลัง 

**ข้อดีของการทำ Template:**
- **Reusable:** เขียนโครงสร้างคำถามแค่ครั้งเดียว แล้ววนลูปเอา Config ของ Router 100 ตัวมาหยอดใส่ช่องว่างทีละตัวได้เลย
- **Consistent Structure:** การตีกรอบคำถามให้ชัดเจน จะบังคับให้ AI ตอบกลับมาในรูปแบบเดิมทุกครั้ง (สำคัญมากเวลาต้องเอาข้อความไปแสดงบน Web UI)
- **Validation:** ป้องกันไม่ให้ส่งข้อมูลผิดประเภทเข้าไปใน Prompt

---

## 🛠️ 2. การสร้างและใช้งานใน LangChain
LangChain จัดการเรื่องนี้ผ่านคลาส `PromptTemplate` โดยมีวิธีเขียนดังนี้:

```python
from langchain.prompts import PromptTemplate

# 1. ร่างแม่พิมพ์คำสั่ง และเจาะช่องว่าง {config} เอาไว้
template_text = """
You are a network security expert analyzing a configuration.
CONFIGURATION:
{config}

SECURITY ANALYSIS:
Please identify:
1. High-risk security issues
2. Medium-risk concerns
3. Best practice recommendations
Rate each issue as HIGH, MEDIUM, or LOW risk.
"""

# 2. นำข้อความไปใส่ใน PromptTemplate เพื่อเปลี่ยนเป็น Object
security_template = PromptTemplate(
    template=template_text,
    input_variables=["config"]  # บอกว่าต้องมีตัวแปรชื่อนี้ส่งเข้ามานะ
)

# 3. หยอดข้อมูลจริง (Inject) เข้าไปในแม่พิมพ์
final_prompt = security_template.format(config="hostname R1\n enable secret cisco...")

# 4. ส่งไปหา AI
result = llm.invoke(final_prompt)
```

---

## 🏆 3. Best Practices ในการเขียน Template
จากโค้ดด้านบน หนังสือสอนเทคนิค **Prompt Engineering** ที่ดีเยี่ยมเอาไว้ 3 อย่าง:
1. **Set Context (กำหนดบทบาท):** ขึ้นต้นด้วย "You are a network security expert..." เพื่อปรับจูนให้ AI ดึงความรู้เฉพาะทางออกมาใช้
2. **Be Specific (เจาะจงสิ่งที่ต้องการ):** แทนที่จะถามลอยๆ ว่ามีอะไรผิดไหม ให้สั่งไปเลยว่าให้หา "High-risk, Medium-risk, Best practice"
3. **Define Output Format (กำหนดรูปแบบผลลัพธ์):** สั่งให้จัดกลุ่มความเสี่ยงเป็น "HIGH, MEDIUM, LOW" เพื่อให้อ่านง่าย

---

## 🔗 ถอดบทเรียนประยุกต์ใช้กับ MyNetMate
ในระบบ Backend (FastAPI) ของเรา เรื่อง Prompt Template คือ **"สิ่งที่ขาดไม่ได้เด็ดขาด (Crucial Component)"** ครับ!

1. **System Prompt = Prompt Template:** 
   ใน MyNetMate เราต้องสร้างไฟล์เก็บ Template เหล่านี้แยกไว้ต่างหาก (อาจจะเก็บในโฟลเดอร์ `prompts/` หรือสร้างเป็น Python Dictionary) แบ่งตาม **Intent (จุดประสงค์)** เช่น:
   - `TROUBLESHOOT_TEMPLATE`
   - `CONFIG_AUDIT_TEMPLATE`
   - `DEVICE_SUMMARY_TEMPLATE`

2. **การเติมข้อมูลแบบ Dynamic (Context Injection):**
   ในบรรทัดที่เราใช้ `.format()` ของ MyNetMate เราจะไม่เติมแค่ `{config}` อย่างเดียว แต่เราจะเติม Context ที่ดึงมาจาก PostgreSQL เข้าไปด้วย เพื่อความแม่นยำขั้นสุด:
   ```python
   # ตัวอย่างใน FastAPI ของเรา
   final_prompt = TROUBLESHOOT_TEMPLATE.format(
       vendor=device.vendor,           # "Cisco"
       model=device.model,             # "Catalyst 9300"
       topology=device.neighbors,      # "Connected to Core-SW1"
       cli_output=netmiko_output       # ผลลัพธ์จากการยิงคำสั่ง
   )
   ```
   
นี่คือการทำให้ AI ใน MyNetMate กลายเป็น **"Co-pilot ที่รู้ใจวิศวกรอย่างแท้จริง"** ครับ!
