# Dashboard & Monitoring — Glossary

> **วัตถุประสงค์:** เป็นคำศัพท์กลางสำหรับเอกสาร Feature, Database Schema, Component Diagram, API Contract, UI และ Acceptance Test ของ Dashboard & Monitoring (D&M)
>
> **หลักการใช้งาน:** หากคำเดียวกันถูกใช้ต่างความหมายในเอกสารเก่า ให้ใช้ความหมายในไฟล์นี้ร่วมกับมติล่าสุดใน [`P2_Operational_Monitoring/MVP D&M.md`](P2_Operational_Monitoring/MVP%20D%26M.md)
>
> **ข้อจำกัด:** ไฟล์นี้กำหนดความหมายเชิงแนวคิด ยังไม่กำหนดชื่อตาราง ชื่อ Column หรือค่า Enum ฉบับ Physical Database

---

## 1. คำย่อและชื่อ Feature

| คำศัพท์        | คำแปล/คำเรียกภาษาไทย           | ความหมายที่ใช้ใน MyNetMate                                                                                                |
| -------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| **D&M**        | Dashboard & Monitoring         | Feature สำหรับแสดงภาพรวมและสถานะการทำงานล่าสุดของ Network โดยผู้ใช้เป็นผู้สั่งเก็บข้อมูล                                  |
| **Dashboard**  | หน้าสรุป                       | หน้ารวมข้อมูลสำคัญเพื่อให้ผู้ใช้รู้ว่าควรเริ่มตรวจที่ใด ไม่ใช่หน้ารวมรายละเอียดทุก Port หรือทุก Route                     |
| **Monitoring** | การติดตามสถานะ                 | ใน D&M MVP หมายถึงการดู Current Operational Snapshot ไม่ได้หมายถึง Continuous Monitoring หรือ Real-time Monitoring        |
| **MVP**        | ผลิตภัณฑ์ขั้นต่ำที่ใช้งานได้   | ขอบเขต Feature ขั้นต่ำที่ต้องทำงานร่วมกันและแสดงคุณค่าหลักของ D&M ได้จริง                                                 |
| **NTV**        | Network Topology Visualization | Feature แสดงอุปกรณ์และความเชื่อมโยงบนแผนผัง เป็นเจ้าของข้อมูล Topology Link และ Layout ไม่ใช่เจ้าของ Operational Snapshot |
| **CIS**        | Center for Internet Security   | แหล่งแนวทางความปลอดภัยที่ MyNetMate นำมาปรับเป็นกฎตรวจ Configuration ตาม Scope ของโครงการ                                 |

## 2. ขอบเขตของ Dashboard & Monitoring

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Current Operational Snapshot** | ภาพสถานะการทำงานล่าสุดที่เก็บจากอุปกรณ์ ณ ช่วงเวลาหนึ่ง ผู้ใช้ต้องดูเวลาที่เก็บข้อมูลประกอบเสมอ |
| **Enterprise Monitoring System** | ระบบเฝ้าตรวจระดับองค์กรที่มี Polling ต่อเนื่อง, Time-series, Alerting, Telemetry และการวิเคราะห์จำนวนมาก ซึ่งไม่อยู่ใน D&M MVP |
| **Continuous Monitoring** | การเก็บสถานะอัตโนมัติอย่างต่อเนื่องตามรอบเวลา ไม่อยู่ใน MVP |
| **Periodic Polling** | การเชื่อมต่ออุปกรณ์อัตโนมัติตามช่วงเวลา เช่น ทุก 1 หรือ 5 นาที ไม่อยู่ใน MVP รอบแรก |
| **Real-time Monitoring** | การรับข้อมูลปัจจุบันทันทีหรือเกือบทันทีอย่างต่อเนื่อง ห้ามใช้เรียก D&M MVP |
| **Streaming Telemetry** | การที่อุปกรณ์ส่ง Metric หรือ Event เข้าระบบอย่างต่อเนื่อง ไม่อยู่ใน MVP |
| **Historical Monitoring** | การเก็บข้อมูลหลายช่วงเวลาเพื่อดูแนวโน้ม กราฟ หรือ Availability ย้อนหลัง ไม่อยู่ใน MVP |
| **Operational Visibility** | ความสามารถในการมองเห็น Actual State ของ Device, Interface และ Routing เพื่อช่วยจำกัดพื้นที่ตรวจสอบปัญหา |

## 3. การ Refresh และการเก็บข้อมูล

