ผล Step 0 ชัดเจนว่า “Scope ระดับ Feature” ค่อนข้างนิ่งแล้ว แต่รายละเอียดของ Input, Rule Semantics, Gate, Toggle และ Override ยังไม่เป็นมติ จึงยังไม่ควรเขียน Schema หรือ Component Diagram ขณะนี้ และผมไม่ได้แก้ไขหรือสร้างไฟล์ใด

## 1. ไฟล์ภายในที่เกี่ยวข้อง

หลักฐานที่มีน้ำหนักสูงสุด:

- [AGENTS.md (line 109)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/AGENTS.md:109) — กฎโครงการและ Scope ล่าสุด
- [MyNetMate Weight Feature List.md (line 190)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/MyNetMate Weight Feature List.md:190) — Single Source of Truth ของ MVP
- [01_MVP Feature.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/09_Security & Validation/01_MVP Feature.md) — ขณะนี้เป็นไฟล์ว่าง 0 ไบต์ ยังไม่มีมติ Feature
- CIS IOS XE 16.x v2.2.0 CIS_Cisco_IOS_XE_16.x_Benchmark_v2.2.0.pdf
- CIS IOS XE 17.x v2.2.1 CIS_Cisco_IOS_XE_17.x_Benchmark_v2.2.1.pdf

เอกสารประกอบที่เกี่ยวข้องแต่ยังเป็น Working hypothesis/ข้อเสนอ:

- [แนวทางการหา Feature.md (line 124)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/แนวทางการหา Feature.md:124) — เสนอ `validation_runs`, findings, rule version และ risk acceptance แต่ระบุเองว่าเป็น Working hypothesis
- [MyNetMate รายการ Features.md (line 433)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/MyNetMate รายการ Features.md:433) — Raw feature list เดิม มี 24 Rules และ Three-tier severity
- [Data Information.md (line 110)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/02_Device Inventory Management/Data Information.md:110) และ [Data Schema.md (line 92)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/Data Schema.md:92) — Schema ข้อเสนอเดิม ไม่ใช่มติของ Security Feature
- [Component Description.md (line 451)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/Component Description.md:451) — API/Component proposal เดิม
- [Dashboard Database Schema.md (line 1)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/01_Dashboard&Monitoring/02_Database Schema.md:1) และ [Dashboard Research (line 85)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/01_Dashboard&Monitoring/01_Desk Research/MyNetMate Dashboard.md:85) — แสดงข้อมูลที่ Dashboard คาดว่าจะขอจาก Security
- [Configuration Compliance (line 7)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/05_knowledge_base/หนังสือ/ข้อมูลจากหนังสือ/NPA2e Ch 2 - Network Automation/NPA2e Ch 2 - Network Automation - 6 Type of Network Automation - Configuration Compliance.md:7) และ [State Validation (line 7)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/05_knowledge_base/หนังสือ/ข้อมูลจากหนังสือ/NPA2e Ch 2 - Network Automation/NPA2e Ch 2 - Network Automation - 7 Type of Network Automation - State Validation.md:7) — ใช้แยก Compliance ออกจาก Operational State
- Proposal เดิมยังระบุ 24 Rules และ `ciscoconfparse` เช่น [Technical Design (line 74)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/04_project_management/Document Project/split/05_technical-design.md:74) และ [QR-3 เดิม (line 191)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/04_project_management/Document Project/split/10_appendix-empathize-define.md:191)

## 2. ขอบเขตที่ยืนยันได้

ยืนยันจาก Scope ล่าสุดได้ว่า:

- Security & Validation เป็น P1-CORE และอยู่ใน Flow  
    `Config Builder → Preview → CIS Scan → Plan/Apply`
