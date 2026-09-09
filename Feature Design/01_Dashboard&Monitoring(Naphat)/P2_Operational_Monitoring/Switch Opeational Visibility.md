# “Dashboard สำหรับโชว์ Demo” เป็น “Dashboard ที่วิศวกรสามารถนำไปใช้งานจริงในขอบเขตเล็กได้

Dashboard ต้องแสดง “สถานะการทำงานภายใน Switch” ด้วย ไม่ใช่แค่ว่าอุปกรณ์ทั้งเครื่อง Online/Offline
ต้องมีแบบ Minimal Interface/VLAN Visibility ไม่ใช่ขยายเป็นระบบ Monitoring เต็มรูปแบบ

เหตุผลสำคัญคือ Dashboard เดิมที่มีแค่จำนวน Device Online/Offline, Activity และ API Status ยังดูคล้าย Dashboard เว็บแอปทั่วไป การเพิ่มสถานะ Port, Access/Trunk และ VLAN จะทำให้เห็นชัดว่า MyNetMate เป็นเครื่องมือของวิศวกรเครือข่ายจริง และเป็น Feedback โดยตรงจากอาจารย์ด้วย

หลักคิดที่เหมาะที่สุดคือ:

> ภายใน 30 วินาที วิศวกรต้องตอบได้ว่า “อะไรเสีย อยู่ที่ไหน กระทบอะไร ข้อมูลใหม่แค่ไหน และควรไปทำอะไรต่อ”

```
PC ── Access Port (VLAN 10) ── SW1
                                ║
                     Trunk (VLAN 10,20,30)
                                ║
                               SW2
```

## คำศัพท์แต่ละตัวหมายถึงอะไร

| คำ               | ความหมาย                                              | ตัวอย่าง                                          |
| ---------------- | ----------------------------------------------------- | ------------------------------------------------- |
| **VLAN**         | แบ่ง Network Layer 2 ออกเป็นกลุ่มเสมือน               | VLAN 10 = Staff, VLAN 20 = Student                |
| **Access Mode**  | Port สำหรับต่ออุปกรณ์ปลายทาง อยู่ใน VLAN เดียว        | `Gi0/1` ต่อ PC และอยู่ VLAN 10                    |
| **Trunk Mode**   | Port ที่ส่งข้อมูลได้หลาย VLAN โดยทั่วไปใช้ 802.1Q Tag | `Gi0/24` เชื่อม Switch อีกตัวและส่ง VLAN 10,20,30 |
| **Port Up/Down** | สถานะทางกายภาพหรือการทำงานของ Interface               | สายเสียบและปลายทางเปิดอยู่ = Up                   |
| **Link**         | การเชื่อมต่อระหว่าง Port ต้นทางกับ Port ปลายทาง       | SW1 `Gi0/24` เชื่อม SW2 `Gi0/24`                  |

### Access Port

ใช้ต่อกับอุปกรณ์ปลายทาง เช่น:

- PC
- Printer
- Server
- IP Camera

โดยปกติรองรับ VLAN เดียว:

```
interface GigabitEthernet0/1
 switchport mode access
 switchport access vlan 10
```

Dashboard ควรบอกได้ว่า:

```
Gi0/1 | Access | VLAN 10 | Up
```

### Trunk Port

ใช้เชื่อมระหว่างอุปกรณ์ Network เช่น:

- Switch ↔ Switch
- Switch ↔ Router
- Switch ↔ Access Point
- Switch ↔ Firewall

หนึ่ง Port สามารถส่งหลาย VLAN:

```
interface GigabitEthernet0/24
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
```

Dashboard ควรบอกได้ว่า:

```
Gi0/24 | Trunk | Allowed VLANs 10,20,30 | Up
```

Trunk มีความสำคัญมาก เพราะหาก Trunk/Uplink Down อุปกรณ์หรือผู้ใช้หลาย VLAN อาจได้รับผลกระทบพร้อมกัน

### Port Up/Down ต้องแยกสองสถานะ

ในทาง Network ควรแยก:

| สถานะ                       | ความหมาย                            |
| --------------------------- | ----------------------------------- |
| **Admin Status**            | ผู้ดูแลเปิดหรือปิด Port ด้วย Config |
| **Operational/Link Status** | สถานะการเชื่อมต่อจริง ณ ขณะนั้น     |