| คำศัพท์                        | คำแปล/คำเรียกภาษาไทย                 | ความหมายที่ใช้ใน MyNetMate                                                                                                  |
| ------------------------------ | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| **Manual Operational Refresh** | การสั่งเก็บสถานะด้วยตนเอง            | ผู้ใช้เป็นผู้เริ่มเก็บ Operational Snapshot ใหม่ ไม่ใช่งานที่ระบบตั้งเวลาเอง                                                |
| **Refresh Selected Device**    | Refresh อุปกรณ์ที่เลือก              | ผู้ใช้เลือก Switch หรือ Router ที่ต้องการเก็บข้อมูลใหม่ แทนการ Refresh อุปกรณ์ทั้งหมดโดยไม่จำเป็น                           |
| **Collection**                 | การเก็บข้อมูล                        | กระบวนการเชื่อมต่ออุปกรณ์ ส่งคำสั่ง Read-only รับผลลัพธ์ และแปลงผลลัพธ์เป็นข้อมูลที่ระบบใช้ได้                              |
| **Collection Attempt**         | ความพยายามเก็บข้อมูลหนึ่งครั้ง       | การลองเก็บข้อมูลแต่ละครั้ง ไม่ว่าจะสำเร็จหรือล้มเหลว                                                                        |
| **Collection Run**             | รอบการเก็บข้อมูล                     | หน่วยงานหนึ่งรอบที่มีผู้เริ่ม เป้าหมาย เวลา สถานะ และผลลัพธ์ อาจครอบคลุมหนึ่งอุปกรณ์หรือหลายอุปกรณ์ตาม Scope ที่ตกลงภายหลัง |
| **Read-only Collection**       | การอ่านข้อมูลโดยไม่แก้ Configuration | ใช้เฉพาะคำสั่งที่อ่านสถานะ เช่นคำสั่งตระกูล `show` และห้ามเข้า Configuration Mode                                           |
| **Collector**                  | ส่วนเชื่อมต่อและเก็บข้อมูล           | Component ที่เชื่อมต่ออุปกรณ์และรับ CLI Output ไม่ควรเป็นผู้ตัดสินว่า Network ผิดปกติหรือไม่                                |
| **Parser**                     | ตัวแปลงผลลัพธ์                       | Component ที่แปลง CLI Output ให้เป็นข้อมูลแบบมีโครงสร้าง Parser Failure ต้องไม่ถูกตีความเป็น Device Failure                 |
| **Allowlist**                  | รายการเป้าหมายที่อนุญาต              | รายการอุปกรณ์หรือ Address ที่ระบบได้รับอนุญาตให้เชื่อมต่อ Collection ห้ามเชื่อมต่อเป้าหมายนอก Allowlist                     |
| **Managed Device**             | อุปกรณ์ที่ระบบจัดการข้อมูล           | อุปกรณ์ที่ลงทะเบียนใน Device Inventory และผ่านเงื่อนไขการจัดการตามที่โครงการกำหนด                                           |
| **Isolated Lab**               | ห้องทดลองเครือข่ายแยก                | สภาพแวดล้อมทดสอบที่แยกจากเครือข่ายมหาวิทยาลัยหรือ Production Network                                                        |

## 4. สถานะหลักที่ห้ามใช้ปะปนกัน

### 4.1 Reachability State

**Reachability** หมายถึงผลการตรวจว่า Management Endpoint ติดต่อได้หรือไม่ตามวิธีที่ระบบรองรับ ไม่ได้บอกว่า Collection สำเร็จหรือ Network Service ทำงานปกติ

| สถานะ | ความหมาย |
|---|---|
| **Reachable** | ติดต่อ Management Endpoint ได้ตามเกณฑ์ที่กำหนด |
| **Unreachable** | ติดต่อ Management Endpoint ไม่ได้ตามเกณฑ์ที่กำหนด |
| **Unknown Reachability** | ยังไม่มีผลตรวจหรือหลักฐานไม่เพียงพอให้สรุป |

> **ข้อควรระวัง:** ไม่ควรใช้คำว่า `Online` แทน Reachable เพราะคำว่า Online อาจถูกตีความว่าอุปกรณ์และ Network Service ทุกส่วนทำงานปกติ

### 4.2 Collection Status

**Collection Status** หมายถึงสถานะของกระบวนการอ่านและแปลงข้อมูล ไม่ใช่สถานะของอุปกรณ์จริง