- P1 ทำ Plan/Apply แบบจำลอง ยังไม่ Push SSH จริง [Weight Feature List (line 160)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/MyNetMate Weight Feature List.md:160)
- ใช้ Rule-based/Parser ตัดสินผล ไม่ใช้ AI ตัดสิน Pass/Fail
- MVP เหลือ 8 กฎ ไม่ใช่ 24 กฎ
- Config ที่จะเข้าสู่ Deployment ต้องผ่าน Security Gate ไม่ว่าต้นทางเป็น Template หรือ AI
- Audit Trail และ CIS Override Logging อยู่ใน P1 แต่รายละเอียดการ Override ยังไม่ยืนยัน
- CIS Rule Toggles อยู่ใน P1 แต่ความหมายของการปิด Rule ยังไม่ยืนยัน
- Cisco เป็น Baseline; Huawei และ MikroTik เป็นเพียง Candidate ตามรุ่น ระบบปฏิบัติการ และผล Lab
- Cross-device Impact Analysis และ Auto-Rollback ถูกตัดออก
- Running-config upload, SSH snapshot และ AI-generated config อยู่ P2 หรือยังเป็น Nice-to-have
- Auto-remediation ไม่ปรากฏเป็น P1 ใน Scope ล่าสุด และคำสั่งปัจจุบันของคุณกำหนดให้เป็น Non-goal

ข้อควรระวังสำคัญ: Project ใช้คำว่า “Cisco IOS Baseline” แต่ CIS ที่มีเป็น Benchmark สำหรับ “Cisco IOS XE 16.x/17.x” จึงยังห้ามสรุปว่าใช้ Benchmark นี้กับ Cisco ทุกเครื่องได้จนกว่าจะทราบรุ่นและ OS จริง

## 3. ผลตรวจ 8 กฎกับ CIS ต้นฉบับ

|กฎของ MyNetMate|สถานะจาก CIS IOS XE 17.x|ข้อสังเกต|
|---|---|---|
|มี `enable secret`|CIS โดยตรง 1.4.1|การเช็คแค่ว่ามีคำสั่งเป็นการลดรูป เพราะ CIS กล่าวถึงชนิดรหัสที่แข็งแรงด้วย|
|เปิด `service password-encryption`|CIS โดยตรง 1.4.2|เป็นกฎตรง แต่ CIS เตือนว่าการเข้ารหัสนี้ไม่ได้แข็งแรงมาก|
|ใช้ `ip ssh version 2`|CIS โดยตรง 2.1.1.2|v2.2.1 จัดเป็น Manual และให้ตรวจด้วยสถานะ SSH; การดูบรรทัด Config อย่างเดียวเป็น MVP approximation|
|ปิด Telnet|CIS โดยตรงผ่าน 1.2.2|CIS ต้องการ `transport input ssh` ภายใต้ VTY ทุกช่วง ไม่ใช่แค่หา `no transport input telnet`|
|ปิด `ip http server`|ไม่ใช่ Recommendation เดี่ยวที่ตรงคำ|ใกล้สุดคือ 1.1.5 ซึ่งกำหนด Authentication เมื่อเปิด HTTP/HTTPS; การปิด HTTP เป็น MyNetMate hardening rule/ทางเลือกหนึ่ง|
|SNMP ไม่ใช้ `public`/`private`|CIS โดยตรง 1.5.2 และ 1.5.3|เป็นการรวมสอง Recommendation และควรพิจารณากรณีไม่ได้ใช้ SNMP|
|VTY มี `access-class`|CIS โดยตรง 1.2.5|ต้องตรวจภายใต้ VTY ทุกช่วง และ CIS ยังมี Recommendation แยกสำหรับ ACL ที่ถูกอ้างถึง|
|มี Banner MOTD|CIS โดยตรง 1.3.3|เช็คเพียงคำว่า `banner motd` ยังไม่ยืนยันว่า Banner มีข้อความถูกต้องและปิด delimiter ครบ|

ข้อสรุป:

- ห้ามเรียกผล 8 ข้อนี้ว่า “ผ่าน CIS Benchmark”
- ชื่อที่ตรงกว่าอาจเป็น “MyNetMate Basic Security Baseline — selected checks derived from CIS IOS XE” แต่ยังต้องให้คุณยืนยัน
- `Critical / Warning / Info` เป็น Severity ของโครงการ ไม่ได้มาจาก CIS ซึ่งใช้ Profile Level และสถานะ Automated/Manual
- Benchmark 16.x และ 17.x จัดบาง Recommendation ต่างกัน เช่น SSH v2 เปลี่ยนจาก Automated เป็น Manual นี่เป็นหลักฐานชัดว่าควรเก็บ Benchmark version และ Rule version

### Regex เพียงอย่างเดียวพอหรือไม่

ยังไม่พอสำหรับทั้ง 8 กฎ:

- Regex แบบบรรทัดเดียวอาจพอสำหรับ `enable secret` และ `service password-encryption`
- `line vty`, `transport input` และ `access-class` ต้องรู้ความสัมพันธ์ Parent–Child และตรวจทุก VTY block
- SNMP ต้องตรวจ community ทุกบรรทัด รวมกรณีไม่ใช้ SNMP
- Banner มีรูปแบบ delimiter หลายบรรทัด
- SSH v2 ตาม CIS 17.x มีส่วนที่อาศัย Operational command
- HTTP มีเงื่อนไขระหว่าง HTTP, HTTPS, Authentication และการปิดบริการ

เอกสารยังขัดกันระหว่าง “Regex 8 ข้อ” ใน Weight List กับ `ciscoconfparse` ใน AGENTS/Proposal จึงยังไม่ควรเลือก Regex, Stateful Parser หรือ `ciscoconfparse` ก่อนปิด Input Contract และ Acceptance Criteria

## 4. สิ่งที่ยังเป็นเพียงข้อเสนอ

ยังไม่ใช่ User-confirmed decision:

- `Critical` บล็อกถาวร, `Warning` ข้ามได้, `Info` ไม่บล็อก
- Admin เท่านั้นที่ Override ได้
- Operator Deploy ได้แต่ Override ไม่ได้
- Override เป็นความสัมพันธ์ 1:1 กับ Scan Result
- Override มีวันหมดอายุหรือ Revoke ได้
- Dashboard ไม่นับ Critical finding ที่มี Active Override
- ใช้ Boolean `passed` เพียงค่าเดียว
- ชื่อตาราง `scan_results`, `cis_overrides` หรือชุดใหม่ `validation_runs`, `validation_findings`, `risk_acceptances`
- API เช่น `/api/cis/scan` และ `/api/cis/override/{id}`
- เก็บ Regex ในฐานข้อมูลหรือเก็บ Implementation ใน Source Code
- สแกน Full Config, Delta Config หรือ Effective Config หลัง Merge

## 5. จุดขัดกันหรือล้าสมัย

1. Proposal และ Knowledge Base เดิมกำหนด 24 Rules แต่ Scope ล่าสุดเหลือ 8
2. รายการ 8 กฎใน Data Schema ใช้ Console/VTY timeout แทน SNMP และ `access-class` จึงไม่ตรง Weight List
3. Raw Feature List บอก Critical ห้าม Override แต่ Working hypothesis, Schema และ Dashboard ออกแบบให้ Admin Override Critical ได้
4. Weight List บอก P1 เป็น Simulation และ Snapshot อยู่ P2 แต่ Component/Restore docs เดิมมี SSH Push และ Pre/Post Snapshot ใน P1
5. เอกสารอาจารย์รอบก่อนมี Protect Mode/Auto-Rollback แต่ Scope ล่าสุดตัด Auto-Rollback
6. เอกสารเก่าบางไฟล์ยังใช้ RAG, Presidio และ Full multi-vendor ซึ่งถูกยกเลิกหรือจำกัดแล้ว
7. Weight List บอก Regex ขณะที่ AGENTS และ Proposal ระบุ `ciscoconfparse`
8. Schema เดิมใช้ Boolean Pass/Fail จึงแยก Parse Error, Not Applicable และ Unable to Evaluate ไม่ได้
9. CIS ที่มีเป็น IOS XE ไม่ใช่หลักฐานรองรับ Cisco IOS ทุกรุ่น
10. `01_MVP Feature.md` ยังว่าง จึงยังไม่มีเอกสาร Feature ที่รวบรวม Correction ล่าสุด

## 6. คำศัพท์ที่ต้องกำหนดก่อน

- CIS Benchmark Recommendation
- CIS-inspired rule
- MyNetMate Security Baseline
- Candidate Config
- Config Delta/Snippet
- Full Config และ Effective Config
- Running Config/Snapshot
- Validation Run, Rule Result และ Finding
- Pass, Fail, Not Applicable, Unable to Evaluate และ Parse Error
- Severity เทียบกับ Gate Effect
- Rule Toggle
- Override/Risk Acceptance
- Active/Expired/Revoked Override
- Ruleset Version, Rule Version และ Parser Version
- Configuration Compliance เทียบกับ State Validation
- Gate Result และความสดใหม่ของผลตรวจ

## 7. Open Questions ที่ต้องปิดก่อนเขียน MVP

