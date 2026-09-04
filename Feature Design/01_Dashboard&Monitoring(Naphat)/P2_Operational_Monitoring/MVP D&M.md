# MyNetMate MVP — Dashboard & Monitoring

> **แนวทางล่าสุด:** Dashboard ต้องมี Switch และ Router Operational Visibility ในระดับ Current Operational Snapshot ที่ผู้ใช้สั่ง Refresh แบบ Read-only ไม่ใช่ระบบ Monitoring แบบต่อเนื่องหรือระดับ Enterprise

คำตอบตรงที่สุดคือ: **MVP ที่ตอบโจทย์วิศวกรเครือข่ายจริงควรมีทั้ง Switch และ Router Operational Visibility แต่ทำเป็น “Current Operational Snapshot” แบบเล็ก** ไม่ใช่ระบบ Monitoring เต็มรูปแบบ

Dashboard เดิมที่มีเพียงจำนวนอุปกรณ์, Security, Activity และ System Health ยังตอบได้แค่ว่า “ระบบมีอะไรเกิดขึ้น” แต่ยังตอบไม่ได้ว่า “เครือข่ายเสียตรงไหน”

# MyNetMate Dashboard & Monitoring — MVP Feature Scope

## 1. เป้าหมายของ MVP

Dashboard & Monitoring ของ MyNetMate เป็นระบบแสดง **Current Operational Snapshot** หรือภาพสถานะการทำงานล่าสุดของเครือข่าย ช่วยให้วิศวกรตอบได้ว่า:

- อุปกรณ์ใดติดต่อไม่ได้
- การเก็บข้อมูลจากอุปกรณ์สำเร็จหรือไม่
- Switch Interface, WAN และ Routing มีปัญหาที่ควรตรวจหรือไม่
- ข้อมูลที่แสดงใหม่เพียงใด
- ควรเปิดดู Device, Interface หรือข้อมูลใดต่อ
    

ระบบไม่ใช่ Enterprise Monitoring System และไม่เฝ้าตรวจสอบเครือข่ายอย่างต่อเนื่อง

---

## 2. Feature ที่อยู่ใน MVP

### F-01: Current Operational Snapshot

แสดงภาพสถานะล่าสุดของอุปกรณ์เครือข่ายที่ลงทะเบียนใน Device Inventory โดยระบุเวลาที่ข้อมูลถูกเก็บอย่างชัดเจน และไม่อ้างว่าเป็นข้อมูล Real-time

### F-02: Network Overview

สรุปภาพรวมของอุปกรณ์และข้อมูลปฏิบัติการ เช่น Reachable, Unreachable, Unknown, Collection Failed และ Stale เพื่อให้ผู้ใช้เห็นสถานการณ์เบื้องต้นจากหน้าเดียว

### F-03: Manual Operational Refresh

ให้ผู้ใช้เป็นผู้สั่ง `Refresh Operational Status` สำหรับอุปกรณ์ที่ต้องการตรวจ โดยเชื่อมต่อเฉพาะอุปกรณ์ที่ลงทะเบียนและอยู่ใน Allowlist พร้อมใช้คำสั่ง Read-only เท่านั้น

### F-04: Operational State Separation

แยกสถานะออกเป็นคนละมิติ ได้แก่:

- Reachability — ติดต่ออุปกรณ์ได้หรือไม่
    
- Collection Status — เก็บและแปลงข้อมูลสำเร็จหรือไม่
    
- Operational State — Interface, WAN หรือ Routing ทำงานอย่างไร
    
- Data Freshness — ข้อมูลยังใหม่หรือเก่าแล้ว
    

ระบบต้องไม่ใช้สถานะหนึ่งแทนความหมายของอีกสถานะหนึ่ง

### F-05: Operational Problem Summary

สรุปรายการปัญหาสำคัญที่ตรวจพบจาก Operational Snapshot และ Expected State ด้วยกฎที่แน่นอน โดยไม่ใช้ AI และไม่ฟันธงสาเหตุของปัญหา

ครอบคลุมปัญหาหลักในระดับ Feature ได้แก่:

- Device Unreachable
    
- Collection Failed
    
- Stale Operational Data
    
- Critical Switch Interface Problem
    
- Err-disabled Port
    
- Critical WAN Problem
    
- Missing Expected Default Route
    

