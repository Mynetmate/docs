1. Verdict: **Not Approved**

มี P1 contract ที่ขัดกันจริงระหว่าง Audit Trail กับ Authentication จึงยังไม่ควรเริ่ม implement โดยถือว่าเอกสารพร้อมทั้งหมด

2. สิ่งที่ถูกต้อง พร้อมหลักฐานไฟล์
    - Scope P1 จำกัดเป็น Audit Trail แบบ append-only, centralized storage, Admin full read; ตัด SIEM, alerting, WORM และ advanced export ออกชัดเจน จึงไม่ขยายเป็น SIEM  
        [01_MVP - Audit Trail.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/01_MVP - Audit Trail.md)  
        [MyNetMate Weight Feature List.md (line 354)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/MyNetMate Weight Feature List.md:354)
        
    - ใช้ `audit_logs` ตารางเดียวตาม Central Schema และ Audit Trail ระบุห้ามสร้าง schema แข่งขัน  
        [Data Information.md (line 503)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/02_Device Inventory Management/Data Information.md:503)  
        [02_Data Ownership and Event Catalog.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/02_Data Ownership and Event Catalog.md)
        
    - `user_id` และ `resource_id` เป็น nullable; Auth กำหนด failed login ที่ไม่พบบัญชีให้ actor/resource เป็น `null` และ failed login ของบัญชีที่มีจริงให้ actor เป็น `null`, resource เป็นบัญชีเป้าหมาย  
        [Data Information.md (line 509)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/02_Device Inventory Management/Data Information.md:509)  
        [03_Component Diagram.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/03_Component Diagram.md)
        
    - `result` ถูกจำกัดเป็น `success`/`failure`; `safe_error_category` ถูกอธิบายว่าเป็นหมวดความผิดพลาดที่ปลอดภัย และ Auth map `login_failed` เป็น `authentication_error`, `permission_denied` เป็น `authorization_error`  
        [Data Information.md (line 513)](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/02_Device Inventory Management/Data Information.md:513)  
        [03_Component Diagram.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/03_Component Diagram.md)
        
    - กำหนด transaction boundary ไว้ชัด: producer ใช้ DB session เดียวกับ business action; มี acceptance test สำหรับ device rollback และ Auth มี test สำหรับ password-change rollback  
        [04_API Contracts.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/04_API Contracts.md)  
        [05_Acceptance Tests.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/05_Acceptance Tests.md)  
        [05_Acceptance Tests.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/05_Acceptance Tests.md)
        
    - ไม่มี Audit API สำหรับแก้ไขหรือลบ และ Full Audit จำกัด `audit.read` สำหรับ Admin  
        [01_MVP - Audit Trail.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/01_MVP - Audit Trail.md)  
        [06_Permission Catalog.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/06_Permission Catalog.md)
        
    - D&M Recent Activity ถูกกำหนดให้ใช้ positive allowlist 5 actions, cursor pagination (`created_at DESC, id DESC`) และ redaction/`Unknown` สำหรับ actor ที่ไม่ทราบตัวตน  
        [04_API Contracts.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/01_Dashboard&Monitoring(Naphat\)/04_API Contracts.md)  
        [06_Permission Catalog.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/06_Permission Catalog.md)
        
3. Blocker หรือ concern

**P1 blockers**

- Full Audit API ขัดกัน:

    - Audit contract ส่ง `user_id`, `created_at`, `ip_address`, `description`, pagination แบบ `offset`.
    - Auth contract ส่ง `actor_user_id`, `occurred_at`, ไม่มี `ip_address`/`description` ในตัวอย่าง, pagination แบบ `page`.
    
    ทั้งสองระบุ endpoint เดียวกันคือ `GET /api/audit-logs` จึง implement ตามทั้งคู่ไม่ได้  
    [04_API Contracts.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/04_API Contracts.md)  
    [04_API Contracts.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/04_API Contracts.md)
    
- Event catalog มี `user.deleted` แต่ Auth P1 ระบุให้ “Deactivate/Disable” และไม่ได้รองรับ user deletion. นอกจากนี้ catalog บอกว่า action เป็น `resource_type.action` แต่ `user.login_success` มีสามส่วนและใน Auth ใช้ `resource_type=auth` ไม่ใช่ `user`  
    [02_Data Ownership and Event Catalog.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/02_Data Ownership and Event Catalog.md)  
    [01_MVP - Authentication & RBAC.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/01_MVP - Authentication & RBAC.md)
    
