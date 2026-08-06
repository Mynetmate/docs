# 📚 Ch.5 — LangChain for Networking | Outline สำหรับ MyNetMate
> **หนังสือ:** AI Networking Cookbook (Packt)  
> **วัตถุประสงค์:** Outline หัวข้อใหญ่-ย่อย เพื่อนำไปให้ Gemini Pro อ่านและอธิบาย  
> **โครงงาน:** MyNetMate — Network Management System + AI Co-pilot  

---

## 🗺️ ภาพรวมบทที่ 5

บทนี้แนะนำ **LangChain** — Framework สำหรับ "ต่อ LEGO ของ AI" โดยครอบคลุม 5 Recipe:

| Recipe | หัวข้อ | เกี่ยวข้องกับ MyNetMate |
|--------|--------|------------------------|
| **5.1** | Installing & Setting up LangChain | 🟢 พื้นฐาน AI Framework |
| **5.2** | Network Configuration Analyzer | 🟢 Core Feature ของ MyNetMate |
| **5.3** | Prompt Templates for Reusability | 🟢 RAG / Prompt Engineering |
| **5.4** | Combining Models with Simple Chains | 🔵 Multi-model Strategy |
| **5.5** | Using Agents with LangChain | 🔵 Intent Detection / AI Tools |

> **Key Concept:** LangChain = LEGO blocks สำหรับ AI ที่ต่อ LLMs, APIs, Tools เข้าด้วยกัน  
> MyNetMate ใช้ **Gemini API โดยตรง** ไม่ใช่ LangChain แต่ใช้แนวคิดเดียวกัน

---

## ส่วนที่ 1 — LangChain คืออะไร?
> *(บทนำ)*

### 1.1 ที่มาและปรัชญาของ LangChain
- สร้างโดย Harrison Chase ในปี 2022 เพื่อแก้ปัญหา: LLM ไม่รู้จัก Real-time data
- ชื่อ "LangChain" = Language + Chain — แนวคิดการเชื่อม Steps เป็น Workflow
- Open Source + Business Model (คล้าย Red Hat): Free to use, Enterprise support เสริม

### 1.2 ปัญหาที่ LangChain แก้
- LLMs ไม่สามารถเข้าถึง Up-to-date หรือ Proprietary data ได้เอง
- LLMs ไม่สามารถ Interact กับ External tools ได้โดยตรง
- ต้องการ Pipeline ของ Workflows ที่ประกอบ AI หลายตัวเข้าด้วยกัน

### 1.3 Components หลักของ LangChain
- **LLMs / Chat Models:** ตัว AI model ที่ต้องการใช้งาน
- **Prompt Templates:** โครงสร้าง Prompt ที่นำกลับมาใช้ซ้ำได้
- **Chains:** การเชื่อม Steps หลายขั้นตอนเข้าด้วยกัน
- **Agents:** AI ที่เลือก Tool เองอัตโนมัติตามคำถาม
- **Tools:** ฟังก์ชัน Python ที่ Agent เรียกใช้ได้

> 🔗 **เชื่อมกับ MyNetMate:** MyNetMate ไม่ใช้ LangChain โดยตรง แต่ใช้แนวคิดเดียวกัน — FastAPI เป็น Orchestrator ที่รับ Intent → inject Context → ส่ง Prompt ที่สมบูรณ์ไปหา Gemini API

---

## ส่วนที่ 2 — Recipe 5.1: Installing and Setting Up LangChain
> *(หน้า 125-130)*

### 2.1 Technical Stack ในบทนี้
- **Ollama:** Local LLM runner (รัน AI model บนเครื่องตัวเอง)
- **llama2:7b-chat:** LLM model ขนาด 7B parameter (Open Source)
- **Docker Compose:** Deploy Ollama + Ollama Web UI เป็น Container
- **LangChain:** `langchain==0.1.0`, `langchain-community`

### 2.2 การเชื่อมต่อ LangChain กับ Ollama
```python
from langchain_community.llms import Ollama
llm = Ollama(model="llama2:7b-chat", base_url="http://localhost:11434")
ai_response = llm.invoke("What is OSPF in networking?")
```
- `Ollama()` — สร้าง LLM object ที่ชี้ไปที่ Container
- `.invoke()` — ส่ง Prompt และรับ Response กลับมา

