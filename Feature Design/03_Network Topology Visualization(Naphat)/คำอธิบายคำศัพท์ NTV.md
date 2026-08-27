# คำอธิบายคำศัพท์ Network Topology Visualization (NTV)

เอกสารนี้อธิบายคำศัพท์เฉพาะที่ใช้ใน [01_MVP - MyNetMate NTV.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/03_Network Topology Visualization(Naphat)/01_MVP - MyNetMate NTV.md) ด้วยภาษาง่าย ๆ โดยยึดบริบทของ MyNetMate ไม่ได้มุ่งเป็นนิยามสากลที่ครอบคลุมระบบเครือข่ายทุกประเภท

> [!NOTE]
> ไฟล์นี้เป็นเอกสารช่วยอ่าน ไม่ใช่ Source of Truth สำหรับชื่อตารางหรือขอบเขตการส่งมอบ หากคำศัพท์หรือชื่อตารางขัดกับ `01_MVP - MyNetMate NTV.md` หรือ `02_Database Schema.md` ให้ยึดสองไฟล์นั้นตามลำดับ

> **Scope ล่าสุด:** NTV MVP แสดง Topology จาก LLDP Observation เท่านั้น ไม่มี Manual Override, Verify/Reject, Report Incorrect หรือ Resolve Conflict Workflow คำศัพท์เหล่านี้เก็บไว้เพื่ออธิบาย Future Enhancement และไม่ใช่ข้อกำหนด MVP

## 1. ภาพรวมการทำงานแบบสั้น

MyNetMate มีช่องทางนำอุปกรณ์เข้าสู่ระบบ 2 วิธี:

1. **Manual Device Enrollment:** ผู้ใช้ทราบ IP ของอุปกรณ์อยู่แล้ว จึงระบุ IP และเลือกชุดข้อมูลรับรองสำหรับอุปกรณ์นั้น
2. **Network Discovery:** ระบบค้นหาอุปกรณ์ที่อาจมีอยู่ในขอบเขตเครือข่ายปิดที่กำหนด

ไม่ว่าจะเริ่มด้วยวิธีใด ระบบยังต้องเชื่อมต่ออุปกรณ์แบบอ่านอย่างเดียว ดึงข้อมูลจริง แปลงข้อมูล และบันทึกลง Device Inventory ก่อนที่ NTV จะนำข้อมูลไปวาดแผนผัง

ลำดับอย่างง่ายคือ:

`หาอุปกรณ์เป้าหมาย` → `เชื่อมต่อแบบอ่านอย่างเดียว` → `ดึงข้อมูลอุปกรณ์และเพื่อนบ้าน` → `แปลงข้อมูล` → `บันทึก Inventory` → `ตรวจสอบ Link` → `แสดง Topology`

## 2. คำศัพท์เกี่ยวกับการนำอุปกรณ์เข้าสู่ระบบ

### Manual Input / Manual Device Enrollment

ใน MyNetMate หมายถึงผู้ใช้ **ระบุอุปกรณ์เป้าหมายด้วยตนเอง** เช่น ใส่ Management IP Address และเลือก Device Credential Profile จากนั้นระบบจึงเชื่อมต่อไปอ่านข้อมูลจากอุปกรณ์

คำว่า Manual ในที่นี้ไม่ได้หมายถึงผู้ใช้กรอก Hostname, Model, Interface และ Link สมมติขึ้นเองทั้งหมด

**ตัวอย่าง:** ผู้ใช้กรอก IP `192.168.10.2` เลือก Credential ของ Cisco Switch แล้วระบบใช้ SSH ดึง Hostname, รุ่น, IOS Version, รายชื่อ Interface และข้อมูลเพื่อนบ้าน

### Network Discovery

กระบวนการที่ระบบค้นหาอุปกรณ์เป้าหมายภายในขอบเขตที่อนุญาต เช่น Ping IP ใน Isolated Lab หรือเริ่มจาก Seed IP แล้วอ่านข้อมูลเพื่อนบ้าน

Discovery ช่วยตอบว่า “มี IP หรืออุปกรณ์ใดที่อาจนำเข้าสู่ระบบได้บ้าง” แต่การตอบ Ping ได้เพียงอย่างเดียวยังไม่ยืนยันว่าเป็น Router/Switch หรือดึงข้อมูล Topology ได้

### Candidate Device

อุปกรณ์ที่ระบบ “สงสัยว่าอาจมีอยู่” เช่น IP ที่ตอบ Ping แต่ระบบยังเข้า SSH ไม่สำเร็จหรือยังไม่ทราบว่าเป็นอุปกรณ์ชนิดใด จึงยังไม่ควรแสดงเป็นอุปกรณ์ที่ยืนยันแล้วใน NTV

### Managed Device

อุปกรณ์ที่นำเข้าสู่ Device Inventory แล้วและระบบมีข้อมูลเพียงพอสำหรับบริหารจัดการ เช่น ระบุตัวตนได้ เชื่อมต่อได้ และมีผลการเก็บข้อมูลล่าสุด

### Verified Topology Node

Node ที่ NTV แสดงในฐานะอุปกรณ์ที่เชื่อถือได้ เพราะอ้างอิง Managed Device ที่ผ่านการเก็บข้อมูลจริงแล้ว ไม่ใช่ Node ที่วาดขึ้นมาเพื่อประกอบแผนผัง

### Known IP / Management IP Address

IP Address ที่ใช้ติดต่อและบริหารอุปกรณ์ เช่น IP ของ Management Interface ไม่จำเป็นต้องเป็น IP ของทุก Interface บนอุปกรณ์

### Seed IP

IP เริ่มต้นที่ระบบใช้เข้าสู่อุปกรณ์หนึ่งตัว แล้วอ่านตารางเพื่อนบ้านเพื่อหาอุปกรณ์ตัวถัดไป Seed IP ไม่ได้แปลว่าระบบได้รับอนุญาตให้ออกไปค้นหาทุกเครือข่ายโดยอัตโนมัติ

### Device Inventory

ฐานข้อมูลกลางของอุปกรณ์ที่ระบบบริหาร เช่น Device ID, Hostname, Vendor, Model, OS Version, Management IP, Interface และสถานะการเก็บข้อมูล NTV ต้องอ้าง Device จาก Inventory และไม่สร้าง Device ซ้ำเอง

## 3. คำศัพท์เกี่ยวกับข้อมูลรับรองและความปลอดภัย

### Credential

