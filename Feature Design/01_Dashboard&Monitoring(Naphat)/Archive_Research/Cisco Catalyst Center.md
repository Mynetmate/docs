## Cisco Catalyst Center คืออะไร
[What is Cisco Catalyst Center?](https://www.rogerperkin.co.uk/cisco-catalyst-center/what-is-cisco-catalyst-center/)
[Cisco Catalyst Center At-a-Glance](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/dna-center/nb-06-cisco-dna-center-aag-cte-en.html)

**Cisco Catalyst Center** (ชื่อเดิมคือ **Cisco DNA Center** ก่อนเปลี่ยนชื่อในปี 2023) เป็นผลิตภัณฑ์เดียวกัน เพียงแค่เปลี่ยนชื่อใหม่ โดยเป็นระบบบริหารจัดการเครือข่ายที่ทรงพลัง ใช้ปัญญาประดิษฐ์ (AI) ในการเชื่อมต่อ รักษาความปลอดภัย และทำงานอัตโนมัติให้กับระบบเครือข่าย ช่วยลดความซับซ้อนในการจัดการโครงสร้างพื้นฐานเครือข่าย Cisco Catalyst และรับประกันประสบการณ์การใช้งานที่สอดคล้องกันทั้งเครือข่ายแบบมีสายและไร้สาย พูดง่ายๆ คือเป็น "ศูนย์ควบคุม" (Controller) ที่ให้ทีม IT บริหารจัดการอุปกรณ์เครือข่าย Cisco ทั้งหมดจากแดชบอร์ดเดียว แทนที่จะต้อง config อุปกรณ์ทีละตัวผ่าน CLI

### ฟังก์ชันหลัก

**1. Design (ออกแบบเครือข่าย)** ออกแบบเครือข่ายผ่าน workflow ที่ใช้งานง่าย เริ่มจากการกำหนดสถานที่ที่จะติดตั้งอุปกรณ์เครือข่าย

**2. Provisioning (การติดตั้งใช้งาน)** รองรับการค้นหาอุปกรณ์เครือข่ายอัตโนมัติ และช่วยลดความซับซ้อนในการ provisioning ด้วย plug and play, zero-touch provisioning

**3. Policy (นโยบายเครือข่าย)** ช่วยลดข้อผิดพลาดจากมนุษย์และรองรับการปฏิบัติตามนโยบาย โดยแปลงนโยบายให้เป็นค่า configuration และนำไปใช้อย่างสม่ำเสมอทั่วทั้งเครือข่าย

**4. Assurance (การรับประกันคุณภาพ)** การวิเคราะห์เชิงคาดการณ์ (Predictive analytics) ช่วยระบุปัญหาที่อาจเกิดขึ้นก่อนที่จะกลายเป็นปัญหาจริง และเมื่อเกิดปัญหาขึ้น ช่วยให้แก้ไขปัญหาได้เร็วขึ้นด้วย machine learning

**5. Software Image Management (SWIM)** การจัดการอิมเมจซอฟต์แวร์แบบอัตโนมัติ ช่วยลดความยุ่งยากในการอัปเดตซอฟต์แวร์อุปกรณ์ด้วยตนเอง

### รูปแบบการติดตั้ง (Deployment)

Catalyst Center สามารถติดตั้งได้ทั้งแบบ cloud service หรือแบบ on-premises

- **Physical Appliance**: ออกแบบมาสำหรับเครือข่ายระดับองค์กรขนาดใหญ่ ติดตั้งแบบ on-premises
- **Virtual Appliance**: ออกแบบให้ติดตั้งบน public cloud อย่าง AWS, Azure หรือบน VMware ESXi

### ใช้ทำอะไร / เหมาะกับใคร

มักใช้สำหรับงาน network provisioning, policy management, assurance และ analytics โดยมีเป้าหมายเพื่อลดความซับซ้อนในการบริหารเครือข่ายและเพิ่มประสิทธิภาพ และมักใช้ร่วมกับ Cisco Software-Defined Access (SDA) เหมาะสำหรับองค์กรที่มีเครือข่าย Cisco Catalyst ขนาดใหญ่ เช่น มหาวิทยาลัย โรงพยาบาล บริษัทที่มีหลายสาขา ที่ต้องการจัดการอุปกรณ์เครือข่ายจำนวนมากจากศูนย์กลาง


## ออกแบบมาสำหรับอุปกรณ์ Cisco เป็นหลัก
โดยเฉพาะฟีเจอร์เต็มรูปแบบอย่าง provisioning, SD-Access, SWIM (software update) ล้วนใช้ได้กับอุปกรณ์ Cisco Catalyst เท่านั้น

แต่ตั้งแต่เวอร์ชัน **2.3.7.x** เป็นต้นมา Cisco เพิ่มการรองรับอุปกรณ์ third-party แบบจำกัดด้วย โดยมีเงื่อนไขดังนี้:

### เงื่อนไขอุปกรณ์ third-party ที่รองรับ

อุปกรณ์ third-party ในที่นี้หมายถึงอุปกรณ์ที่ไม่ใช่ Cisco แต่รองรับมาตรฐาน MIB-II/SNMP (RFC1213) เท่านั้น ซึ่งจะถูกจัดประเภทเป็น "Generic Device"

### สิ่งที่ทำได้กับอุปกรณ์ third-party

การเพิ่มอุปกรณ์ third-party ต้องทำผ่านเมนู Inventory โดยใช้ SNMP Credentials เท่านั้น ยังไม่รองรับผ่านช่องทาง Discovery/PnP และขอบเขตการใช้งานจำกัดอยู่ที่:

- **Inventory**: การกำหนด site, resync, ลบอุปกรณ์, แก้ไขข้อมูล, ดูรายละเอียดอุปกรณ์ (เช่น สถานะ interface, ข้อมูลฮาร์ดแวร์)
- **Topology**: แสดงไอคอนอุปกรณ์ แต่ไม่มีข้อมูลการเชื่อมโยง (link) ระหว่างอุปกรณ์
- **Assurance**: ดู device health score จากสถานะการเข้าถึง (reachability) รวมถึงปัญหาด้าน interface และ reachability

### สิ่งที่ทำ**ไม่ได้**กับอุปกรณ์ third-party

- ไม่รองรับอุปกรณ์ไร้สาย เช่น AP หรือ WLC ของ third-party เพราะยังไม่สามารถให้ข้อมูล MIB-II ได้
- ไม่รองรับการ provisioning อุปกรณ์ third-party
- ฟีเจอร์อย่าง SWIM, RMA, Compliance check และ Config drift ไม่รองรับสำหรับอุปกรณ์ third-party
- Cisco จะไม่ออก entitlement ใหม่หรือปรับปรุง EULA สำหรับอุปกรณ์ third-party เหล่านี้

### สรุปง่ายๆ

| ประเภทงาน                          | Cisco device | Third-party (SNMP) |
| ---------------------------------- | ------------ | ------------------ |
| Automation/Provisioning เต็มรูปแบบ | ✅            | ❌                  |
| SD-Access                          | ✅            | ❌                  |
| Software Update (SWIM)             | ✅            | ❌                  |
| ดูสถานะ/Health monitoring พื้นฐาน  | ✅            | ✅ (จำกัด)          |
| Topology (ไม่มี link)              | ✅            | ✅ (จำกัด)          |

พูดง่ายๆ คือ Catalyst Center **มองเห็น** อุปกรณ์ non-Cisco ได้ในระดับ monitoring พื้นฐานเท่านั้น แต่ **บริหารจัดการ/config เชิงลึก** ยังคงจำกัดเฉพาะอุปกรณ์ Cisco Catalyst เป็นหลักครับ