> 🔗 **เชื่อมกับ MyNetMate:** เราใช้ Gemini API แทน Ollama และ `google.generativeai` แทน `langchain_community.llms` แต่ Pattern เหมือนกัน: สร้าง LLM object → ส่ง Prompt → รับ Response

---

## ส่วนที่ 3 — Recipe 5.2: Network Configuration Analyzer
> *(หน้า 130-134)*

### 3.1 แนวคิด: AI วิเคราะห์ Config อัตโนมัติ
- โหลด Config file จาก Disk (router, switch, problem config)
- ส่ง config text เข้าไปใน Prompt พร้อมคำถาม
- AI วิเคราะห์และระบุ: Device type, Function, Issues

### 3.2 โครงสร้าง Script
```python
def load_config(filename):   # โหลด Config ไฟล์
def analyze_config(config_text, config_name):  # ส่ง Prompt + รับ Analysis
def main():   # วน Loop ทุก Config ไฟล์ → บันทึกผล
```

### 3.3 Prompt Design สำหรับ Network Config Analysis
```
Analyze this network configuration:
{config_text}
Please tell me:
1. What type of device is this?
2. What is its main function?
3. Any obvious issues or concerns?
Keep your response clear and practical for a network engineer.
```

### 3.4 ตัวอย่างปัญหาที่ AI ตรวจพบ
- Missing default gateway
- Incomplete OSPF configuration
- Inconsistent IP addressing
- Weak passwords (`cisco123`)
- Access-list ที่ permit traffic ทุกอย่าง
- Telnet ไม่มี Encryption

> 🔗 **เชื่อมกับ MyNetMate:**  
> - Recipe นี้ = **Core Feature ของ MyNetMate** โดยตรง — Config Analysis ด้วย AI  
> - MyNetMate ทำขั้นตอนนี้แต่ต้อง inject Context เพิ่ม: Vendor, Device Type, Topology  
> - ผลลัพธ์ของ AI ควรถูก Parse และแสดงผลใน React Frontend อย่างสวยงาม

---

## ส่วนที่ 4 — Recipe 5.3: Prompt Templates for Reusability
> *(หน้า 135-140)*

### 4.1 ทำไมต้องใช้ Prompt Templates?
- **Raw String Prompt** (Recipe 5.2): ใช้ One-off, Hardcode ใน Code
- **Prompt Template:** เขียนครั้งเดียว ใช้ซ้ำได้ทุกที่

| ข้อดีของ Prompt Template | ตัวอย่าง |
|--------------------------|---------|
| Reusable | เขียน template ครั้งเดียว ใช้กับทุก config |
| Scalable | ทีมงานทุกคนใช้ prompt format เดียวกัน |
| Consistent Structure | ได้ output format เดิมทุกครั้ง |
| Validation | ป้องกัน input ผิดรูปแบบ |

### 4.2 การสร้าง Prompt Template ใน LangChain
```python
from langchain.prompts import PromptTemplate

template = """
You are a network security expert analyzing a configuration.
CONFIGURATION:
{config}
SECURITY ANALYSIS:
Please identify:
1. High-risk security issues
2. Medium-risk concerns
3. Best practice recommendations
Rate each issue as HIGH, MEDIUM, or LOW risk.
ANALYSIS:
"""

security_template = PromptTemplate(
    template=template,
    input_variables=["config"]  # ← ตัวแปรที่จะ inject
)
```

### 4.3 การใช้งาน Template
```python
# 1. Format Template (inject ค่าเข้าไป)
prompt = security_template.format(config=config_text)

# 2. ส่งไปหา LLM
result = llm.invoke(prompt)
```

### 4.4 Best Practices สำหรับ Prompt Template
- **Be Specific:** ระบุให้ชัดเจน (เช่น "check for weak passwords")
- **Set Context:** บอก Role ของ AI (เช่น "You are a security expert")
- **Define Output Format:** ระบุรูปแบบผลลัพธ์ (เช่น "Rate as HIGH/MEDIUM/LOW")

### 4.5 Template หลายแบบในไฟล์เดียว
- `create_security_template()` — วิเคราะห์ Security issues
- `create_basic_overview_template()` — สรุปภาพรวม Device