เรียงตามลำดับที่กระทบการออกแบบมากที่สุด:

1. P1 รับ Config จาก Config Builder อย่างเดียว หรือรับ Uploaded/Running Config ด้วย
2. Config Builder ส่ง Full Config หรือเฉพาะคำสั่งที่เปลี่ยน
3. ถ้าเป็น Delta ระบบจะรู้ Existing Config จากไหนเพื่อประเมิน Effective Config
4. Target จริงคือ Cisco IOS หรือ IOS XE รุ่นใด และเลือก Benchmark ฉบับใด
5. ผลต่อ Rule ใช้สถานะอะไร และ Parse Error อยู่ระดับ Run หรือ Rule
6. Final Rule Mapping ของทั้ง 8 ข้อ รวม Applicability และ Evidence ที่ยอมรับได้
7. Severity แต่ละระดับบล็อก Deployment อย่างไร
8. Critical Override ได้หรือไม่
9. ใคร Override ได้ และอนุญาตให้ผู้สร้าง Config อนุมัติของตนเองหรือไม่
10. Rule Toggle คือไม่รัน Rule, ไม่ Block หรือเพียงซ่อนผล
11. การปิด Rule ต้องบันทึกเหตุผล ผู้ดำเนินการ และช่วงเวลาหรือไม่
12. Override ผูกกับ Rule Result, Config hash, Device หรือ Deployment Plan
13. เมื่อ Config เปลี่ยน Override เดิมหมดผลทันทีหรือไม่
14. Evidence เก็บเพียงข้อความ หรือเก็บบรรทัด/Block ที่เกี่ยวข้องด้วย
15. Remediation เป็นคำแนะนำเท่านั้นและต้อง Mask secret อย่างไร
16. ต้องเก็บ Benchmark, Ruleset, Rule implementation และ Parser version ใดบ้าง
17. Dashboard ต้องนับ Failure แบบต่อ Rule, ต่อ Device หรือต่อผลสแกนล่าสุด
18. Deployment จะตรวจอย่างไรว่าผล Gate ยังตรงกับ Config เดิมและยังไม่หมดอายุ

## ลำดับการศึกษาที่แนะนำ

1. กำหนด Target Platform และคำเรียกผลลัพธ์ให้ไม่กล่าวอ้างเกินจริง
2. ปิด Input Contract: แหล่ง Config และ Full/Delta/Effective
3. ทำ Final Rule Mapping 8 ข้อกับ Benchmark และ Applicability
4. กำหนด Result State กับ Parse Error
5. กำหนด Gate, Severity, Toggle และ Override Policy
6. กำหนด External Data Contracts กับ Config Management, Inventory, Auth, Settings, Deployment, Dashboard และ Audit
7. จึงเริ่ม Step 1 เขียน Overview, Scope และ Non-goals

จบเฉพาะ Step 0 ตามที่ขอ และหยุดรอคำสั่งต่อไปครับ



# 1. กำหนด Target Platform และคำเรียกผลลัพธ์ให้ไม่กล่าวอ้างเกินจริง
ควรกำหนด 2 เรื่องแยกกันครับ:

2. ระบบ “ตั้งใจรองรับอะไร”
3. ผลตรวจ “พิสูจน์ได้แค่ไหน”

หากไม่แยกสองเรื่องนี้ เราอาจเผลอเขียนว่า “รองรับ Cisco” หรือ “ผ่าน CIS” ทั้งที่ทดสอบเพียงบางรุ่นและบางกฎ

## 1. กำหนด Target Platform เป็นหลายระดับ

คำว่า Target Platform ไม่ควรมีเพียง `Cisco` แต่ควรระบุอย่างน้อย:

| มิติ              | ต้องระบุ                                     |
| ----------------- | -------------------------------------------- |
| Vendor            | Cisco                                        |
| Network OS        | IOS, IOS XE หรือระบบอื่น                     |
| Version           | เช่น IOS XE 17.x                             |
| Device role       | Router, Layer-2 Switch หรือ Layer-3 Switch   |
| Config source     | Candidate Config, Running Config หรือทั้งสอง |
| Assessment source | Config text หรือ Operational command         |
| Test environment  | GNS3/Emulator หรืออุปกรณ์จริงใน Isolated Lab |
| Support status    | Candidate, Designed, Tested หรือ Verified    |