- `record_audit_event()` รับ action เป็น string อิสระ แต่มี registry validation เฉพาะ `record_auth_event()` ของ Auth; ยังไม่มี global owner/validation ที่บังคับ canonical action, resource type และ safe-error category สำหรับ producer อื่น
    
- Acceptance tests ครอบคลุม login failed, rollback และ redaction แต่ permission denied ระบุเพียง “ต้องบันทึก” ใน Auth test โดยไม่มี assertion ของ row ที่เขียนจริง เช่น actor/resource/result/error category. Redaction test ยังเน้น password/credential secret เป็นหลัก ไม่ได้วัด token และ raw failed-login identifier ใน Full Audit API โดยตรง
    

**P1 concerns**

- `safe_error_category` ไม่มี allowed-value constraint กลาง และไม่ระบุ invariant ว่าเหตุการณ์ `success` ต้องเป็น `null` หรือเมื่อใดที่ failure ต้องมี category
- Full Audit อนุญาตให้ Admin เห็น raw client IP และ description ซึ่งอาจเหมาะกับ audit แต่ต้องกำหนดให้ชัดว่าเป็นข้อมูลจำเป็น, description ต้องผ่าน redaction ก่อน write, และห้ามใช้เป็นช่องเก็บ PII อิสระ

**P2**

- `config.deploy` ถูกระบุใน catalog เป็น P2 สอดคล้องกับ scope โดยรวม; ไม่ควร implement producer นี้ใน P1  
    [02_Data Ownership and Event Catalog.md](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/11_Audit Trail(Naphat\)/02_Data Ownership and Event Catalog.md)

4. Contract delta ที่ต้องให้ owner อื่นยืนยัน
    - **Auth + Audit owner:** เลือก DTO เดียวสำหรับ `GET /api/audit-logs`: ชื่อ field, การมี/ไม่มี IP และ description, และ pagination เพียงแบบเดียว
    - **Auth + Audit owner:** ตัด `user.deleted` ออกจาก P1 catalog หรือเพิ่ม Auth endpoint/scope ที่รองรับอย่างชัดเจน
    - **Audit owner:** ประกาศ global action registry และความสัมพันธ์ที่อนุญาตระหว่าง action/resource type/result/safe error category
    - **Dashboard + Audit owner:** ยืนยันว่า D&M ใช้ cursor-only ตาม D&M contract และไม่รับ Full Audit description/IP แม้ caller เป็น Admin
    - **Security/Auth owner:** กำหนด allowlist ของ `safe_error_category` กลาง และ policy ของ raw IP ใน Full Audit
5. รายการแก้ไขขั้นต่ำเพื่อให้ Ready to Implement
    
6. Reconcile `GET /api/audit-logs` ให้เหลือ contract เดียว พร้อม response และ pagination ตัวอย่างเดียว
    
7. ปรับ canonical event catalog: ลบ `user.deleted` ใน P1 และนิยาม action ว่าเป็น canonical dotted event แทนการอ้างว่าเท่ากับ `resource_type.action`
    
8. กำหนด registry กลางสำหรับทุก producer พร้อม validation ของ action/resource/result/error category
    
9. เพิ่ม acceptance test ที่ query ตรวจ row ของ `auth.permission_denied`, และ test ยืนยันว่า Full Audit/D&M ไม่เผย token, password, raw failed-login identifier หรือ description ที่ยังไม่ redacted
    
10. ระบุ invariant ของ `safe_error_category` และ policy/IP exposure สำหรับ Full Audit ให้เป็นสัญญาเดียวกัน
    
                
เอกสารมีฐานที่ดีหลายส่วน แต่ข้อความใน Integration Matrix ที่บอกว่า “ไม่มีความขัดแย้ง” ยังไม่ตรงกับ API contract และ event catalog ที่มีอยู่จริงครับ

เพื่อให้การแก้ไขรัดกุมและตอบโจทย์ AD อย่างครบถ้วน ผมได้ลิสต์รายการสิ่งที่จะต้องเข้าไปแก้ไข (Action Plan) แบ่งตามแต่ละไฟล์เป็นข้อๆ ดังนี้ครับ เพื่อให้ท่านพิจารณาก่อนลงมือจริง:


สิ่งที่จะให้ Gemini ทำคือ
### 📄 1. สิ่งที่จะแก้ใน `04_API Contracts.md` (API & Invariants)
- **ปรับรวม Contract `GET /api/audit-logs` (Full Audit):**
  - **DTO Naming:** เปลี่ยนไปใช้ `actor_user_id` และ `occurred_at` (ตามที่เอกสาร Auth ระบุไว้) เพื่อไม่ให้ชื่อฟิลด์ขัดแย้งกัน
  - **Pagination:** เสนอให้ใช้ระบบ **Cursor Pagination** (สอดคล้องกับ D&M) หรือระบุให้ชัดเจนไปเลยเพื่อแทนที่ `page` ในเอกสาร Auth
  - **Fields:** ระบุชัดเจนว่าต้องคืนค่า `ip_address` และ `description` ด้วย (ซึ่งฝั่ง Auth ตกหล่นไป)
- **เพิ่มกฎ Invariant พื้นฐาน (Data Integrity):**
  - กฎที่ 1: หาก `result == 'success'` ฟิลด์ `safe_error_category` **ต้องเป็น** `null` เสมอ
  - กฎที่ 2: หาก `result == 'failure'` ต้องมีหรือไม่มี `safe_error_category` ตาม Allowlist ที่กำหนด
- **เพิ่มนโยบาย IP Exposure & Description:**
  - เขียนกำกับชัดเจนว่า `ip_address` และ `description` ถูกเปิดเผยเฉพาะใน Full Audit API เท่านั้น เพื่อจุดประสงค์ด้าน Security Audit
  - `description` ต้องผ่านกระบวนการ Redact ก่อนถูกเขียนลงฐานข้อมูลเสมอ (ห้ามใช้ API เป็นตัวกรองออกทีหลัง)

Created 04_API%20Contracts.md

ผมได้ทำการแก้ไขไฟล์ `04_API Contracts.md` ของฝั่ง Audit Trail ตามคำสั่งเรียบร้อยแล้วครับ 

### 📝 สรุปส่วนที่แก้ไขในไฟล์นี้:
1. **DTO Naming:** เปลี่ยนไปใช้ `actor_user_id` และ `occurred_at` แทนชื่อคอลัมน์ดิบๆ พร้อมระบุชัดเจนว่าฟิลด์ไหนสามารถเป็น `null` ได้บ้าง
2. **Cursor Pagination:** ยกเลิกระบบ Page/Offset ทั้งหมด และบังคับใช้ Cursor Pagination (`limit`, `cursor`) เท่านั้น พร้อมระบุให้เรียงข้อมูลตาม `created_at DESC, id DESC` และคืนค่าในรูปแบบ `{ "data": [...], "next_cursor": "..." }`
3. **Response Example:** เพิ่มตัวอย่าง JSON Response ที่คืนค่า `ip_address` และ `description` ได้อย่างถูกต้องครบถ้วนตาม DTO ใหม่
4. **Data Integrity Invariants:** บัญญัติกฎเหล็กความสัมพันธ์ระหว่าง `result` และ `safe_error_category` ไว้อย่างชัดเจน (Success = null, Failure = allowlist จาก Global Action Registry)
5. **IP Exposure & Description Policy:** กำหนดนโยบายห้ามเผยแพร่ผ่าน D&M และบังคับ Redaction ก่อน Insert ลง Database (รวมถึงสั่งแบนการเก็บค่า Password, Token, และ Raw Failed-login Identifier)

---

### ⚠️ จุดที่ต้องส่งให้ Auth Owner ยืนยันหรือปรับปรุงในไฟล์ของ Auth (`04_API Contracts.md`):
เพื่อให้ Contract ของ Endpoint `GET /api/audit-logs` เป็นหนึ่งเดียวกัน ทีม Auth จำเป็นต้อง:
1. ยอมรับและแก้ไข Pagination ในเอกสารของตนเอง **ให้เปลี่ยนจาก `page` ไปใช้ Cursor Pagination เหมือนกัน** 
2. อัปเดต Response DTO ในฝั่ง Auth **ให้ครอบคลุมการคืนค่า `ip_address` และ `description`** (แม้จะไม่มีหรือถูกซ่อนก็ตาม ต้องให้โครงสร้างตรงกัน)
3. ยืนยันว่าเข้าใจนโยบาย Data Privacy ที่ห้ามส่ง Token หรือ Raw Failed-login identifier ลงมาใน description ตั้งแต่ต้นทาง

