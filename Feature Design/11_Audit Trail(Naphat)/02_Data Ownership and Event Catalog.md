# Data Ownership and Event Catalog

เอกสารนี้กำหนดการเป็นเจ้าของข้อมูล (Data Ownership) และแค็ตตาล็อกเหตุการณ์มาตรฐาน (Canonical Events) ตลอดจนการตรวจสอบก่อนบันทึกข้อมูลเข้าฐานข้อมูล

## 1. Data Ownership
- **Schema Owner:** โครงสร้างตาราง `audit_logs` ต้องอ้างอิงตาม **Central Schema** ในเอกสาร `02_feature/Data Information 27-06-69.md` อย่างสมบูรณ์ ห้ามสร้าง Schema หรือ Table สำหรับ Audit แข่งขัน
- **Write Owner:** Feature Audit Trail เป็นเจ้าของฟังก์ชันภายใน (internal writer) ชื่อ `record_audit_event()`
- **Read Owner:** Feature Audit Trail เป็นเจ้าของ Full Audit API (`GET /api/audit-logs`) ในขณะที่ Feature D&M ทำหน้าที่เป็นเพียง Read-only Consumer สำหรับ API เส้น Recent Activity

## 2. Event Catalog (Canonical Actions)
รูปแบบของ Action จะต้องใช้ **Canonical Dotted Event Format** 

- **นิยาม:** Action เป็นชื่อเหตุการณ์ที่ใช้เครื่องหมายจุด (Dotted Event) เช่น `user.login_success`, `auth.permission_denied`, `device.create`
- **ความหมายของ Segment:** Segment แรกของ Action **ไม่จำเป็นต้องตรงกับฟิลด์ `resource_type`** ในฐานข้อมูล เนื่องจาก `resource_type` เป็น Field แยกต่างหากที่ Global Action Registry จะเป็นคนกำหนดความสัมพันธ์ให้ (เช่น Action `user.login_failed` อาจมี `resource_type` เป็น `auth` หรือ `user` ก็ได้ ขึ้นอยู่กับ Registry)
- ไม่จำเป็นต้องพยายามเปลี่ยนชื่อ Canonical Actions ที่มีอยู่เดิมเพียงเพื่อให้มันเหลือสอง Segment

**รายการ Action ที่อนุญาตใน P1 (ห้ามเพิ่ม Action ใหม่ที่อยู่นอกเหนือ P1 Scope):**

### 2.1 Authentication & User Management (P1)
- `user.login_success`
- `user.login_failed`
- `user.logout`
- `user.password_changed`
- `user.created`
- `user.updated`
- `user.deactivated`
- `auth.permission_denied`
*(หมายเหตุ: ลบ `user.deleted` ออกเนื่องจาก Auth P1 รองรับเพียง Deactivate/Disable เท่านั้น ไม่ใช่ Hard delete)*

### 2.2 P1 Producer Actions
- `device.create`
- `device.update`
- `device.delete`
- `config.generate`
- `scan.run`
- `scan.override`
- `settings.update`

### 2.3 P2 Producer Actions
- `config.deploy` **[P2 Only]** *(ห้ามถือเป็น P1 implementation requirement)*

## 3. Global Action Registry and Writer Validation
ฟังก์ชัน `record_audit_event()` ต้องทำการ Validate ค่าพารามิเตอร์เทียบกับตารางกลางนี้เสมอ ก่อนที่จะทำการ Insert ลงฐานข้อมูล

### 3.1 Mapping Auth (สอดคล้องกับเอกสาร Auth ปัจจุบัน)
| Canonical Action | Phase | Allowed `resource_type` | `result` | Allowed/Required `safe_error_category` | Actor/Resource Binding Rule |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `user.login_success` | P1 | `auth` | `success` | `null` | actor เป็น user ที่ login สำเร็จ, `resource_id=null` |
| `user.login_failed` (ไม่พบบัญชี) | P1 | `auth` | `failure` | `authentication_error` | `actor_user_id=null`, `resource_id=null` |
| `user.login_failed` (รหัสผ่านผิด) | P1 | `user` | `failure` | `authentication_error` | `actor_user_id=null`, `resource_id` เป็น target user |
| `user.logout` | P1 | `auth` | `success` | `null` | actor เป็น user ปัจจุบัน |
| `user.password_changed` | P1 | `user` | `success` | `null` | actor และ resource เป็น user เดียวกัน |
| `user.created` | P1 | `user` | `success` | `null` | actor เป็น Admin, resource เป็น user ใหม่ |
| `user.updated` | P1 | `user` | `success` | `null` | actor เป็น Admin, resource เป็น target user |
| `user.deactivated` | P1 | `user` | `success` | `null` | actor เป็น Admin, resource เป็น target user |
| `auth.permission_denied` | P1 | `auth` | `failure` | `authorization_error` | actor เป็น authenticated user ที่ถูกปฏิเสธ; `resource_id` เป็น UUID ของ target (nullable ได้ถ้าเป้าหมายไม่มี UUID) |

