Router เป็นจุดเชื่อมระหว่าง Network/Subnet ส่วน Switch ดูแลการเชื่อมต่อภายใน Layer 2

ถ้า Switch Operational Visibility ตอบว่า:

> “Port และ VLAN ภายใน LAN ทำงานถูกต้องหรือไม่?”

Router Operational Visibility ควรตอบว่า:

> “Interface และเส้นทาง Layer 3 ยังส่ง Traffic ไปยัง Network อื่นได้หรือไม่?”
> 
## Switch กับ Router ต้องดูคนละอย่าง

| Switch Visibility          | Router Visibility               |
| -------------------------- | ------------------------------- |
| Access/Trunk mode          | WAN/LAN interface               |
| Access/Native/Allowed VLAN | IP address และ subnet           |
| Port Up/Down               | Interface Status/Protocol       |
| Err-disabled               | Default route                   |
| Critical Uplink            | Next hop และ outgoing interface |
| VLAN mismatch              | Static route ที่ Active         |
| Layer 2 Link               | Layer 3 Reachability            |


ทั้งสองใช้งานตาราง `interfaces` ร่วมกันได้ แต่ Router ต้องมีข้อมูล IP และ Routing เพิ่มเติม

## ทำไมดูแค่ Router Online ไม่พอ

### กรณี Router Online แต่ WAN Down

```
Router Management IP: Online
LAN Interface:         Up/Up
WAN Interface:         Down/Down
Default Route:         ผ่าน WAN
```

Dashboard เดิมอาจแสดง Router สีเขียว เพราะ Management IP ยัง Ping ได้จาก LAN แต่ผู้ใช้ออก Internet หรือเชื่อมสาขาไม่ได้

ประโยชน์ของ WAN Interface Status คือทำให้รู้ทันทีว่า:

- Router ยังทำงานอยู่
- ปัญหาไม่ได้อยู่ที่ตัวเครื่องทั้งหมด
- ปัญหาอยู่ที่ WAN Link หรือ Provider

### กรณี Interface Up แต่ไม่มี Default Route

```
GigabitEthernet0/0: Up/Up
GigabitEthernet0/1: Up/Up
Default route:      Missing
```

สายและ Interface ปกติ แต่ Router ไม่รู้ว่าจะส่ง Traffic ที่ไม่มี Route เฉพาะไปทางใด ผู้ใช้จึงอาจออก Internet ไม่ได้

ประโยชน์ของ Default Route Visibility คือช่วยแยกว่า:

- ปัญหาอยู่ที่ Link
- หรือปัญหาอยู่ที่ Routing Configuration

### กรณี Static Route ชี้ไป Interface ที่ Down

```
Route: 10.20.0.0/16
Next hop: 192.168.1.2
Outgoing interface: Gi0/1
Gi0/1 status: Down
```

ระบบควรเชื่อมข้อมูล Route กับ Interface เพื่อแสดงว่า Route นี้อาจใช้งานไม่ได้

## Router MVP ควรแสดงอะไร

### หน้า Dashboard หลัก

แสดงเป็น Summary เท่านั้น:

- Routers Online/Offline/Unknown
- WAN Interfaces Down
- Routers ที่ไม่มี Active Default Route
- Critical Layer 3 Interface Problems
- Routing data ที่เป็น Stale
- Critical Security Validation Failures

ตัวอย่าง:

```
Router Overview
├─ Routers: 3
├─ Online: 3
├─ WAN links down: 1
├─ Missing default route: 1
└─ Last checked: 2 minutes ago
```

### หน้า Router Detail

#### Interface Summary

| Interface | Role     | Admin | Protocol | IP/Prefix       | Description  |
| --------- | -------- | ----- | -------- | --------------- | ------------ |
| Gi0/0     | LAN      | Up    | Up       | 192.168.10.1/24 | Internal LAN |
| Gi0/1     | WAN      | Up    | Down     | 203.0.113.2/30  | ISP-1        |
| Lo0       | Loopback | Up    | Up       | 10.255.0.1/32   | Router ID    |

