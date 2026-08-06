เนื้อหาในหัวข้อ **"Using Jinja Filters" (การใช้งาน Jinja Filters)** สามารถสรุปและอธิบายรายละเอียดโดยอิงตามข้อเท็จจริงในหนังสือได้ดังนี้ครับ

## 1. หัวข้อนี้พูดถึงอะไร?

หัวข้อนี้พูดถึง **"การใช้งาน Jinja Filters (ตัวกรอง)"** ซึ่งเป็นฟังก์ชันมอดูลาร์ขนาดเล็กที่สามารถเรียกใช้ ณ จุดใดก็ได้ในเทมเพลต เพื่อทำหน้าที่รับข้อมูลหรือข้อความเข้ามาเป็นอินพุต ประมวลผลเฉพาะทางบางอย่าง และส่งผลลัพธ์นั้นออกไปในเทมเพลตที่ถูกเรนเดอร์

หนังสือระบุว่า โครงสร้างข้อมูล (เช่น list และ dictionary) และตรรกะพื้นฐาน (เช่น loop และ conditional) ที่นำเสนอไปก่อนหน้านี้มีความก้าวหน้าไม่เพียงพอสำหรับงานบางอย่าง เช่น การแปลงอินพุตให้เป็นตัวพิมพ์ใหญ่ทั้งหมด หรือการกลับอักษรในสตริง ซึ่งหากไม่มีฟิลเตอร์ งานเหล่านี้จะยากมากหรือเป็นไปไม่ได้เลย ไวยากรณ์ของฟิลเตอร์มีความเรียบง่าย โดยทำงานคล้ายกับการส่งต่อผลลัพธ์ (Pipe) ด้วยเครื่องหมาย `|` จากคำสั่งหนึ่งไปยังอีกคำสั่งหนึ่งใน Terminal Shell ของ Linux นอกจากนี้หนังสือนังนำเสนอทั้งฟิลเตอร์สำเร็จรูป การร้อยเรียงฟิลเตอร์ และการเขียนฟิลเตอร์ขึ้นมาใช้งานเองสำหรับงาน Network Automation

## 2. ตัวอย่างในหนังสือและการอธิบาย

หนังสือได้ยกตัวอย่างการใช้งานไว้ทั้งหมด 5 ตัวอย่าง ดังนี้ครับ:

### ตัวอย่างที่ 1: ไวยากรณ์ฟิลเตอร์พื้นฐาน (Example 9-8)

หนังสือแสดงรูปแบบไวยากรณ์เริ่มต้นของการใช้ฟิลเตอร์ผ่านเครื่องหมายปีกกาคู่:

Plaintext

```
Example 9-8. Basic filter syntax in Jinja
{{ hostname|myfilter }}
```

- **คำอธิบายจากหนังสือ:** ตัวอย่างนี้ใช้ตัวแปรชื่อ `hostname` โดยก่อนที่เนื้อหาของมันจะถูกเรนเดอร์ออกไปเป็นผลลัพธ์สุดท้าย ข้อมูลจะถูกส่งผ่านเครื่องหมาย `|` เข้าไปยังฟิลเตอร์ที่ชื่อ `myfilter` ก่อน แล้วจึงนำผลลัพธ์ที่ได้จากฟิลเตอร์นั้นไปเติมลงในส่วนดังกล่าวของเทมเพลต
    

### ตัวอย่างที่ 2: การใช้ฟิลเตอร์ `upper` (Built-in Filter)

หนังสือได้เปลี่ยนตัวอย่างโครงสร้างเดิมให้เป็นตัวอย่างที่ใช้งานได้จริง โดยใช้ฟิลเตอร์สำเร็จรูปชื่อ `upper` ที่ติดมากับไลบรารี Jinja2 สำหรับ Python เพื่อแปลงคำอธิบายพอร์ตอินเทอร์เฟซให้เป็นตัวพิมพ์ใหญ่:

Plaintext

```
{% for interface in interface_list %}
interface {{ interface.name }}
description {{ interface.desc|upper }}
{% if interface.uplink %}
switchport mode trunk
{% else %}
switchport access vlan {{ interface.vlan }}
switchport mode access
{% endif %}
{% endfor %}
```

- **คำอธิบายจากหนังสือ:** ฟิลเตอร์ `upper` จะทำหน้าที่รับข้อความที่ส่งผ่านท่อ (`|`) มาหาตัวมัน แล้วแปลงข้อความนั้นให้กลายเป็นตัวพิมพ์ใหญ่ทั้งหมด
    

### ตัวอย่างที่ 3: การร้อยเรียงฟิลเตอร์ (Chaining Jinja Filters)

หนังสือแสดงให้เห็นว่าเราสามารถนำฟิลเตอร์มาต่อสายร่วมกันได้ เหมือนกับการส่งต่อคำสั่งใน Linux โดยเพิ่มฟิลเตอร์ `reverse` ต่อท้ายเพื่อกลับตัวอักษรจากหลังมาหน้า:

Plaintext

```
{% for interface in interface_list %}
interface {{ interface.name }}
description {{ interface.desc|upper|reverse }}
{% if interface.uplink %}
switchport mode trunk
{% else %}
switchport access vlan {{ interface.vlan }}
switchport mode access
{% endif %}
{% endfor %}
```

เมื่อทำงานร่วมกับข้อมูลจำลองในหนังสือ จะได้ผลลัพธ์คอนฟิกที่เรนเดอร์ออกมาดังนี้:

Plaintext

