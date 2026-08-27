Dashboard & Monitoring สามารถจัดกลุ่มได้หลายแบบ แต่สำหรับ MVP ควรแยกก่อนว่า:
- **Section** — แบ่งพื้นที่ของหน้า
- **Group** — รวมรายการที่มีลักษณะเดียวกัน
- **Filter** — จำกัดข้อมูลที่ต้องการดู
- **Sort** — เรียงสิ่งสำคัญก่อน
## กลุ่มหลักที่แนะนำบนหน้า Dashboard

### 1. Network Overview
ตอบว่า “ภาพรวมตอนนี้เป็นอย่างไร”

- Total Devices
- Reachable
- Unreachable
- Unknown
- Collection Failed
- Stale Data
- Last Successful Refresh

กลุ่มนี้ต้องแยก Reachability, Collection และ Freshness ออกจากกัน ไม่ควรรวมเป็น Online/Offline ค่าเดียว
### 2. Operational Problems
ตอบว่า “ตอนนี้ควรตรวจอะไรเป็นอันดับแรก”
แบ่งเป็น:

- Device Unreachable
- Collection Failed
- Stale Operational Data
- Critical Uplink/Trunk Down
- Err-disabled Port
- Critical WAN Down
- Missing Expected Default Route

ควรเรียง Critical ก่อน Warning และ Stale/Unknown

### 3. Switch Operations

ตอบว่า “ปัญหาใน Layer 2 อยู่ตรงไหน”
แสดง Summary เช่น:
- Switch Unreachable
- Critical Uplink/Trunk Down
- Err-disabled Port
- Switch Data Stale

เมื่อกดจึงเปิด Switch Detail เพื่อดู Interface, Access/Trunk และ VLAN

### 4. Router Operations

ตอบว่า “ปัญหา WAN หรือ Routing อยู่ตรงไหน”

แสดง Summary เช่น:

- Router Unreachable
- Critical WAN Down
- Missing Expected Default Route
- Routing Data Stale

เมื่อกดจึงเปิด Router Detail เพื่อดู Interface, IP/Prefix, Default Route, Next Hop และ Outgoing Interface

### 5. Security Summary

ตอบว่า “Configuration มีความเสี่ยงด้านความปลอดภัยหรือไม่”

- Critical Findings
- Warning Findings
- อุปกรณ์ที่เกี่ยวข้อง
- เวลาสแกนล่าสุด

ต้องแยกจาก Operational Problems เพราะ Network อาจทำงานปกติแต่ Configuration ยังไม่ปลอดภัย

### 6. Recent Activity

ตอบว่า “ก่อนหน้านี้มีใครทำอะไร”

- Refresh Operational Status
- เพิ่มหรือแก้ไข Device
- สร้าง Configuration
- สแกน CIS
- Override Finding
- User, Action, Target และ Timestamp

Activity ใช้สร้างลำดับเหตุการณ์ แต่ไม่ควรใช้ฟันธงว่าใครเป็นต้นเหตุ

### 7. System Health

ตอบว่า “ตัวระบบ MyNetMate พร้อมใช้งานหรือไม่”

- Backend
- Database
- Operational Collection
- AI/Offline Mode

System Health ต้องแยกจาก Network Health เช่น Database ล่มไม่ได้หมายความว่า Switch ล่ม และ Offline Mode ไม่ใช่ Critical Error

### 8. Quick Actions

รวมทางลัดตามสิทธิ์:

- Refresh Selected Device
- Open Device Inventory
- Open Config Builder
- Open Security Validation
- Open Audit Trail

---

## มิติที่ใช้จัดกลุ่มรายการได้

เมื่อแสดง Device หรือ Problem List สามารถจัดกลุ่มตามมิติเหล่านี้:

| จัดกลุ่มตาม       | ตัวอย่าง                         | เหมาะกับ               |
| ----------------- | -------------------------------- | ---------------------- |
| Site              | HQ, Branch A, Branch B           | หาพื้นที่ที่มีปัญหา    |
| Device Type       | Switch, Router                   | แยก Layer 2/Layer 3    |
| Reachability      | Reachable, Unreachable, Unknown  | ตรวจการเข้าถึง         |
| Collection Status | Success, Failed, Never Collected | ตรวจระบบเก็บข้อมูล     |
| Freshness         | Fresh, Stale, Unknown            | ตรวจความน่าเชื่อถือ    |
| Problem Type      | Uplink, WAN, Route, Err-disabled | เริ่ม Troubleshoot     |
| Severity          | Critical, Warning, Information   | จัดลำดับความสำคัญ      |
| Interface Role    | Uplink, Access, WAN, LAN         | แยกผลกระทบของ Port     |
| Device Role       | Core, Access, Edge, Internal     | แยกหน้าที่ของอุปกรณ์   |
| Tags              | Production, Lab, Critical        | การจัดกลุ่มแบบยืดหยุ่น |

## กลุ่มที่เหมาะกับ MVP จริง

ไม่จำเป็นต้องรองรับทุกแบบตั้งแต่แรก แนะนำให้มีเพียง:

1. Site
2. Device Type
3. Reachability
4. Collection Status
5. Freshness
6. Problem Type
7. Severity

ส่วน Interface Role และ Device Role ใช้ใน Detail และ Expected State ก่อน ยังไม่จำเป็นต้องเป็นตัวกรองหลักบน Dashboard

## Layout ที่แนะนำ

```
[Site Filter] [Last Refresh] [Refresh Selected Device]

[Unreachable] [Collection Failed] [Stale] [Critical Problems]

[Switch Problems]
- Critical Uplink Down
- Err-disabled

[Router Problems]
- Critical WAN Down
- Missing Expected Default Route

[Security Summary]       [System Health]

[Recent Activity]        [Quick Actions]
```

## สิ่งที่ไม่ควรรวมเป็นกลุ่มเดียวกัน

- Reachable กับ Operational Normal
- Unreachable กับ Collection Failed
- Stale กับ Current Data
- Access Port Down กับ Critical Uplink Down
- Security Finding กับ Operational Problem
- Network Health กับ MyNetMate System Health
- Actual State กับ Expected-State Deviation

ข้อเสนอที่เหมาะที่สุดสำหรับ MVP คือจัดหน้าตาม **Overview → Problems → Switch/Router → Security/System → Activity/Actions** และให้ Filter หลักเป็น **Site, Device Type, Status และ Severity** ครับ