*(หมายเหตุ: ณ ตอนนี้สถานะของ Cross-feature Contract ยัง **ถือว่ายังไม่สมบูรณ์และยังไม่ Reconciled** จนกว่า Auth Owner จะทำการยืนยันการใช้ DTO และ Cursor Pagination ชุดเดียวกันนี้ครับ)*
Edited 04_API%20Contracts.md
Edited 05_Acceptance%20Tests.md
Edited 02_Data%20Ownership%20and%20Event%20Catalog.md
Viewed 04_API%20Contracts.md:1-90
Edited 04_API%20Contracts.md
Edited 05_Acceptance%20Tests.md
Edited 06_Integration%20Contract%20Matrix.md

จัดให้ตามคำขอของทีม Auth (คุณนภัทร) และเก็บงานฝั่ง Audit ครบทุกจุดแล้วครับ! 

คราวนี้เป็นการปรับแก้ตาม "แนวทาง Ownership ที่ถูกต้อง" จริงๆ เพื่อลดปัญหาเอกสารซ้ำซ้อนในอนาคตครับ:

### 🛠️ 1. งานที่แก้ในฝั่งทีม Auth
- **`04_API Contracts.md` (หัวข้อ 2.7):** ลบสเปค DTO และ Pagination เดิมทิ้งทั้งหมด แล้วเขียนข้อความว่า *"ให้ไปอ้างอิง Source of Truth จากเอกสาร `02_feature/11_Audit Trail(Naphat)/04_API Contracts.md`"* (แบบนี้ดีกว่าจริงๆ ครับ ในอนาคตถ้า Audit เติมฟิลด์ เอกสาร Auth จะได้ไม่ตกหล่น)
- **`05_Acceptance Tests.md` (ข้อ 12):** เพิ่มกฎ Privacy ชัดเจนว่า ห้ามส่ง Password (Plaintext/Hash), JWT, Token, Credential Secret หรือ Raw identifier (เช่น username ที่พิมพ์ผิด) ลงมาใน Description

### 🛠️ 2. งานที่เก็บตกในฝั่งทีม Audit
- **`02_Data Ownership and Event Catalog.md`:** ลบ `user.deleted` ออกจากแคตตาล็อก P1 แล้วครับ (เหลือแค่ `user.deactivated` ตามสเปคของ Auth)
- **`04_API Contracts.md` (Internal Contract):** เพิ่มคำสั่งชัดเจนให้ `record_audit_event()` ทำหน้าที่เป็น **Gatekeeper** โดยต้อง Validate กับ Global Action Registry และทำการ Redact ข้อความที่ดูคล้าย Secret บนฝั่ง Server-side เลย (ไม่โยนภาระให้ Producer 100%)
- **`05_Acceptance Tests.md` (ข้อ 7):** ลบคำว่า `offset` ทิ้งไปแล้ว บังคับใช้คำว่า `cursor` ล้วนๆ ใน Test Scenario
- **`06_Integration Contract Matrix.md`:** เปลี่ยนสถานะกลับมาเป็น **"Reconciled สอดคล้องและอัปเดตแล้ว"** โดยระบุว่าทั้ง 2 ฝั่งตกลงใช้ Single Source of Truth เดียวกันครับ

ตอนนี้โครงสร้างการเชื่อมต่อระหว่าง 2 ฝั่งเคลียร์ชัดเจน ไร้รอยต่อ และไม่มีการอ้างสิทธิ์ทับซ้อนกันแล้วครับ! พร้อมส่งให้ AD ตรวจสอบรอบที่ 2 (และน่าจะผ่านฉลุย) แล้วครับผม! 🚀




### 📄 2. สิ่งที่จะแก้ใaน `02_Data Ownership and Event Catalog.md` (Catalog & Validation)
- **ตัด `user.deleted` ออก:** เพื่อให้ตรงกับ Auth P1 ที่รองรับแค่ระงับบัญชี (Deactivate/Disable)
- **นิยาม Action Format ใหม่:** 
  - เปลี่ยนคำอธิบายจากรูปแบบ `resource_type.action` เป็น **"Canonical Dotted Event Format"** (เช่น `domain.action_result`) เพื่อให้รองรับชื่ออย่าง `user.login_success` ได้ถูกต้องโดยไม่สับสนกับฟิลด์ `resource_type`
