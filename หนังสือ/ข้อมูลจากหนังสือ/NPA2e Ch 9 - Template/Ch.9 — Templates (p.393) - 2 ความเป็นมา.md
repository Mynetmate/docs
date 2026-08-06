
ความเป็นมา บทบาท และโครงสร้างการทำงานของภาษาเทมเพลต (Template Languages) 
โดยชี้ให้เห็นว่าเทคโนโลยีนี้มีมานานแล้วและถูกใช้งานอย่างลึกซึ้งในอุตสาหกรรมการพัฒนาเว็บ ก่อนที่จะขยายขอบเขตมาสู่การใช้งานกับสื่อที่เป็นข้อความประเภทอื่น รวมถึงการตั้งค่าคอนฟิกเครือข่าย

เนื้อหาหลักแบ่งออกเป็นประเด็นสำคัญพร้อมตัวอย่างตามที่หนังสือระบุไว้ดังนี้:

### จุดเริ่มต้นและประโยชน์ของภาษาเทมเพลต

หนังสือระบุว่าเว็บส่วนใหญ่ในปัจจุบันมีพื้นฐานมาจากเทมเพลต เนื่องจากมีขอบเขตการใช้งานที่หลากหลายในสื่อรูปแบบข้อความ (Text-based medium) ทุกชนิด รวมถึงการทำเอกสาร (Documentation) และการทำรายงาน (Reports)

- **ตัวอย่างที่หนังสือยกขึ้นมา:** ในเว็บไซต์โซเชียลมีเดีย แทนที่นักพัฒนาจะต้องเขียนไฟล์ HTML แยกให้กับหน้าโปรไฟล์ของผู้ใช้งานทุกคน นักพัฒนาจะเขียนเทมเพลตขึ้นมาเพียงไฟล์เดียว แล้วใช้วิธีแทรกค่าไดนามิก (Dynamic values) ลงไปในเทมเพลตนั้นแทน โดยขึ้นอยู่กับข้อมูลที่ถูกส่งมาจากระบบหลังบ้าน (Backend)
    

### 3 ขั้นตอนสำคัญในการใช้งานเทมเพลต

หนังสือเน้นย้ำว่า ตัวเทมเพลตเดี่ยวๆ นั้นไม่ได้มีประโยชน์อะไรมากนัก การใช้งานให้เกิดผลลัพธ์จะต้องประกอบด้วย 3 ขั้นตอน คือ:

1. **ขั้นตอนแรก:** เทมเพลตจะต้องถูกเขียนขึ้นมาก่อน
    
2. **ขั้นตอนที่สอง:** จะต้องมีข้อมูล (Data) ในรูปแบบใดรูปแบบหนึ่ง เพื่อนำข้อมูลนั้นไปเรนเดอร์เข้าสู่เทมเพลตให้เกิดสิ่งที่มีความหมาย เช่น คอนฟิกเครือข่าย
    
3. **ขั้นตอนที่สาม:** ต้องมีบางสิ่งมาทำหน้าที่ขับเคลื่อนข้อมูล (Drive data) เข้าไปในเทมเพลต
    
- **ตัวอย่างเครื่องมือขับเคลื่อนข้อมูลที่หนังสือระบุ:** สิ่งที่นำข้อมูลไปใส่ในเทมเพลตอาจเป็นเครื่องมือ Automation อย่าง **Ansible** (เนื้อหาบทที่ 12) หรือการจัดการด้วยตัวเองผ่านการเขียนภาษา **Python** (เนื้อหาช่วงท้ายของบทนี้)
    

### ความสัมพันธ์ระหว่างภาษาเทมเพลตและภาษาหลัก

ภาษาเทมเพลตส่วนใหญ่ไม่ใช่ภาษาโปรแกรมมิ่งแบบเต็มตัว แต่จะผูกติดอย่างใกล้ชิดกับภาษาหลักที่ทำหน้าที่ส่งข้อมูลให้ ส่งผลให้ภาษาเทมเพลตนั้นมีความคล้ายคลึงกับภาษาแม่ของมัน

- **ตัวอย่างที่หนังสือยกขึ้นมา:** ภาษาเทมเพลตที่ชื่อว่า **Jinja** เติบโตมาจากกลุ่มคอมมูนิตี้ที่เน้นการใช้ Python เป็นหลัก (Python-centric community) ทำให้ Jinja มีลักษณะความคล้ายคลึงกับภาษา Python อย่างเห็นได้ชัด
    
- **คำแนะนำจากหนังสือ:** หากไม่แน่ใจว่าจะเลือกใช้ภาษาเทมเพลตไหน ดีที่สุดคือให้พิจารณาว่าคุณกำลังใช้งานร่วมกับภาษา "จริง" (Real language) ภาษาใดอยู่ (ไม่ว่าจะจากการเขียนโค้ดเองหรือใช้เครื่องมือที่มีอยู่แล้วอย่าง Ansible) แล้วจึงเริ่มต้นจากจุดนั้น
    

### วิวัฒนาการสู่เนื้อหาแบบไดนามิก (Dynamic Content)

ในยุคเริ่มต้นของเว็บ เว็บไซต์ส่วนใหญ่ถูกสร้างขึ้นจากเนื้อหาที่ค่อนข้างคงที่ (Static content) การพัฒนาภาษาเทมเพลตเข้ามาเพื่อทำหน้าที่โหลดชิ้นส่วนข้อมูลเข้าสู่หน้าเว็บแบบไดนามิกจึงถือเป็นก้าวสำคัญอย่างมากในเวลานั้น แม้ว่าในปัจจุบันเรื่องนี้จะกลายเป็นเรื่องปกติที่ผู้คนไม่ได้ใส่ใจแล้วก็ตาม

The Rise of Modern Template Languages
Template technologies have been around for a very, very long time. Just a basic
web search for “template languages” shows a multitude of these, most often several
options for every related programming language.
You may also notice that the majority of these languages have deep applications in the
web development industry. This is because much of the web is based on templates!
Instead of writing HTML files for every single user-profile page that a social media
site may have, the developers will write one and insert dynamic values into that
template, depending on the data being presented by the backend.
In short, template languages have a wide variety of relevant use cases. Their obvious
roots are in web development, and of course we’ll be talking about using them for
network configuration in this chapter, but they have applications in just about any
text-based medium, including documentation and reports.
So it’s important to remember that using templates requires three steps. First, the
templates have to be written. Second, you need some form of data, which will
ultimately get rendered into the template to produce something meaningful like a
network configuration. This leads us to the third step: something has to drive data
into the template. This could be an automation tool like Ansible, which we cover in
Chapter 12, or you could be doing it yourself with a language like Python, which we
show later in this chapter. Templates are not very useful on their own.
Most template languages aren’t full-on programming languages in
the purest sense. Most often, a template language is closely tied to
another language that will drive data into the templates that you’ve
built. As a result, each template language and its “parent” language
have several similarities. A good example is one that we heavily
discuss in this chapter: Jinja is a template language that came out of
a Python-centric community, so Jinja has distinct similarities with
Python. So if you’re wondering which template language to use, it’s
probably best to decide which “real” language you’re aligned with
(either through writing your own code or by using an existing tool
like Ansible) and go from there.
As mentioned previously, template languages aren’t necessarily a new concept, but
we are seeing new ideas and even entire languages make it into the ecosystem all the
time. If you look at the history of template languages, many were created to serve as
a crucial part of the web: dynamic content. This is easily taken for granted these days,
but back when the web was just getting started and most websites were built from
fairly static content, dynamically loading pieces of data into a page was a big step
forward.
368