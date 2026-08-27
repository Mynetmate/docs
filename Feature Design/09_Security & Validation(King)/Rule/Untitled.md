ถูกต้องครับ — ต้องยกเลิกการมองว่า “24 ลดเหลือ 8” เป็นมติ เพราะทั้ง 24 และ 8 ยังไม่มีหลักฐานการคัดเลือกที่ชัดเจน

สถานะใหม่ควรเป็น:

- `8 Rules` = ข้อเสนอที่ AI เลือก ไม่ใช่มติผู้ใช้
- `24 Rules` = เป้าหมายใน Proposal เดิม แต่ไม่มีเอกสารแจกแจงว่าเลือก 24 ข้อใดและเลือกด้วยเกณฑ์อะไร
- มติจากคุณล่าสุด = ต้องศึกษาใหม่ โดยเป้าหมายควรมากกว่า 10 กฎตามคำแนะนำอาจารย์
- จำนวนสุดท้าย = ยังเป็น `TBD` จนกว่าจะประเมินทีละ Rule

## ข้อค้นพบสำคัญ

CIS IOS XE 17.x v2.2.1 ไม่ได้มีเพียง 24 กฎ แต่มี Recommendation ย่อยทั้งหมด 84 ข้อ แบ่งเป็น:

- Automated 51 ข้อ
- Manual 33 ข้อ

ดังนั้นโจทย์ที่ถูกต้องไม่ใช่ “เลือก 8 จาก 24” แต่คือ:

> เลือกกฎมากกว่า 10 ข้อจาก CIS 84 Recommendations โดยใช้เกณฑ์ที่อธิบายและทดสอบได้

ข้อมูลมาจาก Appendix: Summary Table ของ CIS ต้นฉบับ CIS_Cisco_IOS_XE_17.x_Benchmark_v2.2.1.pdf

## กลุ่มกฎทั้งหมดใน CIS

| กลุ่ม                           | จำนวนโดยประมาณ | ความเหมาะสมกับ MVP                                       |
| ------------------------------- | -------------- | -------------------------------------------------------- |
| AAA และ Authentication          | 10             | สำคัญแต่หลายข้อต้องมี RADIUS/TACACS+                     |
| VTY, Console และ Access Control | 10             | เหมาะมาก                                                 |
| Banner                          | 4              | เลือกเฉพาะที่ใช้จริง                                     |
| Password                        | 3              | เหมาะมาก                                                 |
| SNMP                            | 10             | เหมาะแบบมีเงื่อนไข                                       |
| SSH และ Global Services         | 12             | เหมาะบางข้อ บางข้อต้องใช้ Operational Output             |
| Logging                         | 8              | เหมาะบางข้อ                                              |
| NTP Security                    | 5              | ต้องใช้เมื่อเปิด NTP                                     |
| Loopback/Source Interface       | 4              | ขึ้นกับสถาปัตยกรรมเครือข่าย                              |
| Routing Security                | 4              | หลายข้อเป็น Interface-specific                           |
| Border Filtering                | 2              | ต้องรู้ว่า Interface ใดเป็น External                     |
| EIGRP/OSPF/BGP Authentication   | 12             | เหมาะ P2 หรือเมื่อ Config Builder รองรับ Routing ขั้นสูง |

## Candidate Baseline 14 กฎ

นี่เป็น “ชุดสำหรับศึกษา” ไม่ใช่ Final decision ผมแนะนำ 14 ข้อเพราะมากกว่า 10 ตามคำแนะนำอาจารย์ ครอบคลุมความเสี่ยงหลัก และยังไม่ขยายไปเป็น Enterprise Compliance Engine

| #   | Candidate Rule                                    | CIS Mapping | เหตุผล                                   |
| --- | ------------------------------------------------- | ----------- | ---------------------------------------- |
| 1   | ต้องมี `enable secret`                            | 1.4.1       | ป้องกัน Privileged mode                  |
| 2   | ต้องมี `service password-encryption`              | 1.4.2       | ลดการปรากฏรหัสผ่านแบบ Plain text         |
| 3   | Local user ทุกคนต้องใช้ `username ... secret`     | 1.4.3       | ห้ามใช้ `username ... password`          |
| 4   | VTY ทุกช่วงต้องใช้ `transport input ssh` เท่านั้น | 1.2.2       | ปิด Telnet อย่างถูกต้องตามโครงสร้าง      |
| 5   | VTY ทุกช่วงต้องมี `access-class`                  | 1.2.5       | จำกัด Source ที่เข้าถึง Management plane |
| 6   | Console ต้องมี Idle timeout ไม่เกิน 10 นาที       | 1.2.7       | ลดความเสี่ยงจาก Session ที่ถูกทิ้งไว้    |
| 7   | VTY ต้องมี Idle timeout ไม่เกิน 10 นาที           | 1.2.8       | ป้องกัน Remote session ค้าง              |
| 8   | SSH ต้องใช้ Version 2                             | 2.1.1.2     | ไม่อนุญาต SSH v1                         |
| 9   | ต้องมี Banner MOTD ที่สมบูรณ์                     | 1.3.3       | แสดง Legal/Security notice               |
| 10  | SNMP Community ห้ามเป็น `private`                 | 1.5.2       | Default community ที่คาดเดาได้           |
| 11  | SNMP Community ห้ามเป็น `public`                  | 1.5.3       | Default community ที่คาดเดาได้           |
| 12  | SNMP Community ห้ามเป็น `RW`                      | 1.5.4       | ป้องกันการแก้ไขอุปกรณ์ผ่าน SNMPv2        |
| 13  | SNMP Community ทุกตัวต้องมี ACL                   | 1.5.5       | จำกัด Management station ที่เข้าถึงได้   |
| 14  | ต้องเปิด Login success/failure logging            | 2.2.8       | มีหลักฐานสำหรับสืบสวนและ Audit           |