### F-06: Switch Operational Visibility
	
	แสดงสถานะการทำงานของ Switch ทั้งในหน้า Dashboard Summary และหน้า Switch Detail เพื่อให้ผู้ใช้ตรวจสอบ Interface, Access/Trunk, VLAN และปัญหาของ Uplink ได้
	
	ระบบต้องแยก Access Port Down ทั่วไปออกจาก Critical Uplink หรือ Err-disabled Port เพื่อไม่แจ้งเตือนเกินจริง

### F-07: Router Operational Visibility

	แสดงสถานะการทำงานของ Router ทั้งในหน้า Dashboard Summary และหน้า Router Detail เพื่อให้ผู้ใช้ตรวจสอบ Layer 3 Interface, WAN และ Default Route ได้
	
	Reachability ของ Management IP ต้องไม่ถูกใช้เป็นหลักฐานว่า WAN และ Routing ทำงานปกติ

### F-08: Expected State and Criticality

	ให้ผู้ใช้กำหนดความคาดหวังของอุปกรณ์และ Interface ก่อนที่ระบบจะสรุปว่า Actual State ผิดปกติ
	Feature นี้ครอบคลุมแนวคิดระดับ Feature ได้แก่:
	
	- Interface Role
	- Critical Flag
	- Expected Interface State
	- Edge Router Expectation
	- Expected Network State
	    

หากไม่มี Expected State ระบบแสดงเฉพาะ Actual State และห้ามสรุปว่าเป็นความผิดปกติ

### F-09: Data Freshness and Last Known State
	
	แสดงเวลาที่เก็บข้อมูลสำเร็จล่าสุด สถานะ Stale และผลของ Collection Attempt ล่าสุด
	
	เมื่อ Collection รอบใหม่ล้มเหลว ระบบสามารถแสดง Last Known State เพื่ออ้างอิงได้ แต่ต้องติดป้ายว่าเป็นข้อมูลเก่าและห้ามแสดงเหมือนเป็นสถานะปัจจุบัน

### F-10: Operational Drill-down

	ให้ผู้ใช้กดจาก Summary หรือจำนวนปัญหาไปยังรายการ Device, Interface หรือ Route ที่เกี่ยวข้อง เพื่อเปิดดูหลักฐานและรายละเอียดต่อได้ทันที
	
	Dashboard ต้องไม่แสดง Port และ Route ทุกแถวบนหน้าหลัก แต่ใช้ Summary แล้ว Drill-down ไปดูรายละเอียด

### F-11: Security Summary

	แสดงจำนวน Critical Security Validation Findings จาก Security & Validation Feature โดย Dashboard อ่านและสรุปข้อมูลจากเจ้าของข้อมูล ไม่สร้างผลการตรวจความปลอดภัยเอง
	
	Operational Problem และ Security Finding ต้องแสดงแยกกัน เพราะเป็นปัญหาคนละประเภท

### F-12: Recent Activity and Audit Integration

	แสดงกิจกรรมล่าสุดจาก Audit Trail และบันทึกการ Refresh หรือการดำเนินการสำคัญของ D&M ลง Audit Trail
	
	Activity Feed ใช้ช่วยสร้างลำดับเหตุการณ์ แต่ไม่ใช่หลักฐานว่าผู้ใช้คนใดเป็นต้นเหตุของปัญหา

### F-13: System Health and Offline Mode Status

	แสดงความพร้อมของ Backend, Database และสถานะ Offline Mode เพื่อให้ผู้ใช้ทราบว่าระบบ MyNetMate พร้อมทำงานหรือไม่
	
	Offline Mode เป็นสถานะที่ผู้ใช้ตั้งใจเปิด ไม่ใช่ Critical Error

### F-14: Quick Actions

	มีทางลัดไปยัง Workflow สำคัญ เช่น Device Inventory, Config Builder, Security Validation และ Audit Trail โดยแสดงตามสิทธิ์ของผู้ใช้

---

## 3. ข้อกำหนดร่วมของทุก Feature