ตัวอย่าง:

|Admin|Operational|ความหมาย|
|---|---|---|
|Up|Up|Port เปิดและเชื่อมต่อสำเร็จ|
|Up|Down|เปิด Port แล้ว แต่ไม่มีสาย ปลายทางปิด หรือ Link มีปัญหา|
|Down|Down|ผู้ดูแลสั่ง `shutdown` โดยตั้งใจ|
|Up|Err-disabled|Switch ปิด Port อัตโนมัติเพราะพบความผิดปกติ|

ดังนั้นการแสดงแค่คำว่า `down` ยังไม่พอ เพราะต้องรู้ว่า Down โดยตั้งใจหรือเกิดปัญหา

### Device Online ไม่เท่ากับ Port Up

สองอย่างนี้ต้องแยกกัน:

- **Device Online:** Management IP ของ Switch ตอบ Ping
- **Port Up:** Interface แต่ละช่องมี Physical/Operational link

กรณีหนึ่งอาจเกิดแบบนี้:

```
Switch Online
├─ Gi0/1  Access VLAN 10   Up
├─ Gi0/2  Access VLAN 10   Down
├─ Gi0/3  Access VLAN 20   Err-disabled
└─ Gi0/24 Trunk            Down  ← ปัญหารุนแรง
```

Switch ยังตอบ Ping ได้ แต่ Trunk ที่เชื่อมไปอีก Switch อาจ Down ทำให้ผู้ใช้จำนวนมากใช้งานไม่ได้
Dashboard เดิมอาจแสดงสีเขียวเพราะ Switch Online แต่อาจารย์จะมองว่า Network กำลังมีปัญหาจริง

## ทำไมต้องมี VLAN

VLAN เป็นตัวบอกว่า Traffic ของผู้ใช้กลุ่มใดกำลังวิ่งผ่าน Port ใด หากไม่มีข้อมูล VLAN วิศวกรจะรู้เพียงว่า Port Up แต่ไม่รู้ว่าเชื่อมต่อกับ Network กลุ่มใด

### กรณี Port อยู่ผิด VLAN

```
Gi0/1
Link: Up
Mode: Access
ควรอยู่: VLAN 10
ตั้งค่าจริง: VLAN 20
```

ทุกอย่างดูเหมือนปกติ:

- Switch Online
- Port Up
- ไม่มีสายหลุด

แต่ PC ใช้งาน Network ผิดวง เพราะ Port ถูกกำหนด VLAN ผิด

Dashboard ที่แสดง VLAN จะช่วยให้มองเห็นปัญหานี้ได้ ส่วน Dashboard ที่แสดงเพียง Port Up จะหาไม่พบ

### กรณี Trunk ขาด VLAN

```
Gi0/24
Mode: Trunk
Link: Up
Allowed VLANs: 10,20
VLAN ที่ต้องใช้: 10,20,30
```

Port และสายยัง Up แต่ผู้ใช้ VLAN 30 ข้ามไปอีก Switch ไม่ได้ นี่เป็นเหตุผลที่ต้องดูทั้ง:

- Link status
- Access/Trunk mode
- Allowed VLANs
- Native VLAN

# Dashboard ควรแสดงอะไร

## สิ่งที่ผู้ใช้งานจริงต้องการดู

| คำถามของวิศวกร              | ข้อมูลบน Dashboard                                       |
| --------------------------- | -------------------------------------------------------- |
| อุปกรณ์ใดติดต่อไม่ได้?      | Device Online/Offline/Unknown                            |
| ปัญหาอยู่ตรงไหน?            | Site, Device, Interface                                  |
| Port ที่เสียสำคัญหรือไม่?   | Access/Trunk/Uplink และ Port description                 |
| Port ถูกปิดหรือสายหลุด?     | Admin status แยกจาก Operational status                   |
| VLAN ใดได้รับผลกระทบ?       | Access VLAN, Native VLAN, Allowed VLANs                  |
| Config มีความเสี่ยงหรือไม่? | Critical Security Validation Failures                    |
| ก่อนเกิดปัญหามีใครแก้อะไร?  | Recent Activity/Audit Trail                              |
| ข้อมูลยังใหม่อยู่หรือไม่?   | Last checked, Stale/Unknown indicator                    |
| ต้องไปทำอะไรต่อ?            | ลิงก์ไป Device, Interface, Validation หรือ Config Detail |

