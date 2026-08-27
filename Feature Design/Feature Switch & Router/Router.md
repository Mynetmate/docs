Router สำหรับบริษัททั่วไปควรเป็น Business/Enterprise Router และรองรับ Feature ต่อไปนี้

### Routing และ Interface

1. **Static Route** — กำหนดเส้นทางแบบคงที่
2. **Default Route** — กำหนดเส้นทางออกอินเทอร์เน็ต
3. **Dynamic Routing** — อย่างน้อย OSPF และ BGP หากต้องเชื่อมหลายสาขาหรือหลาย ISP
4. **Inter-VLAN Routing** — Routing ระหว่าง VLAN
5. **802.1Q Subinterface** — รองรับ Router-on-a-Stick
6. **Policy-Based Routing (PBR)** — เลือกเส้นทางตามแหล่งที่มา ปลายทาง หรือประเภท Traffic
7. **Route Tracking/IP SLA** — ตรวจสอบเส้นทางและเปลี่ยน Gateway อัตโนมัติ
8. **Equal-Cost Multi-Path (ECMP)** — ใช้งานหลายเส้นทางพร้อมกัน
9. **VRF/Virtual Router** — แยก Routing Table สำหรับหลายหน่วยงานหรือหลายเครือข่าย
10. **IPv4 และ IPv6 Dual Stack**

### Internet และ NAT

11. **NAT/PAT** — ให้ผู้ใช้ภายในออกอินเทอร์เน็ตโดยใช้ Public IP
12. **Static NAT** — จับคู่ Private IP กับ Public IP
13. **Port Forwarding** — เปิดบริการภายในตามพอร์ตที่กำหนด
14. **NAT Exemption** — ยกเว้น NAT สำหรับ VPN หรือ Traffic บางประเภท
15. **Multiple WAN** — รองรับอินเทอร์เน็ตมากกว่าหนึ่งเส้น
16. **WAN Failover** — เปลี่ยนไปใช้ ISP สำรองอัตโนมัติ
17. **WAN Load Balancing** — กระจาย Traffic ระหว่างหลาย ISP
18. **PPPoE, Static IP และ DHCP Client** — รองรับรูปแบบการเชื่อมต่อกับ ISP
### Security และ Firewall

19. **Standard และ Extended ACL** — อนุญาตหรือปฏิเสธ Traffic ตาม IP, Protocol และ Port
20. **Stateful Firewall** — ตรวจสอบสถานะของ Connection
21. **Zone-Based Firewall** — แบ่งโซน เช่น LAN, WAN, Server และ Guest
22. **Application Control** — ควบคุม Application หาก Router รองรับ Next-Generation Firewall
23. **URL/Web Filtering** — จำกัดเว็บไซต์หรือหมวดหมู่เนื้อหา
24. **Intrusion Prevention System (IPS)** — ตรวจจับและป้องกันการโจมตี
25. **Anti-Spoofing/uRPF** — ป้องกันการปลอมแปลง Source IP
26. **DoS/DDoS Protection** — จำกัดหรือป้องกัน Traffic ผิดปกติ
27. **Geo-IP Filtering** — จำกัด Traffic ตามประเทศ หากจำเป็น
28. **Security Logging** — บันทึกเหตุการณ์ที่ถูกอนุญาตหรือปฏิเสธ
29. **Object Group** — รวม IP, Network และ Service เพื่อบริหาร Rule ได้ง่าย