- Cisco IOS เป็น Baseline หลัก
- Huawei Router และ MikroTik Switch เป็น Candidate จนกว่าจะทดสอบจริง
- เชื่อมต่อเฉพาะอุปกรณ์ที่ลงทะเบียนใน Device Inventory
- เป้าหมายต้องอยู่ใน Allowlist
- ทดสอบเฉพาะ Isolated Lab
- Operational Refresh ใช้คำสั่ง Read-only
- ห้ามเข้า Configuration Mode
- ห้ามเปลี่ยน Configuration หรือ Restart Interface
- Refresh ต้องเกิดจากการกระทำของผู้ใช้
- การสรุปปัญหาใช้กฎที่ตรวจสอบย้อนกลับได้
- AI ไม่มีสิทธิ์ Refresh, สรุปสถานะ หรือสั่งอุปกรณ์
- การ Refresh และ Action สำคัญต้องบันทึกลง Audit Trail
- Dashboard ไม่สร้างตาราง `dashboard` เพื่อเก็บค่าที่คำนวณจากข้อมูลต้นทางได้
- ข้อมูลจาก Feature อื่นต้องใช้ผ่าน Dependency Contract
    

---

## 4. Feature ที่ยังไม่อยู่ใน MVP

Feature ต่อไปนี้มีประโยชน์ แต่ยังไม่รวมใน MVP รอบแรก:
- Switch Port/VLAN Aggregate Summary
- Full Static Route Snapshot
- Uptime Monitoring
- Current CPU/Memory Visibility
- Advanced Search and Filter
- Manual Next-hop Reachability Check
- Extended Expected VLAN Validation
- Last State Change
- Maintenance and Suppression
- Export Operational Report

Feature เหล่านี้เป็น Backlog หลัง MVP และจะพิจารณาอีกครั้งหลัง Feature หลักทำงานครบ

---

## 5. Future Enhancement

- Periodic หรือ Continuous Monitoring
- Historical Availability Graph
- Historical Bandwidth Graph
- Historical CPU/Memory Graph
- Time-series Monitoring
- Full SNMP Monitoring
- Email, LINE และ Alert Notification
- OSPF, EIGRP และ BGP Neighbor Monitoring
- Route Flap History
- NAT, VPN, QoS และ NetFlow Monitoring
- Streaming Telemetry
- Huawei และ MikroTik Operational Parser หลังผ่านการทดสอบจริง
    

---

## 6. Won’t Have

Feature ต่อไปนี้ไม่อยู่ในขอบเขตของ D&M:
- Automatic Root-cause Analysis
- AI วิเคราะห์และแก้ปัญหาอุปกรณ์อัตโนมัติ
- AI สั่ง Refresh หรือสั่งงานอุปกรณ์
- Automatic Configuration Change จาก Dashboard
- Network Scan นอก Isolated Lab หรือ Allowlist
- Complex Multi-vendor Policy
- การอ้างว่าเป็น Real-time Monitoring โดยไม่มี Continuous Collection
- Full Enterprise Network Monitoring System

---

## 7. ขอบเขตความรับผิดชอบ

| Dashboard & Monitoring ทำ                                | Dashboard & Monitoring ไม่ทำ                         |
| -------------------------------------------------------- | ---------------------------------------------------- |
| แสดง Current Operational Snapshot                        | อ้างว่าเป็น Real-time โดยไม่มีการเก็บข้อมูลต่อเนื่อง |
| แยก Reachability, Collection และ Operational State       | ใช้ Ping ผ่านแล้วสรุปว่าอุปกรณ์ปกติ                  |
| แสดงปัญหาที่มีกฎและหลักฐานรองรับ                         | ฟันธง Root Cause                                     |
| เปรียบเทียบกับ Expected State ที่ผู้ใช้กำหนด             | เดา Expected State                                   |
| ให้ผู้ใช้สั่ง Read-only Refresh                          | เปลี่ยน Configuration                                |
| แสดง Last Known State พร้อมคำเตือน                       | แสดงข้อมูลเก่าเหมือนเป็นข้อมูลปัจจุบัน               |
| เชื่อมไปยัง Device, Interface, Security และ Audit Detail | คัดลอกข้อมูลของ Feature อื่นมาเป็นเจ้าของ            |
| ใช้กฎตายตัวในการสรุปสถานะ                                | ใช้ AI ตัดสินสถานะเครือข่าย                          |

---

## 8. ข้อสรุป Feature-Level MVP

MVP ประกอบด้วย Feature หลัก 14 รายการ:
1. Current Operational Snapshot
2. Network Overview
3. Manual Operational Refresh
4. Operational State Separation
5. Operational Problem Summary
6. Switch Operational Visibility
7. Router Operational Visibility
8. Expected State and Criticality
9. Data Freshness and Last Known State
10. Operational Drill-down
11. Security Summary
12. Recent Activity and Audit Integration
13. System Health and Offline Mode Status
14. Quick Actions
    