| สถานะเชิงแนวคิด | ความหมาย |
|---|---|
| **Never Collected** | ยังไม่เคยมี Collection Attempt ที่สร้างข้อมูลสำเร็จ |
| **Requested** | ผู้ใช้ขอเริ่ม Refresh แล้ว แต่ระบบยังไม่เริ่มเชื่อมต่อ |
| **Running** | กำลังเชื่อมต่อ อ่านคำสั่ง หรือ Parse ข้อมูล |
| **Succeeded** | เชื่อมต่อ อ่าน และ Parse ข้อมูลที่จำเป็นสำเร็จ |
| **Failed** | Collection ไม่สำเร็จ ต้องแสดง Failure Category และเวลาที่พยายาม |

ตัวอย่าง Failure Category:

- Connection Failed
- Authentication Failed
- Timeout
- Command Unsupported
- Permission Denied
- Parser Failed
- Partial Collection

### 4.3 Operational State

**Operational State** หมายถึงค่าการทำงานจริงที่อุปกรณ์รายงาน เช่น Interface Up/Down, Err-disabled หรือมี Active Default Route หรือไม่

Operational State ต้องแสดงเป็น Actual State ที่มีหลักฐาน ห้ามใช้คำว่า `Healthy` ครอบทุกอย่างโดยไม่มีเกณฑ์ชัดเจน

### 4.4 Freshness State

**Data Freshness** หมายถึงความใหม่ของข้อมูลเมื่อเทียบกับเวลาปัจจุบันและ Freshness Threshold

| สถานะ | ความหมาย |
|---|---|
| **Fresh** | ข้อมูลยังไม่เกิน Freshness Threshold |
| **Stale** | ข้อมูลเกิน Freshness Threshold ต้องแสดงเวลาที่เก็บและคำเตือน |
| **Unknown Freshness** | ยังไม่มี Successful Collection จึงไม่มีเวลาที่ใช้ประเมิน |

### 4.5 กฎความสัมพันธ์ของสถานะ

```text
Reachable ≠ Collection Succeeded
Collection Succeeded ≠ Operational Normal
Operational State ≠ Data Freshness
Collection Failed ≠ Device Unreachable
Stale ≠ Down
Unknown ≠ Failed
```

## 5. เวลาและข้อมูลล่าสุด

| คำศัพท์                        | ความหมายที่ใช้ใน MyNetMate                                                                                        |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| **Latest Collection Attempt**  | ความพยายาม Collection ครั้งล่าสุด อาจสำเร็จหรือล้มเหลว                                                            |
| **Last Successful Collection** | Collection ครั้งล่าสุดที่อ่านและ Parse ข้อมูลสำคัญสำเร็จ                                                          |
| **`last_collected_at`**        | เวลาอ้างอิงของข้อมูล Operational ที่เก็บสำเร็จ ไม่ควรเปลี่ยนเป็นเวลาของรอบที่ล้มเหลว                              |
| **Freshness Threshold**        | ระยะเวลาสูงสุดที่ยอมให้ Snapshot ถูกถือว่ายัง Fresh                                                               |
| **Last Known State**           | Successful Snapshot ล่าสุดที่ยังแสดงเพื่ออ้างอิงเมื่อรอบใหม่ล้มเหลว ต้องติดป้ายว่าเป็นข้อมูลเดิมและแสดง Freshness |
| **Latest Attempt Error**       | ข้อมูลสรุปความล้มเหลวของ Collection Attempt ล่าสุด ไม่ใช่ Operational State ของอุปกรณ์                            |

## 6. Actual State, Expected State และ Assessment