> 🔗 **เชื่อมกับ MyNetMate:**  
> - **PromptTemplate = System Prompt ของ MyNetMate** — เราต้องสร้าง Template หลายแบบตาม Intent  
> - Template ควรมี placeholder สำหรับ: `{vendor}`, `{device_model}`, `{topology}`, `{config}`  
> - จาก Ch.7 & 8 ของ AI Cookbook: เราสร้าง Dynamic System Prompt แทน PromptTemplate  
> - แนวคิดเดียวกัน แต่ MyNetMate inject context จาก PostgreSQL แทนที่จะ format จาก file

---

## ส่วนที่ 5 — Recipe 5.4: Combining Models with Simple Chains
> *(หน้า 140-148)*

### 5.1 แนวคิด: ใช้ LLM หลายตัวร่วมกัน
- Local LLM (Ollama) = **ถูก, เร็ว, Private** → ใช้สำหรับงานพื้นฐาน
- Remote LLM (OpenAI/Gemini) = **แพงกว่า, ฉลาดกว่า** → ใช้สำหรับ Advanced reasoning

### 5.2 LangChain Expression Language (LCEL)
- **เก่า (SequentialChain):** Verbose, ยากต่อการแก้ไข
- **ใหม่ (LCEL):** ใช้ operator `|` เชื่อม Steps เหมือน Unix pipe

```python
# LCEL Syntax (ใหม่)
basic_chain = basic_analysis_template | local_llm
advanced_chain = advanced_analysis_template | openai_llm
synthesis_chain = synthesis_template | openai_llm
```

### 5.3 Mixed Model Chain: 3-Step Workflow
```
Input Config
    ↓
Step 1: local_llm (Llama2)
    → Basic Analysis (device type, interfaces, protocols)
    ↓
Step 2: openai_llm (GPT-3.5)
    → Advanced Analysis (architecture assessment, recommendations)
    ↓
Step 3: openai_llm (GPT-3.5)
    → Combined Executive Summary (ผสมผลลัพธ์จาก Step 1+2)
```

### 5.4 RunnablePassthrough และ RunnableLambda
- `RunnablePassthrough.assign()` — ส่งผ่าน context พร้อมเพิ่ม key ใหม่
- `RunnableLambda()` — ห่อ Python function ให้เป็น Runnable step

### 5.5 Model Context Protocol (MCP)
- ประกาศโดย Anthropic ปี 2024
- วิธีใหม่ให้ AI models route ระหว่างกันอย่างชาญฉลาด
- กำลังได้รับความนิยมใน Community

> 🔗 **เชื่อมกับ MyNetMate:**  
> - **Multi-step Workflow** = แนวคิดเดียวกับ Intent Detection → Context Injection → AI Response  
> - ถ้า MyNetMate ขยายในอนาคต: Gemini Flash (เร็ว, ถูก) สำหรับ Basic queries, Gemini Pro สำหรับ Complex analysis  
> - Recipe นี้แสดง Pattern "**ใช้ Local model ก่อน แล้วค่อยส่งต่อ Remote model**" — ลดค่าใช้จ่าย API  
> - ตรงกับ Philosophy ของ MyNetMate: "ใช้ AI เมื่อต้องการ 'ความเข้าใจ' ไม่ใช้เมื่อต้องการ 'ความถูกต้อง'"

---

## ส่วนที่ 6 — Recipe 5.5: Using Agents with LangChain
> *(หน้า 148-156)*

### 6.1 Agent คืออะไร?
- Agent = AI ที่สามารถ **เลือก Tool เองอัตโนมัติ** ตาม Context ของคำถาม
- เหมือนหัวหน้าทีมที่ตัดสินใจว่าจะส่งงานให้ใคร

### 6.2 การสร้าง Tools สำหรับ Agent
```python
from langchain.tools import Tool
import re

def find_ip_addresses(config_text):
    """Find IP addresses in config"""
    ips = re.findall(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', config_text)
    return f"Found IP addresses: {', '.join(set(ips))}"

def identify_device(config_text):
    """Identify device type"""
    if "switchport" in config_text.lower():
        return "Device type: Switch"
    elif "router" in config_text.lower():
        return "Device type: Router"

tools = [
    Tool(name="IP_Finder",  description="Find IP addresses in config", func=find_ip_addresses),
    Tool(name="Device_ID",  description="Identify device type", func=identify_device)
]
```

### 6.3 การสร้างและใช้ Agent
```python
from langchain.agents import initialize_agent, AgentType

agent = initialize_agent(
    tools=tools,
    llm=llm,
    agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,  # ← ReAct Pattern
    verbose=True,
    max_iterations=2
)
result = agent.invoke("What type of device is this config?")
```

