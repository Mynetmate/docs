# 📚 Chapter 10 — Working with Network APIs
> **ที่มา:** Network Programmability and Automation (2nd Edition) | บทที่ 10
> **เป้าหมาย:** สรุปโครงสร้างเนื้อหาฉบับภาษาไทย คัดเน้นเฉพาะหัวข้อที่เกี่ยวเนื่องและเป็นประโยชน์ต่อการทำ Backend ของโปรเจกต์ **MyNetMate** พร้อมยกตัวอย่างโค้ดที่สามารถนำไปประยุกต์ใช้ได้จริง

---

## 🗂️ สารบัญ
1. [Understanding Network APIs (พื้นฐาน HTTP และ RESTful API)](#1-understanding-network-apis-พื้นฐาน-http-และ-restful-api)
2. [The Netmiko Python Library (คอร์หลักของ CLI Automation)](#2-the-netmiko-python-library-คอร์หลักของ-cli-automation)
3. [The Python Requests Library (การใช้ Python เชื่อมต่อ API)](#3-the-python-requests-library-การใช้-python-เชื่อมต่อ-api)
4. [Comparing NETCONF, RESTCONF, and gNMI (ความรู้เปรียบเทียบ)](#4-comparing-netconf-restconf-and-gnmi-ความรู้เปรียบเทียบ)

---

## 1. Understanding Network APIs (พื้นฐาน HTTP และ RESTful API)

ก่อนที่เราจะเขียนโค้ดเรียก API เราต้องเข้าใจโครงสร้างของ HTTP API ก่อน ซึ่งถือเป็นพื้นฐานที่สำคัญที่สุดสำหรับการทำเว็บแอปพลิเคชันอย่าง FastAPI

### 1.1 RESTful APIs คืออะไร?
RESTful API เป็นสถาปัตยกรรมการออกแบบ API ที่ได้รับความนิยมสูงสุด หลักการสำคัญที่เกี่ยวข้องกับเครือข่ายมี 3 ข้อคือ:
- **Client-server:** แยกระบบฝั่งผู้เรียก (Client เช่น สคริปต์ Python หรือ Web UI) ออกจากผู้ถูกเรียก (Server เช่น อุปกรณ์เครือข่าย)
- **Stateless:** การเรียกแต่ละครั้งต้องส่งข้อมูลไปให้ครบถ้วนในรอบเดียว (ไม่ต้องเปิด Session ค้างไว้เหมือน SSH)
- **Uniform interface:** มองทุกอย่างเป็น Resource (ทรัพยากร) ผ่าน URL เช่น `/api/devices` หรือ `/api/interfaces`

### 1.2 HTTP Request Types (ประเภทของคำสั่ง HTTP)
ในการเรียกใช้งาน RESTful API เราจะใช้ "กริยา (Verb)" ของ HTTP เป็นตัวบอกว่าต้องการทำอะไรกับ Resource นั้นๆ:
- **GET:** ขอดูข้อมูล (ใช้ดึงค่า Config หรือ Status ปัจจุบัน)
- **POST:** สร้างข้อมูลใหม่ (เช่น สร้างวง VLAN ใหม่)
- **PUT:** สร้างหรือแก้ไขแทนที่ข้อมูลเดิมทั้งหมด
- **PATCH:** แก้ไขข้อมูลเฉพาะบางส่วน
- **DELETE:** ลบข้อมูลทิ้ง

### 1.3 HTTP Response Codes (รหัสตอบกลับ)
เมื่อ Server ประมวลผลเสร็จ จะตอบกลับมาพร้อมตัวเลข 3 หลักเพื่อบอกสถานะ:
- **2xx (Successful):** ทำงานสำเร็จ (เช่น 200 OK)
- **4xx (Client error):** Client ส่งข้อมูลผิด (เช่น 401 ล็อกอินผิด, 404 หา URL ไม่เจอ)
- **5xx (Server error):** เซิร์ฟเวอร์หรือตัวอุปกรณ์เครือข่ายพัง

### 1.4 Non-RESTful HTTP-based APIs (API ที่ไม่เป็น RESTful)
มีเครือข่ายบางค่าย (เช่น Arista eAPI หรือค่ายเก่าๆ) ที่ไม่ได้ออกแบบเป็น RESTful แต่ใช้สไตล์ที่เรียกว่า **RPC (Remote Procedure Call)**
- **ลักษณะเด่น:** ทุกการเรียกใช้งานจะใช้ URL เดียว (เช่น `/command-api`) และใช้แค่ **POST** เสมอ โดยการระบุว่าต้องการทำอะไรจะถูกห่อส่งไปใน Body (Payload) แทน
- **ตัวอย่าง Payload ของ JSON-RPC:**
  ```json
  {
      "jsonrpc": "2.0",
      "method": "runCmds",
      "params": {
          "cmds": ["show vlan brief"]
      }
  }
  ```

> 💡 **โยงกับ MyNetMate:** FastAPI ที่เราใช้อยู่ ถูกออกแบบมาตามหลักการ RESTful แบบ 100% การเข้าใจเรื่อง GET, POST, และ Response Code จะช่วยให้เราออกแบบ API ฝั่ง Backend ให้ Frontend เรียกใช้ได้อย่างถูกต้อง

---

## 2. The Netmiko Python Library (คอร์หลักของ CLI Automation)

แม้เทรนด์โลกจะไปทาง API แต่สำหรับงาน Network แล้ว **SSH (CLI) ก็ยังคงเป็นพระเอก** โดยเฉพาะกับอุปกรณ์รุ่นเก่าหรือฟีเจอร์บางอย่างที่ API ไม่รองรับ (ซึ่งเข้าทาง MyNetMate ที่ต้องซัพพอร์ตหลากยี่ห้อ)

### 2.1 การตั้งค่าและสร้างการเชื่อมต่อ
Netmiko จะใช้ `ConnectHandler` ในการจัดการการเชื่อมต่อ:

```python
from netmiko import ConnectHandler

device = ConnectHandler(
    host='nxos-spine1',
    username='admin',
    password='admin',
    device_type='cisco_nxos' # บอก Netmiko ว่านี่คืออุปกรณ์ค่ายไหน
)
```

### 2.2 Methods ยอดฮิตที่ต้องรู้
- `device.find_prompt()`: ใช้เช็กว่าตอนนี้อยู่โหมดไหน เช่น พ่นค่า `nxos-spine1#` ออกมา
- `device.config_mode()`: สั่งเข้าโหมด Config อัตโนมัติ (ข้ามพวก `configure terminal` ให้เลย)
- `device.send_command('show run')`: สั่งรันคำสั่ง (ใช้ดึงข้อมูล)
- `device.send_config_set(['interface vlan 10', 'shutdown'])`: สั่งรันคำสั่งแบบเป็นชุด (List) ใช้สำหรับ Config
- `device.send_config_from_file('nxos.conf')`: สั่ง Config โดยอ่านคำสั่งจากไฟล์ .conf หรือ .txt

### 🔥 2.3 การติดปีกให้ Netmiko ด้วย TextFSM (สำคัญมาก)
ปัญหาใหญ่ของการทำ Automation ผ่าน CLI คือข้อมูลที่ได้กลับมาเป็น **"Text ดิบๆ"** ที่ไร้โครงสร้าง จะเอาไปประมวลผลต่อก็ต้องเขียน Regex ตัดคำเองซึ่งเหนื่อยและพังง่าย

Netmiko แก้ปัญหานี้ด้วยการควบรวมกับ **TextFSM** (ตัวตัดคำของ Google) และ **NTC Templates** (เทมเพลตตัดคำสำหรับ Network ของทุกยี่ห้อ)

**ตัวอย่างการใช้แบบเดิม (ได้ Text):**
```python
output = device.send_command('show int brief')
# ผลลัพธ์: จะได้เป็น String ยาวๆ หน้าตาเหมือนตารางที่คนดู
```

**ตัวอย่างการใช้คู่กับ TextFSM (ได้ JSON/Dict):**
```python
parsed_output = device.send_command('show int brief', use_textfsm=True)

# ผลลัพธ์: แปลงเป็นโครงสร้างให้อัตโนมัติ!
print(parsed_output[0])
# {
#    'interface': 'mgmt0', 
#    'status': 'up', 
#    'ip': '10.0.0.15', 
#    'speed': '1000'
# }
```

> 💡 **โยงกับ MyNetMate:** เราใช้ `use_textfsm=True` เป็นฟีเจอร์หลักในการดึงข้อมูลจาก Cisco/Huawei เพื่อเอา Dict ที่ได้ไปยิงเข้าฐานข้อมูล PostgreSQL ได้ทันทีโดยไม่ต้องเขียนโค้ดตัด string เอง

---

## 3. The Python Requests Library (การใช้ Python เชื่อมต่อ API)

เมื่อต้องคุยกับ HTTP API (ไม่ว่าจะคุยกับ Network API สมัยใหม่ หรือคุยกับ 3rd-party อย่าง Webhook หรือ AI) ไลบรารี `requests` คือตัวจบ

### 3.1 การยิงคำสั่งพื้นฐาน
ตัวอย่างการยิง **GET** เพื่อดึงข้อมูล และการยิง **POST** เพื่อส่งข้อมูล:

```python
import requests
import json

base_url = "https://api.meraki.com/api/v1"
headers = {
    "X-Cisco-Meraki-API-Key": "my-secret-token",
    "Content-Type": "application/json"
}

# --- 1. การดึงข้อมูล (GET) ---
response_get = requests.get(f"{base_url}/organizations", headers=headers)
print(response_get.status_code) # ควรได้ 200
organizations = response_get.json() # แปลง JSON Response กลับมาเป็น Dictionary (List)

# --- 2. การสร้างข้อมูลใหม่ (POST) ---
payload = {
    "name": "My New Network",
    "productTypes": ["switch"]
}

# ต้องแปลง Dict ของ Python กลับเป็น JSON String ผ่าน json.dumps(payload)
response_post = requests.post(
    f"{base_url}/organizations/123/networks",
    headers=headers,
    data=json.dumps(payload)
)
```

### 3.2 การประยุกต์ใช้เพื่อความอัตโนมัติ (Closed-loop)
หนังสือยกตัวอย่างสคริปต์สุดคลาสสิก: **"การดึงข้อมูล LLDP มาเขียน Description ของ Interface ให้อัตโนมัติ"**
1. ยิง `requests` ไปขอข้อมูล `show lldp neighbors` (ได้โครงสร้างเพื่อนบ้านกลับมา)
2. วนลูป (Loop) ค่าเพื่อนบ้าน เอาชื่อ Switch ฝั่งตรงข้ามมาต่อเป็นประโยค
3. ยิง `requests` กลับไป Config หน้า Description ของพอร์ตนั้นๆ

> 💡 **โยงกับ MyNetMate:** `requests` เป็นเครื่องมือสำคัญที่เราใช้เชื่อมระบบต่างๆ เข้าหากัน นอกเหนือจากการใช้คุยกับอุปกรณ์ฝั่ง REST API แล้ว เรายังสามารถใช้ `requests` เรียกโมเดล Gemini API เมื่อต้องการให้ AI ช่วยวิเคราะห์ข้อมูลได้ด้วย

---

## 4. Comparing NETCONF, RESTCONF, and gNMI (ความรู้เปรียบเทียบ)

แม้ว่าเราจะใช้ Netmiko เป็นหลัก แต่การเข้าใจพัฒนาการของเครื่องมือฝั่ง Data-Model Driven API จะช่วยให้เรามองภาพรวมของวงการออก (และมีประโยชน์มากตอนสอบหรือคุยกับอาจารย์)

### 4.1 เปรียบเทียบ 3 ทหารเสือ
| ฟีเจอร์                         | NETCONF                                                  | RESTCONF                                      | gNMI                             |
| ------------------------------- | -------------------------------------------------------- | --------------------------------------------- | -------------------------------- |
| **Encoding (ฟอร์แมตข้อมูล)**    | XML                                                      | JSON หรือ XML                                 | protobuf (กะทัดรัดมาก) หรือ JSON |
| **Transport (ช่องทางส่ง)**      | SSH                                                      | HTTP/TLS (เหมือนเข้าเว็บ)                     | gRPC (บน HTTP/2)                 |
| **Transaction Scope (จุดเด่น)** | Network-wide (ทำ Transaction คลุมหลายอุปกรณ์พร้อมกันได้) | Single-target (ทำแบบดื้อๆ ทีละตัวเหมือน REST) | Single-target เน้นสตรีมมิ่ง      |

### 4.2 Model-driven telemetry (ก้าวข้าม SNMP)
สมัยก่อนเราใช้ SNMP แบบ **"Poll" (ดึงมาทีละครั้ง)** ซึ่งช้า เป็นภาระอุปกรณ์ และข้อมูลไม่เรียลไทม์ โลกยุคใหม่จึงเปลี่ยนมาใช้แนวคิด **Telemetry** ซึ่งเป็นแบบ **"Push" (ผลักข้อมูลออกมาต่อเนื่อง)**

- **Dial-in:** เซิร์ฟเวอร์เราวิ่งเข้าไปต่ออุปกรณ์ แล้วบอกว่า "ขอ Subscribe ข้อมูล CPU นะ" อุปกรณ์ก็จะส่งกลับมาเรื่อยๆ (เป็นแนวทางของ gNMI)
- **Dial-out:** ไปตั้งค่าที่ตัวอุปกรณ์ว่า "มีอะไรเกิดขึ้นให้ยิงแจ้งเตือนมาที่เซิร์ฟเวอร์ IP นี้นะ" (ปลอดภัยกว่า เพราะไม่ต้องเปิดพอร์ตฝั่งอุปกรณ์)

> 💡 **โยงกับ MyNetMate:** แม้โปรเจกต์เราจะยังไม่ได้ใช้ telemetry ขั้นสูง (เช่น gNMI) แต่เราสามารถใช้องค์ความรู้นี้ชี้แจงเหตุผลได้ว่า *"MyNetMate ออกแบบบนฐาน Netmiko เพราะต้องการตีวงกว้างให้ครบทุกอุปกรณ์แบบ Plug-and-Play ก่อน ส่วน API อย่าง NETCONF/gNMI เป็นสถาปัตยกรรมที่ผู้ให้บริการขนาดใหญ่ใช้ ซึ่งอาจพิจารณาขยายต่อในเฟส 2"*