ชุดนี้ครอบคลุม 4 ด้านหลัก:

- Password และ Local Account: 3 กฎ
- Remote Management: 5 กฎ
- SNMP Security: 4 กฎ
- Banner และ Logging: 2 กฎ

Mockup ปัจจุบันมี Input สำหรับ Enable password, SSH user, SNMP, SSH/Telnet, Banner และ Logging อยู่แล้ว จึงเชื่อมกับ Config Builder ได้มากกว่ากฎ AAA หรือ Routing ขั้นสูง [Mockup จากภาพพี่ออม.md (line 17)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/02_Device Inventory Management/Mockup จากภาพพี่ออม.md:17)

## แต่ 14 กฎนี้ยังไม่สามารถยืนยันเป็น P1 ได้ทั้งหมด

เหตุผลคือแต่ละกฎต้องการ Input ต่างกัน:

| Input                      | ตัวอย่างกฎ                                                    |
| -------------------------- | ------------------------------------------------------------- |
| Candidate/Effective Config | `enable secret`, `username secret`, VTY, SNMP, Banner         |
| `show running-config all`  | Console timeout เพราะค่า Default อาจไม่แสดงใน `show run` ปกติ |
| Operational command        | SSH version, timeout และ retry ตาม Audit Procedure ของ CIS    |
| Device context             | Vendor, OS version, Device role                               |
| Organizational policy      | ACL ที่อนุญาต, Syslog server, NTP server                      |

ตัวอย่างสำคัญ: หาก `ip ssh authentication-retries` ใช้ค่า Default 3 ระบบอาจไม่แสดงบรรทัดนี้ใน Running Config ถ้าใช้ Regex แล้วไม่พบและตัดสิน Fail ทันที จะกลายเป็น False Positive

นี่คือเหตุผลที่เราต้องออกแบบสถานะ `Unable to Evaluate` แยกจาก `Fail`

## กฎที่ควรพักไว้ก่อน

กฎเหล่านี้เป็น CIS โดยตรง แต่ยังไม่เหมาะเป็น Core Rules รอบแรก:

- AAA/RADIUS/TACACS+ — ต้องมี External Authentication Server
- RSA modulus ≥ 2048 — CIS ตรวจจากข้อมูล Key จริง ไม่ใช่เพียงบรรทัด Config
- NTP Authentication — ประกอบด้วยหลายคำสั่งและต้องรู้ว่าองค์กรใช้ NTP แบบใด
- Logging host/source interface — ต้องรู้ IP และ Interface ที่องค์กรกำหนด
- ปิด CDP — ไม่ควรบังคับเสมอ เพราะ MyNetMate อาจใช้ CDP ใน Discovery
- ปิด DHCP service — อุปกรณ์บางตัวมีหน้าที่เป็น DHCP Server
- `no ip proxy-arp` — ต้องตรวจทุก Interface และอาจมีข้อยกเว้น
- Border filtering — ต้องรู้ว่า Interface ใดเป็น Internet-facing
- OSPF/EIGRP/BGP authentication — Config Builder จัดเป็น Advanced/P2

กฎเหล่านี้ควรให้ผล `Not Applicable` ตาม Device role/Feature usage ไม่ใช่บังคับ Fail ทุกเครื่อง

## หลักการเลือก Rule ที่ควรใช้แทนการเลือกจากจำนวน

แต่ละ Rule ต้องผ่านเกณฑ์ต่อไปนี้:

1. มี Mapping ไปยัง CIS Recommendation ที่ตรวจสอบได้
2. ใช้กับ Cisco IOS/IOS XE รุ่นเป้าหมาย
3. มี Input เพียงพอให้ตัดสินอย่างแน่นอน
4. กำหนด Pass/Fail/Not Applicable/Unable to Evaluate ได้
5. มี Test case ทั้ง Positive, Negative และ Edge case
6. False Negative ต้องต่ำ โดยเฉพาะกฎที่บล็อก Deployment
7. มี Remediation guidance แต่ไม่แก้ Config อัตโนมัติ
8. ทำได้ภายในเวลาและทักษะของทีม
9. เชื่อมกับ Config Builder หรือ Running Config ที่ระบบรองรับจริง
10. ไม่แบ่งกฎย่อยเพื่อเพิ่มจำนวนแบบไม่มีเหตุผล

## แนวทางเจาะลึกทีละชุด

ผมแนะนำให้ศึกษาต่อเป็น 4 รอบ:

1. Password และ Local Account — 3 กฎ
2. VTY, Console และ SSH — 5 กฎ
3. SNMP — 4 กฎ
4. Banner และ Logging — 2 กฎ

ในแต่ละ Rule เราจะกำหนด:

- CIS source และ Benchmark version
- จุดประสงค์
- Applicability
- Input ที่ต้องใช้
- เงื่อนไข Pass/Fail/N/A/Unable
- Evidence ที่ต้องเก็บ
- Regex หรือ Parser ที่ต้องใช้
- False Positive/Negative risk
- Remediation guidance
- Acceptance tests

ดังนั้น Working target ที่มีเหตุผลตอนนี้คือ “Candidate 14 Rules” ไม่ใช่ Final 14 Rules และเลข 8 ใน [Weight Feature List (line 194)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/MyNetMate Weight Feature List.md:194) ต้องถือเป็น AI-derived proposal ที่รอ Correction ครับ