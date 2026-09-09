สิ่งที่ขาดไม่ใช่ Metric จำนวนมากขึ้น สิ่งที่ยังมองข้ามคือความสามารถ 3 ด้าน:

1. Dashboard ต้องรู้ว่า “อะไรสำคัญ”
2. ผู้ใช้ต้องเชื่อได้ว่าข้อมูลถูกเก็บสำเร็จ
3. ผู้ใช้ต้องรู้ว่าควรทำอะไรต่อ

รายการปัจจุบันของคุณมี “ข้อมูล” ค่อนข้างครบแล้ว แต่ควรเติมองค์ประกอบต่อไปนี้เพื่อให้เป็น MVP ที่ใช้งานจริงได้
## 1. Critical Issues / Action Center — ควรเป็น Must-have

ปัจจุบันคุณมีหลาย Summary Card แต่ผู้ใช้ยังต้องไล่ตีความเอง ควรมีรายการ “ปัญหาที่ต้องจัดการตอนนี้” รวมไว้จุดเดียว

ตัวอย่าง:

|Severity|ปัญหา|อุปกรณ์|เกิดตั้งแต่|Action|
|---|---|---|---|---|
|Critical|WAN interface down|RTR-HQ-01|8 นาที|View router|
|Critical|Trunk uplink down|SW-F2-01|3 นาที|View interface|
|Critical|Port err-disabled|SW-F1-01 Gi0/12|20 นาที|View interface|
|Critical|CIS rule failed|RTR-HQ-01|1 ชั่วโมง|View validation|
|Warning|ข้อมูลเกิน 10 นาที|SW-F3-01|12 นาที|Refresh|

ประโยชน์คือวิศวกรไม่ต้องเปิด Device, Switch, Router และ Security Card ทีละส่วน