| คำศัพท์                      | คำแปล/คำเรียกภาษาไทย        | ความหมายที่ใช้ใน MyNetMate                                                                    |
| ---------------------------- | --------------------------- | --------------------------------------------------------------------------------------------- |
| **Actual State**             | สถานะจริงที่สังเกตได้       | ค่าที่ Collector และ Parser อ่านจากอุปกรณ์ในการ Collection ที่สำเร็จ                          |
| **Expected State**           | สถานะที่คาดหวัง             | ค่าที่ผู้ใช้กำหนดไว้ล่วงหน้าว่า Device หรือ Interface ควรมีสภาพอย่างไร                        |
| **Expected-State Deviation** | ความแตกต่างจากค่าที่คาดหวัง | ผลที่ Actual State ไม่ตรงกับ Expected State ตามกฎที่กำหนด                                     |
| **Assessment**               | การประเมินตามกฎ             | การใช้ Actual State, Expected State และกฎตายตัวเพื่อจำแนกปัญหา ไม่ใช่ Root-cause Analysis     |
| **Deterministic Rule**       | กฎที่ให้ผลแน่นอน            | เมื่อ Input เหมือนเดิมต้องได้ผลเหมือนเดิม และสามารถอธิบายเหตุผลย้อนหลังได้                    |
| **Operational Problem**      | ปัญหาการทำงาน               | ผล Assessment ที่ชี้ว่า Device, Interface หรือ Route ควรได้รับการตรวจ                         |
| **Operational Finding**      | ข้อค้นพบด้านการทำงาน        | ข้อเท็จจริงหรือผลกฎที่อาจมีระดับความรุนแรง ใช้เป็นคำกลางเมื่อยังไม่ควรฟันธงว่าเป็น Root Cause |
| **False Positive**           | การแจ้งเตือนผิด             | ระบบรายงานว่าเป็นปัญหา ทั้งที่สภาพดังกล่าวเป็นสิ่งที่ตั้งใจไว้หรือไม่มี Expected State รองรับ |
| **Root Cause**               | สาเหตุรากของปัญหา           | สาเหตุจริงที่ยืนยันแล้ว D&M MVP ไม่ทำ Automatic Root-cause Analysis                           |

หลักการสำคัญ:

```text
ไม่มี Expected State
→ แสดง Actual State
→ ห้ามสรุป Expected-State Deviation
```

## 7. ความสำคัญและการจัดลำดับปัญหา

| คำศัพท์                           | ความหมายที่ใช้ใน MyNetMate                                                                                                                  |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Severity**                      | ระดับความสำคัญของ Finding เช่น Critical, Warning หรือ Informational ตามกฎที่กำหนด                                                           |
| **Critical**                      | ปัญหาที่ควรได้รับการตรวจเป็นลำดับต้นตาม Expected State และ Critical Flag ไม่ได้แปลว่าระบบรู้ Root Cause แล้ว                                |
| **Warning**                       | สภาพที่ควรตรวจ แต่ยังไม่ยืนยันผลกระทบรุนแรง                                                                                                 |
| **Informational**                 | ข้อมูลประกอบที่ไม่ควรถูกแสดงเป็นความผิดปกติรุนแรง                                                                                           |
| **Critical Flag (`is_critical`)** | ค่าที่ผู้ใช้กำหนดว่า Interface หรือ Resource นั้นมีความสำคัญต่อบริการ                                                                       |
| **Operational Problem Summary**   | สรุปจำนวนและประเภทปัญหาสำคัญจากกฎ เช่น Critical Uplink Down, Err-disabled, Critical WAN Down, Missing Expected Default Route และ Stale Data |

## 8. คำศัพท์สำหรับ Switch Operational Visibility

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Interface / Port** | จุดเชื่อมต่อของอุปกรณ์ ในเอกสารฐานข้อมูลใช้คำว่า Interface เป็นหลัก ส่วน UI อาจใช้คำว่า Port สำหรับ Switch |
| **Admin Status** | สถานะที่ Configuration กำหนดว่า Interface ถูกเปิดหรือปิด |
| **Operational Status / Link Status** | สถานะการทำงานจริงของ Interface ณ เวลาที่เก็บข้อมูล |
| **Err-disabled** | สถานะที่ Switch ปิดการทำงานของ Port เนื่องจากกลไกป้องกันบางอย่าง D&M แสดงสถานะได้แต่ห้ามเดาสาเหตุหากไม่มีหลักฐาน |
| **Access Port** | Switch Port สำหรับอุปกรณ์ปลายทาง โดยทั่วไปอยู่ใน VLAN เดียว |
| **Trunk Port** | Switch Port ที่ส่ง Traffic ได้หลาย VLAN |
| **Uplink** | Interface ที่เชื่อมอุปกรณ์ไปยังส่วน Network ต้นทางหรืออุปกรณ์ Network อื่น ผู้ใช้ต้องกำหนดหรือมีหลักฐานรองรับ |
| **Access VLAN** | VLAN ที่ Access Port ใช้รับส่ง Traffic แบบไม่ติด Tag |
| **Native VLAN** | VLAN สำหรับ Untagged Traffic บน Trunk ตาม Configuration ของอุปกรณ์ |
| **Allowed VLANs** | รายการ VLAN ที่ได้รับอนุญาตให้ผ่าน Trunk |
| **VLAN Mismatch** | Actual VLAN ไม่ตรงกับ Expected VLAN สรุปได้เฉพาะเมื่อผู้ใช้กำหนด Expected State |
| **Critical Uplink/Trunk Down** | Uplink หรือ Trunk ที่กำหนดเป็น Critical และคาดหวังให้ทำงาน แต่ Actual Operational Status ไม่เป็นไปตามเกณฑ์ |