ข้อมูลที่ใช้พิสูจน์สิทธิ์ในการเข้าอุปกรณ์ เช่น Username, Password, SSH Key หรือ SNMP Community String

### Device Credential Profile

ชุดข้อมูลรับรองที่เตรียมไว้สำหรับเชื่อมต่อ Router/Switch ผู้ใช้อาจเลือก Profile ตอน Enrollment โดยไม่ต้องเห็น Password จริง

Device Credential Profile **ไม่ใช่** Username/Password ที่ใช้ Login เข้าเว็บ MyNetMate

### Credential Association

การผูก Candidate Device หรือ Managed Device เข้ากับ Credential Profile ที่ระบบได้รับอนุญาตให้ใช้ หมายถึงการระบุว่า “อุปกรณ์นี้ให้ลองใช้ชุดข้อมูลรับรองใด”

### Authentication

กระบวนการตรวจว่าข้อมูลรับรองถูกต้องและมีสิทธิ์เข้าอุปกรณ์หรือไม่ เช่น อุปกรณ์ยอมรับ Username/Password ที่ส่งผ่าน SSH

### Read-only Collection

การเชื่อมต่อเพื่ออ่านข้อมูลโดยไม่แก้ Configuration เช่นเรียกคำสั่ง `show version`, `show interfaces` หรือ `show lldp neighbors`

คำว่า Read-only เป็นข้อกำหนดด้านการทำงานของ MyNetMate แต่ทีมยังต้องตรวจสิทธิ์จริงของบัญชีบนอุปกรณ์ เพราะบัญชีที่มีสิทธิ์สูงอาจแก้ Configuration ได้แม้โปรแกรมตั้งใจเรียกเฉพาะคำสั่งอ่าน

### Secret

ข้อมูลลับ เช่น Password, Private Key, Enable Secret หรือ SNMP Community String ต้องเก็บแบบปลอดภัยและห้ามแสดงกลับผ่านหน้าเว็บ, Audit Log หรือส่งไป Gemini API

### Isolated Lab

เครือข่ายปิดที่จัดเตรียมสำหรับทดสอบ แยกจากเครือข่ายใช้งานของมหาวิทยาลัย เพื่อลดความเสี่ยงจาก Ping Sweep, Discovery และการเชื่อมต่ออุปกรณ์

### Allowlist

รายการ IP, CIDR หรืออุปกรณ์ที่ระบบได้รับอนุญาตให้ติดต่อ ระบบต้องปฏิเสธเป้าหมายนอก Allowlist แม้ผู้ใช้พยายามกรอกเข้ามา

### CIDR

รูปแบบเขียนขอบเขตเครือข่าย เช่น `192.168.10.0/24` โดย `/24` ระบุจำนวนบิตส่วนเครือข่าย สำหรับ MyNetMate ใช้กำหนดช่วงที่อนุญาตใน Isolated Lab

### RBAC (Role-Based Access Control)

การกำหนดสิทธิ์ตามบทบาท เช่น Admin, Operator และ Viewer เพื่อควบคุมว่าใครดู Topology, เปลี่ยน Shared Layout หรือสั่ง Re-collect ได้ Link จาก LLDP ไม่ต้องใช้สิทธิ์ยืนยันทีละเส้น

### Audit Trail / Audit Log

ประวัติว่าใครทำอะไร เมื่อใด และกับข้อมูลใด เช่น ผู้ใช้คนใดสั่ง Re-collect หรือเปลี่ยน Shared Layout ใช้สำหรับตรวจสอบย้อนหลัง แต่ต้องไม่บันทึก Secret

### Four-eyes Principle

หลักให้คนหนึ่งสร้างรายการและให้อีกคนตรวจยืนยันเพื่อลดความผิดพลาด แนวคิดนี้อาจใช้กับ Manual Override ในอนาคต แต่ไม่เกี่ยวกับ NTV MVP ปัจจุบัน

## 4. โปรโตคอลและวิธีเก็บข้อมูล

### Ping / Ping Sweep

Ping ใช้ตรวจเบื้องต้นว่า IP ตอบสนองหรือไม่ ส่วน Ping Sweep คือการลอง Ping หลาย IP ในช่วงที่กำหนด

Ping บอกได้เพียง Reachability เบื้องต้น ไม่สามารถยืนยัน Vendor, Model, Interface หรือ Link และบางอุปกรณ์อาจทำงานอยู่แต่ปิดการตอบ Ping

### SSH (Secure Shell)

โปรโตคอลสำหรับเชื่อมต่อ CLI ของอุปกรณ์ผ่านช่องทางเข้ารหัส MyNetMate ใช้ SSH เรียกคำสั่งอ่านข้อมูล เช่นคำสั่งตระกูล `show` แล้วรับผลลัพธ์ข้อความกลับมา

### SNMP (Simple Network Management Protocol)

โปรโตคอลสำหรับอ่านข้อมูลบริหารเครือข่ายแบบเป็นโครงสร้าง เช่นรายละเอียดอุปกรณ์ สถานะ Interface และข้อมูล LLDP บางส่วน ความสามารถจริงขึ้นกับ SNMP Version, สิทธิ์, MIB และการตั้งค่าของอุปกรณ์

### LLDP (Link Layer Discovery Protocol)

มาตรฐานที่อุปกรณ์เครือข่ายใช้ประกาศข้อมูลให้เพื่อนบ้านที่ต่อโดยตรง เช่นชื่ออุปกรณ์และ Port ช่วยให้ระบบหา Link ระดับ Layer 2 ได้ รองรับหลายผู้ผลิต แต่ต้องตรวจว่าอุปกรณ์รุ่นจริงรองรับและเปิดใช้งานหรือไม่

### CDP (Cisco Discovery Protocol)

โปรโตคอลค้นหาเพื่อนบ้านเฉพาะระบบนิเวศ Cisco มีเป้าหมายใกล้เคียง LLDP แต่ **ไม่อยู่ในขอบเขตการพัฒนาปัจจุบันของ MyNetMate** ทีมเลือกใช้ LLDP ซึ่งเป็นมาตรฐานกลางสำหรับ Neighbor Observation หลาย Vendor คำนี้เก็บไว้เพื่อช่วยอ่านเอกสารหรือผลจากอุปกรณ์ Cisco เท่านั้น

### LLCP