### ความหมายของ Support Status

- **Candidate** — มีแผนจะศึกษา แต่ยังไม่ได้ทดสอบ
- **Designed** — ออกแบบตามเอกสารทางการแล้ว แต่ยังไม่ผ่าน Lab
- **Tested** — ทดลองกับรุ่นและ OS ที่ระบุแล้ว
- **Verified** — ผ่าน Acceptance Tests ที่กำหนดครบ
- **Unsupported** — ไม่สามารถประเมินได้อย่างน่าเชื่อถือ

อย่าใช้คำว่า “Supported” โดยไม่มีรุ่น OS และหลักฐานทดสอบกำกับ

## 2. Target Platform ที่แนะนำสำหรับตอนนี้

ผมแนะนำให้กำหนดชั่วคราวดังนี้:

|Platform|สถานะ|
|---|---|
|Cisco IOS XE 17.x|Primary research target — ใช้ CIS v2.2.1|
|Cisco IOS XE 16.x|Conditional target — ใช้ CIS v2.2.0 เมื่ออุปกรณ์เป็น 16.x|
|Cisco IOS รุ่นอื่น|Candidate — ยังห้ามอ้างว่าใช้ CIS IOS XE ได้ตรงรุ่น|
|MikroTik RouterOS|Candidate test vendor|
|Huawei VRP|Candidate test vendor|

สาเหตุที่ต้องแยก IOS กับ IOS XE คือ CIS ที่มีใน Workspace เป็น Benchmark สำหรับ IOS XE 16.x และ 17.x โดยเฉพาะ และ CIS เตือนว่าการใช้ Benchmark ผิดรุ่นอาจทำให้ผล Pass/Fail ผิดได้

อ้างอิง CIS IOS XE 16.x CIS_Cisco_IOS_XE_16.x_Benchmark_v2.2.0.pdf และ IOS XE 17.x CIS_Cisco_IOS_XE_17.x_Benchmark_v2.2.1.pdf

หาก Cisco Switch ที่อาจารย์ให้ยืมไม่ใช่ IOS XE 16.x/17.x เราต้องเปลี่ยน Benchmark หรือเรียกกฎเหล่านั้นว่า MyNetMate rules แทน ไม่ควรนำผลจาก IOS XE ไปกล่าวอ้างกับ IOS อื่นตรง ๆ

## 3. ข้อความ Scope ที่แนะนำ

> MyNetMate Security & Validation รุ่น MVP ออกแบบโดยใช้ Cisco IOS XE เป็น Target Platform หลัก โดยเลือกตรวจเฉพาะกฎความปลอดภัยที่ระบบนำไปพัฒนาและทดสอบได้จริง กฎแต่ละข้อจะระบุ CIS Benchmark และ Version ที่ใช้อ้างอิงอย่างชัดเจน การรองรับอุปกรณ์จริงจะจำกัดเฉพาะรุ่น ระบบปฏิบัติการ และชุดคำสั่งที่ผ่านการทดสอบใน Isolated Lab เท่านั้น ส่วน Huawei VRP และ MikroTik RouterOS อยู่ในสถานะ Candidate Test Vendors และยังไม่ถือเป็น Full Support

แต่ก่อนยืนยันข้อความนี้ ต้องทราบ Cisco รุ่นจริงว่าใช้ IOS หรือ IOS XE รุ่นใด

## 4. ตั้งชื่อ Rule Pack ของเราเอง

ไม่ควรเรียกชุดกฎว่า:

- `CIS Compliance Engine`
- `CIS 14-Rule Benchmark`
- `Full CIS Scan`

ชื่อที่แนะนำ:

> **MyNetMate Cisco IOS XE Basic Security Baseline v1**

และกำกับว่า:

> Selected configuration checks mapped to CIS Cisco IOS XE 17.x Benchmark v2.2.1

ภาษาไทย:

> ชุดตรวจสอบความปลอดภัยพื้นฐานของ MyNetMate สำหรับ Cisco IOS XE โดยเลือกบางข้อและทำ Mapping กับ CIS Cisco IOS XE 17.x Benchmark v2.2.1

ประโยคนี้บอกตรงไปตรงมาว่าเราใช้เพียงบาง Recommendation ไม่ใช่ CIS Benchmark ทั้งฉบับ

## 5. แยกผลออกเป็น 3 ชั้น