- **เพิ่ม Global Action Registry:**
  - สร้างตารางกลางที่กำหนดตายตัวเลยว่า Action นี้ ต้องคู่กับ Resource Type, Result และ Safe Error Category อะไรบ้าง (เช่น `user.login_failed` ต้องบังคับใช้ `resource_type=auth`, `result=failure`, `safe_error_category=authentication_error`) เพื่อบังคับให้ฟังก์ชัน `record_audit_event()` เช็คความถูกต้อง
Viewed 02_Data%20Ownership%20and%20Event%20Catalog.md:1-45
Created 02_Data%20Ownership%20and%20Event%20Catalog.md

ผมได้ดำเนินการแก้ไขไฟล์ `02_feature/11_Audit Trail(Naphat)/02_Data Ownership and Event Catalog.md` ตามคำสั่งของ AD ครบถ้วนแล้วครับ

นี่คือสรุปภาพรวมของการเปลี่ยนแปลง:

### 🗑️ 1. Action ที่ลบหรือเปลี่ยนสถานะ
- **ลบออกถาวร:** `user.deleted` (ถูกลบออกจาก Catalog เนื่องจาก Auth P1 รองรับแค่การ Deactivate/Disable เท่านั้น)
- **เปลี่ยนสถานะ:** `config.deploy` (ยังคงอยู่ใน Catalog แต่ถูกแปะป้ายกำกับชัดเจนว่าเป็น **[P2 Only]** และห้ามนำมาเป็น Requirement ในการ Implement งาน P1)

### 📋 2. Global Registry Rules ที่เพิ่มเข้ามาใหม่
มีการเพิ่มตาราง `Global Action Registry` เป็นแกนกลางในการตรวจสอบ (Gatekeeper) และบังคับกฎ (Enforcement) ดังนี้:
- **Strict Validation:** Action ที่ไม่อยู่ใน Registry, หรือส่ง `resource_type`, `result`, `safe_error_category`, และ Actor/Resource binding ไม่ตรงกับเงื่อนไขใน Registry จะต้องถูก **Reject ทันที**ก่อน Insert
- **Bypass Prevention:** Caller ไม่สามารถส่ง Action หรือ Error Category เข้ามามั่วๆ เพื่อเจาะข้าม Catalog ได้
- **P1 Default Rules:** สำหรับ Producer อื่นๆ (Device, Config, CIS, Settings) เมื่อสำเร็จ `safe_error_category` ต้องเป็น `null` เสมอ และไม่อนุญาตให้ยิง Log ตอน Failure แบบ Ad-hoc หากยังไม่เคยมีการกำหนด Intentional Failure ไว้ใน Registry มาก่อน
- **Redaction Rule:** ยืนยันหน้าที่ของ `record_audit_event()` ที่ต้องทำการ Redact ข้อมูลก่อนเขียนลง DB 
- **Safe Error Allowlist:** ตีกรอบให้ใช้งานได้เพียง `authentication_error`, `authorization_error`, `validation_error`, `invalid_request`, `server_error`, และ `null` เท่านั้น

### 🤝 3. รายการที่ต้องให้ Auth Owner ยืนยัน (Cross-feature confirmation)
ก่อนที่เราจะเปลี่ยนสถานะใน Integration Matrix เป็น "Reconciled" ได้อย่างสมบูรณ์ ขอให้ Auth Owner ตรวจสอบและยืนยัน 2 ประเด็นนี้ครับ:
1. **ยืนยัน Registry Binding:** กฎการ Binding ของ `user.login_failed` ทั้ง 2 กรณี (กรณีไม่พบบัญชีใช้ `resource_type=auth` และกรณีรหัสผิดใช้ `resource_type=user`) สอดคล้องกับพฤติกรรมใน Auth Contract หรือไม่
2. **ยืนยัน Allowlist:** การเพิ่มหมวดหมู่ `validation_error` เข้าไปใน Allowlist เพียงพอต่อการใช้งานของฝั่ง Auth หรือไม่

หลังจาก Auth Owner ยืนยัน 2 จุดนี้แล้ว เราถึงจะก้าวไปอัปเดตไฟล์อื่นๆ ที่เหลือและประกาศ Reconciled ได้ครับ!