```
interface GigabitEthernet0/1
description TROP KNILPU
switchport mode trunk
interface GigabitEthernet0/2
description ENO REBMUN TROP REVRES
switchport access vlan 10
switchport mode access
interface GigabitEthernet0/3
description OWT REBMUN TROP REVRES
switchport access vlan 10
switchport mode access
```

- **คำอธิบายจากหนังสือ:** หนังสือสรุปกระบวนการทำงานให้เห็นภาพว่า เดิมทีพอร์ต `GigabitEthernet0/1` มีคำอธิบายเริ่มต้นคือ `first uplink port` เมื่อผ่านฟิลเตอร์แรกคือ `upper` ข้อความจะถูกเปลี่ยนเป็น `UPLINK PORT` จากนั้นฟิลเตอร์ `reverse` ก็เข้ามารับช่วงต่อและกลับตัวอักษรจนกลายเป็น `TROP KNILPU` ก่อนที่จะพิมพ์ผลลัพธ์สุดท้ายลงในเทมเพลต
    

### ตัวอย่างที่ 4: สคริปต์ Python สำหรับสร้าง Custom Filter (Example 9-9)

ในกรณีที่ต้องการฟังก์ชันเฉพาะทางสำหรับระบบอัตโนมัติของเครือข่ายที่ไม่มีมาให้ใน Jinja2 ตัวไลบรารีเปิดโอกาสให้สร้างขึ้นเองได้ โดยหนังสือแสดงสคริปต์ Python ฉบับเต็มไว้ดังนี้:

Python

```
Example 9-9. Full Python script with custom Jinja filter
from jinja2 import Environment, FileSystemLoader
import yaml

ENV = Environment(loader=FileSystemLoader('.'))

def get_interface_speed(interface_name):
    """ get_interface_speed returns the default Mbps value for a given
    network interface by looking for certain keywords in the name
    """
    if 'gigabit' in interface_name.lower():
        return 1000
    if 'fast' in interface_name.lower():
        return 100

ENV.filters['get_interface_speed'] = get_interface_speed
template = ENV.get_template("template.jinja")

with open("data.yml") as f:
    interfaces = yaml.safe_load(f)

print(template.render(interface_list=interfaces))
```

- **คำอธิบายจากหนังสือ:**
    
    - สคริปต์นี้เริ่มต้นด้วยการนำเข้าไลบรารี Jinja2 และ PyYAML พร้อมทั้งประกาศสภาพแวดล้อม (Environment) ของเทมเพลต
        
    - มีการสร้างฟังก์ชันชื่อ `get_interface_speed(interface_name)` เพื่อตรวจหาคำสำคัญในชื่ออินเทอร์เฟซ หากพบคำว่า `gigabit` จะส่งค่าตัวเลขความเร็วกลับไปเป็น `1000` (หน่วย Mbps) และถ้าพบคำว่า `fast` จะส่งกลับไปเป็น `100`
        
    - การนำฟังก์ชันนี้ไปลงทะเบียนเป็นฟิลเตอร์จะทำผ่านคำสั่ง `ENV.filters['get_interface_speed'] = get_interface_speed` ซึ่งเป็นการส่งตัวฟังก์ชันเข้าไปเฉยๆ โดยที่เอนจินของเทมเพลตจะเป็นผู้เรียกใช้ฟังก์ชันนี้ในภายหลังเมื่อมีการสั่ง
        
        `template.render()`
        
    - สุดท้ายสคริปต์จะโหลดข้อมูลจากไฟล์ YAML ภายนอกและส่งเข้าไปเรนเดอร์
        

### ตัวอย่างที่ 5: เทมเพลต Jinja ที่เรียกใช้ Custom Filter (Example 9-10)

หนังสือแสดงการปรับปรุงไฟล์เทมเพลตเพื่อให้เรียกใช้งานฟิลเตอร์สั่งทำพิเศษที่ถูกลงทะเบียนไว้ในตัวอย่างก่อนหน้า:

Plaintext

```
Example 9-10. Updated Jinja template leveraging the custom filter
{% for interface in interface_list %}
interface {{ interface.name }}
description {{ interface.desc|upper|reverse }}
{% if interface.uplink %}
switchport mode trunk
{% else %}
switchport access vlan {{ interface.vlan }}
switchport mode access
{% endif %}
speed {{ interface.name|get_interface_speed }}
{% endfor %}
```

- **คำอธิบายจากหนังสือ:** เทมเพลตนี้ถูกปรับแต่งโดยการเพิ่มบรรทัด `speed {{ interface.name|get_interface_speed }}` ซึ่งเป็นการส่งค่า `interface.name` ผ่านท่อเข้าไปในฟิลเตอร์ `get_interface_speed` ผลลัพธ์ที่ได้ออกมาจะเป็นตัวเลขจำนวนเต็มใดๆ ก็ตามที่ฟังก์ชันนั้นตัดสินใจส่งคืนกลับมา และเนื่องจากชื่ออินเทอร์เฟซในข้อมูลตัวอย่างทั้งหมดเป็น Gigabit Ethernet ค่าความเร็ว (Speed) จึงถูกตั้งค่าเป็น `1000` ทั้งหมด
    

หนังสือทิ้งท้ายไว้ว่า เราไม่จำเป็นต้องสร้างฟังก์ชันขึ้นมาเองเสมอไป เพราะมีไลบรารีอื่นๆ มากมายที่เตรียมฟังก์ชันที่มีประโยชน์ไว้ให้เรานำเข้า (Import) และส่งต่อเข้าสู่ระบบของ Jinja2 เพื่อใช้งานได้ทันที