> **กฎ:** Access Port Down ทั่วไปไม่เป็น Critical โดยอัตโนมัติ เพราะอุปกรณ์ปลายทางอาจปิดอยู่ตามปกติ

## 9. คำศัพท์สำหรับ Router Operational Visibility

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Layer 3 Interface** | Interface ที่มี IP Address และใช้ส่ง Traffic ระหว่าง Network |
| **Protocol Status** | สถานะ Layer 3 Protocol ของ Interface ซึ่งต้องแยกจาก Admin Status |
| **IP Address** | หมายเลข Address ที่กำหนดให้ Interface |
| **Prefix / Prefix Length** | ขนาด Network เช่น `/24` ใช้ร่วมกับ IP Address เพื่อบอกขอบเขต Subnet |
| **WAN Interface** | Interface ที่เชื่อมไปยังผู้ให้บริการ สาขา หรือ Network ภายนอก ต้องกำหนด Interface Role ก่อน Assessment |
| **LAN Interface** | Interface ที่เชื่อม Network ภายในองค์กร |
| **Management Interface** | Interface หรือ Network ที่ใช้บริหารอุปกรณ์ ไม่ได้ยืนยันว่า WAN หรือบริการอื่นทำงานปกติ |
| **Loopback Interface** | Logical Interface ที่ไม่ผูกกับสาย Physical โดยตรง |
| **Route** | ข้อมูลที่บอกว่า Destination Prefix ต้องส่ง Traffic ไปทางใด |
| **Default Route** | Route ที่ใช้เมื่อไม่มี Route ที่เฉพาะเจาะจงกว่า โดยทั่วไปคือ `0.0.0.0/0` สำหรับ IPv4 |
| **Active Default Route** | Default Route ที่ติดตั้งและใช้งานอยู่ใน Routing Table ณ Snapshot นั้น |
| **Next Hop** | Address ของอุปกรณ์ถัดไปที่ Router ส่ง Traffic ไปหา |
| **Outgoing Interface** | Interface ที่ Traffic ของ Route นั้นออกจาก Router |
| **Edge Router** | Router ที่เชื่อม Network ภายในกับ Network ภายนอกและอาจถูกกำหนดว่าต้องมี Default Route |
| **Internal Router** | Router ที่ใช้เชื่อม Network ภายในและอาจตั้งใจไม่มี Default Route |
| **Edge Router Expectation** | Expected State ที่ระบุว่า Router ต้องมี Active Default Route หรือไม่ |
| **Missing Expected Default Route** | ไม่พบ Active Default Route ทั้งที่ `requires_default_route` ถูกกำหนดเป็นจริง |
| **Critical WAN Down** | WAN Interface ที่กำหนดเป็น Critical และคาดหวังให้ทำงาน แต่ Actual Protocol/Operational Status ไม่เป็นไปตามเกณฑ์ |

## 10. Interface Role และ Device Role

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Interface Role** | บทบาทของ Interface ที่ผู้ใช้กำหนดเพื่อใช้แสดงผลและ Assessment |
| **Access Role** | Interface ที่ต่ออุปกรณ์ปลายทาง |
| **Trunk Role** | Interface ที่ขนส่งหลาย VLAN |
| **Uplink Role** | Interface ที่เชื่อมไปยังอุปกรณ์ Network ต้นทางหรือส่วนสำคัญ |
| **WAN Role** | Interface ที่เชื่อม Network ภายนอกหรือ Provider |
| **LAN Role** | Interface ที่เชื่อม Network ภายใน |
| **Management Role** | Interface ที่ใช้บริหารอุปกรณ์ |
| **Loopback Role** | Logical Interface สำหรับงาน Routing หรือ Identification |
| **Device Role** | บทบาทระดับอุปกรณ์ เช่น Core Switch, Access Switch, Edge Router หรือ Internal Router |

Interface Role ไม่เท่ากับ Switchport Mode เช่น Interface อาจมี `switchport_mode = trunk` และมี `interface_role = uplink` พร้อมกันได้