### VPN
30. **IPsec Site-to-Site VPN** — เชื่อมสำนักงานใหญ่กับสาขา
31. **Remote-Access VPN** — ให้พนักงานเชื่อมต่อจากภายนอก
32. **IKEv2** — มาตรฐาน VPN ที่ปลอดภัยและทันสมัย
33. **SSL/TLS VPN** — รองรับการเชื่อมต่อ Remote Access ผ่าน TLS
34. **Route-Based VPN** — ใช้ Tunnel Interface และทำ Routing ผ่าน VPN
35. **VPN Redundancy** — สลับ Tunnel เมื่อเส้นทางหลักขัดข้อง
36. **Strong Encryption** — ควรรองรับ AES-256, SHA-2 และ Perfect Forward Secrecy
37. **Certificate Authentication** — ยืนยันตัวตนด้วย Digital Certificate
38. **MFA Integration** — รองรับการยืนยันตัวตนหลายขั้นตอนสำหรับ Remote VPN

### DHCP และ Network Services

39. **DHCP Server** — แจก IP Address ให้แต่ละ VLAN
40. **DHCP Relay/IP Helper** — ส่งคำขอ DHCP ไปยัง Server กลาง
41. **DHCP Reservation** — จอง IP ให้เครื่องหรืออุปกรณ์ที่กำหนด
42. **DNS Forwarding/Proxy** — ส่งต่อ DNS Request
43. **Dynamic DNS (DDNS)** — ใช้ชื่อ Domain เมื่อ Public IP เปลี่ยน
44. **NTP Client/Server** — ทำเวลาให้อุปกรณ์ตรงกัน
45. **Multicast Routing/IGMP** — รองรับระบบ Video หรือ Multicast หากมีการใช้งาน

### QoS และควบคุม Bandwidth

46. **Quality of Service (QoS)** — จัดลำดับความสำคัญของ Traffic
47. **Traffic Classification/Marking** — จำแนกและกำหนดค่า DSCP
48. **Traffic Shaping** — ควบคุมอัตราการส่ง Traffic
49. **Policing/Rate Limiting** — จำกัด Bandwidth ตาม VLAN, IP หรือ Application
50. **Priority Queue** — ให้ VoIP, Video Conference หรือระบบสำคัญได้รับสิทธิ์ก่อน
51. **Per-user/Per-network Bandwidth Control**

### การบริหารจัดการ

52. **SSHv2** — บริหารผ่าน Command Line อย่างปลอดภัย
53. **HTTPS Management** — บริหารผ่านหน้าเว็บแบบเข้ารหัส
54. **SNMPv3** — ส่งข้อมูลสถานะให้ระบบ Monitoring อย่างปลอดภัย
55. **Syslog** — ส่ง Log ไปยัง Server กลาง
56. **NetFlow/IPFIX** — วิเคราะห์ว่าใครหรือ Application ใดใช้ Bandwidth
57. **AAA** — Authentication, Authorization และ Accounting
58. **RADIUS/TACACS+** — ยืนยันตัวตนผู้ดูแลผ่าน Server กลาง
59. **Role-Based Access Control (RBAC)** — แยกสิทธิ์ผู้ดูแล
60. **Management ACL** — อนุญาตให้บริหาร Router จาก IP หรือ VLAN ที่กำหนดเท่านั้น
61. **Configuration Backup/Restore** — สำรองและกู้คืน Configuration
62. **Configuration Version/Rollback** — ย้อนกลับไปใช้ Configuration เดิม
63. **Firmware Upgrade** — อัปเดตระบบและ Security Patch
64. **Secure Boot/Signed Firmware** — ตรวจสอบความถูกต้องของ Firmware
65. **API หรือ Centralized Management** — บริหารอุปกรณ์หลายตัวจากศูนย์กลาง

### ความพร้อมใช้งาน

66. **High Availability (HA)** — ทำงานร่วมกับ Router สำรอง
67. **VRRP/HSRP** — สร้าง Default Gateway สำรอง
68. **Graceful Restart/Nonstop Forwarding** — ลดผลกระทบระหว่างระบบเปลี่ยนสถานะ
69. **Dual Power Supply** — แหล่งจ่ายไฟสำรอง หากเป็น Router ศูนย์กลาง
70. **Hardware Health Monitoring** — ตรวจสอบ CPU, RAM, อุณหภูมิ พัดลม และ Power Supply