คำที่ปรากฏในบันทึกคำแนะนำอาจารย์ แต่ยังไม่ยืนยันว่าหมายถึง LLDP หรือคำอื่น ห้ามใช้แทน LLDP ในเอกสารออกแบบจนกว่าจะถามอาจารย์เรียบร้อย

### Collector

ส่วนของ Backend ที่รับผิดชอบเชื่อมต่ออุปกรณ์และเก็บผลลัพธ์ เช่นใช้ Netmiko เชื่อม SSH แล้วเรียกคำสั่งอ่านข้อมูล Collector ยังไม่ควรตัดสินว่า Link ใดถูกต้องถาวร

### Parser

ส่วนที่แปลงข้อความดิบจากอุปกรณ์ให้เป็นข้อมูลที่โปรแกรมเข้าใจ เช่นแปลงผล `show lldp neighbors` เป็น Local Interface, Neighbor Name และ Remote Interface

### Raw Output

ข้อความต้นฉบับที่อุปกรณ์ส่งกลับมาก่อน Parse มีประโยชน์ต่อการทดสอบและแก้ Parser แต่ต้องตรวจและปกปิดข้อมูลอ่อนไหวก่อนจัดเก็บหรือแสดง

### Collection Run

เหตุการณ์เก็บข้อมูลหนึ่งรอบ เช่น ผู้ใช้กด Re-collect อุปกรณ์ Cisco เวลา 10:30 น. Collection Run ควรมีเวลา เป้าหมาย ผลสำเร็จ/ล้มเหลว และ Error โดยไม่เก็บ Secret

### Collection Status

ผลของการเก็บข้อมูล เช่น `pending`, `running`, `success`, `partial` หรือ `failed` ใช้บอกว่าระบบดึงข้อมูลจากอุปกรณ์ได้ครบหรือไม่

### Collection Health

ภาพรวมคุณภาพการเก็บข้อมูล ไม่ได้ดูเพียงว่า Ping ผ่าน แต่รวมถึง SSH/SNMP, Parser และความใหม่ของข้อมูลด้วย

### Re-collect

การสั่งให้ระบบกลับไปอ่านข้อมูลอุปกรณ์อีกครั้ง เพื่อให้ Inventory และ NTV สะท้อนสภาพล่าสุด เป็นการอ่านข้อมูลใหม่ ไม่ใช่การ Deploy Configuration
## 5. คำศัพท์พื้นฐานของ Topology

### Network Topology Visualization (NTV)

หน้าจอแสดงความสัมพันธ์ของอุปกรณ์และการเชื่อมต่อเป็นภาพ เพื่อช่วยตอบว่าอุปกรณ์ใดต่อกับอุปกรณ์ใด ผ่าน Port อะไร และข้อมูลล่าสุดเมื่อใด

### Observation-first Topology

แนวทางที่ให้ข้อมูลซึ่งระบบอ่านจากอุปกรณ์จริงเป็นจุดเริ่มต้นของแผนผัง ไม่เริ่มจากการให้ผู้ใช้วาด Node และ Link ตามสมมติฐาน

### Node

รูปแทนอุปกรณ์หนึ่งตัวบน Canvas เช่น Huawei Router หรือ Cisco Switch Node เป็นสิ่งที่ใช้แสดงผล ส่วนข้อมูลอุปกรณ์จริงอยู่ใน Device Inventory

### Link / Edge

เส้นที่แสดงการเชื่อมต่อระหว่าง Node สองตัว ใน MVP เน้น Physical/L2 Link ระหว่าง Interface ไม่ใช่เพียงเส้นระหว่างชื่ออุปกรณ์

### Endpoint

ปลายด้านหนึ่งของ Link ประกอบด้วย Device และ Interface เช่น `Cisco-SW1 GigabitEthernet0/1` Link หนึ่งเส้นโดยทั่วไปมีสอง Endpoint

### Interface / Port

ช่องทางเชื่อมต่อบน Router/Switch เช่น Ethernet Port ในเอกสารนี้มักใช้สองคำนี้ใกล้เคียงกัน แต่ในฐานข้อมูลควรใช้คำว่า Interface เป็น Entity หลักและใช้ Port Name เป็นชื่อแสดงผล

### Port Label

ข้อความบน Link ที่บอกชื่อ Interface ของแต่ละฝั่ง เช่น `Gi0/1 ↔ ether2` ช่วยให้ผู้ใช้ไปตรวจสายหรือ Configuration ได้ถูก Port

### Physical/L2 Topology

แผนผังเน้นการต่ออุปกรณ์ระดับกายภาพและ Data Link Layer เช่น Switch A Port 1 ต่อกับ Switch B Port 2 เหมาะกับข้อมูล LLDP

### Logical/L3 Topology

แผนผังความสัมพันธ์ระดับ IP หรือ Routing เช่น OSPF/BGP Neighbor อาจไม่ตรงกับการต่อสายจริงโดยตรง และยังอยู่นอก MVP ของ NTV

### Snapshot Topology

ภาพเครือข่ายที่สร้างจากข้อมูล ณ ช่วงเวลาหนึ่ง ผู้ใช้ต้องดูเวลาตรวจล่าสุดประกอบ ไม่ถือว่าเปลี่ยนทันทีทุกวินาที

### Real-time Topology / Continuous Polling

ระบบที่เก็บข้อมูลต่อเนื่องและปรับแผนผังใกล้เคียงเวลาจริง ต้องใช้ทรัพยากรและระบบ Monitoring มากกว่า จึงไม่อยู่ใน MVP

### Topology View

มุมมองแผนผังหนึ่งชุด เช่น View ของ Lab A หรือ Device Group หนึ่งชุด View กำหนดว่าแสดง Node ใดและจัดวางอย่างไร แต่ไม่ใช่เจ้าของข้อมูล Device

### Canvas

พื้นที่บนหน้าจอที่ใช้วาง Node และแสดง Link คล้ายกระดานสำหรับดูแผนผัง

### Layout

ตำแหน่งและรูปแบบการจัดวาง Node บน Canvas การแก้ Layout ไม่ได้เปลี่ยนสายหรือ Configuration ของอุปกรณ์จริง

### Interactive Canvas

Canvas ที่ผู้ใช้โต้ตอบได้ เช่นลาก Node, Zoom, Pan, เลือก Node หรือเปิดรายละเอียด

### Drag & Drop

การลาก Node ไปวางตำแหน่งใหม่ เป็นการแก้ Layout เท่านั้น

### Zoom / Pan