## 11. Dashboard และการแสดงผล

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Network Overview** | สรุป Reachability, Collection, Freshness และจำนวนปัญหาสำคัญ |
| **Summary** | ค่ารวมที่คำนวณจากข้อมูลต้นทาง ไม่ควรสร้างตาราง `dashboard` เพื่อเก็บค่าที่คำนวณใหม่ได้ |
| **Metric Card** | กล่องตัวเลขสรุปหนึ่งเรื่อง เช่น Unreachable Devices หรือ Collection Failed |
| **Drill-down** | การกดจาก Summary ไปยังรายการ Device, Interface, Route หรือ Finding ที่เป็นที่มาของตัวเลข |
| **Device Detail** | หน้ารายละเอียดอุปกรณ์หนึ่งตัว รวมข้อมูล Identity และสถานะที่เกี่ยวข้อง |
| **Interface Detail** | หน้าหรือส่วนที่แสดงข้อมูล Interface หนึ่งรายการอย่างละเอียด |
| **Router Detail** | หน้ารายละเอียด Router ที่รวม Interface และ Routing Snapshot |
| **Quick Action** | ทางลัดไปยัง Workflow ที่เกี่ยวข้อง โดยแสดงตามสิทธิ์ของผู้ใช้ |
| **Filter** | การจำกัดชุดข้อมูลที่แสดง เช่น Site, Device Type, Status หรือ Severity |
| **Grouping** | การจัดรายการที่มีคุณสมบัติร่วมให้อยู่กลุ่มเดียวกัน เช่นจัดตาม Site หรือ Problem Type |
| **Sorting** | การเรียงรายการ เช่น Critical ก่อน Warning หรือข้อมูลล่าสุดก่อน |
| **Empty State** | UI เมื่อยังไม่มีรายการ เช่นยังไม่มีอุปกรณ์หรือไม่พบ Finding |
| **Error State** | UI เมื่อ Request หรือ Dependency ทำงานล้มเหลว ต้องไม่แสดงแทนว่า Network ผิดปกติ |

## 12. ปัญหาคนละ Domain ที่ต้องแยกกัน

| คำศัพท์ | เจ้าของหลัก | ความหมาย |
|---|---|---|
| **Operational Problem** | D&M/Operational Assessment ตาม Ownership ที่จะตัดสิน | ปัญหาการทำงานของ Device, Interface หรือ Route |
| **Security Finding** | Security & Validation | ผลการตรวจ Configuration กับกฎความปลอดภัย |
| **System Health** | System/Platform Health | ความพร้อมของ Backend, Database และ Component ของ MyNetMate |
| **Audit Event** | Audit Trail | หลักฐานว่าใครทำ Action อะไรกับ Resource ใดเมื่อใด |
| **Topology Conflict** | NTV | ความขัดแย้งของ Neighbor Observation หรือ Topology Evidence |

```text
Operational Problem ≠ Security Finding
Network State ≠ MyNetMate System Health
Audit Event ≠ Root Cause
Topology Conflict ≠ Interface Down
```

## 13. System, Security และ Safety

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **System Health** | สถานะความพร้อมของ Backend, Database และ Component ของ MyNetMate แยกจาก Network Operational State |
| **Offline Mode** | โหมดที่ปิดการใช้งาน AI โดยตั้งใจ ไม่ใช่ Critical Error และไม่ควรหยุด Rule-based D&M |
| **Security Summary** | สรุป Security Finding จาก Security & Validation โดย D&M ไม่สร้างผล CIS เอง |
| **Recent Activity** | รายการ Audit Event ล่าสุดเพื่อช่วยสร้างลำดับเหตุการณ์ ไม่ใช่หลักฐานยืนยันผู้ก่อปัญหา |
| **Audit Trail** | บันทึก User, Action, Resource และ Timestamp สำหรับตรวจสอบย้อนหลัง |
| **RBAC** | การควบคุมสิทธิ์ตาม Role เช่น Admin, Operator และ Viewer |
| **Human-in-the-Loop** | มนุษย์เป็นผู้เริ่มหรือยืนยัน Action สำคัญ ระบบหรือ AI ไม่ดำเนินการกับอุปกรณ์เอง |
| **PII Masking** | การซ่อนข้อมูลสำคัญก่อนส่งออกไปยัง AI ไม่เกี่ยวกับ Read-only Operational Assessment ที่ไม่ใช้ AI |
| **AI Guardrail** | ข้อจำกัดที่ป้องกัน AI ทำ Action อันตราย ใน D&M AI ไม่มีสิทธิ์ Refresh, Assessment หรือสั่งอุปกรณ์ |