Cisco ใช้ `show ip interface brief` เพื่อแสดง IP, Interface status และ Protocol status ซึ่งช่วยแยก Interface ที่ทำงานปกติแบบ `up/up` ออกจาก Interface ที่ถูกปิดหรือมีปัญหา [Cisco Router Interface Status](https://www.cisco.com/c/en/us/td/docs/routers/access/isr4400/software/configuration/xe-17/isr4400-sw-config-xe-17/isr4400swcfg-xe-16-9-book_chapter_011010.html)

#### Routing Summary

| Route           | Source    | Next Hop     | Out Interface | State    |
| --------------- | --------- | ------------ | ------------- | -------- |
| 0.0.0.0/0       | Static    | 203.0.113.1  | Gi0/1         | Inactive |
| 192.168.10.0/24 | Connected | —            | Gi0/0         | Active   |
| 10.20.0.0/16    | Static    | 192.168.10.2 | Gi0/0         | Active   |

Cisco ระบุว่า `show ip route` ใช้ดู Routing Table รวมถึง Route source, next hop และ Default Route/Gateway of Last Resort [Cisco `show ip route`](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/iproute_pi/command/iri-cr-book/iri-cr-s1.html)

## ข้อมูลใดมีประโยชน์อย่างไร

| ข้อมูล                | ช่วยตอบอะไร                                    | การตัดสินใจ                              |
| --------------------- | ---------------------------------------------- | ---------------------------------------- |
| Admin/Protocol status | Port ถูก Shutdown หรือ Link/Protocol มีปัญหา?  | ตรวจ Config หรือสาย/Provider             |
| IP/Prefix             | Interface อยู่ Network ถูกต้องหรือไม่?         | แก้ IP/Subnet                            |
| Interface role        | Port เป็น WAN, LAN หรือ Management?            | ประเมินความรุนแรงของ Down                |
| Default route         | Router มีทางออกไป Network ที่ไม่รู้จักหรือไม่? | แก้ Static/Default route                 |
| Next hop              | Traffic ถูกส่งไปหา Router ตัวใด?               | ตรวจเพื่อนบ้านหรือ ISP                   |
| Outgoing interface    | Route ออก Port ไหน?                            | เชื่อม Route กับ Interface failure       |
| Route source          | Connected, Static หรือ Dynamic?                | ตรวจว่า Route มาจากแหล่งที่คาดไว้หรือไม่ |
| Uptime                | Router เพิ่ง Restart หรือไม่?                  | ตรวจไฟดับ Crash หรือ Config loss         |
| Last collected        | ข้อมูลยังน่าเชื่อถือหรือไม่?                   | Refresh ก่อนตัดสินใจ                     |

## ต้องมี Expected State ด้วย

ระบบไม่สามารถสรุปว่า Interface Down ทุกอันเป็นปัญหาได้ เพราะ Router อาจมี Port ที่ไม่ได้ใช้งาน

จึงควรมีข้อมูลประกอบ เช่น:

```
interface_role        // wan, lan, management, loopback
monitoring_enabled
is_critical
expected_admin_status
```

ตัวอย่าง Severity:

| เหตุการณ์                                           | ระดับ                     |
| --------------------------------------------------- | ------------------------- |
| Port ที่ไม่ได้ใช้งาน Down                           | Neutral                   |
| LAN Interface Down                                  | Warning/Critical ตามบทบาท |
| WAN Interface Down                                  | Critical                  |
| Loopback Down                                       | Critical                  |
| ไม่มี Default Route ทั้งที่ Router ต้องออก Internet | Critical                  |
| Routing data เก่า                                   | Stale/Unknown             |

การระบุ `WAN` หรือ `Critical` ควรให้ผู้ใช้กำหนดใน Inventory/Interface Detail ไม่ควรให้ระบบเดาเองทั้งหมด

## ขอบเขต Router ที่แนะนำสำหรับ P1

### Must-have

- Router reachability
- Interface Admin/Operational status
- Interface IP/Prefix
- Interface role: WAN/LAN/Management
- Active Default Route
- Static Route Snapshot
- Next hop และ Outgoing Interface
- Last collected/Data freshness

### Should-have

- Uptime
- CPU/Memory Summary
- DHCP Pool Summary หาก Router ทำหน้าที่ DHCP
- Manual next-hop reachability check

### P2

- OSPF/EIGRP/BGP neighbor state
- Route flap history
- Multi-VRF
- NAT session/utilization
- VPN tunnel status
- QoS statistics
- Interface bandwidth graph
- NetFlow/Streaming Telemetry

Dynamic Routing อยู่ใน P2 ของ Scope ปัจจุบัน จึงยังไม่ควรสร้าง OSPF/BGP Dashboard ใน P1

## คำสั่ง Read-only สำหรับ Cisco Router

```
show ip interface brief
show interfaces description
show ip route
show ip route static
show version
```

คำสั่งเสริมเมื่อ Feature นั้นอยู่ใน Scope:

```
show ip dhcp pool
show processes cpu
show memory statistics
```

ทั้งหมดต้องใช้กับอุปกรณ์ที่ลงทะเบียนไว้และใน Isolated Lab เท่านั้น ไม่ใช่การ Scan Network

## ผลกระทบต่อ Database

ตาราง `interfaces` ใช้ร่วมกับ Switch ได้:

```
interfaces
- id
- device_id
- name
- interface_role
- interface_type
- admin_status
- oper_status
- description
- last_collected_at
```

แยก IP ออกจาก Interface จะรองรับ Router ได้ดีกว่า:

```
interface_ip_addresses
- id
- interface_id
- address
- prefix_length
- address_family
- is_primary
```

เพิ่ม Current Routing Snapshot:

```
routes
- id
- device_id
- prefix
- protocol
- next_hop
- outgoing_interface_id
- administrative_distance
- metric
- is_active
- last_collected_at
```

หน้า Dashboard Aggregate จากตารางเหล่านี้ ไม่จำเป็นต้องมีตาราง `router_dashboard`

## ข้อสรุป

ควรสร้างไฟล์ `Router Operational Visibility.md` คู่กับไฟล์ Switch โดยกำหนด P1 ว่า:

> สำหรับ Cisco Router ระบบแสดง Reachability, Layer 3 Interface status, IP/Prefix, WAN/LAN role, Active Default Route, Static Route, Next hop, Outgoing Interface และ Data freshness เพื่อช่วยแยกปัญหา Device, Link และ Routing

Switch Visibility ทำให้รู้ว่า “ผู้ใช้อยู่ VLAN และ Port ที่ถูกต้องหรือไม่” ส่วน Router Visibility ทำให้รู้ว่า “Traffic มีเส้นทางออกจาก Network หรือไม่” เมื่อมีทั้งสองอย่าง Dashboard จึงตอบโจทย์การใช้งาน Network จริงได้ครบตั้งแต่ Layer 2 ถึง Layer 3 โดยยังไม่กลายเป็น Full NMS ครับ