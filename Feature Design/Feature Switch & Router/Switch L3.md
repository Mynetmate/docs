Switch Layer 3 สำหรับบริษัททั่วไปควรรองรับทั้งความสามารถของ Switch L2 และ Routing โดยมี Feature ดังนี้
### Layer 2 และ VLAN

1. **IEEE 802.1Q VLAN**
2. **Access Port และ Trunk Port**
3. **Voice VLAN**
4. **Native VLAN Configuration**
5. **Allowed VLAN Filtering บน Trunk**
6. **Private VLAN (PVLAN)**
7. **MAC Address Table Management**
8. **Jumbo Frame**
9. **LLDP และ LLDP-MED**
10. **Port Mirroring/SPAN**
11. **Remote SPAN (RSPAN)**
### Spanning Tree และป้องกัน Loop

12. **STP – IEEE 802.1D**
13. **RSTP – IEEE 802.1w**
14. **MSTP – IEEE 802.1s**
15. **PortFast/Edge Port**
16. **BPDU Guard**
17. **BPDU Filter**
18. **Root Guard**
19. **Loop Guard**
20. **UDLD**
21. **Storm Control**

### Link Aggregation และระบบสำรอง

22. **Static Link Aggregation**
23. **LACP/EtherChannel – IEEE 802.3ad/802.1AX**
24. **Multi-Chassis Link Aggregation (MLAG/MC-LAG)** — หากต้องการความพร้อมใช้งานสูง
25. **Switch Stacking/Virtual Chassis**
26. **Cross-Stack Link Aggregation**
27. **Stack Redundancy**
28. **Dual/Redundant Power Supply**

### Layer 3 Routing

29. **Switched Virtual Interface (SVI)** — สร้าง Default Gateway ให้แต่ละ VLAN
30. **Routed Port** — เปลี่ยนพอร์ต Physical ให้เป็น Layer 3
31. **Inter-VLAN Routing**
32. **Static Route**
33. **Default Route**
34. **Policy-Based Routing (PBR)**
35. **Equal-Cost Multi-Path (ECMP)**
36. **Route Redistribution**
37. **VRF/VRF-Lite** — แยก Routing Table
38. **IPv4 และ IPv6 Dual Stack**
39. **IPv6 Neighbor Discovery**
40. **IPv6 Router Advertisement**
41. **IPv6 Static Routing**

### Dynamic Routing Protocol

42. **OSPF/OSPFv2** — Dynamic Routing สำหรับ IPv4
43. **OSPFv3** — Dynamic Routing สำหรับ IPv6
44. **BGP** — สำหรับเครือข่ายขนาดใหญ่หรือเชื่อมหลายระบบ
45. **IS-IS** — สำหรับเครือข่ายองค์กรหรือผู้ให้บริการขนาดใหญ่
46. **RIP/RIPng** — รองรับระบบเก่า แต่ไม่แนะนำสำหรับระบบใหม่
47. **Bidirectional Forwarding Detection (BFD)** — ตรวจจับเส้นทางล้มเหลวอย่างรวดเร็ว
48. **Route Filtering และ Route Map**
49. **Prefix List**
50. **Administrative Distance/Route Preference Configuration**

สำหรับบริษัททั่วไป อย่างน้อยควรมี Static Route และ OSPF ส่วน BGP, IS-IS และ BFD ขึ้นอยู่กับขนาดเครือข่ายและ License ของ Switch

### Gateway Redundancy

51. **VRRP**
52. **HSRP** — สำหรับอุปกรณ์ที่รองรับ
53. **Gateway Load Balancing**
54. **Object/IP Tracking**
55. **IP SLA หรือ Network Performance Monitoring**

Feature กลุ่มนี้ต้องใช้ L3 Switch อย่างน้อย 2 ตัวจึงจะเกิด Gateway Redundancy ได้จริง

### DHCP และ Network Services