## 14. คำศัพท์ด้านข้อมูลและฐานข้อมูล

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Source of Truth** | แหล่งข้อมูลหลักที่ได้รับสิทธิ์เป็นเจ้าของและแก้ไขข้อมูลชุดนั้น |
| **Database Ownership** | ข้อตกลงว่า Feature ใดเป็นเจ้าของ Schema และกฎการเปลี่ยนแปลงของข้อมูล |
| **Data Owner** | Feature หรือ Domain ที่รับผิดชอบความหมาย ความถูกต้อง และ Lifecycle ของข้อมูล |
| **Data Producer** | Component หรือ Feature ที่สร้างหรืออัปเดตข้อมูล อาจไม่ใช่ Data Owner |
| **Data Consumer** | Feature ที่อ่านหรือใช้ข้อมูลของเจ้าของอื่น |
| **Dependency Contract** | ข้อตกลงว่าผู้ใช้ข้อมูลขอข้อมูลอะไรจากเจ้าของ ผ่านวิธีใด และคาดหวังรูปแบบหรือพฤติกรรมอย่างไร |
| **Foreign Key (FK)** | Constraint ที่เชื่อม Record ในฐานข้อมูลกับ Record เจ้าของข้อมูลอีกตาราง |
| **API Contract** | ข้อตกลง Request, Response, Error และสิทธิ์ระหว่าง Component หรือ Feature |
| **Event Contract** | ข้อตกลงของ Event ที่ Producer ส่งให้ Consumer เช่น Refresh Completed |
| **Aggregate** | ค่าที่คำนวณจากหลาย Record เช่นจำนวน Critical Problems ไม่จำเป็นต้องเก็บเป็นตาราง Dashboard |
| **Snapshot** | ชุดข้อมูลที่แสดงสภาพ ณ เวลาหนึ่ง แตกต่างจากข้อมูล Identity ที่เปลี่ยนไม่บ่อย |
| **History** | ข้อมูลหลายช่วงเวลาที่เก็บไว้เพื่อดูย้อนหลัง ต้องไม่เพิ่มโดยไม่มี Use Case และ Retention Policy |
| **Retention Policy** | กฎว่าจะเก็บข้อมูลย้อนหลังไว้นานเท่าใดและลบเมื่อใด |
| **Test Fixture** | ชุดข้อมูลทดสอบที่ควบคุมค่าแน่นอน ใช้ทดสอบกฎและ Query ซ้ำได้ |
| **Mock Data** | ข้อมูลจำลองสำหรับ UI หรือ Component ที่ Dependency จริงยังไม่พร้อม |

## 15. คำศัพท์ด้านการออกแบบระบบ

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Entity** | สิ่งที่ระบบต้องรู้จักและเก็บข้อมูล เช่น Device, Interface หรือ Collection Attempt |
| **Relationship** | ความเกี่ยวข้องระหว่าง Entity |
| **Cardinality** | จำนวนความสัมพันธ์ เช่น Device หนึ่งตัวมีหลาย Interface |
| **Lifecycle** | วงจรตั้งแต่ข้อมูลถูกสร้าง เปลี่ยนสถานะ จนสิ้นสุดการใช้งาน |
| **State Model** | แบบจำลองสถานะและเงื่อนไขการเปลี่ยนสถานะ |
| **Conceptual Model** | แบบจำลอง Entity และความหมายโดยยังไม่กำหนด Table/Column |
| **Logical Schema** | แบบตาราง, Column, Key และ Constraint ที่ไม่ผูกกับรายละเอียดการติดตั้งทั้งหมด |
| **Physical Schema** | รายละเอียดจริงของ PostgreSQL เช่น Data Type, Index และ Partition |
| **Component** | ส่วนของระบบที่มีหน้าที่ชัดเจนและมี Interface ติดต่อกับส่วนอื่น |
| **Aggregation Service** | Component ที่รวมข้อมูลจากหลาย Domain เป็น Dashboard Response โดยไม่เป็นเจ้าของข้อมูลต้นทาง |
| **Refresh Orchestrator** | Component ที่ควบคุมลำดับ Refresh เช่นตรวจสิทธิ์ เลือกเป้าหมาย เรียก Collector และบันทึกผล |
| **Assessment Rule Engine** | Component ที่ใช้กฎตายตัวเปรียบเทียบ Actual State กับ Expected State |
| **Repository** | ส่วนที่รวม Query และการเข้าถึงข้อมูลของ Domain เพื่อไม่ให้ Query กระจายใน API Route |

## 16. คำศัพท์ด้านการจัด Scope