Zoom คือขยายหรือย่อมุมมอง ส่วน Pan คือเลื่อนพื้นที่แสดงผลไปด้านข้าง ทั้งสองอย่างไม่แก้ข้อมูลเครือข่าย

### Auto-layout

การให้ระบบคำนวณตำแหน่ง Node อัตโนมัติเพื่อให้แผนผังอ่านง่าย Auto-layout ใช้ Link ที่มีอยู่เป็นข้อมูลตั้งต้น แต่ไม่สร้างหรือแก้ Link จริง

### Pin / Hide / Filter

- **Pin:** ล็อก Node ไว้ในตำแหน่งหนึ่ง
- **Hide:** ซ่อน Node จาก View โดยไม่ลบ Device
- **Filter:** เลือกแสดงเฉพาะข้อมูลที่ตรงเงื่อนไข เช่น Vendor หรือ Status

### Right-click Context Menu

เมนูคำสั่งที่แสดงตามสิ่งที่ผู้ใช้คลิก เช่นเปิด Device Detail หรือ Re-collect ไม่ใช่ฟีเจอร์แกนหลักของข้อมูล Topology

### Parallel Links

อุปกรณ์คู่เดิมเชื่อมกันมากกว่าหนึ่งสายผ่าน Interface คนละคู่ ระบบต้องไม่รวม Link เหล่านี้เป็นเส้นข้อมูลเดียวโดยไม่ตั้งใจ

### Port-channel / LAG

การรวม Physical Link หลายเส้นให้ทำงานเป็น Logical Link เดียว การแสดงผลเรื่องนี้ซับซ้อนกว่า Link ปกติและยังต้องให้ทีมกำหนดขอบเขต

## 6. คำศัพท์เกี่ยวกับหลักฐานและสถานะ Link

### Neighbor

อุปกรณ์เพื่อนบ้านที่ต่อโดยตรงและอุปกรณ์เป้าหมายรายงานผ่าน LLDP

### Neighbor Observation

ข้อมูลที่ระบบสังเกตพบใน Collection Run หนึ่งรอบ เช่น Cisco Switch รายงานว่าที่ `Gi0/1` เห็น Huawei Router ที่ `GE0/0/1` Observation เป็นหลักฐาน ณ เวลานั้น ยังไม่จำเป็นต้องเป็นข้อสรุปถาวร

### Raw Observation

Observation ต้นฉบับที่ได้จาก Collector/Parser ควรเก็บแยกจาก Evidence Assessment และ Current Link Projection เพื่อให้ตรวจสอบย้อนหลังได้

### Immutable

แก้ไขทับไม่ได้ หาก Parser พบข้อผิดพลาดให้บันทึก Parse Status/Error และสร้าง Observation รอบใหม่หลังแก้ Parser หรือ Re-collect โดยไม่เปลี่ยน Endpoint ในหลักฐานเดิม

### Append-only

การเก็บข้อมูลด้วยการเพิ่ม Record ใหม่แต่ไม่เขียนทับประวัติเดิม เช่น Collection รอบใหม่สร้าง Observation ชุดใหม่ ทำให้เปรียบเทียบกับรอบก่อนได้

### Provenance / Source

ที่มาของข้อมูลใน MVP เช่น LLDP ช่วยให้ผู้ใช้ประเมินความน่าเชื่อถือและตรวจย้อนกลับได้ ส่วน Manual Override เป็นแหล่งข้อมูลที่อาจเพิ่มในอนาคต

### Freshness / Last Observed At

ความใหม่ของข้อมูลและเวลาที่พบ Link ล่าสุด เช่น Link ที่พบเมื่อ 2 นาทีที่แล้วน่าเชื่อถือกว่าข้อมูลที่ไม่ได้ตรวจมา 30 วัน แต่ความใหม่อย่างเดียวไม่ได้รับรองว่าข้อมูลถูกต้อง

### Evidence Assessment

ผลที่ระบบประเมินระดับหลักฐานของ Link จาก Observation โดยไม่ต้องให้คนยืนยันทุกเส้น ตัวอย่างเช่น:

- `one_sided` — พบ Link จากอุปกรณ์ฝั่งเดียว แต่จับคู่ Endpoint ได้ จึงแสดงได้ตามปกติพร้อมป้ายบอกระดับหลักฐาน
- `corroborated` — อุปกรณ์ทั้งสองฝั่งรายงาน Port คู่เดียวกัน ระบบรวมเป็น Link เดียวและถือว่ามีหลักฐานสนับสนุนจากสองฝั่ง
- `unresolved` — พบข้อมูล Neighbor แต่ยังจับคู่ Remote Device หรือ Interface ไม่ได้ จึงแสดงใน Warning/Pending List แทนการสร้าง Node สมมติ

Evidence Assessment เป็นคนละเรื่องกับ Current Link State เช่น Link อาจเป็น `one_sided` และ `active` พร้อมกัน หรือเป็น `corroborated` แต่ `stale` เมื่อข้อมูลเก่าเกินเกณฑ์

### Report Incorrect — Future Enhancement

คำสั่งที่ผู้ใช้ใช้รายงานว่า Link หรือ Observation ที่ระบบแสดงอาจไม่ตรงกับสภาพจริง เช่น Parser จับ Remote Port ผิด ผู้ใช้ต้องใส่เหตุผล ระบบเก็บ Raw Observation เดิมไว้และสร้าง Exception Review แยกต่างหาก

### Needs Review / Pending Warning

รายการที่ระบบยังสรุปหรือจับคู่ไม่ได้ ใน MVP ใช้เป็น Warning/Pending List สำหรับเปิดรายละเอียดและ Re-collect ไม่มี Human Review Workflow

### Resolve Conflict — Future Enhancement

การที่ผู้มีสิทธิ์ตรวจหลักฐานซึ่งขัดกัน แล้วบันทึกผลว่าจะใช้ข้อมูลใด สั่ง Re-collect หรือตรวจสายจริง โดยต้องไม่แก้ Raw Observation ของฝ่ายใดทิ้ง

### False Positive

ระบบรายงานว่าพบ Link หรืออุปกรณ์ แต่เมื่อตรวจสอบแล้วไม่ใช่ข้อมูลจริง เช่น Parser อ่านคอลัมน์ผิดจนสร้าง Link ที่ไม่มีอยู่

### Stale

ข้อมูลที่เคยพบแต่ไม่พบซ้ำในการ Collection ล่าสุด หรือเก่าเกินเกณฑ์ Stale ไม่ได้แปลว่าถูกลบหรือสายหลุดแน่นอน เพราะการเก็บข้อมูลอาจล้มเหลวชั่วคราว