ทีม Auth ยืนยันข้อ 1 ครับ:

- ไม่พบบัญชี: `user.login_failed`, `resource_type=auth`, `resource_id=null`, `actor_id=null`
    
- พบบัญชีแต่ password ผิด: `user.login_failed`, `resource_type=user`, `resource_id=<target_user_id>`, `actor_id=null`
    

ตรรกะนี้ตรงกับ Auth Component Diagram และ Acceptance Tests ปัจจุบัน

สำหรับข้อ 2 ยังขอไม่ประกาศ Reconciled ครับ เพราะ Auth ใช้คำว่า `invalid_request` อยู่เดิม ขณะที่ Audit เสนอ `validation_error` ซึ่งความหมายทับกัน

ข้อเสนอของ Auth คือใช้ `validation_error` เป็นคำกลางเพียงคำเดียว และตัด `invalid_request` ออกจาก allowlist เพื่อไม่ให้เกิด synonym ใน Global Action Registry

อย่างไรก็ตาม P1 จะไม่เขียน audit log สำหรับ validation error/HTTP 400 หรือ 422 ทั่วไปทุกครั้ง เพื่อลด log noise และลดความเสี่ยงที่ request body หรือ identifier ดิบจะหลุดเข้า description หากภายหลังต้อง audit กรณีนี้จริง ให้กำหนด canonical action แยกและห้ามบันทึก raw request data โดยเด็ดขาดครับ

Audit Trial ทีม
Edited 02_Data%20Ownership%20and%20Event%20Catalog.md
Edited 02_Data%20Ownership%20and%20Event%20Catalog.md

ผมได้ดำเนินการอัปเดตไฟล์ `02_feature/11_Audit Trail(Naphat)/02_Data Ownership and Event Catalog.md` ตามข้อเสนอและเงื่อนไขของทีม Auth เรียบร้อยแล้วครับ (และไม่ได้แตะไฟล์อื่นเลยตามคำสั่ง)

นี่คือสรุปผลการปรับแก้ในรอบนี้ครับ:

### 🗑️ 1. Action/คำศัพท์ ที่ลบหรือเปลี่ยนสถานะ
- **ลบคำศัพท์:** ลบ `invalid_request` ออกจาก Safe Error Category Allowlist แล้ว เพื่อให้เหลือเพียงคำว่า `validation_error` คำเดียว ป้องกันความซ้ำซ้อน (Synonym) ตามที่ Auth ร้องขอ

### 📋 2. Global Registry Rules ที่เพิ่ม
- **เพิ่มกฎ Validation Error Policy:** ระบุชัดเจนว่าในระยะ P1 จะไม่มีการบันทึก Audit Log สำหรับเคส Validation Error ทั่วไป (เช่น HTTP 400, 422) ทั้งนี้เพื่อลด Log Noise และป้องกันไม่ให้ Raw Request Body หรือ PII ดิบหลุดเข้ามาในคอลัมน์ `description` หากอนาคตต้องมีการเก็บ Log ส่วนนี้ จะต้องสร้าง Canonical Action แยกต่างหากและห้ามบันทึกข้อมูลดิบเด็ดขาด

### ✅ 3. รายการที่ต้องให้ Auth Owner ยืนยัน
- **ไม่มีแล้วครับ:** เนื่องจาก Auth Owner ได้ยืนยันครบถ้วนทั้งเรื่องโครงสร้าง Registry ของ `user.login_failed` ทั้งสองกรณี และตกลงเรื่องการใช้ `validation_error` เรียบร้อยแล้ว ผมจึงได้ **ลบหัวข้อ "Cross-feature confirmation required" ออกจากเอกสาร** ถือว่าประเด็นระหว่าง Auth และ Audit ใน Event Catalog นี้จบลงอย่างสมบูรณ์แบบครับ!
### 📄 3. สิ่งที่จะแก้ใน `05_Acceptance Tests.md` (Test Coverage)
- **เพิ่ม Test สำหรับ `auth.permission_denied`:**
  - ทดสอบว่าเมื่อเกิด 403 Forbidden ข้อมูลที่เขียนลง DB จะต้องระบุ `action=auth.permission_denied`, `result=failure`, `safe_error_category=authorization_error` อย่างถูกต้องครบถ้วน