หน้า Dashboard หลักไม่ควรแสดงทุก Port เพราะจะรก ควรแสดงเป็น Summary:
## Dashboard MVP ที่ใช้งานจริงได้

### Network Overview

- จำนวนอุปกรณ์ทั้งหมด
- Online/Offline/Unknown/Maintenance
- จำนวน Switch ที่มี Critical Interface Problem
- จำนวน Critical Validation Failures
- เวลาตรวจสอบข้อมูลล่าสุด
### Switch Port Overview / Summary

- Total ports
- Ports Up
- Ports Down
- Admin Down
- Err-disabled
- Access ports
- Trunk ports
- Trunk/Uplink Down
- เวลาที่เก็บข้อมูลล่าสุด

```
SW-CORE-01
├─ Access: 20 ports — Up 15 / Down 5
├─ Trunk:   2 ports — Up 1 / Down 1
├─ Err-disabled: 1
└─ Last checked: 2 minutes ago
```
ไม่ควรเอา Port ทุกช่องมาแสดงบน Dashboard เพราะจะรก ให้กดการ์ดแล้วไปหน้า Device Detail
### Interface Detail

|Interface|Admin|Link|Mode|VLAN|ความสำคัญ|
|---|---|---|---|---|---|
|Gi0/1|Up|Up|Access|10|Normal|
|Gi0/2|Up|Down|Access|20|Informational|
|Gi0/23|Up|Err-disabled|Access|30|Critical|
|Gi0/24|Up|Down|Trunk|10,20,30|Critical|

### Critical Link Problems

เน้นเฉพาะรายการสำคัญ:

- Trunk/Uplink Down
- Err-disabled
- Trunk ไม่มี Allowed VLAN ที่ต้องใช้
- Native VLAN mismatch หากระบบตรวจได้
- Access Port อยู่ผิด VLAN หากมีกฎเปรียบเทียบ
- ข้อมูลเกิน Freshness threshold
- Device Offline

Access Port Down ทั่วไปไม่ควรแสดงเป็น Critical เพราะ PC หรือ Printer อาจปิดอยู่ตามปกติ

### VLAN Summary

- จำนวน Active VLANs
- จำนวน Access Port ต่อ VLAN
- Trunk ใดอนุญาต VLAN อะไร
- VLAN ที่ไม่มี Port ใช้งาน อาจเป็นข้อมูลเสริม
### Recent Changes

- ใครเปลี่ยน Device
- ใครสร้าง Config
- ใครสแกนหรือ Override กฎ
- เกิดขึ้นเมื่อใด
- กดไปดูรายละเอียดได้

Port Down ทุกอันไม่ใช่ปัญหารุนแรง เพราะ Access Port อาจ Down เนื่องจาก PC ปิดอยู่ตามปกติ

| เหตุการณ์                           | ระดับที่แนะนำ        |
| ----------------------------------- | -------------------- |
| Access Port Down                    | Neutral/ข้อมูลทั่วไป |
| Admin Down                          | Informational        |
| Err-disabled                        | Critical             |
| Trunk/Uplink Down                   | Critical             |
| Trunk Up แต่ VLAN สำคัญไม่ถูก Allow | Warning/Critical     |
| ข้อมูลเกินเวลาที่กำหนด              | Stale/Unknown        |

นี่คือส่วนสำคัญที่ทำให้ Dashboard ช่วยตัดสินใจ ไม่ใช่เพียงนับจำนวน Port

## Monitoring ที่ใช้งานจริงต้องอัปเดตเอง

ถ้าต้องให้มีโอกาสนำไปใช้จริง การกด Refresh อย่างเดียวอาจยังไม่พอ ควรมีการตรวจแบบเป็นรอบกับอุปกรณ์ที่ผู้ใช้ลงทะเบียนไว้เท่านั้น เช่น:

- Ping ตรวจ Device reachability ทุก 60 วินาที
- อ่าน Interface/VLAN Snapshot ทุก 5 นาที
- มีปุ่ม Manual Refresh
- แสดง `last_checked_at` ทุกครั้ง
- หากตรวจไม่ได้ ให้เปลี่ยนเป็น Unknown/Stale ไม่ใช้ค่าค้างโดยไม่มีคำเตือน

ตัวเลข 60 วินาทีและ 5 นาทีเป็นค่าเริ่มต้นสำหรับทดสอบ ต้องปรับจากผลการทดลองใน GNS3/Isolated Lab

ถ้าไม่มีการตรวจอัตโนมัติ ควรเรียกสิ่งที่ทำว่า “Inventory Snapshot Dashboard” มากกว่า “Monitoring Dashboard”

## ข้อมูลมาจากไหน

สำหรับ Cisco สามารถเก็บจากคำสั่ง Read-only เช่น:

```
show interfaces status
show interfaces switchport
show interfaces trunk
show vlan brief
show interfaces description
show cdp neighbors detail
show lldp neighbors detail
```

แต่ข้อมูลมีสองประเภท:

- **Configuration state:** Access/Trunk, Access VLAN, Allowed VLAN — อ่านจาก Running Config หรือคำสั่ง Switchport
- **Operational state:** Port Up/Down, Err-disabled — ต้องอ่านสถานะปัจจุบันจากอุปกรณ์ ไม่สามารถรู้จาก Config อย่างเดียว

ดังนั้นหาก P1 ยังไม่ทำ Live SSH/SNMP สามารถใช้ Uploaded CLI output หรือ Mock data จาก Isolated Lab สำหรับ Demo ก่อนได้ ส่วน Live collection ค่อยอยู่ใน P2

## ผลกระทบต่อ Database Schema

ตาราง `interfaces` เดิมควรพิจารณาเพิ่ม:

```
interfaces
- id
- device_id
- name
- description
- admin_status
- oper_status
- switchport_mode       // access, trunk, routed
- access_vlan_id
- native_vlan_id
- speed
- duplex
- is_uplink
- last_collected_at
```

สำหรับ VLAN และ Trunk Allowed VLAN อาจต้องมี:

```
vlans
- id
- device_id
- vlan_number
- name
- status

interface_vlans
- interface_id
- vlan_id
- tagging_mode          // access, tagged, native
```

สรุปคำแนะนำจากอาจารย์ได้ว่า:

> Dashboard ต้องแสดงทั้งระดับอุปกรณ์และระดับ Interface เพื่อให้ผู้ดูแลเห็นว่า Switch ยัง Online อยู่หรือไม่, Port ใด Up/Down, Port ใดเป็น Access/Trunk และ VLAN ใดกำลังวิ่งผ่าน Port เหล่านั้น

นี่อาจเป็นการเปลี่ยน Scope จาก Dashboard แบบสรุป Inventory ไปเป็น Dashboard ที่มี Switch Operational Visibility ซึ่งควรบันทึกเป็น Feedback จากอาจารย์และประเมินใหม่ว่า Interface Monitoring ส่วนใดเป็น P1 และส่วนใดเป็น P2 ครับ

## การเก็บข้อมูลแบบไม่ทำ Database บวม

ไม่ต้องเก็บผลทุก Poll ตลอดเวลาใน P1 ให้เก็บ:

- Current device state
- Current interface state
- Current VLAN/mode
- Last checked
- Last state change
- เหตุการณ์เมื่อสถานะเปลี่ยนเท่านั้น เช่น Up → Down

แนวคิดนี้เก็บข้อมูลน้อยกว่าการทำ Time-series เต็มรูปแบบ แต่ยังตอบได้ว่า Port เปลี่ยนสถานะเมื่อใด

## ผลกระทบต่อ Scope เดิม

ผมแนะนำให้ยกระดับส่วนนี้เข้ามาใน P1 แล้วลดความสำคัญของสิ่งเหล่านี้ก่อนหากเวลาไม่พอ:

1. Export Report
2. Dashboard customization
3. System API Status แบบละเอียด
4. Historical graph
5. Topology preview

ข้อสรุปที่เหมาะสมคือ:

> P1 ต้องมี Snapshot ของ Interface/VLAN สำหรับ Cisco ที่ผู้ใช้กด Refresh เอง โดยแสดง Port Up/Down, Access/Trunk, VLAN และ Critical Uplink Problems แต่ยังไม่ทำ Continuous Monitoring หรือ Automatic Discovery

วิธีนี้ตอบ Feedback อาจารย์ มีคุณค่าทาง Network Engineering ชัดเจน และยังควบคุม Scope ได้ครับ

## วิธีเก็บข้อมูลแบบไม่ทำ Scope บาน

สำหรับ P1 แนะนำ:

- รองรับ Cisco ก่อน
- ผู้ใช้เพิ่มอุปกรณ์เองจาก Device Inventory
- กด `Refresh Interface Status` ด้วยตนเอง
- Backend ส่งเฉพาะคำสั่ง Read-only เช่น:

```
show interfaces status
show interfaces switchport
show interfaces trunk
show vlan brief
```

- ทดสอบเฉพาะ GNS3 หรือ Isolated Lab
- ไม่เข้า Configuration Mode
- ไม่ส่งคำสั่งแก้ Config
- ไม่ทำ Network Scan
- ไม่ต้องมี Scheduled polling ในรอบแรก

Cisco ระบุว่าข้อมูล Interface และ Neighbor สามารถอ่านผ่านคำสั่งสถานะของ CDP/LLDP และ Interface ได้ จึงเป็นข้อมูลปฏิบัติการที่มีพื้นฐานชัดเจน [Cisco CDP](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/cdp/configuration/xe-2/cdp-xe-2-book/nm-cdp-discover-xe.html), [Cisco LLDP](https://www.cisco.com/c/en/us/td/docs/routers/ios/config/17-x/application-services/b-application-services/m_ce-lldp-multivend.html)


## ขอบเขตการเชื่อมต่อที่ปลอดภัย

เพื่อให้เหมาะกับการใช้งานจริงและกติกาโครงการ:

- เชื่อมเฉพาะอุปกรณ์ที่เพิ่มใน Inventory โดยผู้ใช้
- ใช้บัญชี Read-only หากอุปกรณ์รองรับ
- ส่งเฉพาะคำสั่ง `show`
- ห้ามเข้า Configuration Mode
- ไม่ Scan ช่วง IP
- ไม่แตะเครือข่ายมหาวิทยาลัยนอก Isolated Lab
- เก็บ Credential แบบเข้ารหัส
- บันทึกทุกการ Refres ลhง Audit Trail
- AI ไม่มีสิทธิ์สั่งงานอุปกรณ์


## สิ่งที่ยังไม่จำเป็นต่อ MVP จริง

- Bandwidth graph
- CPU/Memory graph
- Historical port availability
- SNMP monitoring เต็มรูปแบบ
- Automatic topology
- Email/LINE notification
- Real-time streaming
- Multi-vendor interface parser
- Customizable Dashboard
- AI วิเคราะห์เหตุขัดข้อง
- SNMP Monitoring เต็มรูปแบบ
- Multi-vendor ตั้งแต่รอบแรก

Cisco Catalyst Center เองแยกมุมมอง Device health, Interface information และ Topology เพื่อช่วยระบุปัญหาและเจาะลงรายละเอียด แต่ MyNetMate ควรหยิบมาเฉพาะ Workflow ที่จำเป็น ไม่ต้องทำระบบเทียบเท่า [Cisco Network Health](https://www.cisco.com/c/en/us/td/docs/cloud-systems-management/network-automation-and-management/catalyst-center-assurance/3-2-x/cisco-catalyst-assurance-user-guide-3-2-x/b_cisco_catalyst_assurance_3_2_x_ug_chapter_0110.html), [Cisco Topology and Device Details](https://www.cisco.com/c/en/us/td/docs/cloud-systems-management/network-automation-and-management/catalyst-center/3-2-x/user-guide/cisco-catalyst-center-user-guide-3-2-x/b_cisco_catalyst_center_ug_3_1_x_chapter_0101.html)

# แนวคิดของอาจาร์ยกับของฉัน ทำไมอาจาร์ยถึงคิดว่า ต้องเพิ่ม VLAN อะไรพวกนี้เข้ามา
ผมคิดว่าอาจารย์กับคุณกำลังมองคำว่า “Dashboard” คนละระดับครับ และแนวคิดของทั้งสองฝ่ายไม่ได้ผิด

| มุมมองของคุณ                         | มุมมองของอาจารย์                           |
| ------------------------------------ | ------------------------------------------ |
| Dashboard ของระบบ MyNetMate          | Dashboard สำหรับปฏิบัติงาน Network         |
| ดู Device Online/Offline             | ดูว่า Network Service ใช้งานได้จริงหรือไม่ |
| ดู Activity, Security และ API Status | ดู Port, Link, VLAN, Access/Trunk          |
| สรุปข้อมูลจาก Feature ที่มีใน P1     | แสดงข้อมูลที่วิศวกรใช้ Troubleshoot        |
| เน้นควบคุม Scope                     | เน้นคุณค่าเมื่อนำไปใช้งานจริง              |

## สิ่งที่อาจารย์กำลังพยายามผลัก

อาจารย์น่าจะต้องการให้ Dashboard ตอบคำถามว่า:

> “ระบบเครือข่ายกำลังให้บริการได้ตามที่ตั้งใจไว้หรือไม่?”

ไม่ใช่เพียง:

> “อุปกรณ์และเว็บแอปยังเปิดอยู่หรือไม่?”

นี่เป็นความแตกต่างระหว่าง:

- **System Dashboard:** MyNetMate API และ Database ทำงานหรือไม่
- **Network Operations Dashboard:** Switch, Port, Trunk และ VLAN ทำงานถูกต้องหรือไม่

## เหตุผลด้านคะแนนโครงงาน

ถ้า Dashboard มีเพียง:

- Total devices
- Online/Offline
- Recent activity
- API status

อาจารย์อาจมองว่าเป็น Dashboard ของ Web CRUD ทั่วไป เพราะระบบ Inventory, Server Management หรือ IoT ก็ทำแบบเดียวกันได้

แต่เมื่อเพิ่ม:

- Interface status
- Access/Trunk mode
- VLAN assignment
- Critical uplink
- Err-disabled port

Dashboard จะสะท้อนความรู้ด้าน Network Engineering โดยตรง และเชื่อมโยงกับ Config Builder ของ MyNetMate ชัดขึ้น

```
Config Builder
    ↓ สร้าง Access/Trunk/VLAN Config
Device
    ↓ ใช้งาน Config
Dashboard
    ↓ แสดงสถานะและค่าที่เกิดขึ้น
Security Validation
    ↓ ตรวจความปลอดภัย
```

กล่าวคืออาจารย์อาจมองว่าระบบไม่ควรแค่ “สร้าง Config” แต่ต้องสามารถ “สะท้อนผลของ Config” กลับมาให้ผู้ดูแลเห็นด้วย

## จุดต่างสำคัญ

แนวคิดเดิมของคุณมองจากข้อมูลที่ระบบมี:

```
มี devices → แสดงจำนวน Device
มี audit_logs → แสดง Activity
มี scan_results → แสดง Security
```

แนวคิดของอาจารย์มองจากงานที่ผู้ใช้ต้องทำ:

```
ผู้ใช้ Network ใช้งานไม่ได้
→ Switch ยัง Online หรือไม่?
→ Uplink ยัง Up หรือไม่?
→ Port อยู่ Access หรือ Trunk?
→ Port อยู่ VLAN ถูกต้องหรือไม่?
→ VLAN ถูก Allow ผ่าน Trunk หรือไม่?
```

อาจารย์จึงย้อนกลับมาบอกว่าระบบต้องมีข้อมูล Port และ VLAN

สรุปสั้นที่สุด:

> คุณออกแบบ Dashboard จากมุมมอง “ระบบมีข้อมูลอะไรอยู่แล้ว” แต่อาจารย์ออกแบบจากมุมมอง “วิศวกรต้องใช้อะไรแก้ปัญหาเครือข่ายจริง”

VLAN, Access/Trunk และ Port status จึงไม่ได้เป็นเพียง Widget เพิ่มเติม แต่เป็นข้อมูลที่เชื่อมระหว่าง Config ที่ระบบสร้างกับสภาพการทำงานจริงของ Network ครับ