### 6.4 AgentType.ZERO_SHOT_REACT_DESCRIPTION คืออะไร?
- **ReAct Pattern:** Reasoning + Acting — AI คิดก่อน แล้วค่อย Act
- **Zero-Shot:** ไม่ต้องมี Examples ให้ดู — เข้าใจจาก Description ของ Tool เท่านั้น
- AI อ่าน Description ของแต่ละ Tool แล้วตัดสินใจเรียก Tool ที่เหมาะสม

### 6.5 Tool Selection Logic
```
คำถาม: "What type of device is this?"
    ↓ AI อ่าน Tool Descriptions
    ↓ "IP_Finder" = Find IP addresses
    ↓ "Device_ID" = Identify device type  ← เลือกอันนี้
    ↓ เรียก identify_device(config)
    ↓ Return result
```

> 🔗 **เชื่อมกับ MyNetMate:**  
> - **Agent = Intent Detection ของ MyNetMate** — เราตรวจ intent ด้วย keyword scanning แทน  
> - ถ้าต้องการขยาย: MyNetMate ใช้ LangChain Agent เพื่อเลือกว่าจะ "show config", "ping", หรือ "analyze topology"  
> - Pattern นี้เหมาะกับ Feature "AI Co-pilot ที่เลือก Action เองอัตโนมัติ"  
> - **ความแตกต่าง:** MyNetMate ไม่ควรให้ AI execute commands เอง (Safety!) แต่แนะนำ Action ให้ Engineer ตัดสินใจ

---

## 📊 สรุปเปรียบเทียบ LangChain กับ MyNetMate

| Concept ใน LangChain | Equivalent ใน MyNetMate |
|----------------------|------------------------|
| `Ollama LLM` | Gemini API (`google.generativeai`) |
| `PromptTemplate` | Dynamic System Prompt Builder (FastAPI) |
| `Chain (LCEL)` | FastAPI Request Pipeline |
| `Agent` | Intent Detection Logic |
| `Tools` | FastAPI functions (ping, show config, etc.) |
| `Sequential Chain` | Intent → Context Injection → AI Response |
| Mock Config Files | Real Device Data via Netmiko + PostgreSQL |

---

## 🎯 Key Takeaways สำหรับ MyNetMate

1. **PromptTemplate = System Prompt Engineering** — MyNetMate ต้องสร้าง Template หลายแบบ แยกตาม Intent (troubleshoot, configure, explain) และ Vendor (Cisco, MikroTik, Huawei)

2. **Mixed Model Strategy ลดต้นทุน** — ใช้ Gemini Flash สำหรับ Simple queries และ Gemini Pro สำหรับ Complex analysis — หลักการเดียวกับที่เรียนใน AI Cookbook Ch.8

3. **Agent = Intent Detection ที่ฉลาดขึ้น** — ปัจจุบัน MyNetMate ใช้ Keyword scanning แต่ในอนาคตอาจใช้ Agent Pattern ให้ AI เลือก Action เองได้

4. **Output Saving Pattern** — Recipe 5.2 บันทึก Analysis ไปที่ Output folder — MyNetMate ควรบันทึก AI Responses ลง PostgreSQL เพื่อ audit trail และ Config History

5. **"Description เป็นสิ่งสำคัญ"** — ใน Agents, Tool description คือสิ่งที่ AI ใช้ตัดสินใจ — ใน MyNetMate, System Prompt description คือสิ่งที่กำหนดพฤติกรรม AI

---

## ⚠️ สิ่งที่ต้องปรับเมื่อนำไปใช้ใน MyNetMate

| ใน Cookbook | ต้องเปลี่ยนเป็น |
|-------------|----------------|
| `Ollama` (Local LLM) | `google.generativeai` (Gemini API) |
| `OpenAI ChatGPT` | Gemini Pro |
| Mock Config Files (`.txt`) | Real-time data จาก Netmiko SSH |
| Local file storage (output folder) | PostgreSQL (Config History table) |
| Hard-coded model URL | Environment Variable + Docker Secret |
| `langchain.agents` | Custom Intent Detection หรือ Gemini Function Calling |

---

*Outline นี้สร้างโดย Antigravity AI | วันที่: 2026-07-21*  
*ไฟล์ต้นฉบับ: Ch.5 — LangChain for Networking (p.152).md (856 บรรทัด, 32 KB)*