Feature เพิ่มเติมทั้ง 6 รายการจากเอกสารเดิม ได้แก่ Operational Problem Summary, Manual Refresh แบบเลือกอุปกรณ์, การแยกสถานะ, Interface Role/Critical Flag, Edge Router Expectation และ Drill-down ถูกนำเข้า MVP ทั้งหมด โดยรวม Interface Role และ Edge Router Expectation ไว้ภายใต้ Feature Expected State and Criticality


# ตัวอย่างสภาพแวดล้อมบริษัทขนาดเล็ก–กลาง

สมมติบริษัทมีพนักงานประมาณ 80 คน ใช้งานอุปกรณ์ดังนี้:

- Router 1 ตัวเชื่อมต่ออินเทอร์เน็ต
- Core Switch 1 ตัว
- Access Switch 2 ตัวสำหรับชั้นสำนักงาน
- VLAN 10 สำหรับพนักงานทั่วไป
- VLAN 20 สำหรับฝ่ายบัญชี
- VLAN 30 สำหรับ Server
- VLAN 99 สำหรับ Management
- อุปกรณ์ทุกตัวถูกลงทะเบียนใน Device Inventory และมี Credential สำหรับคำสั่ง Read-only

MyNetMate ไม่ต้องเฝ้าตรวจสอบตลอดเวลา วิศวกรเปิด Dashboard แล้วกด `Refresh Operational Status` เพื่อเก็บ Snapshot ล่าสุดจากอุปกรณ์ใน Isolated Lab หรือเครือข่ายที่ได้รับอนุญาต

## เหตุการณ์จำลองที่ 1 — พนักงานทั้งชั้นใช้งานเครือข่ายไม่ได้

### สิ่งที่เกิดขึ้นจริง

สาย Uplink ระหว่าง Core Switch กับ Access Switch ชั้น 2 หลุด แต่ Core Switch และ Router ยังทำงานตามปกติ

### ถ้ามี Dashboard แบบเดิม

Dashboard อาจแสดงเพียงว่า Access Switch ติดต่อไม่ได้ วิศวกรยังต้องเข้าอุปกรณ์หลายตัวเพื่อค้นหาว่าปัญหาเกิดที่สาย Port หรืออุปกรณ์

### สิ่งที่ Dashboard MVP แสดง

```text
Network Overview
├─ Router: Reachable
├─ Core Switch: Reachable
├─ Access Switch ชั้น 2: Unreachable
└─ Critical Interface: CORE-SW Gi0/24 — Admin Up / Oper Down
   Description: Uplink to FLOOR2-SW
   Last collected: 10:04
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

วิศวกรเห็นว่า Core Switch ยังติดต่อได้ แต่ Port ที่ผู้ใช้กำหนดเป็น `uplink` มีสถานะ Admin Up และ Operational Down จึงจำกัดพื้นที่ตรวจสอบไปที่สาย Uplink, SFP หรือ Access Switch ชั้น 2 ได้ทันที

ระบบยังไม่ควรสรุปว่า “สายเสียแน่นอน” เพราะอาจเกิดจากปลายทางปิดอยู่หรือ SFP มีปัญหา ระบบควรระบุเพียงว่า **Critical Uplink ไม่สามารถทำงานได้ตามสถานะที่คาดหวัง**

## เหตุการณ์จำลองที่ 2 — คอมพิวเตอร์ฝ่ายบัญชีต่อ Network ได้แต่เข้า Server ไม่ได้

### สิ่งที่เกิดขึ้นจริง

Port ของคอมพิวเตอร์ฝ่ายบัญชีถูกตั้งเป็น Access VLAN 10 แทน VLAN 20 หลังมีการย้ายโต๊ะ

### สิ่งที่ Dashboard และ Switch Detail แสดง

```text
Interface: Gi0/12
Admin: Up
Operational: Up
Mode: Access
Actual VLAN: 10
Description: ACC-PC-07
Expected VLAN: 20
Assessment: VLAN differs from expected state
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

กรณีนี้ Device และ Port ยังเป็นสีเขียวหากดูเฉพาะ Up/Down แต่ผู้ใช้ยังเข้า Resource ของฝ่ายบัญชีไม่ได้ การแสดง Mode และ VLAN จึงช่วยแยกปัญหา Layer 2 Configuration ออกจากปัญหาสาย