### Removed

สถานะที่ระบบหรือผู้ใช้สรุปแล้วว่า Link ไม่ใช่ Link ปัจจุบัน การเปลี่ยนจาก Stale เป็น Removed ต้องมีนโยบายที่ชัดเจน และไม่ควร Hard-delete ประวัติเดิม

### Manual Override — Future Enhancement

แนวคิด Link ที่มนุษย์บันทึกเป็นข้อยกเว้นเมื่อ LLDP ใช้ไม่ได้ โดยต้องเลือก Device และ Interface ที่ระบบเก็บจากอุปกรณ์จริงแล้ว พร้อมเหตุผล หลักฐาน ผู้บันทึก และสถานะการยืนยัน แต่ยังไม่ทำใน MVP

Manual Override ไม่ใช่การวาดเส้นอย่างอิสระเพื่อให้ Diagram ดูครบ

### Evidence Note

ข้อความอธิบายหลักฐานที่ใช้สร้าง Manual Override เช่น “ตรวจสายจริงใน Lab แล้ว Huawei GE0/0/1 ต่อกับ Cisco Gi0/1”

### Reconciliation

กระบวนการเปรียบเทียบ Neighbor Observation หลายรายการเพื่อสรุปว่า Link ปัจจุบันควรมีสถานะอะไร โดยไม่ทำลายหลักฐานต้นฉบับ

### Conflict

กรณีข้อมูลไม่ตรงกัน เช่น Observation รอบก่อนบอกว่า Cisco `Gi0/1` ต่อกับ Huawei แต่รอบใหม่บอกว่าต่อกับ MikroTik ระบบต้องแสดง Warning และไม่เขียนทับหลักฐานเดิมแบบเงียบ ๆ

### One-sided Observation

พบข้อมูล Link จากอุปกรณ์เพียงฝั่งเดียว เช่น Cisco รายงานว่าเห็น Huawei แต่ยังเก็บข้อมูลจาก Huawei ไม่สำเร็จ ความเชื่อมั่นจึงต่ำกว่าการพบตรงกันทั้งสองฝั่ง

### Two-sided Corroboration

อุปกรณ์ทั้งสองฝั่งรายงาน Endpoint ที่สอดคล้องกัน เช่น Cisco เห็น Huawei และ Huawei เห็น Cisco ผ่าน Port คู่เดียวกัน ใช้เพิ่มความเชื่อมั่น แต่ยังต้องระวังข้อมูลเก่าหรือ Parser Error

### Ground Truth

ข้อมูลที่ทีมตรวจสอบว่าเป็นสภาพจริงสำหรับใช้เปรียบเทียบผลระบบ เช่นตารางสายจริงใน Lab ที่บันทึกว่าอุปกรณ์และ Port ใดต่อกัน

### Source of Truth

แหล่งข้อมูลหลักที่ระบบยึดถือสำหรับเรื่องหนึ่ง เช่น Device Identity มาจาก `devices` ส่วน Raw Neighbor Evidence มาจาก `neighbor_observations` ไม่ควรมีหลายตารางที่ต่างฝ่ายต่างเก็บข้อสรุปเดียวกันโดยไม่มีกฎชัดเจน

## 7. คำศัพท์เกี่ยวกับฐานข้อมูลและระบบซอฟต์แวร์

### Entity / Record

- **Entity:** ประเภทของสิ่งที่ระบบเก็บ เช่น Device, Interface หรือ Topology Link
- **Record:** ข้อมูลหนึ่งรายการของ Entity เช่น Device ของ Cisco Switch หนึ่งตัว

### Device ID / Interface ID / Link ID

รหัสภายในฐานข้อมูลที่ใช้ระบุ Record อย่างแน่นอน ชื่ออุปกรณ์หรือชื่อ Port อาจเปลี่ยนได้ แต่ ID ควรคงเดิมตามนโยบายของระบบ

### Foreign Key / Reference

การอ้างจาก Record หนึ่งไปยังอีก Record เช่น `local_interface_id` ใน Link อ้างไปยัง Interface ต้นทาง ทำให้ระบบทราบว่า Link ใช้ Port ใดจริง

### `devices`

ชื่อตาราง Candidate สำหรับเก็บข้อมูลหลักของ Managed Device เช่น Hostname, Vendor, Model และ Management IP

### `interfaces`

ชื่อตาราง Candidate สำหรับเก็บ Interface ของแต่ละ Device เช่นชื่อ Port, MAC Address, Admin Status และ Oper Status

### `neighbor_observations`

ชื่อตาราง Candidate สำหรับเก็บผลที่ LLDP สังเกตพบในแต่ละ Collection Run แบบรักษาประวัติ

### `topology_links`

ชื่อตาราง Candidate สำหรับเก็บ Link ปัจจุบันหลังผ่านการ Reconcile แล้ว ต้องอ้างกลับไปยัง Neighbor Observation ได้

### `topology_link_evaluations`

ตารางของ NTV สำหรับเก็บผลประเมิน Link ในแต่ละ Reconciliation Run เช่นระดับหลักฐานและ Warning State โดยชื่อและ Field ให้ยึด `02_Database Schema.md`

### `topology_link_evidence`

ตารางเชื่อมผลประเมิน Link กับ `neighbor_observations` ที่ใช้เป็นหลักฐาน ทำให้ผลสรุปแต่ละรอบตรวจย้อนกลับไปยังข้อมูล LLDP ต้นทางได้

> Human Review, Report Incorrect และ Resolve Conflict เป็น Future Extension ที่ยังไม่มี Logical Table ใน MVP

### `topology_views`

ชื่อตาราง Candidate สำหรับเก็บ View เช่นชื่อ View, Site หรือ Device Group ไม่ควรเก็บข้อมูลตัวตนอุปกรณ์ซ้ำจาก `devices`

### `topology_node_placements`

ตารางของ NTV สำหรับเก็บตำแหน่ง `x/y` ของ Device Node ในแต่ละ View การแก้ตารางนี้เปลี่ยน Layout เท่านั้นและไม่เปลี่ยนข้อมูล Device, Interface หรือ Link

### Admin Status / Oper Status

- **Admin Status:** สถานะที่ผู้ดูแลกำหนด เช่นสั่งปิด Interface
- **Oper Status:** สถานะการทำงานที่อุปกรณ์รายงานจริง เช่น Link Up หรือ Down

