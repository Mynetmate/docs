เนื้อหาในหัวข้อ **"Extensible Stylesheet Language Transformations (XSLT)"** สามารถสรุปและอธิบายรายละเอียดโดยอิงตามข้อเท็จจริงที่ปรากฏในหนังสือได้ดังนี้ครับ

## 1. หัวข้อนี้พูดถึงอะไร?

หัวข้อนี้พูดถึง **"Extensible Stylesheet Language Transformations (XSLT)"** ซึ่งเป็นรูปแบบการทำเทมเพลต (Templating format) ที่มีความทนทานและแข็งแกร่ง โดยระบุประเด็นสำคัญดังนี้:

- **ความเกี่ยวพันกับ XML:** XML เป็นรูปแบบข้อมูลที่ได้รับความนิยมอย่างมากและได้รับการสนับสนุนเป็นอย่างดีจากระบบปฏิบัติการเครือข่าย (NOS) รายใหญ่เพื่อวัตถุประสงค์ด้านระบบอัตโนมัติ ซึ่ง XSLT ถูกกำหนดข้อกำหนดโดย W3C และถูกนำมาใช้สำหรับการแปลงรูปแบบ (Transformations) ข้อมูล XML โดยเฉพาะ เช่น การแปลงข้อมูล XML ไปเป็น XHTML หรือเอกสาร XML อื่นๆ
    
- **การใช้งานทั่วไป:** เช่นเดียวกับ Jinja ตัว XSLT สามารถนำมาใช้สร้างเทมเพลตสำหรับเอกสารรูปแบบใดๆ ก็ได้ และด้วยความใกล้ชิดกับระบบนิเวศของ XML มันจึงเป็นตัวเลือกที่สำคัญที่วิศวกรควรมีไว้ในคลังเครื่องมือหากต้องทำงานกับ XML บ่อยครั้ง
    
- **ข้อสรุปเปรียบเทียบจากหนังสือ:** แม้ว่าเราจะสามารถผลิตคอนฟิกเครือข่ายออกมาได้โดยการใช้ XSLT แต่หนังสือยอมรับว่ามันค่อนข้างมีความยุ่งยาก (Cumbersome) โดยวิศวกรจะพบว่า Jinja เป็นภาษาเทมเพลตที่มีประโยชน์และเหมาะสมกว่ามากในการสร้างคอนฟิกเครือข่าย เนื่องจากมีฟีเจอร์ต่างๆ ที่เอื้ออำนวยต่อการทำ Network Automation
    

## 2. ตัวอย่างในหนังสือและการอธิบายอย่างละเอียด

หนังสือได้แสดงตัวอย่างการใช้งาน XSLT ร่วมกับ Python และการประยุกต์ใช้กับงานเน็ตเวิร์กไว้ตามลำดับดังนี้:

### ชุดตัวอย่างที่ 1: การสร้างตาราง HTML จากข้อมูล XML ของผู้เขียน

**1. ข้อมูลดิบในรูปแบบ XML (Raw Data)** เริ่มต้นด้วยการเตรียมข้อมูลดิบที่จะนำไปเติมในเทมเพลต ซึ่งเป็นข้อมูลรายชื่อผู้เขียนหนังสือ:

XML

```
<?xml version="1.0" encoding="UTF-8"?>
<authors>
  <author>
    <firstName>Christian</firstName>
    <lastName>Adell</lastName>
  </author>
  <author>
    <firstName>Scott</firstName>
    <lastName>Lowe</lastName>
  </author>
  <author>
    <firstName>Matt</firstName>
    <lastName>Oswalt</lastName>
  </author>
</authors>
```

- **คำอธิบาย:** ข้อมูลนี้ประกอบด้วยรายการของผู้เขียน (Authors) ซึ่งภายในจะมีองค์ประกอบย่อยเป็นชื่อจริง (`<firstName>`) และนามสกุล (`<lastName>`) โดยมีเป้าหมายคือการนำข้อมูลชุดนี้ไปสร้างเป็นตาราง HTML
    

**2. ไฟล์เทมเพลต XSLT (Example 9-14)** เทมเพลต XSLT ที่ถูกสร้างขึ้นมาเพื่อทำหน้าที่แปลงข้อมูล XML ให้เป็นตาราง HTML มีโครงสร้างดังนี้:

XML

```
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output indent="yes"/>
<xsl:template match="/">
<html>
<body>
  <h2>Authors</h2>
  <table border="1">
    <tr bgcolor="#9acd32">
      <th style="text-align:left">First Name</th>
      <th style="text-align:left">Last Name</th>
    </tr>
    <xsl:for-each select="authors/author">
    <tr>
      <td><xsl:value-of select="firstName"/></td>
      <td><xsl:value-of select="lastName"/></td>
    </tr>
    </xsl:for-each>
  </table>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
```

- **คำอธิบายข้อสังเกตสำคัญจากหนังสือ:**
    
    - โครงสร้างของลูป `for-each` พื้นฐานจะถูกฝังอยู่ภายในสิ่งที่มีหน้าตาเหมือนกับเอกสาร HTML ที่ถูกต้อง นี่เป็นแนวปฏิบัติมาตรฐานในภาษาเทมเพลต คือ ข้อความที่คงที่ (Static text) จะคงเดิมไว้ และจะวางส่วนตรรกะ (Logic) เล็กๆ น้อยๆ ลงไปในจุดที่จำเป็น
        
    - คำสั่ง `for-each` จะใช้พารามิเตอร์พิกัดตำแหน่ง (ระบุเป็น `authors/author`) เพื่อชี้ชัดว่าส่วนใดของเอกสาร XML ที่มีข้อมูลที่ต้องการนำมาใช้งาน ไวยากรณ์นี้เรียกว่า **XPath** ซึ่งใช้ภายในเอกสารและเครื่องมือ XML เพื่อระบุตำแหน่งภายในโครงสร้างต้นไม้ (XML tree)
        
    - มีการใช้คำสั่ง `value-of` เพื่อทำหน้าที่แทรกค่าข้อมูลจาก XML เข้ามาแบบไดนามิก (เปรียบเสมือนตัวแปรในโปรแกรมภาษา Python) ในรูปแบบข้อความ
        

