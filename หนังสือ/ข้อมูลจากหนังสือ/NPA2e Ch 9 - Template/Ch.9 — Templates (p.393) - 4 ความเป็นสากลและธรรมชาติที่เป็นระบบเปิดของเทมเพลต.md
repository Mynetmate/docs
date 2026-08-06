หัวข้อนี้พูดถึง **"ความเป็นสากลและธรรมชาติที่เป็นระบบเปิดของเทมเพลต"** โดยเน้นย้ำว่าแนวคิดของเทมเพลตไม่ได้จำกัดอยู่แค่กรณีการใช้งาน (Use case) ใดกรณีหนึ่งเท่านั้น แต่สามารถนำไปประยุกต์ใช้กับสื่อหรือเอกสารใดๆ ก็ตามที่เป็นรูปแบบข้อความ (Text-based medium) เพื่อแปลงข้อมูลให้ออกมาอยู่ในรูปแบบข้อความเฉพาะที่ต้องการ

เนื้อหาหลักแบ่งออกเป็นประเด็นสำคัญพร้อมตัวอย่างและภาพประกอบตามที่ระบุในหนังสือ ดังนี้ครับ:

### กระบวนการทำงานพื้นฐานของเทมเพลต (Figure 9-1)

หนังสือระบุว่า เทคโนโลยีเทมเพลตทั้งหมดที่พูดถึงในบทนี้มีหลักการทำงานพื้นฐานที่เหมือนกัน ซึ่งสรุปขั้นตอนการทำงานได้ตาม **Figure 9-1: How templates are produced** ดังนี้:

1. **Data:** เริ่มต้นจากข้อมูลดิบ ซึ่งอาจอยู่ในรูปแบบของตัวเลข (Integers), ข้อความ (Strings), รายการข้อมูล (Lists) หรือดิกชันนารี (Dictionaries) และอื่นๆ
    
2. **Template:** ข้อมูลจะถูกส่งต่อเข้าสู่เทมเพลตที่มีการกำหนดตัวแปร (Variables) และตรรกะควบคุม (Logic) เอาไว้ภายใน
    
3. **Result:** ผลลัพธ์ที่ได้ออกมาคือเอกสารข้อความที่ถูกเรนเดอร์ค่าต่างๆ ลงไปอย่างสมบูรณ์ (Fully rendered text document)
    ![[Pasted image 20260715200840.png]]

ด้วยรูปแบบการทำงานนี้ ทำให้เทมเพลตมีประโยชน์กับทุกสิ่งที่เป็นข้อความ ไม่ว่าจะเป็นรายงาน (Reports) หรือไฟล์การตั้งค่าระบบ (Configuration files) ต่างๆ

### การทำรายงานสรุปข้อมูลเครือข่าย

หนังสือยกสถานการณ์ตัวอย่างในงานเน็ตเวิร์กไว้ว่า หากคุณดึงข้อมูลมาจากอุปกรณ์เครือข่าย (Network device) แล้วต้องการสร้างรายงานที่ดูดีเพื่อส่งอีเมลหาเพื่อนร่วมงาน คุณสามารถใช้เทมเพลตในการจัดการได้

> **ตัวอย่างที่หนังสือยกขึ้นมา (Example 9-1):** หนังสือแสดงตัวอย่างของ **Jinja template** ที่ใช้สร้างรายงานตารางรายชื่อ VLAN ซึ่งเขียนโครงร่างข้อความและมีตรรกะการวนลูปดังนี้:
> 
> Plaintext
> 
> ```
> | VLAN ID | NAME | STATUS |
> | ------- |------| -------|
> {% for vlan in vlans %}
> | {{ vlan.get('vlan_id') }} | {{ vlan.get('name') }} | {{ vlan.get('status') }} |
> {% endfor %}
> ```
> 
> - **การทำงานของตัวอย่างนี้:** ตราบใดที่ผลลัพธ์สุดท้ายที่คุณต้องการคือข้อความ (Text) คุณก็สามารถสร้างเทมเพลตขึ้นมารองรับได้เสมอ ระบบจะนำข้อมูล VLAN แต่ละตัวที่มีค่า `vlan_id`, `name` และ `status` มาวนลูป (`{% for ... %}`) และแทนที่ลงในตัวแปร `{{ ... }}` เพื่อต่อให้เป็นตารางข้อความที่สมบูรณ์
>     

### สรุปคำแนะนำจากหนังสือ

หนังสือทิ้งท้ายให้ผู้จำไว้ว่า เทมเพลตมีลักษณะที่เป็นสากล (Generic nature) เมื่อเริ่มเข้าสู่รายละเอียดของกรณีใช้งานเฉพาะทางหรือเทคโนโลยีเฉพาะอย่าง Jinja ขอให้ตระหนักไว้เสมอว่า **เทมเพลตนั้นมีการประยุกต์ใช้งานที่ก้าวไกลและกว้างขวางกว่าชุดกรณีการใช้งานแคบๆ ที่ยกมานำเสนอในบทนี้มากครับ**

_(หมายเหตุ: หนังสือระบุเพิ่มเติมว่า โค้ดตัวอย่างฉบับเต็มทั้งหมดในบทนี้ สามารถเข้าไปดูได้ที่ GitHub repository ของหนังสือตามลิงก์ที่ให้ไว้ในหน้าข้อความครับ)_


Expanding On the Use of Templates
The concepts of templating, especially those discussed in this chapter, are not specific
to any single use case and can be applied to nearly any text-based medium. At the
end of the day, templates are just a way to transform data into a specific text format.
Figure 9-1 illustrates this flow.
Figure 9-1. How templates are produced
All template technologies discussed in this chapter generally work this way. This
makes templates useful for anything text based, including reports, configuration files,
and configurations. Perhaps you’re pulling data from a network device and want to
be able to produce a nice report on this data and email it to coworkers. Example 9-1
shows a Jinja template for producing a report containing a list of VLANs.
Full versions of the code examples in this chapter can be found in
the book’s GitHub repo at https://github.com/oreilly-npa-book/exam
ples/tree/v2/ch09-templates.
Example 9-1. Basic report with Jinja
| VLAN ID | NAME | STATUS |
| ------- |------| -------|
{% for vlan in vlans %}
| {{ vlan.get('vlan_id') }} | {{ vlan.get('name') }} | {{ vlan.get('status') }} |
{% endfor %}
Because you’re really just working with text, you can build a template for it. Keep
the generic nature of templates in mind as you get into the details of specific use
cases and particular template technologies like Jinja; templates have applications well
beyond the narrow set of use cases presented in this chapter.