| คำศัพท์ | ความหมายที่ใช้ใน MyNetMate |
|---|---|
| **Must Have** | ความสามารถที่ขาดแล้ว MVP ไม่สามารถให้คุณค่าหลักหรืออาจแสดงข้อมูลผิด |
| **Should Have** | ความสามารถสำคัญที่ทำหลัง Must Have และสามารถเลื่อนได้หากเวลาจำกัด |
| **Could Have** | ความสามารถเสริมที่ทำเมื่อส่วนหลักเสถียรแล้ว |
| **Backlog** | งานที่ยังมีคุณค่าแต่ไม่ได้อยู่ใน MVP รอบแรก |
| **Future Enhancement** | ความสามารถสำหรับระยะถัดไปที่ต้องพึ่งโครงสร้างหรือการทดลองเพิ่มเติม |
| **Won't Have** | ความสามารถที่ตั้งใจไม่ทำในขอบเขตปัจจุบัน |
| **Scope Correction** | มติใหม่ที่แก้ขอบเขตเดิมโดยบันทึกเหตุผลไว้ |
| **Historical** | แนวคิดเก่าที่เก็บเป็นหลักฐานแต่ไม่ใช่ข้อกำหนดปัจจุบัน |
| **Superseded** | เนื้อหาที่ถูกมติใหม่แทนที่และห้ามใช้เป็นข้อกำหนดปัจจุบันโดยตรง |

## 17. คำมาตรฐานที่แนะนำสำหรับ UI และเอกสาร

| ต้องการสื่อ | คำที่แนะนำ | คำที่ควรหลีกเลี่ยง |
|---|---|---|
| ติดต่อ Management Endpoint ได้ | **Reachable** | Online, Healthy |
| ติดต่อไม่ได้ตามเกณฑ์ | **Unreachable** | Offline หากยังไม่ได้กำหนดความหมายเฉพาะ |
| ยังไม่มีหลักฐาน | **Unknown** | Failed |
| เก็บข้อมูลสำเร็จ | **Collection Succeeded** | Device Healthy |
| เก็บข้อมูลล้มเหลว | **Collection Failed** | Device Down |
| ข้อมูลเกินเวลา | **Stale** | Offline, Failed |
| ข้อมูลสำเร็จชุดล่าสุด | **Last Known State** | Current State หากข้อมูล Stale |
| ค่าที่อุปกรณ์รายงาน | **Actual State** | Expected State |
| ค่าที่ผู้ใช้กำหนดว่าควรเป็น | **Expected State** | Default/Normal State |
| ผลต่างจากสิ่งที่คาดหวัง | **Expected-State Deviation** | Root Cause |
| ปัญหาที่กฎชี้ให้ตรวจ | **Operational Problem/Finding** | AI Diagnosis |
| AI ถูกปิดโดยตั้งใจ | **Offline Mode** | System Failure |

## 18. กฎสรุปที่ต้องใช้ร่วมกันทุกเอกสาร

1. ห้ามใช้ Reachable แทนคำว่า Operational Normal
2. ห้ามใช้ Collection Failed แทน Device Unreachable
3. ห้ามแสดง Last Known State เป็น Current State โดยไม่มีเวลาและ Stale Label
4. ห้ามสรุป Expected-State Deviation เมื่อไม่มี Expected State
5. ห้ามจัด Access Port Down ทั่วไปเป็น Critical โดยอัตโนมัติ
6. ห้ามรวม Operational Problem, Security Finding และ System Health เป็นสถานะเดียว
7. ห้ามเรียก D&M MVP ว่า Real-time หรือ Continuous Monitoring
8. ห้ามให้ AI Refresh, Assessment, เปลี่ยน Configuration หรือสั่งอุปกรณ์
9. ห้ามให้ D&M เป็นเจ้าของสำเนาข้อมูลของ Feature อื่นโดยไม่มี Ownership Decision
10. ทุก Summary ต้อง Drill-down หรืออธิบายที่มาของตัวเลขได้

---

## 19. คำศัพท์ที่ยังต้องตัดสินใน Step ต่อไป

คำต่อไปนี้มีความหมายเบื้องต้นแล้ว แต่รายละเอียดต้องตัดสินใน Database Ownership, Lifecycle หรือ API Step:

- Interface Identity Owner
- Operational Snapshot Owner
- Expected State Owner
- Collection Run Scope
- Partial Collection
- Freshness Threshold ต่อชนิดข้อมูล
- Operational Finding Persistence
- Snapshot History และ Retention
- Reachability Method เมื่ออุปกรณ์ปิด ICMP
- สิทธิ์ Manual Refresh ของ Admin, Operator และ Viewer

