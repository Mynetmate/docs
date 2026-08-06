# 📚 Chapter 9 — Templates (แม่แบบ)
> **ที่มา:** Network Programmability and Automation (2nd Edition) | หน้า 393–421
> **ภาษา:** สรุปเป็นภาษาไทย เน้นเนื้อหาที่เกี่ยวข้องกับโปรเจกต์ MyNetMate

---

## 🗂️ สารบัญบทนี้

| หัวข้อ | เนื้อหา |
|--------|---------|
| [1. Templates คืออะไร?](#1-templates-คืออะไร) | ปัญหา CLI และประโยชน์ของ Template |
| [2. ความเป็นมา](#2-ความเป็นมาของ-template-language) | ประวัติ Template ในโลก Web |
| [3. การประยุกต์ใช้แนวคิด](#3-การประยุกต์ใช้แนวคิด-template-กับ-network) | นำ Template มาใช้กับ Network |
| [4. ความเป็นสากลและ Open Source](#4-ความเป็นสากลและ-open-source) | ทำไม Template ถึงโอเค |
| [5. คุณค่าและความสำคัญ](#5-คุณค่าและความสำคัญของ-template) | ประโยชน์จริงๆ ที่ได้รับ |
| [6. Jinja คืออะไร?](#6-jinja-คืออะไร) | แนะนำ Jinja2 |
| [7. วิธีใช้ Jinja กับ Python](#7-วิธีใช้-jinja-กับ-python) | render template ด้วย Python |
| [8. ยกระดับ Template ให้เต็มประสิทธิภาพ](#8-ยกระดับ-template-ให้เต็มประสิทธิภาพ) | Loops, Conditionals, Data Structures |
| [9. Jinja Filters](#9-jinja-filters-ตัวกรอง) | ฟังก์ชันแปลงข้อมูลใน Template |
| [10. Template Inheritance](#10-template-inheritance-การสืบทอดเทมเพลต) | แยกไฟล์ Template แล้วประกอบกัน |
| [11. การสร้างตัวแปรใน Jinja](#11-การสร้างตัวแปรใน-jinja) | ใช้ set statement |
| [12. XSLT ⚠️](#12-xslt-ข้ามได้-ไม่ใช่ใน-scope-โปรเจกต์) | ⚠️ ข้ามได้ ไม่ใช่ Scope โปรเจกต์ |
| [13. Go Templates ⚠️](#13-go-templates-ข้ามได้-ไม่ใช่ใน-scope-โปรเจกต์) | ⚠️ ข้ามได้ เราใช้ Python |
| [สรุปบทเรียน](#-สรุปบทเรียน-summary) | Best Practices 4 ข้อ |

---

## 1. Templates คืออะไร?

### 🔴 ปัญหาเดิมที่ต้องแก้

งานส่วนใหญ่ของวิศวกรเครือข่ายคือการใช้ CLI พิมพ์คำสั่งซ้ำๆ ทีละอุปกรณ์ ซึ่งมีปัญหาหลักคือ:

- **ไม่มีประสิทธิภาพ** — ยิ่งนานยิ่งช้า เพราะต้องทำซ้ำทุกครั้ง
- **เกิดข้อผิดพลาดได้ง่าย** — ลืม Configuration เล็กน้อยได้เสมอ เช่น ลืมแนบ BGP Community ที่ถูกต้อง
- **ไม่มีมาตรฐาน** — แต่ละคนทำไม่เหมือนกัน ขึ้นอยู่กับองค์กร

### ✅ Template แก้ปัญหาได้อย่างไร?

**Template** = ไฟล์แม่แบบที่เขียนโครงสร้างคำสั่งตายตัวไว้ แล้วเปิดช่องว่างให้ "เติมค่า" บางส่วนในภายหลัง

ผลที่ได้:
- **ความเร็ว** — ใช้ข้อมูลน้อยลงมากในการสร้าง Config
- **ความสม่ำเสมอ** — ทุกอุปกรณ์ได้รับ Config ในรูปแบบเดียวกัน 100%
- **ความปลอดภัย** — Template บรรจุคำสั่งที่จำเป็นทั้งหมดตามนโยบายองค์กรไว้ครบแล้ว ไม่มีลืม

> 💡 **โยงกับ MyNetMate:** Jinja2 Template คือ Core ของ Config Generation 80% ในระบบเรา

---

## 2. ความเป็นมาของ Template Language

- Template Language เริ่มต้นจากโลก **Web Development** — แทนที่จะต้องเขียนไฟล์ HTML แยกสำหรับผู้ใช้งานทุกคน นักพัฒนาเขียนเทมเพลตเพียงไฟล์เดียวแล้วเติมข้อมูลแบบ Dynamic
- **Jinja** ถูกสร้างขึ้นจากชุมชน Python (Python-centric community) จึงมีไวยากรณ์คล้าย Python มาก
- ต่อมาวิศวกรเครือข่ายนำแนวคิดนี้มาประยุกต์ใช้กับ Network Config แทน HTML

### 🔑 3 ขั้นตอนสำคัญในการใช้ Template (หนังสือเน้นมาก)

หนังสือระบุว่า **Template เดี่ยวๆ ไม่มีประโยชน์** ต้องครบ 3 อย่าง:

```
1. Template   →  ไฟล์แม่แบบที่เขียนโครงสร้างไว้
2. Data       →  ข้อมูลที่จะเติมเข้าไปในช่องตัวแปร
3. Engine     →  ตัวขับเคลื่อน เช่น Python Script หรือ Ansible
```

> 💡 **โยงกับ MyNetMate:**
> - **Template** = ไฟล์ `.jinja` ของ Cisco/MikroTik/Huawei
> - **Data** = ข้อมูล Inventory จาก PostgreSQL
> - **Engine** = FastAPI Backend ที่เรียก `template.render()`

---

## 3. การประยุกต์ใช้แนวคิด Template กับ Network

แนวคิดเดียวกับ Web Template แต่เปลี่ยนจาก HTML → Network Config:

```
[Web]      HTML โครงสร้างคงที่  +  ข้อมูล User    →  หน้าเว็บ
[Network]  CLI Template คงที่   +  ข้อมูล Device   →  Config สำเร็จรูป
```

### ตัวอย่างจากหนังสือ: Django HTML → Jinja Network

**ก่อน (Django Web Template):**
```html
<h1>{{ title }}</h1>
{% for article in article_list %}
<h2><a href="{{ article.get_absolute_url }}">{{ article.headline }}</a></h2>
{% endfor %}
```

**หลัง (Jinja Network Template — แนวคิดเดียวกันเลย):**
```jinja2
hostname {{ device_name }}
{% for vlan in vlan_list %}
vlan {{ vlan.id }}
 name {{ vlan.name }}
{% endfor %}
```

### ตัวอย่าง: Template สำหรับทำรายงาน VLAN (Example 9-1 จากหนังสือ)

Template ใช้ได้กับทุกสิ่งที่เป็น Text ไม่ใช่แค่ Config:

```jinja2
| VLAN ID | NAME    | STATUS |
| ------- |------   | -------|
{% for vlan in vlans %}
| {{ vlan.get('vlan_id') }} | {{ vlan.get('name') }} | {{ vlan.get('status') }} |
{% endfor %}
```

ผลลัพธ์เป็นตาราง Markdown พร้อมส่งอีเมลได้เลย

> 💡 **โยงกับ MyNetMate:** เราสามารถใช้ Jinja2 สร้างทั้ง Config ที่ Deploy ได้ และ Report สรุปสถานะ VLAN สำหรับแสดงใน UI ได้จาก Template เดียวกัน

---

## 4. ความเป็นสากลและ Open Source

- Jinja2 เป็น **Open Source** ใช้ได้ฟรี
- รองรับทุก Vendor — Cisco, MikroTik, Huawei — เพราะ Template คือแค่ข้อความ
- มีชุมชนนักพัฒนาขนาดใหญ่ หาตัวอย่างได้ง่าย

> 💡 **โยงกับ MyNetMate:** เราสามารถเขียน Template แยกต่างหากสำหรับแต่ละ Vendor ได้เลย โดยใช้ Jinja2 เป็นตัวเดียวกัน

---

## 5. คุณค่าและความสำคัญของ Template

| ผู้ใช้งาน           | ประโยชน์ที่ได้รับ                        |
| ------------------- | ---------------------------------------- |
| **Network Admin**   | สร้าง Config ได้เร็วขึ้น ไม่ต้องพิมพ์ซ้ำ |
| **Help Desk / NOC** | ใช้ได้โดยไม่ต้องรู้ CLI ลึก              |
| **IT Engineer**     | มั่นใจได้ว่า Config ถูกต้องตาม Policy    |
| **องค์กร**          | ลด Human Error และเพิ่มความปลอดภัย       |

### 🏢 สถานการณ์ตัวอย่างจากหนังสือ: ติดตั้งสวิตช์ใน Data Center แห่งใหม่

สมมติต้องเตรียม Config สำหรับสวิตช์ 50 ตัวใน Data Center:

```
ส่วนที่เหมือนกันทุกตัว (Static):      ส่วนที่ต่างกันแต่ละตัว (Dynamic):
─────────────────────────────────      ──────────────────────────────────
• SNMP Community String เดียวกัน       • Hostname
• Admin Password เดียวกัน             • IP Address
• VLAN พื้นฐานเหมือนกัน              • Interface Description
• NTP Server เดียวกัน                 • Routing config เฉพาะ
```

**โดยไม่มี Template:** ต้องนั่งพิมพ์ Config 50 ชุด มีโอกาสผิดพลาดสูง

**เมื่อใช้ Template:** เขียน Template ครั้งเดียว + เตรียมไฟล์ข้อมูล 50 แถว → ได้ Config 50 ชุดที่สม่ำเสมอ 100%

> ⚠️ **สำคัญ:** หนังสือระบุว่า Template ไม่ได้กำจัด Human Error 100% แต่ถ้าทดสอบ Template ดีๆ จะลด Error ได้มากมาย และในโปรเจกต์จริง ไม่ใช่มนุษย์ที่ใช้ Template โดยตรง — **Ansible หรือ FastAPI จะเป็นตัว push Config ไปยังอุปกรณ์แบบ Automated**

---

## 6. Jinja คืออะไร?

**Jinja2** คือ Template Language ของ Python ที่ได้รับความนิยมสูงสุดในวงการ Network Automation

### ไวยากรณ์พื้นฐาน 3 แบบ:

| รูปแบบ | ใช้สำหรับ | ตัวอย่าง |
|--------|-----------|----------|
| `{{ ... }}` | แสดงค่าตัวแปร | `{{ hostname }}` |
| `{% ... %}` | คำสั่งควบคุม (if, for) | `{% if vlan_id %}` |
| `{# ... #}` | Comment ที่ไม่แสดงผล | `{# VLAN Section #}` |

### พัฒนาการของ Template 3 ขั้น (จากหนังสือ Examples 9-2, 9-3, 9-4)

หนังสือแสดงให้เห็นว่า Config เดิมพัฒนาเป็น Template ได้อย่างไร:

**Config เดิม (ก่อนทำ Template):**
```
interface GigabitEthernet0/1
description Server Port
switchport access vlan 10
switchport mode access
```

**ขั้น 1 — ตัวแปรเดียว (Example 9-2):** เปลี่ยนแค่ชื่อ Interface
```jinja2
interface {{ interface_name }}
description Server Port
switchport access vlan 10
switchport mode access
```

**ขั้น 2 — ตัวแปรหลายตัว (Example 9-3):** ยืดหยุ่นกว่า เปลี่ยนได้ทุกค่า
```jinja2
interface {{ interface_name }}
description {{ interface_description }}
switchport access vlan {{ interface_vlan }}
switchport mode access
```

**ขั้น 3 — ใช้ Object/Dict (Example 9-4 — แนะนำ):** Namespace-friendly
```jinja2
interface {{ interface.name }}
description {{ interface.description }}
switchport access vlan {{ interface.vlan }}
switchport mode access
```

ข้อมูลที่ส่งเข้า:
```python
interface = {
    "name": "GigabitEthernet0/1",
    "description": "Server Port",
    "vlan": 10
}
# หรือใช้ Python Class ก็ได้ — Jinja2 รองรับทั้งสองแบบ
```

> 💡 **โยงกับ MyNetMate:** เราจะใช้ขั้น 3 (Dict/Object) เพราะข้อมูลมาจาก PostgreSQL ผ่าน SQLAlchemy ORM ซึ่งเป็น Python Object พอดี

---

## 7. วิธีใช้ Jinja กับ Python

### ติดตั้งก่อน (ทำครั้งเดียว):
```bash
pip3 install jinja2
```
> ⚠️ Jinja2 ไม่ได้อยู่ใน Python Standard Library ต้องติดตั้งเองผ่าน pip

### ขั้นตอนแบบละเอียด (จากหนังสือ — ทำตามได้เลย):

**ขั้นที่ 1: เตรียม Environment และโหลดไฟล์ Template**
```python
from jinja2 import Environment, FileSystemLoader

# บอกว่าไฟล์ Template อยู่ในโฟลเดอร์เดียวกัน ('.')
ENV = Environment(loader=FileSystemLoader('.'))

# โหลดไฟล์ Template ขึ้นมา
template = ENV.get_template("template.jinja")
```

**ขั้นที่ 2: เตรียมข้อมูล (Data)**
```python
# ข้อมูลเป็น Dictionary — Key ต้องตรงกับชื่อตัวแปรใน Template!
interface_dict = {
    "name": "GigabitEthernet0/1",
    "description": "Server Port",
    "vlan": 10,
    "uplink": False
}
# ในงานจริง: ดึงข้อมูลจาก API หรือ DB แทนการ Hard-code แบบนี้
```

**ขั้นที่ 3: Render และแสดงผล**
```python
# ชื่อ argument "interface" ต้องตรงกับคำที่ใช้ใน Template!
print(template.render(interface=interface_dict))
```

**ผลลัพธ์:**
```
interface GigabitEthernet0/1
description Server Port
switchport access vlan 10
switchport mode access
```

### โหลดข้อมูลจากไฟล์ YAML (แนะนำสำหรับงานจริง):
```python
import yaml

with open("data.yml") as f:
    data = yaml.safe_load(f)

print(template.render(interface=data))
```

> 💡 **โยงกับ MyNetMate:** FastAPI Backend จะรับข้อมูลจาก PostgreSQL → แปลงเป็น Dict → ส่งเข้า `template.render()` → คืน Config String กลับมาให้ Frontend

---

## 8. ยกระดับ Template ให้เต็มประสิทธิภาพ

### 8.1 การวนลูป (For Loop)

ใช้เมื่อต้องการสร้าง Config หลายรายการจากข้อมูล List:

```jinja2
{% for interface in interface_list %}
interface {{ interface.name }}
 description {{ interface.desc }}
 ip address {{ interface.ip }} {{ interface.mask }}
!
{% endfor %}
```

ข้อมูล YAML:
```yaml
interface_list:
  - name: GigabitEthernet0/1
    desc: "Link to Core"
    ip: 192.168.1.1
    mask: 255.255.255.0
  - name: GigabitEthernet0/2
    desc: "Link to Server"
    ip: 10.0.0.1
    mask: 255.255.255.0
```

### 8.2 เงื่อนไข (If / Else)

ใช้เมื่อต้องการ Config ที่ต่างกันตามเงื่อนไข:

```jinja2
{% for interface in interface_list %}
interface {{ interface.name }}
 {% if interface.uplink %}
 switchport mode trunk
 {% else %}
 switchport mode access
 switchport access vlan {{ interface.vlan }}
 {% endif %}
{% endfor %}
```

### 8.3 Dictionary (Key-Value)

```jinja2
{% for name, desc in interface_dict.items() %}
interface {{ name }}
 description {{ desc }}
{% endfor %}
```

> 💡 **โยงกับ MyNetMate:** เราใช้ For Loop วน VLAN List และ If/Else เลือก Config ตาม Mode ของ Interface

---

## 9. Jinja Filters (ตัวกรอง)

**Filter** คือฟังก์ชันขนาดเล็กที่ใช้แปลงข้อมูลภายใน Template โดยไม่ต้องแก้โค้ด Python

### ไวยากรณ์:
```jinja2
{{ ตัวแปร | filter_name }}
```
ทำงานคล้ายกับ `|` (Pipe) ใน Linux Terminal

### ตัวอย่าง Built-in Filters:

| Filter | หน้าที่ | ตัวอย่าง | ผลลัพธ์ |
|--------|---------|---------|---------|
| `upper` | แปลงเป็นตัวพิมพ์ใหญ่ | `{{ desc\|upper }}` | `SERVER LINK` |
| `lower` | แปลงเป็นตัวพิมพ์เล็ก | `{{ desc\|lower }}` | `server link` |
| `reverse` | กลับตัวอักษร | `{{ desc\|reverse }}` | `knil revreS` |
| `default` | ค่า Default ถ้าตัวแปรว่าง | `{{ vlan\|default(1) }}` | `1` |

### การต่อสาย Filter (Chaining):
```jinja2
{{ interface.desc|upper|reverse }}
```
ทำงานซ้ายไปขวา: ได้ตัวพิมพ์ใหญ่ก่อน แล้วค่อยกลับ

### Custom Filter (สร้างเอง):

```python
# Python Script
def get_interface_speed(interface_name):
    if 'gigabit' in interface_name.lower():
        return 1000
    if 'fast' in interface_name.lower():
        return 100

# ลงทะเบียน Filter
env.filters['get_interface_speed'] = get_interface_speed
```

```jinja2
{# ใช้ใน Template #}
speed {{ interface.name|get_interface_speed }}
```

> 💡 **โยงกับ MyNetMate:** Custom Filter มีประโยชน์มากในการแปลง Subnet Mask หรือตรวจสอบ VLAN Range ก่อนใส่ลงไปใน Config

---

## 10. Template Inheritance (การสืบทอดเทมเพลต)

ใช้เมื่อต้องการแยก Template ออกเป็นไฟล์ย่อยๆ แล้วประกอบรวมกัน

### วิธีที่ 1: `include` — ดึงไฟล์อื่นมาแทรก

```jinja2
{# ใน main_template.jinja #}
{% include 'vlans.jinja' %}       {# ดึง VLAN Config จากไฟล์แยก #}
{% include 'interfaces.jinja' %}  {# ดึง Interface Config จากไฟล์แยก #}
{% include 'routing.jinja' %}     {# ดึง Routing Config จากไฟล์แยก #}
```

เหมาะกับ: การประกอบ Config ที่แยกเป็น Section อิสระจากกัน

### วิธีที่ 2: `block` + `extends` — สืบทอดและเขียนทับ

**Template แม่** (`base.jinja`):
```jinja2
{% for interface in interface_list %}
interface {{ interface.name }}
 description {{ interface.desc }}
{% endfor %}
!
{% block http_config %}
no ip http server
no ip http secure-server
{% endblock %}
```

**Template ลูก** (`with_http.jinja`):
```jinja2
{% extends "base.jinja" %}
{% block http_config %}
ip http server
ip http secure-server
{% endblock %}
```

เมื่อ Render ผ่าน `with_http.jinja` → ส่วน Interface จาก Base จะอยู่ครบ แต่ส่วน HTTP จะถูกแทนที่

> 💡 **โยงกับ MyNetMate:** เราสามารถทำ Template แม่สำหรับ Cisco IOS พื้นฐาน แล้วทำ Template ลูกแยกสำหรับ C2960, ISR4000 ที่มี Config เฉพาะรุ่นต่างกันได้

---

## 11. การสร้างตัวแปรใน Jinja

ใช้ `set` เพื่อย่อชื่อตัวแปรที่ยาว:

```jinja2
{% set int_desc = sw01.config.interfaces['ge0/1']['description'] %}

{# จากนี้ใช้ int_desc แทนได้เลย #}
description {{ int_desc }}
```

มีประโยชน์มากเมื่อต้องเข้าถึง Nested Dictionary หลายชั้น และใช้ค่าเดิมซ้ำหลายครั้ง

---

## ⚠️ 12. XSLT — ข้ามได้ ไม่ใช่ใน Scope โปรเจกต์

XSLT เป็น Template Language สำหรับแปลง XML เท่านั้น เราใช้ Python + Jinja2 จึงไม่จำเป็น
> หนังสือเองก็ยอมรับว่า Jinja เหมาะกับ Network Automation มากกว่า XSLT

---

## ⚠️ 13. Go Templates — ข้ามได้ ไม่ใช่ใน Scope โปรเจกต์

Go Templates ใช้กับภาษา Go เท่านั้น โปรเจกต์เราใช้ Python ทั้งหมด จึงไม่เกี่ยวข้อง

---

## 🏆 สรุปบทเรียน (Summary)

หนังสือแนะนำ **Best Practices 4 ข้อ** สำหรับการใช้ Template:

| # | หลักการ | อธิบาย |
|---|---------|--------|
| 1 | **รักษาความเรียบง่าย** | อย่าใส่ Logic ซับซ้อนใน Template เกินไป ย้ายส่วนที่ซับซ้อนไปใส่ Python แทน |
| 2 | **ใช้ Template Inheritance** | แยก Config เป็น Module ย่อยๆ แล้วประกอบกัน อย่าทำไฟล์ยักษ์ไฟล์เดียว |
| 3 | **แยก Syntax กับ Data ออกจากกัน** | Template = โครงสร้างคำสั่ง, YAML = ข้อมูล อย่าปนกัน |
| 4 | **ใช้ Version Control** | Template คือ Text File → ใส่ใน Git ได้เลย ติดตามการเปลี่ยนแปลงได้ |

---

## 🔗 ความเชื่อมโยงกับโปรเจกต์ MyNetMate

```
ผู้ใช้กรอก Form (VLAN ID, IP, Interface)
         ↓
Backend ดึงข้อมูลจาก PostgreSQL (Inventory)
         ↓
Jinja2 Template Engine ประกอบ Config
  ├── For Loop วน VLAN List
  ├── If/Else เลือก Trunk/Access Mode
  ├── Custom Filter ตรวจสอบ VLAN Range
  └── Template Inheritance (Base Cisco + รุ่นเฉพาะ)
         ↓
ได้ Config พร้อม Deploy → ส่ง Review / Deploy
```

> 📖 **ไฟล์ต้นฉบับแยกรายหัวข้อ:** อยู่ในโฟลเดอร์เดียวกันนี้ ไฟล์ 1-13