อย่างไรก็ตาม ระบบจะแจ้งว่า VLAN ผิดได้ต่อเมื่อผู้ใช้กำหนด `Expected VLAN` ไว้ก่อน หากไม่มี Expected State ระบบต้องแสดงเพียง Actual VLAN และห้ามสรุปเองว่า VLAN 10 ผิด

ดังนั้น Expected VLAN เป็น **Should Have ที่มีคุณค่าสูง** แต่ไม่ควรบังคับใช้กับทุก Port ใน MVP รุ่นแรก

## เหตุการณ์จำลองที่ 3 — บริษัทใช้อินเทอร์เน็ตไม่ได้ แต่ Router ยัง Ping ได้

### สิ่งที่เกิดขึ้นจริง

LAN Interface และ Management IP ของ Router ยังทำงาน แต่ WAN Interface ที่เชื่อมกับผู้ให้บริการมีสถานะ Protocol Down

### สิ่งที่ Dashboard MVP แสดง

```text
Router: EDGE-R01 — Reachable
WAN Gi0/1: Admin Up / Protocol Down
Default Route: Inactive via Gi0/1
Last collected: 10:12
Severity: Critical
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

Ping ไปยัง Management IP สำเร็จบอกเพียงว่า Router ยังเข้าถึงได้จาก LAN ไม่ได้แปลว่าเส้นทางออกอินเทอร์เน็ตปกติ การแยก WAN Status และ Default Route ทำให้วิศวกรเลือกตรวจสาย WAN, อุปกรณ์ของ Provider หรือสถานะวงจรเชื่อมต่อก่อนแก้ LAN

ระบบไม่ควรสรุปว่า Provider ล่ม เพราะข้อมูลที่มีพิสูจน์ได้เพียง WAN Protocol Down และ Default Route ใช้งานไม่ได้

## เหตุการณ์จำลองที่ 4 — WAN Up แต่ไม่มีเส้นทางออกจากบริษัท

### สิ่งที่เกิดขึ้นจริง

WAN Interface เป็น Up/Up แต่ Default Route ถูกลบหรือไม่ถูกติดตั้งใน Routing Table

### สิ่งที่ Dashboard MVP แสดง

```text
Router: EDGE-R01 — Reachable
WAN Gi0/1: Up / Up
Expected Default Route: Required
Active Default Route: Not found
Assessment: Missing expected default route
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

วิศวกรสามารถแยกได้ว่าปัญหาไม่ได้อยู่ที่สถานะสาย แต่ควรตรวจ Routing Configuration หรือ Next Hop

คำเตือนนี้ต้องใช้ Expected State เช่น `requires_default_route = true` หรือระบุว่าอุปกรณ์เป็น `edge_router` เพราะ Router ภายในบางตัวอาจตั้งใจไม่มี Default Route หากไม่มีเงื่อนไขดังกล่าว ระบบต้องแสดง Routing Snapshot โดยไม่กล่าวว่าเป็นความผิดปกติ

## เหตุการณ์จำลองที่ 5 — Dashboard แสดงค่าปกติ แต่ข้อมูลเก่าแล้ว

### สิ่งที่เกิดขึ้นจริง

Snapshot ล่าสุดเก็บเมื่อสองชั่วโมงก่อน แต่การ Refresh รอบใหม่เชื่อมต่อ SSH ไม่สำเร็จ

### สิ่งที่ Dashboard MVP แสดง

```text
Last successful collection: 08:15
Latest collection attempt: 10:15 — Failed
Freshness: Stale
Displayed state: Last known state
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

หาก Dashboard แสดงค่าเดิมเป็นสีเขียวโดยไม่บอกเวลา วิศวกรอาจเชื่อว่า Network ยังปกติ ทั้งที่ระบบไม่มีข้อมูลล่าสุด ดังนั้น `Reachability`, `Collection Status` และ `Data Freshness` ต้องเป็นคนละค่า

ระบบควรเก็บ Snapshot เดิมไว้เพื่ออ้างอิง แต่ต้องติดป้ายว่าเป็น `Last known state` และห้ามเปลี่ยนเป็น Offline เพียงเพราะ SSH Collection ล้มเหลว เพราะอาจเกิดจาก Credential, Timeout หรือ SSH Service ไม่พร้อม

## เหตุการณ์จำลองที่ 6 — ตรวจสอบสิ่งที่เกิดขึ้นก่อนเริ่มมีปัญหา

### สิ่งที่เกิดขึ้นจริง

หลังผู้ใช้สร้าง Configuration หรือดำเนิน Workflow กับ Switch แล้ว VLAN ที่ใช้งานมีปัญหา

### สิ่งที่ Dashboard MVP แสดง

Recent Activity แสดงว่า:

```text
09:42 Operator-A generated configuration for FLOOR2-SW
09:45 Operator-A ran security validation
10:02 Admin-B refreshed operational status
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