### ชั้นที่ 1: ผลต่อ Rule

ใช้สถานะ:

|สถานะ|ความหมาย|
|---|---|
|`Pass`|หลักฐานที่ตรวจได้ตรงตามเงื่อนไขของ Rule นี้|
|`Fail`|มีหลักฐานชัดเจนว่าขัดกับ Rule นี้|
|`Not Applicable`|Rule นี้ไม่ใช้กับ Device หรือ Config ก้อนนี้|
|`Unable to Evaluate`|Input, Version หรือหลักฐานไม่พอที่จะตัดสิน|
|`Disabled by Policy`|Rule ถูกปิดตามนโยบาย จึงไม่ได้ประเมิน|

`Parse Error` ควรเป็น Error ของกระบวนการ ไม่ใช่ Security Failure

### ชั้นที่ 2: สรุป Validation Run

ไม่ควรใช้:

- `CIS Compliant`
- `Passed CIS Benchmark`
- `Secure`
- `100% Safe`

ควรแสดงเป็นข้อมูล เช่น:

> ตรวจประเมินสำเร็จ 12 จาก 14 กฎ: Pass 9, Fail 2, Not Applicable 1, Unable to Evaluate 2

หรือ:

> Validation completed with 2 failed rules and 2 unevaluated rules.

คำว่า `Pass` หมายถึงผ่านเฉพาะ Rule ที่ระบบ Implement และประเมินได้ ไม่ได้แปลว่าผ่าน CIS ทั้ง Benchmark

### ชั้นที่ 3: ผลของ Deployment Gate

แยกจากผล Rule:

|Gate Result|ความหมาย|
|---|---|
|`Allowed`|ไม่มี Failure ที่มีผลบล็อก|
|`Blocked`|มี Failure ที่นโยบายกำหนดให้บล็อก|
|`Exception Required`|ต้องได้รับการยอมรับความเสี่ยงจากผู้มีสิทธิ์|
|`Evaluation Incomplete`|มี Parse Error หรือ Unable to Evaluate ที่นโยบายไม่อนุญาตให้ Deploy|

การ Override ต้องไม่เปลี่ยน `Fail` เป็น `Pass` ตัวอย่าง:

> Rule result: Fail  
> Risk acceptance: Approved  
> Deployment gate: Allowed by authorized exception

แบบนี้ Audit ย้อนหลังจะยังเห็นว่ากฎไม่ผ่านจริง

## 6. คำที่ควรใช้และควรหลีกเลี่ยง

|หลีกเลี่ยง|ใช้แทน|
|---|---|
|ผ่าน CIS Benchmark|ผ่านกฎที่ระบบประเมินได้ 12 จาก 14 ข้อ|
|CIS Compliant|No blocking failure detected in the selected rule set|
|CIS Certified|Mapped to selected CIS recommendations|
|รองรับ Cisco|ทดสอบกับ Cisco รุ่น X, IOS XE รุ่น Y|
|รองรับ Multi-vendor|Huawei และ MikroTik อยู่ระหว่าง Candidate Lab Testing|
|Config ปลอดภัย|ไม่พบ Failure จากกฎที่เปิดใช้งานและประเมินได้|
|Rule ถูกปิดจึงผ่าน|Rule ไม่ได้ถูกประเมินเนื่องจากถูกปิดโดย Policy|
|Override แล้วผ่าน|Failure ได้รับ Authorized Risk Acceptance|

## 7. Decision ที่ควรยืนยันใน Step นี้

ข้อเสนอของผมคือ:

> กำหนด Research Baseline เป็น Cisco IOS XE 17.x และ CIS v2.2.1 ก่อน แต่ยังให้สถานะ `Designed/Unverified` จนกว่าจะทราบรุ่น Cisco จริง จากนั้นเลือกมากกว่า 10 กฎโดยไม่กำหนดเลขตายตัวล่วงหน้า และเรียกผลว่า “MyNetMate Basic Security Validation Results” ไม่ใช้คำว่า “CIS compliant”

ส่วน IOS XE 16.x จะใช้ Rule Mapping แยกต่างหากหากอุปกรณ์จริงเป็น 16.x และ Cisco IOS รุ่นอื่นจะยังอยู่ในสถานะ Candidate จนกว่าจะมี Benchmark และผลทดสอบตรงรุ่นครับ