# 📚 เจาะลึก Ch.5: LangChain for Networking (ส่วนที่ 2 - Recipe 5.1)
> **ที่มา:** AI Networking Cookbook (Packt) | Chapter 5
> **หัวข้อ:** Installing and Setting Up LangChain (การติดตั้งและเชื่อมต่อ AI Framework)

---

## 🛠️ 1. Technical Stack ในบทนี้ (สิ่งที่หนังสือใช้)
ในหนังสือ AI Networking Cookbook บทนี้ ผู้เขียนเลือกใช้เครื่องมือแบบ Local เพื่อความประหยัดและปลอดภัยของข้อมูล (Data Privacy) โดยประกอบด้วย:

1. **Ollama:** เครื่องมือที่ช่วยให้เราสามารถรันโมเดล AI (LLM) ขนาดใหญ่ได้บนคอมพิวเตอร์ของเราเอง โดยไม่ต้องง้อ Cloud
2. **llama2:7b-chat:** โมเดล AI จาก Meta (Facebook) ขนาด 7 พันล้านพารามิเตอร์ ซึ่งถือว่าเล็กพอที่จะรันบน Laptop ทั่วไปได้สบายๆ แต่ก็ฉลาดพอที่จะตอบคำถามเรื่อง Network
3. **Docker Compose:** ใช้สำหรับ Deploy ระบบ Ollama และ Web UI ของมันขึ้นมาพร้อมกันแบบง่ายๆ เป็น Container
4. **LangChain:** ไลบรารี Python เวอร์ชัน 0.1.0 และ `langchain-community` สำหรับเขียนโค้ดสั่งการ

---

## 🔌 2. การเขียนโค้ดเชื่อมต่อ LangChain กับ Ollama
เมื่อระบบ Ollama รันอยู่บน Docker (มักจะใช้พอร์ต 11434) การจะเขียนโค้ด Python ผ่าน LangChain เพื่อเข้าไปสั่งการ AI นั้นทำได้ง่ายมากด้วยโค้ดเพียงไม่กี่บรรทัด:

```python
# อิมพอร์ตคลาส Ollama จากชุมชนของ LangChain
from langchain_community.llms import Ollama

# 1. สร้าง Object เพื่อเชื่อมต่อไปยัง AI
# ระบุชื่อโมเดลที่ต้องการใช้ และ URL ของเซิร์ฟเวอร์ Ollama
llm = Ollama(model="llama2:7b-chat", base_url="http://localhost:11434")

# 2. ส่งคำถามไปให้ AI คิดและรอรับคำตอบ
ai_response = llm.invoke("What is OSPF in networking?")

# 3. แสดงผลลัพธ์
print(ai_response)
```

**สิ่งที่เกิดขึ้นเบื้องหลัง:**
- เมธอด `.invoke()` คือหัวใจสำคัญ มันทำหน้าที่ส่งข้อความ String เปล่าๆ วิ่งผ่าน HTTP Request ไปหา Ollama Container
- Ollama จะประมวลผล (กินทรัพยากร CPU/GPU ในเครื่อง) แล้วส่ง Text กลับมาให้ Python แสดงผล

---

## 🔗 นำแนวคิดมาปรับใช้กับ MyNetMate
ในโปรเจกต์ MyNetMate ของเรา เราเปลี่ยน Stack จาก **Ollama (Local)** มาเป็น **Gemini API (Cloud)** เพื่อความฉลาดที่เหนือกว่าและไม่ต้องพึ่งพา Hardware หนักๆ แต่รูปแบบการเขียนโค้ด (Design Pattern) ยังคงเหมือนกันเป๊ะครับ:

**ใน Cookbook (LangChain + Ollama):**
```python
llm = Ollama(model="llama2:7b-chat")
response = llm.invoke(prompt)
```

**ใน MyNetMate (Google SDK + Gemini):**
```python
import google.generativeai as genai
# (ตั้งค่า API Key ผ่าน genai.configure)
model = genai.GenerativeModel('gemini-1.5-flash')
response = model.generate_content(prompt)
```

จะเห็นได้ว่าแม้เราจะไม่ใช้ LangChain เราก็ยังคงเดินตามสถาปัตยกรรม **"สร้าง Model Object ➔ ส่ง Prompt ➔ รับ Response"** อย่างถูกต้องตามหลักการพัฒนา AI Backend ทุกประการครับ!