Interface อาจมี Admin Status เป็น Up แต่ Oper Status เป็น Down ได้ หากเปิด Port ไว้แต่ไม่มีสัญญาณเชื่อมต่อ

### Soft-delete / Hard-delete

- **Soft-delete:** ทำเครื่องหมายว่าไม่ใช้งานแล้วแต่ยังเก็บ Record ไว้ตรวจย้อนหลัง
- **Hard-delete:** ลบ Record ออกจากฐานข้อมูลจริง

ข้อมูลหลักฐานและ Audit ควรหลีกเลี่ยง Hard-delete โดยไม่มีนโยบายรองรับ

### API (Application Programming Interface)

ช่องทางที่ Frontend ใช้ขอข้อมูลหรือสั่งงาน Backend เช่นขอโหลด Topology หรือสั่ง Re-collect

### API Endpoint

เส้นทางของคำสั่ง API หนึ่งรายการ เช่น `POST /devices/{device_id}/collections` สำหรับเริ่ม Collection Run ใหม่ ไม่เกี่ยวกับคำว่า Link Endpoint ซึ่งหมายถึงปลายสาย

### GET / POST / PATCH / DELETE

- **GET:** ขออ่านข้อมูล
- **POST:** ขอสร้างรายการหรือเริ่มกระบวนการ
- **PATCH:** ขอแก้บางส่วนของข้อมูล
- **DELETE:** ขอเอารายการออกตามนโยบาย

ชื่อ Method บอกเจตนาทางซอฟต์แวร์ แต่ไม่ได้แปลว่าผู้ใช้ได้รับอนุญาตเสมอ ยังต้องตรวจ RBAC และกฎของข้อมูล

### CRUD

คำรวมของ Create, Read, Update และ Delete หากกล่าวว่า “CRUD Link ได้อิสระ” จะขัดกับแนวคิด Observation-first เพราะ Raw Observation ไม่ควรถูกแก้หรือลบแบบข้อมูลทั่วไป

### Frontend / Backend

- **Frontend:** หน้าเว็บที่ผู้ใช้เห็นและโต้ตอบ เช่น Topology Canvas
- **Backend:** ส่วนที่เชื่อมต่ออุปกรณ์ ประมวลผลกฎ ติดต่อฐานข้อมูล และให้บริการ API

### Component Diagram

แผนภาพอธิบายว่าส่วนประกอบซอฟต์แวร์ใดรับผิดชอบงานอะไรและติดต่อกันอย่างไร เช่น Inventory Service, Collector, Parser, Topology Service และ Database

### Database Schema

แบบโครงสร้างฐานข้อมูล ระบุ Table, Field, ความสัมพันธ์ และข้อจำกัดของข้อมูล

### Dependency

สิ่งที่ฟีเจอร์หนึ่งต้องพึ่งพา เช่น NTV ต้องพึ่ง Device Inventory, Interface Data และ Neighbor Observation จาก Discovery/Collection

## 8. คำศัพท์เกี่ยวกับขอบเขตและการทดสอบ

### MVP (Minimum Viable Product)

ระบบรุ่นเล็กที่สุดที่ยังแก้ปัญหาหลักและสาธิตคุณค่าได้ สำหรับ NTV คือผู้ใช้เห็นอุปกรณ์และ Link จากข้อมูลที่เก็บจริง พร้อม Port, Source, Freshness และขั้นตอนตรวจสอบ

MVP ไม่ได้หมายถึงทำหน้าจอให้เปิดได้แต่ไม่มีข้อมูลที่เชื่อถือได้

### Must / Should / Could / Won't

วิธีแบ่งความสำคัญของขอบเขต:

- **Must:** ขาดไม่ได้ มิฉะนั้น MVP แก้ปัญหาหลักไม่สำเร็จ
- **Should:** สำคัญ แต่ยังสาธิต MVP ได้หากเลื่อนไปภายหลัง
- **Could:** ทำเมื่อเวลาเหลือ
- **Won't:** ยืนยันว่าจะไม่ทำในขอบเขตรอบนี้

### Acceptance Test

เงื่อนไขที่ใช้ตรวจว่าฟีเจอร์ทำงานตามที่ตกลง เช่น “IP ที่ตอบ Ping แต่ SSH ล้มเหลวต้องไม่กลายเป็น Verified Topology Node”

### Definition of Done

รายการผลลัพธ์ที่ต้องครบก่อนถือว่างานเสร็จ ไม่ได้วัดเพียงว่าเขียน Code แล้ว แต่รวมถึงพฤติกรรม ความปลอดภัย และการทดสอบ

### Vendor

ผู้ผลิตอุปกรณ์ เช่น Cisco, Huawei และ MikroTik แต่ละ Vendor อาจใช้คำสั่ง ชื่อ Interface และรูปแบบ Output ต่างกัน

### Vendor-neutral Data Model

การออกแบบฐานข้อมูลกลางที่ไม่ผูกชื่อ Field กับ Cisco เพียงรายเดียว เช่นใช้ `vendor`, `model` และ `interface_name` กลาง แล้วให้ Collector/Parser ของแต่ละ Vendor แปลงข้อมูลเข้ารูปแบบเดียวกัน

### Baseline Vendor

Vendor หลักที่ทีมใช้เป็นจุดเริ่มต้นในการพัฒนาและทดสอบ ปัจจุบันคือ Cisco IOS

### Candidate Vendor

Vendor ที่มีแผนทดลองรองรับ แต่ยังรับรองไม่ได้จนทราบรุ่น, OS, Protocol, คำสั่ง และผลทดสอบจริง ปัจจุบันรวม Huawei Router และ MikroTik Switch

### Full Support

การรับรองว่าระบบรองรับขอบเขตคำสั่งและรุ่นที่ระบุอย่างผ่านการทดสอบ ไม่ควรใช้คำว่า Full Support เพียงเพราะเชื่อมต่ออุปกรณ์ได้หนึ่งครั้ง

### Emulated Environment

สภาพแวดล้อมจำลอง เช่น GNS3 หรือ Packet Tracer ใช้พัฒนาและทดสอบ Flow ได้ แต่พฤติกรรมอาจต่างจากอุปกรณ์จริง

### Physical Lab

สภาพแวดล้อมที่ใช้อุปกรณ์จริงและสายจริง สำหรับยืนยันความสามารถตามรุ่น/OS และผล Vendor Support