Audit Trail ช่วยสร้างลำดับเหตุการณ์ให้วิศวกรรู้ว่าควรเปิดดู Configuration, Validation Result หรือ Snapshot ใดต่อ แต่ Activity Feed ไม่ใช่หลักฐานว่าผู้ใช้คนนั้นเป็นต้นเหตุ และ Dashboard ไม่ควรทำ Automatic Root-cause Analysis

## เหตุการณ์จำลองที่ 7 — อุปกรณ์ยัง Ping ได้ แต่เก็บข้อมูล Operational ไม่สำเร็จ

### สิ่งที่เกิดขึ้นจริง

Core Switch ยังตอบ Ping ผ่าน Management IP แต่รหัสผ่านของบัญชี Read-only ถูกเปลี่ยน ทำให้ MyNetMate เชื่อมต่อ SSH เพื่ออ่านสถานะ Interface ไม่สำเร็จ

### สิ่งที่ Dashboard MVP แสดง

```text
Device: CORE-SW-01
Reachability: Reachable
Collection Status: Failed — Authentication failed
Latest collection attempt: 10:30
Last successful collection: 09:45
Displayed operational data: Last known state
Freshness: Stale
```

Dashboard มี Quick Action ไปยัง Device Inventory เพื่อให้ผู้มีสิทธิ์ตรวจสอบ Credential Profile ของอุปกรณ์ โดยไม่แสดงรหัสผ่านบน Dashboard

### เหตุผลที่ข้อมูลนี้มีประโยชน์

กรณีนี้พิสูจน์ว่า Reachability และ Collection Status ต้องแยกจากกัน หากระบบใช้คำว่า Online เพียงค่าเดียว ผู้ใช้อาจเข้าใจผิดว่าข้อมูล Interface ที่แสดงเป็นข้อมูลใหม่ ทั้งที่ระบบอ่านข้อมูลจากอุปกรณ์ไม่ได้แล้ว

ระบบต้องรักษา Last Known State ไว้พร้อมคำเตือน และบันทึก Refresh ที่ล้มเหลวลง Audit Trail โดยห้ามสรุปว่า Switch หรือ Interface เปลี่ยนเป็น Down จากความล้มเหลวของการเชื่อมต่อ SSH

## เหตุการณ์จำลองที่ 8 — Switch ติดต่อได้ แต่ Port สำคัญเป็น Err-disabled

### สิ่งที่เกิดขึ้นจริง

Access Switch ยัง Reachable และ Uplink ยังทำงาน แต่ Port `Gi0/8` ที่ต่อกับอุปกรณ์สำคัญถูก Switch เปลี่ยนเป็นสถานะ Err-disabled

### สิ่งที่ Dashboard MVP แสดง

```text
Switch: FLOOR1-SW — Reachable
Operational Problem: Err-disabled port — 1
Interface: Gi0/8
Admin: Up
Operational: Err-disabled
Description: Finance Printer
Last collected: 10:36
```

ผู้ใช้กดรายการ Err-disabled จาก Operational Problem Summary เพื่อ Drill-down ไปยัง Interface Detail ที่เกี่ยวข้อง

### เหตุผลที่ข้อมูลนี้มีประโยชน์

Dashboard ที่ดูเพียง Device Reachability จะยังแสดง Switch เป็นสีเขียว ทั้งที่บริการบางส่วนใช้งานไม่ได้ การแสดง Err-disabled ช่วยระบุ Interface ที่ควรตรวจโดยตรง

อย่างไรก็ตาม ระบบต้องไม่เดาว่าสาเหตุเกิดจาก Port Security, BPDU Guard หรือ Link Flap หากข้อมูลที่เก็บมายังพิสูจน์ไม่ได้ และต้องไม่ส่งคำสั่งเปิด Port กลับอัตโนมัติ