**3. การสั่งรันผ่านโปรแกรม Python** สมมติว่าเซฟไฟล์เทมเพลตชื่อ `template.xslt` และไฟล์ข้อมูลชื่อ `data.xml` คุณสามารถใช้ Python Interpreter ร่วมกับไลบรารี `lxml` ในการรวมสองส่วนนี้เข้าด้วยกันเพื่อให้ได้เอาต์พุต HTML:

Python

```
from lxml import etree

xslRoot = etree.fromstring(bytes(open("template.xslt").read(), encoding='utf8'))
transform = etree.XSLT(xslRoot)
xmlRoot = etree.fromstring(bytes(open("data.xml").read(), encoding='utf8'))
transRoot = transform(xmlRoot)
```

**4. ผลลัพธ์สุดท้าย (Figure 9-2)** รหัสโปรแกรมด้านบนจะผลิตตาราง HTML ที่ถูกต้องออกมา โดยมีหน้าตาการแสดงผลดังภาพด้านล่างนี้ครับ:
![[Pasted image 20260715215308.png]]
### ข้อความสั่งการทางตรรกะเพิ่มเติมใน XSLT

หนังสือระบุเพิ่มเติมว่า XSLT ยังมีคำสั่งทางตรรกะอื่นๆ ให้ใช้งานอีก เช่น:

- `<if>`: ใช้สำหรับส่งเอาต์พุตขององค์ประกอบ (Elements) ออกไปก็ต่อเมื่อตรงตามเงื่อนไขที่กำหนดเท่านั้น
    
- `<sort>`: ใช้สำหรับจัดเรียงลำดับองค์ประกอบก่อนที่จะเขียนออกมาเป็นเอาต์พุต
    
- `<choose>`: เป็นเวอร์ชันที่ก้าวหน้ากว่าคำสั่ง `<if>` (เปิดโอกาสให้ใส่ตรรกะในสไตล์แบบ else if หรือ else ได้)
    

### ชุดตัวอย่างที่ 2: การนำ XSLT มาสร้าง Network Configuration

หนังสือได้ขยายแนวคิดนี้ไปใช้กับการสร้างเทมเพลตสำหรับคอนฟิกเครือข่าย โดยใช้ข้อมูลการตั้งค่าคอนฟิกที่ถูกกำหนดไว้ในรูปแบบ XML ดังนี้:

**1. ข้อมูลอินเทอร์เฟซในรูปแบบ XML (Example 9-15)**

XML

```
<?xml version="1.0" encoding="UTF-8"?>
<interfaces>
  <interface>
    <name>GigabitEthernet0/0</name>
    <ipv4addr>192.168.0.1 255.255.255.0</ipv4addr>
  </interface>
  <interface>
    <name>GigabitEthernet0/1</name>
    <ipv4addr>172.16.31.1 255.255.255.0</ipv4addr>
  </interface>
  <interface>
    <name>GigabitEthernet0/2</name>
    <ipv4addr>10.3.2.1 255.255.254.0</ipv4addr>
  </interface>
</interfaces>
```

- **คำอธิบาย:** ข้อมูลชุดนี้จัดเก็บรายชื่ออินเทอร์เฟซเครือข่าย โดยระบุชื่อพอร์ต (`<name>`) และหมายเลข IP พร้อม Subnet mask (`<ipv4addr>`) แยกเป็นแต่ละไอเทม
    

**2. เทมเพลต XSLT สำหรับเราเตอร์คอนฟิก (Example 9-16)** จากนั้นทำการสร้างเทมเพลต XSLT เพื่อรับข้อมูลข้างต้นแล้วนำไปเรนเดอร์ให้ออกมาเป็นเอกสารใหม่ที่มีคำสั่งคอนฟิกเครือข่ายที่ถูกต้อง:

XML

```
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <xsl:for-each select="interfaces/interface">
interface <xsl:value-of select="name"/>
 ip address <xsl:value-of select="ipv4addr"/>
  </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
```

- **คำอธิบาย:** เทมเพลตนี้จะทำการวนลูปผ่านตำแหน่ง `interfaces/interface` จากนั้นจะพิมพ์คำสั่งข้อความคงที่อย่างคำว่า `interface` ตามด้วยการดึงค่าจากแท็ก `name` ออกมาเติม และพิมพ์คำว่า `ip address` ตามด้วยการดึงค่าจากแท็ก `ipv4addr` ออกมาเติมในบรรทัดถัดไป
    

**3. ผลลัพธ์คอนฟิกที่ได้ (Output)** เมื่อประมวลผลเอกสาร XML และ XSLT ชุดนี้เข้าด้วยกัน จะได้คอนฟิกเราเตอร์ขั้นพื้นฐานในลักษณะเดียวกันกับการเจนหน้าเว็บ HTML ดังนี้ครับ:

Plaintext

```
interface GigabitEthernet0/0
 ip address 192.168.0.1 255.255.255.0
interface GigabitEthernet0/1
 ip address 172.16.31.1 255.255.255.0
interface GigabitEthernet0/2
 ip address 10.3.2.1 255.255.254.0
```