### Test Fixture

ชุดข้อมูลและการต่ออุปกรณ์ที่เตรียมไว้ให้ทดสอบซ้ำได้ เช่น Huawei Router 1 ตัว, Cisco Switch 1 ตัว และ MikroTik Switch 1 ตัว พร้อมตาราง Port-to-Port ที่ทราบคำตอบ

## 9. ชื่อ Field ที่ปรากฏในเอกสาร

| Field | ความหมายแบบง่าย |
|---|---|
| `device_id` | รหัสอุปกรณ์ในฐานข้อมูล |
| `interface_id` | รหัส Interface ในฐานข้อมูล |
| `topology_id` | รหัส Topology View |
| `hostname` | ชื่อที่อุปกรณ์ใช้ระบุตัวเอง |
| `vendor` | ผู้ผลิต เช่น Cisco/Huawei/MikroTik |
| `model` | รุ่นอุปกรณ์ |
| `device_type` | ประเภท เช่น Router หรือ Switch |
| `ip_address` | IP ที่เกี่ยวข้องกับอุปกรณ์หรือ Interface ตาม Schema |
| `local_interface_id` | Interface ฝั่งที่กำลังรายงาน Neighbor |
| `remote_interface_id` | Interface ของอุปกรณ์เพื่อนบ้าน ถ้าระบุตัวตนได้ |
| `source` | แหล่งที่มาของข้อมูล; MVP ใช้ LLDP ส่วน Manual Override เป็น Future Enhancement |
| `collection_status` | ผลของการเก็บข้อมูลรอบนั้น |
| `evidence_assessment` | ระดับหลักฐานที่ระบบประเมิน เช่น One-sided/Corroborated/Unresolved |
| `current_link_state` | วงจรชีวิตของ Link เช่น Active/Stale/Archived |
| `warning_state` | ผลคำเตือนที่ระบบคำนวณ เช่น Normal/Conflict ไม่ใช่ผลการยืนยันของผู้ใช้ |
| `last_collected_at` | เวลาที่เก็บข้อมูลจากอุปกรณ์ล่าสุด |
| `last_observed_at` | เวลาที่พบ Link ล่าสุด |
| `created_by` / `created_at` | ใครสร้างรายการและสร้างเมื่อใด; ใช้กับ Manual Override ใน Future Enhancement |
| `verified_by` / `verified_at` | ใครยืนยันรายการและยืนยันเมื่อใด; เป็น Field ของ Future Enhancement |
| `reason` | เหตุผลของ Report Incorrect, Resolve Conflict หรือ Override ใน Future Enhancement |
| `evidence_note` | บันทึกหลักฐานของ Manual Override ใน Future Enhancement |
| `position_x` / `position_y` | ตำแหน่ง Node บน Canvas |
| `is_pinned` | Node ถูกล็อกตำแหน่งหรือไม่ |
| `is_hidden` | Node ถูกซ่อนใน View หรือไม่ |

ชื่อ Field สำหรับ MVP ให้ยึด [02_Database Schema.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/03_Network Topology Visualization(Naphat)/02_Database Schema.md) ส่วน Field ที่ระบุว่า Future Enhancement ยังไม่ต้องสร้างใน Schema ปัจจุบัน

## 10. รหัสที่ใช้จัดหมวดในเอกสาร

| รูปแบบ | ความหมาย |
|---|---|
| `E-NTV-xx` | Evidence หรือหลักฐานอ้างอิง |
| `D-NTV-xx` | Decision หรือมติการออกแบบ |
| `UD-NTV-xx` | User Decision ที่ NTV ต้องช่วยให้ผู้ใช้ตัดสินใจ |
| `Q-NTV-xx` | Open Question หรือคำถามที่ยังไม่ปิด |
| `AT-NTV-xx` | Acceptance Test หรือเกณฑ์ตรวจรับ |
| ตัวอักษร `R` เช่น `AT-NTV-R01` | Revised หรือรายการฉบับแก้ไขหลังมติ Observation-first |

รหัสเหล่านี้เป็นรหัสติดตามเอกสาร ไม่ใช่ Field ที่ต้องใส่ในฐานข้อมูลทุกตัว

## 11. คำที่ห้ามใช้สลับกัน

| คำที่อาจสับสน | ความแตกต่าง |
|---|---|
| Manual Input กับ Manual Link | Manual Input คือระบุอุปกรณ์เป้าหมายเพื่อให้ระบบไปเก็บข้อมูล ส่วน Manual Link คือการสร้างเส้นด้วยคน ซึ่งไม่อยู่ใน MVP; Manual Override เป็น Future Enhancement |
| Device Credential กับ User Login | Device Credential ใช้เข้า Router/Switch ส่วน User Login ใช้เข้าเว็บ MyNetMate |
| Candidate Device กับ Managed Device | Candidate เพียงถูกค้นพบเบื้องต้น ส่วน Managed Device ผ่านการนำเข้าและมีข้อมูลที่ระบบจัดการได้ |
| Ping Success กับ Collection Success | Ping ผ่านแปลว่า IP ตอบเบื้องต้น ส่วน Collection Success แปลว่าระบบเข้าไปดึงและ Parse ข้อมูลที่ต้องการได้ |
| Device กับ Node | Device คือข้อมูลอุปกรณ์ใน Inventory ส่วน Node คือรูปแทน Device บน Topology View |
| Interface กับ Link | Interface คือ Port หนึ่งช่อง ส่วน Link คือความสัมพันธ์ระหว่างสอง Endpoint |
| Link Endpoint กับ API Endpoint | Link Endpoint คือปลายสาย Device/Interface ส่วน API Endpoint คือเส้นทางเรียก Backend |
| Layout Change กับ Network Change | Layout Change คือขยับรูปบนจอ ส่วน Network Change คือเปลี่ยนสาย, Port หรือ Configuration จริง |
| One-sided กับ Pending Warning | One-sided คือ Link ปกติที่พบจากฝั่งเดียวและจับคู่ Endpoint ได้ ส่วน Pending Warning คือข้อมูลที่จับคู่ไม่ได้ ขัดแย้ง หรือเก่า |
| Corroborated กับ Human-confirmed | Corroborated คือระบบพบข้อมูลตรงกันสองฝั่งโดยอัตโนมัติ ไม่ได้หมายถึงมีคนกดยืนยัน |
| Manual Override กับ Freehand Drawing | ทั้งสองอย่างไม่อยู่ใน MVP; หากทำ Override ในอนาคตต้องอ้าง Device/Interface จริงและมีหลักฐาน ส่วน Freehand Drawing ไม่มีหลักฐานและไม่อยู่ใน Scope |
| Stale กับ Down | Stale แปลว่าข้อมูลเก่าหรือไม่พบในรอบล่าสุด ส่วน Down คือสถานะ Interface/Reachability ที่ระบบตรวจได้ ณ เวลาหนึ่ง |
| Stale กับ Removed | Stale ยังไม่สรุปว่าหาย ส่วน Removed คือผ่านกฎหรือการตรวจจนสรุปว่าไม่ใช่ Link ปัจจุบัน |
| Source กับ Source Device | `source` ในบริบทหลักฐานหมายถึงที่มาข้อมูล เช่น LLDP ส่วน Source Device หมายถึงอุปกรณ์ต้นทางของ Link ต้องตั้งชื่อ Field ให้ชัดเพื่อไม่ให้สับสน |
| Physical/L2 กับ Logical/L3 | Physical/L2 เน้น Port และการต่อโดยตรง ส่วน Logical/L3 เน้น IP/Routing Relationship |
| Read-only กับไม่มีความเสี่ยง | Read-only ลดความเสี่ยงการแก้ Config แต่ยังมีความเสี่ยงเรื่อง Credential, Load, Timeout และข้อมูลอ่อนไหว |