56. **DHCP Server**
57. **DHCP Relay/IP Helper**
58. **DHCP Snooping**
59. **DHCP Option 82**
60. **DHCPv6 Relay**
61. **DNS Client**
62. **NTP Client/Server**
63. **Multicast Routing**
64. **IGMP Snooping**
65. **IGMP Querier**
66. **PIM Sparse Mode/Dense Mode**
67. **Multicast Listener Discovery (MLD) สำหรับ IPv6**
### Network Security

68. **Standard และ Extended ACL**
69. **IPv4/IPv6 ACL**
70. **VLAN ACL (VACL)**
71. **Port ACL (PACL)**
72. **Time-Based ACL**
73. **Port Security**
74. **Dynamic ARP Inspection (DAI)**
75. **IP Source Guard**
76. **ARP Inspection/ARP Protection**
77. **Anti-Spoofing/uRPF**
78. **MAC Address Filtering**
79. **Protected Port/Port Isolation**
80. **Control Plane Policing (CoPP)**
81. **802.1X Port-Based Authentication**
82. **MAC Authentication Bypass (MAB)**
83. **RADIUS และ TACACS+**
84. **Access Control List สำหรับ Management**
85. **DoS Protection และ Rate Limiting**

### QoS

86. **Layer 2–4 Traffic Classification**
87. **DSCP และ IEEE 802.1p Marking**
88. **Priority Queuing**
89. **Traffic Shaping**
90. **Traffic Policing**
91. **Rate Limiting ต่อพอร์ตหรือ VLAN**
92. **Voice/Video QoS**
93. **Trust Boundary**
94. **Weighted Round Robin/Strict Priority Queue**
95. **QoS Statistics**

### การบริหารและตรวจสอบ

96. **SSHv2**
97. **HTTPS Management**
98. **SNMPv3**
99. **Syslog**
100. **NetFlow/sFlow/IPFIX**
101. **AAA**
102. **Role-Based Access Control (RBAC)**
103. **CLI และ Web GUI**
104. **REST API/NETCONF/RESTCONF**
105. **Centralized/Cloud Management**
106. **Configuration Backup และ Restore**
107. **Configuration Rollback**
108. **Firmware/Image Upgrade**
109. **Dual Firmware Image**
110. **Zero-Touch Provisioning**
111. **CPU, Memory, Temperature และ Power Monitoring**
112. **Cable Diagnostics**
113. **Event และ Interface Logging**

### Hardware ที่ควรตรวจสอบ

- Access Port อย่างน้อย `1 Gbps`
- Uplink ควรเป็น `10/25 Gbps` ตามปริมาณ Traffic
- รองรับ SFP/SFP+/SFP28 ตามที่ใช้งาน
- Switching Capacity แบบ Non-blocking
- Forwarding Rate เพียงพอกับจำนวนพอร์ต
- MAC Address Table, ARP Table และ Routing Table เพียงพอ
- รองรับจำนวน VLAN, SVI, ACL และ Route ตามขนาดระบบ
- รองรับ PoE+/PoE++ หากใช้กับ Access Point, IP Phone หรือ CCTV
- มี Console Port และ Out-of-Band Management
- มี Redundant Power Supply และ Hot-swappable Fan สำหรับ Core Switch

Feature ขั้นต่ำที่ไม่ควรขาด ได้แก่ VLAN, Trunk, RSTP/MSTP, LACP, SVI, Inter-VLAN Routing, Static Route, OSPF, VRRP, ACL, DHCP Relay, DHCP Snooping, DAI, IP Source Guard, 802.1X, QoS, IPv4/IPv6, SSH, SNMPv3, Syslog, NTP และ Configuration Backup/Restore

ทั้งนี้ L3 Switch ปกติไม่ได้ออกแบบมาใช้แทน Internet Firewall จึงไม่จำเป็นต้องมี NAT, Stateful Firewall, IPS หรือ Remote-Access VPN โดยควรให้ Router หรือ Firewall โดยเฉพาะรับหน้าที่ดังกล่าวครับ