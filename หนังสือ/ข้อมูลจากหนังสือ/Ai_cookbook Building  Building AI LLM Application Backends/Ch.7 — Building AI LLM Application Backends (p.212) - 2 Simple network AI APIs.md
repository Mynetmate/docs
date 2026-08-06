### **7.1 Simple network AI APIs (การสร้าง API สำหรับ Network AI อย่างง่าย)**

ในหัวข้อนี้ เราจะมาสร้างแอปพลิเคชัน FastAPI พื้นฐานที่ใช้โมเดล GPT ของ OpenAI ในการตอบคำถามเกี่ยวกับเครือข่ายอย่างชาญฉลาด แม้ว่าเราจะเคยทำอะไรคล้ายๆ แบบนี้มาแล้วในบทก่อนๆ แต่ครั้งนี้เราจะนำมาทำบน **FastAPI** เพื่อเรียนรู้พื้นฐานของเฟรมเวิร์กนี้กันครับ

---

### **Getting ready (เตรียมความพร้อม)**

ไม่ต้องติดตั้งซอฟต์แวร์อะไรใหม่ครับ แค่ตรวจสอบให้แน่ใจว่าได้ใช้คำสั่ง `pip install` ติดตั้งแพ็กเกจต่างๆ ตามที่แจ้งไว้ในหัวข้อ Technical requirements เรียบร้อยแล้วก็พอ

---

### **How to do it… (ขั้นตอนการทำ)**

```python
from fastapi import FastAPI
from pydantic import BaseModel
import openai

import os

app = FastAPI(title="Network AI")

client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

classQuestionRequest(BaseModel):

    question: str

@app.post("/ask")

defask_question(request: QuestionRequest):

ifnot client.api_key:

return {

"answer": "Please set your OPENAI_API_KEY environment

                      variable"

        }

try:

        response = client.chat.completions.create(

            model="gpt-3.5-turbo",

            messages=[

                {

"role": "system",

"content": "You are a network engineer assistant

                               Give concise, practical answers about

                               network troubleshooting,

                               configuration, and performance

                               issues."         },

                {

"role": "user",

"content": request.question

                }

            ],

            max_tokens=150

        )

return {"answer": response.choices[0].message.content}

except Exception as e:


return {"answer": f"AI service unavailable: {str(e)}"}

if __name__ == "__main__":

import uvicorn

    uvicorn.run(app, port=8000)


```

1. **สร้างไฟล์ Python ชื่อ `main_v1.py`:**
    - โค้ดจะเริ่มจากการ Import เครื่องมือที่จำเป็น (FastAPI, Pydantic, OpenAI)
    - สร้างคลาส `QuestionRequest` เพื่อกำหนดโครงสร้างข้อมูลว่า User ต้องส่งตัวแปรชื่อ `question` เข้ามา
    - สร้าง Endpoint ชื่อ `/ask` (รับคำสั่งแบบ POST) เมื่อมีคำถามเข้ามา โค้ดจะนำคำถามนั้นไปผูกกับ System Prompt (ที่ตั้งค่าไว้ว่า "คุณคือผู้ช่วยวิศวกรเครือข่าย...") แล้วส่งไปให้ OpenAI ประมวลผล จากนั้นคืนค่าคำตอบกลับมาเป็น JSON
    
2. **รันเซิร์ฟเวอร์:** ใช้คำสั่ง `$ python main_v1.py` ระบบจะใช้ Uvicorn สตาร์ทเซิร์ฟเวอร์ขึ้นมาที่พอร์ต 8000
3. **ทดสอบยิง API:** ใช้คำสั่ง `curl` จำลองการส่งคำถาม (เช่น "ทำไม BGP session ถึง down?") ระบบก็จะพ่นคำตอบสาเหตุต่างๆ กลับมาเป็น JSON
4. **ความแตกต่างของ Backend:** ถ้าเราลองเปิด Browser ไปที่ `127.0.0.1:8000` เราจะเจอหน้าจอที่ดูไม่สวยงามเลย (โชว์แค่ Not Found) เพราะ Backend ถูกสร้างมาเพื่อเสิร์ฟ "ข้อมูล" ไม่ใช่ "หน้าตาเว็บ (UI)"
5. **จุดเด่นของ FastAPI:** ถึงหน้าเว็บจะตลก แต่ FastAPI มีของดีซ่อนอยู่คือ ถ้าเราเข้า URL `127.0.0.1:8000/docs` มันจะสร้างหน้าเอกสาร API (Swagger UI) ที่สวยงามและใช้ทดสอบระบบได้อัตโนมัติ!

---

### **How it works… (เบื้องหลังการทำงานของโค้ด)**

- **FastAPI:** แค่ประกาศตัวแปร `app = FastAPI(...)` มันก็จะจัดการเรื่อง HTTP requests, การแปลงไฟล์ JSON, และสร้างหน้า Document ให้เราอัตโนมัติ
- **Pydantic:** คือฟีเจอร์เด็ดที่สุดของ FastAPI จากโค้ด `class QuestionRequest(BaseModel):` มันจะทำหน้าที่ **"ด่านตรวจ"** ให้เราโดยอัตโนมัติ ถ้า User ส่งข้อมูลผิดประเภท หรือส่งข้อมูลมาไม่ครบ Pydantic จะบล็อกแล้วส่ง Error Message กลับไปแจ้ง User ทันทีโดยที่เราไม่ต้องเขียนโค้ดเช็กเอง
- **AI Magic:** โค้ดส่วน `client.chat.completions.create(...)` คือหัวใจหลักที่ใช้ปั้น Prompt เลือกรุ่นโมเดล (gpt-3.5-turbo) และส่งไปหา AI
- **Uvicorn Import:** การเขียน `import uvicorn` ไว้บรรทัดล่างสุดภายใต้ `if __name__ == "__main__":` ถือเป็น Best Practice ของ FastAPI เพราะมันจะโหลด Uvicorn เฉพาะตอนที่เราสั่งรันไฟล์นี้โดยตรงเท่านั้น

---

### **There’s more… (เทคนิคเพิ่มเติม)**

หากเราอยากเก็บ Log (บันทึกการทำงาน) ให้ละเอียดขึ้น เราสามารถ Import ไลบรารี `logging` ของ Python เข้ามาใช้ในโค้ดได้ เช่น ให้มันปรินต์ `logging.info(...)` เก็บไว้ทุกครั้งที่มีคนส่งคำถามเข้ามา

---

### **See also (แหล่งข้อมูลเพิ่มเติม)**

สามารถไปศึกษาความเจ๋งของ FastAPI เพิ่มเติมได้ที่เว็บไซต์หลัก: `https://fastapi.tiangolo.com/`

---

**💡 สรุปความเชื่อมโยงกับ MyNetMate ของเรา:** หัวข้อนี้คือ **"จุดเริ่มต้นของการทำ Backend ของเรา"** เลยครับ! โค้ด `QuestionRequest` (Pydantic) คือสิ่งที่เราจะใช้ตรวจสอบตอนที่หน้าเว็บ React/Next.js ของเราส่งข้อมูลเข้ามาหา FastAPI และหน้า `/docs` (Swagger UI) ก็คือหน้าจอหลักที่ทีม Backend ของกลุ่มคุณจะใช้ทดสอบระบบกันครับ!

ถ้ามีท่อนไหนต้องการให้อธิบายเจาะลึกเพิ่ม หรือพร้อมไปท่อนต่อไปแล้ว บอกได้เลยนะครับ!