### 3.2 Mapping สำหรับ P1 Producer อื่นๆ
| Canonical Action | Phase | Allowed `resource_type` | `result` | Allowed/Required `safe_error_category` | Actor/Resource Binding Rule |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `device.create` | P1 | `device` | `success` | `null` | actor เป็น current user, resource เป็น device ใหม่ |
| `device.update` | P1 | `device` | `success` | `null` | actor เป็น current user, resource เป็น target device |
| `device.delete` | P1 | `device` | `success` | `null` | actor เป็น current user, resource เป็น target device |
| `config.generate` | P1 | `config` | `success` | `null` | actor เป็น current user, resource เป็น target config-history ID |
| `scan.run` | P1 | `device` | `success` | `null` | actor เป็น current user, resource เป็น target device ID |
| `scan.override` | P1 | `scan` | `success` | `null` | actor เป็น Admin, resource เป็น target scan_result_id |
| `settings.update` | P1 | `settings` | `success` | `null` | actor เป็น Admin, resource เป็น null เสมอ (global setting) |

*(หมายเหตุ: หากใน P1 Scope ยังไม่มี Intentional Failure Event สำหรับระบบเหล่านี้ จะไม่อนุญาตให้ Caller บันทึก Failure Action แบบ Ad-hoc ได้ หากต้องการบันทึก ต้องมาเพิ่ม Registry Entry ในตารางนี้ก่อนเสมอ)*

## 4. Safe Error Category Allowlist & Enforcement
ค่าของ `safe_error_category` อนุญาตให้ใช้เฉพาะค่าจาก Global Allowlist ดังนี้:
- `authentication_error`
- `authorization_error`
- `validation_error` *(Reserved: สงวนไว้ ยังใช้งานไม่ได้จนกว่าจะมีการเพิ่ม Registry Entry ในอนาคต)*
- `server_error` *(Reserved: สงวนไว้ ยังใช้งานไม่ได้จนกว่าจะมีการเพิ่ม Registry Entry ในอนาคต)*
- `null` (เฉพาะเมื่อ Registry อนุญาตให้ใช้ได้)

**กฎการบังคับใช้ (Enforcement Rules):**
1. Action ใดที่ไม่อยู่ใน Registry ต้องถูก **Reject** ก่อน Insert
2. หากค่า `resource_type`, `result`, `safe_error_category` หรือ Actor/Resource Binding ไม่ตรงตามเงื่อนไขที่กำหนดใน Registry ต้องถูก **Reject** ก่อน Insert
3. Caller ห้ามส่ง Action หรือ Error Category เข้ามาอย่างอิสระเพื่อ Bypass Catalog เด็ดขาด
4. ฟังก์ชัน `record_audit_event()` ต้องทำงานอยู่ใน DB Session เดียวกับ Business Transaction
5. ต้องทำกระบวนการ Redaction (ปิดบังข้อมูลความลับ) ก่อนเขียนลงฐานข้อมูล (Write) เสมอ
6. **Validation Error Policy:** ในระยะ P1 จะไม่มีการบันทึก Audit Log สำหรับ Validation Error หรือ HTTP 400/422 ทั่วไป (เช่น การกรอกฟอร์มผิด) เพื่อลด Log Noise และป้องกันความเสี่ยงที่ข้อมูลดิบใน Request Body จะหลุดเข้ามาใน Description หากมีความจำเป็นต้องใช้ในอนาคต จะต้องกำหนด Canonical Action แยกเฉพาะ และห้ามบันทึก Raw Request Data โดยเด็ดขาด