- **ปรับปรุง Test การปกปิดข้อมูล (Redaction Test):**
  - นอกจากเช็ค Password ขาเข้าแล้ว จะเพิ่มการทดสอบให้เช็ค **JWT Token, ข้อมูล Credential Secret, และ Raw Failed-login Identifier** (เช่น พิมพ์ username ผิดเป็น `admin_fake_123` จะต้องไม่ถูกเก็บลง `description`) 
  - ตรวจสอบผ่าน Full Audit API ว่าไม่มีข้อมูลเหล่านี้หลุดออกไป

### 📄 4. สิ่งที่จะแก้ใน `06_Integration Contract Matrix.md` (Cross-Feature Delta)
- **เปลี่ยนสถานะของ Auth เป็น "⚠️ มี Delta ที่เสนอให้เจ้าของ Feature พิจารณา"** โดยมีรายการแก้ไขดังนี้:
  - **ให้ Auth:** ยอมรับรูปแบบ Pagination และยืนยัน DTO (`actor_user_id`, `occurred_at`, `ip_address`, `description`) สำหรับ `GET /api/audit-logs` เป็นมาตรฐานเดียวกัน
  - **ให้ Auth:** อัปเดต Validation ให้ตรงกับ Global Registry ของ Audit Trail
- **เปลี่ยนสถานะของ Dashboard (D&M) เป็น "⚠️ มี Delta ที่เสนอให้พิจารณา"**
  - **ให้ D&M:** ยืนยันว่าการอ่าน Recent Activity ผ่าน DB (ORM) มีการตัด `ip_address` และ `description` ทิ้ง ก่อนส่งให้ UI ตาม Contract เดิม แม้คนเรียกดูจะมี Role เป็น Admin ก็ตาม

### 📄 5. สิ่งที่จะแก้ใน `00_Glossary.md`
- อัปเดตนิยามของ **Action (Canonical Name)** ให้สะท้อนรูปแบบ Dotted Event ที่ยืดหยุ่นขึ้น
- เพิ่มนิยาม **Invariant Rules** (ความสัมพันธ์ของ Result และ Safe Error Category)

ท่านเห็นด้วยกับแนวทางการปรับปรุงทั้ง 5 ข้อนี้ไหมครับ? หากมีข้อไหนที่ต้องการให้ปรับวิธีแก้ หรือเพิ่มประเด็นไหนอีก สามารถแจ้งได้เลยครับ


เห็นด้วยกับทั้ง 5 ข้อ และเป็นแนวแก้ที่ตรงกับ blocker ที่พบครับ

ขอเพิ่มเงื่อนไขขั้นต่ำ 3 ข้อก่อนถือว่า Ready:

- Global Action Registry ต้องครอบคลุมทุก P1 producer ไม่ใช่เฉพาะ Auth: Device, Config Generate, CIS, Settings ด้วย และระบุ `config.deploy` ว่า P2 ชัดเจน
- กฎ failure ต้องไม่เขียนคลุมเครือว่า “มีหรือไม่มีตาม allowlist” แต่ registry ต้องกำหนดราย action ไปเลยว่า `safe_error_category` เป็นค่าใดหรือเป็น `null` ได้ เช่น `auth.permission_denied → authorization_error`; ส่วน failure ที่ไม่มี category ต้องระบุ action ที่อนุญาตไว้ชัดเจน
- ต้องแก้หรือให้ Auth owner ยืนยันแก้ [Authentication API Contract](E:/CEPP Project/หลักศูตร/KMITL_Knowledge/Project/02_feature/00_Authentication(Naphat\)/04_API Contracts.md) จริง เพราะการแก้เฉพาะเอกสาร Audit แล้ว endpoint เดียวกันยังระบุ pagination/fields คนละแบบอยู่ ความขัดแย้งจะยังไม่หาย

แนะนำเพิ่ม Acceptance Test อีกหนึ่งกรณี: D&M ต้องพิสูจน์ว่า query เหตุการณ์นอก positive allowlist จะไม่ออกสู่ UI, cursor ไม่ซ้ำ/ไม่ข้าม, และตัด `ip_address`/`description` แม้ผู้เรียกเป็น Admin

เมื่อทำตามนี้และ Auth/D&M owner ยืนยัน delta แล้ว แนวทางนี้เพียงพอให้เปลี่ยน verdict เป็น **Approved with Conditions** ได้ครับ