## เหตุการณ์จำลองที่ 9 — อุปกรณ์ใหม่ยังไม่มี Operational Snapshot

### สิ่งที่เกิดขึ้นจริง

ผู้ใช้เพิ่ม Access Switch ตัวใหม่ใน Device Inventory แล้ว แต่ยังไม่เคยสั่งเก็บข้อมูล Operational และระบบไม่มี Snapshot เดิมสำหรับอุปกรณ์นี้

### สิ่งที่ Dashboard MVP แสดง

```text
Device: FLOOR3-SW
Reachability: Unknown
Collection Status: Never collected
Operational State: Unknown
Last collected: Never
Available action: Refresh Operational Status
```

ผู้ใช้เลือก Refresh เฉพาะ `FLOOR3-SW` โดยไม่ต้องเก็บข้อมูลใหม่จากอุปกรณ์ทุกตัวในบริษัท

### เหตุผลที่ข้อมูลนี้มีประโยชน์

ค่า Unknown ช่วยแยกกรณี “ยังไม่มีหลักฐาน” ออกจาก Unreachable หรือ Collection Failed และ Manual Refresh แบบเลือกอุปกรณ์ช่วยลดเวลารอและปริมาณการเชื่อมต่อโดยไม่ต้องสร้าง Scheduled Polling

หลัง Refresh ระบบต้องบันทึกว่าใครเป็นผู้เริ่มดำเนินการ เมื่อใด และผลสำเร็จหรือล้มเหลวลง Audit Trail

## เหตุการณ์จำลองที่ 10 — Router ภายในไม่มี Default Route โดยตั้งใจ

### สิ่งที่เกิดขึ้นจริง

บริษัทมี Internal Router สำหรับเชื่อมเฉพาะ VLAN ภายใน Router ตัวนี้ใช้ Route เฉพาะและไม่ควรมี Default Route ขณะที่ Edge Router ที่เชื่อมอินเทอร์เน็ตต้องมี Default Route

### สิ่งที่ Dashboard MVP แสดง

