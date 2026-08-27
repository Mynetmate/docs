รายการ Feature ที่จำเป็นสำหรับ Switch Layer 2 แบบ Managed Switch ในบริษัท มีดังนี้
### Feature ที่ต้องมี

1. **IEEE 802.1Q VLAN**  แบ่งเครือข่ายออกเป็นแผนกหรือกลุ่มผู้ใช้งาน
2. **Access Port และ Trunk Port**  เชื่อมผู้ใช้และส่งหลาย VLAN ระหว่าง Switch/Router
3. **Rapid Spanning Tree Protocol (RSTP / 802.1w)**  ป้องกัน Network Loop และกู้คืนเส้นทางได้รวดเร็ว
4. **Link Aggregation (LACP / 802.3ad)** —รวมหลายพอร์ตให้มี Bandwidth และความทนทานสูงขึ้น
5. **Port Security**  จำกัดจำนวนหรือระบุ MAC Address ที่อนุญาตบนพอร์ต
6. **BPDU Guard**  ป้องกันผู้ใช้นำ Switch อื่นมาต่อจนเกิด Loop
7. **PortFast หรือ Edge Port**  ทำให้พอร์ตผู้ใช้พร้อมทำงานรวดเร็ว
8. **Storm Control**  จำกัด Broadcast, Multicast และ Unknown Unicast Storm
9. **DHCP Snooping** ป้องกัน DHCP Server ปลอม
10. **Dynamic ARP Inspection (DAI)** ป้องกัน ARP Spoofing/ARP Poisoning
11. **IP Source Guard**  ป้องกันการปลอมแปลง IP Address
12. **Management VLAN**  แยกช่องทางบริหาร Switch ออกจากเครือข่ายผู้ใช้
13. **SSH/SSHv2**  บริหาร Switch อย่างปลอดภัยผ่าน CLI
14. **SNMPv3**  ตรวจสอบสถานะ Switch ผ่านระบบ Monitoring
15. **Syslog**  ส่งเหตุการณ์และข้อผิดพลาดไปเก็บที่ Log Server
16. **NTP**  ตั้งเวลาให้ Log ของทุกอุปกรณ์ตรงกัน
17. **LLDP / LLDP-MED** ตรวจสอบว่าแต่ละพอร์ตเชื่อมต่อกับอุปกรณ์ใด
18. **Port Mirroring หรือ SPAN**  คัดลอก Traffic สำหรับวิเคราะห์ด้วย Wireshark หรือ IDS
19. **QoS**  จัดลำดับความสำคัญให้ Voice, Video และ Application สำคัญ
20. **Configuration Backup/Restore** สำรองและกู้คืน Configuration
21. **Role-Based Access หรือ AAA**  ควบคุมสิทธิ์ผู้ดูแลระบบ
22. **802.1X Authentication** —ตรวจสอบผู้ใช้หรืออุปกรณ์ก่อนอนุญาตให้เข้าเครือข่าย