## 12. ตัวอย่างครบหนึ่งเหตุการณ์

สมมติใน Physical Lab มี Cisco Switch ต่อกับ Huawei Router:

1. ผู้ใช้กรอก Management IP ของ Cisco Switch และเลือก Device Credential Profile
2. ระบบ Authentication ผ่าน SSH สำเร็จ จึงเริ่ม Collection Run
3. Collector เรียกคำสั่งอ่านข้อมูล และ Parser แปลงผลเป็น Device, Interface และ Neighbor Observation
4. Cisco รายงานว่า `Gi0/1` เห็น Huawei ที่ `GE0/0/1`
5. NTV แสดง Cisco และ Huawei เป็น Node พร้อม Link และ Port Label
6. Link มี Source เป็น LLDP และแสดง Last Observed At
7. หากยังเก็บข้อมูลจาก Huawei ไม่ได้ Link จะแสดงเป็น One-sided โดยไม่ต้องรอผู้ใช้ยืนยัน
8. หากทีมเก็บข้อมูลจาก Huawei แล้ว Huawei รายงานกลับมาสอดคล้องกัน ระบบเปลี่ยน Evidence Assessment เป็น Corroborated อัตโนมัติ
9. หากผู้ใช้พบว่า Port ที่แสดงผิด ให้ตรวจสาย/Parser และกด Re-collect; MVP ไม่มีคำสั่งแก้ Link ด้วยมือ
10. หากภายหลังย้ายสายไป `Gi0/2` ผู้ดูแลต้องเปลี่ยนสายจริงแล้วกด Re-collect
11. Observation ใหม่แสดง `Gi0/2` ส่วน Link เดิมอาจเป็น Stale/Conflict Warning จนกว่าจะผ่าน Reconciliation

ถ้า Huawei ไม่รองรับหรือไม่ได้เปิด LLDP ระบบแสดงว่าไม่มี Neighbor Data หรือยังระบุ Link ไม่ได้ โดยไม่เติม Link ด้วยมือใน MVP ทีมค่อยประเมิน Manual Override หลังทดสอบอุปกรณ์จริง

## 13. คำแปลที่แนะนำสำหรับเอกสารภาษาไทย

| คำอังกฤษ | คำไทยที่แนะนำ |
|---|---|
| Manual Device Enrollment | การนำอุปกรณ์เข้าสู่ระบบโดยผู้ใช้ระบุเป้าหมาย |
| Network Discovery | การค้นหาอุปกรณ์เครือข่ายอัตโนมัติ |
| Device Credential Profile | ชุดข้อมูลรับรองสำหรับอุปกรณ์เครือข่าย |
| Read-only Collection | การเก็บข้อมูลแบบอ่านอย่างเดียว |
| Candidate Device | อุปกรณ์ที่ค้นพบเบื้องต้น |
| Managed Device | อุปกรณ์ที่นำเข้าสู่ระบบและบริหารจัดการได้ |
| Neighbor Observation | ข้อมูลเพื่อนบ้านที่ระบบตรวจพบ |
| Observation-first Topology | แผนผังที่ยึดข้อมูลตรวจพบจากอุปกรณ์เป็นหลัก |
| Evidence Assessment | การประเมินระดับหลักฐานโดยระบบ |
| One-sided Observation | ข้อมูล Link ที่พบจากอุปกรณ์ฝั่งเดียว |
| Corroborated Link | Link ที่มีข้อมูลตรงกันจากอุปกรณ์ทั้งสองฝั่ง |
| Needs Review | รายการผิดปกติที่ต้องให้ผู้ใช้ตรวจสอบ |
| Report Incorrect | รายงานว่าข้อมูลที่แสดงอาจไม่ถูกต้อง |
| Resolve Conflict | ตรวจและสรุปผลของข้อมูลที่ขัดแย้งกัน |
| Manual Override | ข้อมูลการเชื่อมต่อที่ผู้ใช้บันทึกเป็นข้อยกเว้น |
| Provenance | ที่มาของข้อมูล |
| Freshness | ความใหม่ของข้อมูล |
| Reconciliation | การตรวจเทียบและสรุปข้อมูลจากหลายแหล่ง |
| Conflict | ข้อมูลขัดแย้งที่ต้องตรวจสอบ |
| Stale | ข้อมูลเก่าหรือไม่พบซ้ำในการตรวจล่าสุด |
| Topology View | มุมมองแผนผังเครือข่าย |
| Layout | การจัดวางองค์ประกอบบนแผนผัง |
| Audit Trail | ประวัติการดำเนินงานที่ตรวจสอบย้อนหลังได้ |
| Acceptance Test | เกณฑ์การทดสอบเพื่อยอมรับฟีเจอร์ |
| Definition of Done | เงื่อนไขที่ต้องครบก่อนถือว่างานเสร็จ |

เมื่อใช้ในเอกสารครั้งแรก แนะนำให้เขียนคำไทยตามด้วยคำอังกฤษในวงเล็บ หลังจากนั้นใช้คำไทยหรือคำย่อให้สม่ำเสมอตลอดเอกสาร