```text
Device: INTERNAL-R01
Role: Internal Router
Requires default route: No
Active default route: Not found
Assessment: Actual state only — no problem reported

Device: EDGE-R01
Role: Edge Router
Requires default route: Yes
Active default route: Present
Assessment: Meets expected state
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

หากระบบแจ้งเตือน Router ทุกตัวที่ไม่มี Default Route จะเกิด False Positive หรือคำเตือนผิดจำนวนมาก Edge Router Expectation จึงจำเป็นต่อการบอกว่ากรณีใดเป็นปัญหา โดยระบบต้องไม่เดาบทบาทของ Router เองเมื่อไม่มี Expected State

## เหตุการณ์จำลองที่ 11 — Network ทำงานปกติ แต่ Configuration มี Critical Security Finding

### สิ่งที่เกิดขึ้นจริง

Switch ทุกตัว Reachable, Uplink ทำงาน และไม่มี Err-disabled Port แต่ผล CIS Scan ล่าสุดพบว่าอุปกรณ์หนึ่งยังเปิด Telnet หรือไม่มี `enable secret` ตามกฎที่โครงการกำหนด

### สิ่งที่ Dashboard MVP แสดง

```text
Operational Problems: 0
Critical Security Findings: 1
Affected device: FLOOR1-SW
Operational state: No current operational problem detected
```

ผู้ใช้กด Security Summary หรือ Quick Action เพื่อเปิด Security Validation Detail และดูหลักฐานของกฎที่ไม่ผ่าน

### เหตุผลที่ข้อมูลนี้มีประโยชน์

Operational State และ Security Compliance เป็นข้อมูลคนละประเภท อุปกรณ์สามารถให้บริการได้ตามปกติแต่ยังมีความเสี่ยงด้านความปลอดภัย Dashboard จึงต้องแยก Security Summary จาก Operational Problem Summary และห้ามใช้คำว่า “Network ปลอดภัย” เพียงเพราะไม่พบปัญหาการทำงาน

## เหตุการณ์จำลองที่ 12 — ระบบอยู่ใน Offline Mode โดยตั้งใจ

### สิ่งที่เกิดขึ้นจริง

ผู้ดูแลเปิด Offline Mode หรือ Gemini API ไม่ถูกใช้งานในช่วงสาธิต แต่ Backend, Database และ Read-only Operational Collection ของ MyNetMate ยังพร้อมทำงาน

### สิ่งที่ Dashboard MVP แสดง

```text
Backend: Available
Database: Available
Operational Collection: Available
AI Mode: Offline — configured by administrator
Impact on Operational Snapshot: None
```

### เหตุผลที่ข้อมูลนี้มีประโยชน์

Offline Mode เป็นสถานะที่ผู้ดูแลตั้งใจเลือก ไม่ใช่เหตุขัดข้องของเครือข่ายหรือ Critical System Error การแสดง System Health แยกเป็นราย Component ทำให้ผู้ใช้รู้ว่า Feature แบบ Deterministic เช่น Refresh, Snapshot และ Operational Problem Summary ยังใช้งานได้โดยไม่พึ่ง AI

## ข้อสรุปจากสถานการณ์จำลอง

Dashboard ที่มีประโยชน์ต่อวิศวกรไม่ควรบอกเพียงว่า “มีอุปกรณ์ Online กี่ตัว” แต่ควรช่วยจำกัดพื้นที่ของปัญหา:

| คำถามของวิศวกร                                     | ข้อมูลขั้นต่ำที่ใช้ตอบ                            |
| -------------------------------------------------- | ------------------------------------------------- |
| อุปกรณ์เข้าถึงได้หรือไม่?                          | Reachability และเวลาตรวจล่าสุด                    |
| เก็บข้อมูลจากอุปกรณ์สำเร็จหรือไม่?                 | Collection Status และ Error Summary               |
| ปัญหาอยู่ที่ Switch Uplink หรือ Access Port?       | Interface Role, Admin/Oper Status และ Description |
| Port อยู่ VLAN ใด?                                 | Mode, Access VLAN, Native/Allowed VLAN            |
| Router ยังมีทางออกหรือไม่?                         | WAN Status และ Active Default Route               |
| ข้อมูลยังเชื่อถือได้หรือไม่?                       | Last Collected และ Stale State                    |
| ก่อนเกิดเหตุมีการดำเนินการอะไร?                    | Recent Activity และ Audit Trail                   |
| อุปกรณ์ Ping ได้แต่ระบบอ่านข้อมูลไม่ได้หรือไม่?    | Reachability แยกจาก Collection Status             |
| ยังไม่มีข้อมูลหรือเก็บข้อมูลล้มเหลว?               | Unknown/Never Collected แยกจาก Collection Failed  |
| Port ใดถูกอุปกรณ์ปิดเพราะความผิดปกติ?              | Err-disabled และ Interface Detail                 |
| การไม่มี Default Route เป็นความผิดปกติจริงหรือไม่? | Edge Router Expectation และ Expected State        |
| Network ทำงานแต่ยังมีความเสี่ยง Security หรือไม่?  | Security Summary แยกจาก Operational Problems      |
| MyNetMate ส่วนใดพร้อมใช้งาน?                       | System Health และ Offline Mode Status             |

หลักสำคัญคือ Dashboard ทำหน้าที่ **ชี้ตำแหน่งและหลักฐานเบื้องต้น** ไม่ได้ฟันธง Root Cause และไม่ได้แก้ Configuration ให้อัตโนมัติ

## Feature Coverage จากเหตุการณ์จำลอง

| Feature ใน MVP                              | เหตุการณ์ที่ใช้ยืนยันความจำเป็น |
| ------------------------------------------- | ------------------------------- |
| Current Operational Snapshot               | 1–12                            |
| Network Overview                            | 1, 3, 5, 7, 8, 9, 11, 12       |
| Manual Operational Refresh                  | 5, 7, 9                         |
| Operational State Separation                | 3, 5, 7, 9, 11, 12              |
| Operational Problem Summary                 | 1, 3, 4, 5, 8                   |
| Switch Operational Visibility               | 1, 2, 8                         |
| Router Operational Visibility               | 3, 4, 10                        |
| Expected State and Criticality              | 1, 2, 4, 10                     |
| Data Freshness and Last Known State         | 5, 7, 9                         |
| Operational Drill-down                      | 1, 2, 8, 11                     |
| Security Summary                            | 6, 11                           |
| Recent Activity and Audit Integration       | 6, 7, 9                         |
| System Health and Offline Mode Status       | 12                              |
| Quick Actions                               | 7, 11                           |