Cisco Catalyst Center เองจัด Issue ด้วย Severity, Entity, Impact และ Suggested Actions ซึ่งสนับสนุนแนวคิดว่า Dashboard ควรพาผู้ใช้จาก “พบปัญหา” ไปสู่ “ดำเนินการต่อ” [Cisco Issue Enrichment](https://developer.cisco.com/docs/catalyst-center/get-issue-enrichment-details/)

สำหรับ P1 ไม่ต้องสร้าง Incident Management เต็มรูปแบบ สามารถ Aggregate ปัญหาจากสถานะปัจจุบันโดยตรงได้

## 2. Data Collection Health — สำคัญมากและมักถูกมองข้าม

ต้องแยกสามกรณีนี้ออกจากกัน:

```
Device Offline
≠ SSH Authentication Failed
≠ Collector/Parser Failed
```

ตัวอย่าง:

|Collection Result|ความหมาย|
|---|---|
|`success`|เก็บข้อมูลสำเร็จ|
|`device_unreachable`|ติดต่อ Management IP ไม่ได้|
|`auth_failed`|อุปกรณ์ตอบ แต่ Credential ผิด|
|`timeout`|เชื่อมต่อหรือรอคำสั่งนานเกินไป|
|`command_unsupported`|IOS รุ่นนี้ไม่มีคำสั่งดังกล่าว|
|`parse_failed`|ได้ CLI output แต่ Parser อ่านไม่ได้|
|`never_collected`|ยังไม่เคยเก็บข้อมูล|

ถ้าไม่มีข้อมูลนี้ ระบบอาจแสดง Router เป็น Unknown ทั้งที่จริง Router ปกติแต่ Password ผิด ทำให้วิศวกรวิเคราะห์ผิดทาง

อย่างน้อยควรเก็บ:

```
collection_status
last_attempted_at
last_successful_at
collection_error_code
collection_error_message
```

Zabbix ก็แยก Available, Not available, Mixed และ Unknown พร้อมแสดงรายละเอียด Error ของ Interface เพราะ Unknown ไม่ได้แปลว่าอุปกรณ์เสียเสมอไป [Zabbix Host Availability](https://www.zabbix.com/documentation/current/en/manual/web_interface/frontend_sections/data_collection/hosts?s%5B%5D=availability)

## 3. Expected State / Monitoring Intent — จุดที่สำคัญที่สุด

การรู้สถานะจริงอย่างเดียวยังไม่พอ ระบบต้องรู้ด้วยว่า “สิ่งที่ควรเป็น” คืออะไร

ตัวอย่าง:

```
Observed:
Gi0/1 = Access VLAN 20
```

ข้อมูลนี้ยังบอกไม่ได้ว่าผิด เพราะระบบไม่รู้ว่า Gi0/1 ควรอยู่ VLAN ใด

ต้องมี:

```
Expected:
Gi0/1 = Access VLAN 10

Observed:
Gi0/1 = Access VLAN 20

Result:
VLAN mismatch
```

กรณี Router ก็เหมือนกัน:

```
Observed: ไม่มี Default Route
```

จะสรุปว่า Critical ไม่ได้ หาก Router ตัวนั้นออกแบบมาให้ใช้เฉพาะ Internal Routes

จึงควรมี Monitoring Intent ขั้นต่ำ:

```
device_criticality        // critical, normal, lab
interface_role            // wan, lan, uplink, access, management
monitoring_enabled
expected_oper_status      // up/down
expected_switchport_mode  // access/trunk
expected_access_vlan
expects_default_route
```

ตัวอย่างการตัดสิน Severity:

```
Trunk Down
+ interface_role = uplink
+ expected_oper_status = up
→ Critical
```

NetBox แยก “Intended state” ออกจาก “Actual operational state” เพื่อให้ตรวจจับ Drift ได้อย่างมีความหมาย [NetBox Intended vs Operational State](https://netboxlabs.com/docs/learn/)

สำหรับ P1 ไม่ต้องทำ Config Drift ทั้งระบบ ให้รองรับเฉพาะสิ่งสำคัญ:

- Expected Up/Down
- Interface role
- Criticality
- Expected Access/Trunk
- Expected VLAN
- Router expects Default Route หรือไม่

## 4. “Down Since” หรือเวลาที่สถานะเปลี่ยน

`last_checked_at` บอกว่าตรวจเมื่อใด แต่ไม่บอกว่าปัญหาเริ่มเมื่อใด

ควรมีทั้ง:

```
last_checked_at
status_changed_at
```

ตัวอย่าง:

```
Status: Offline
Down since: 10:32
Last checked: 10:40
```

ประโยชน์:

- รู้ว่าปัญหาเกิดมานานแค่ไหน
- เทียบกับ Recent Activity ได้
- ช่วยหาว่าปัญหาเกิดหลังใครแก้ Config หรือไม่
- ไม่ต้องสร้าง Historical Time-series เต็มรูปแบบ

P1 เก็บเพียงเวลาที่ State เปลี่ยน ไม่ต้องเก็บทุก Poll

## 5. Maintenance/Suppression ที่มีเหตุผลและวันหมดอายุ

คุณมีสถานะ `Maintenance` แล้ว แต่ต้องตอบได้ว่า:

- ใครตั้ง Maintenance?
- เพราะอะไร?
- เริ่มและสิ้นสุดเมื่อใด?
- ยังเก็บข้อมูลระหว่าง Maintenance หรือไม่?

ขั้นต่ำควรมี:

```
maintenance_reason
maintenance_started_at
maintenance_until
maintenance_created_by
```

Dashboard ต้องไม่เอาอุปกรณ์ที่กำลัง Maintenance มาปนกับ Offline จริง แต่ยังควรเปิดให้ผู้ใช้เลือกดูได้

ระบบ Monitoring จริงใช้ Maintenance เพื่อระงับปัญหาในช่วงเวลาที่กำหนด ลด False alarm และ Alert fatigue [Zabbix Maintenance](https://www.zabbix.com/documentation/7.0/en/manual/maintenance)

## 6. Filter, Search และ Drill-down

นี่ไม่ใช่ Widget แต่จำเป็นต่อการใช้งานจริง

ควร Filter ได้อย่างน้อย:

- Site
- Device type: Switch/Router
- Status
- Severity
- Vendor
- Maintenance
- Stale data

และทุก Summary ต้องกดลงรายละเอียดได้:

```
“2 Trunks Down”
→ เปิด Interface List
→ Filter mode=trunk, status=down
```

หาก Dashboard แสดงจำนวนแต่กดไปหาต้นเหตุไม่ได้ ข้อมูลนั้นมีประโยชน์จำกัดมาก

## ชุด MVP ที่แนะนำหลังเติมส่วนที่ขาด

### ส่วนสรุป

- Device status
- Switch operational summary
- Router operational summary
- Critical Validation Failures
- Data freshness
- System health

### ส่วน Action

- Critical Issues/Action Center
- Filter/Search
- Drill-down links
- Manual Refresh
- Maintenance control ตาม RBAC

### ส่วนความน่าเชื่อถือของข้อมูล

- Last attempted
- Last successful
- Collection status/error
- Status changed at
- Expected vs Observed state ขั้นต่ำ

### ส่วนตรวจสอบย้อนหลัง

- Recent Activity Feed
- Maintenance reason
- การเปลี่ยน Expected State
- การ Refresh/Collection ที่ล้มเหลว

## สิ่งที่ยังไม่ควรเพิ่ม

- Bandwidth/Traffic graphs
- CPU/Memory history
- Email/LINE alerts
- AI root-cause analysis
- Full configuration drift
- Automatic topology
- Routing protocol history
- SLA reporting
- Customizable dashboard
- Acknowledge/assign/close Incident workflow เต็มรูปแบบ

## ลำดับความสำคัญ

ถ้าต้องเลือกเฉพาะสิ่งที่สำคัญที่สุด ผมจัดดังนี้:

1. **Collection Health/Error Reason**
2. **Monitoring Intent และ Criticality**
3. **Critical Issues/Action Center**
4. **Status Changed At/Down Since**
5. **Filter และ Drill-down**
6. **Maintenance พร้อม Reason/Expiry**

สรุปคือ Dashboard ของคุณไม่ได้ขาด Switch หรือ Router Metric มากนักแล้ว สิ่งที่ขาดคือบริบทที่จะทำให้ Metric เหล่านั้น “เชื่อถือได้ ตีความได้ และลงมือแก้ไขต่อได้” ซึ่งเป็นสิ่งที่แยก Dashboard สำหรับ Demo ออกจาก Dashboard ที่นำไปใช้งานจริงครับ