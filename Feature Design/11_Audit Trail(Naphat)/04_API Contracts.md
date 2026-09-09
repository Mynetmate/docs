# API Contracts

เอกสารนี้ระบุรายละเอียดของ Contract ทั้งแบบภายใน (Internal) และภายนอก (REST API) สำหรับ Audit Trail

## 1. Internal Contract (Producer Interface)
ฟังก์ชันนี้ออกแบบมาให้ Feature อื่นเรียกใช้ใน Backend (Python/FastAPI)

```python
async def record_audit_event(
    db: AsyncSession,          # Business transaction หรือ intentional audit transaction ตาม Event Type
    action: str,
    resource_type: str,
    result: str,
    user_id: UUID | None = None,
    resource_id: UUID | None = None,
    safe_error_category: str | None = None,
    description: str | None = None
) -> None:
    pass
```
*หมายเหตุ:*
1. *ห้ามมี API หรือฟังก์ชันสำหรับการแก้ไข (Update) หรือลบ (Delete) ข้อมูล Audit Log เพื่อรักษา Append-Only Policy*
2. *ฟังก์ชัน `record_audit_event` จะต้องทำหน้าที่เป็นด่านหน้า (Gatekeeper) โดยตรวจสอบความถูกต้องของ `action`, `resource_type`, `result` และ `safe_error_category` เทียบกับ **Global Action Registry** เสมอ หากข้อมูลไม่ตรงตามสเปค ต้อง Reject ทันที*
3. *ฟังก์ชันจะต้องมีกระบวนการ Redaction พื้นฐานอยู่ภายใน (Server-side redaction) เพื่อดักจับและลบข้อมูลที่ดูคล้าย Secret, Password หรือ Token ออกจาก `description` ก่อนลง DB เสมอ ไม่ควรคาดหวังให้ Producer ทุกตัวส่งข้อมูลมาถูกต้อง 100%*
4. *Business Mutation Event ต้องใช้ DB Session/Transaction เดียวกับ Business Action ส่วน `user.login_failed` และ `auth.permission_denied` ต้องใช้ Intentional Audit Transaction แยกที่ Commit ได้แม้ Request หลักถูกปฏิเสธ*
5. *Auth Caller ใช้ Wrapper ที่รับ 4 Business Arguments เท่านั้นและห้ามส่ง Client IP หรือ `description`; Wrapper/Audit Writer เป็นผู้กำหนด `description=null` หรือ Fixed Safe Template ภายใน*
6. *หาก Mandatory Audit Write ล้มเหลว ระบบต้อง Fail Closed และตอบ `503 AUTH_SERVICE_UNAVAILABLE`; กรณี Login สำเร็จห้ามออก Session/Cookie หาก Session Row และ Audit Row ยัง Commit ไม่สำเร็จพร้อมกัน*

## 2. External API: Full Audit Trail (Admin)

| Endpoint | สิทธิ์ | Input | Output หลัก | Cache/Error behavior |
| :--- | :--- | :--- | :--- | :--- |
| `GET /api/audit-logs` | `audit.read` (Admin) | `limit` (Default 50, Max 100), `cursor` (Optional) <br> Filters: `action`, `resource_type`, `actor_user_id`, `result`, `start_date`, `end_date` | ประวัติการทำงานฉบับเต็ม พร้อม Cursor Pagination | ไม่มีการ Cache |

### 2.1 DTO (Data Transfer Object)
เพื่อไม่ให้สับสนกับ Schema ฐานข้อมูล ระบบจะแปลงคอลัมน์ตอนส่งออกเป็น JSON ดังนี้:
- `id`
- `actor_user_id` (Nullable) — Map มาจากคอลัมน์ `audit_logs.user_id`
- `action`
- `resource_type`
- `resource_id` (Nullable)
- `result` — `success` หรือ `failure`
- `safe_error_category` (Nullable) — ตามกฎ Invariant
- `description` (Nullable) — ผ่านการ Redaction แล้วเท่านั้น
- `occurred_at` — Map มาจากคอลัมน์ `audit_logs.created_at`

### 2.2 Cursor Pagination Rule
- ยกเลิกการใช้ `page`, `offset`, และ `total` ออกจาก Contract เพื่อป้องกันปัญหา Performance กับข้อมูลขนาดใหญ่
- บังคับใช้ **Cursor Pagination** เท่านั้น
- Query ต้องเรียงลำดับด้วย `ORDER BY created_at DESC, id DESC`
- ค่า `cursor` ต้องอ้างอิงจากคู่ `created_at` และ `id` เพื่อป้องกันปัญหาข้อมูลซ้ำหรือข้ามตอนเปลี่ยนหน้า
- Response ต้องใช้รูปแบบ `{ "data": [...], "next_cursor": "..." }`

### 2.3 ตัวอย่าง Response
```json
{
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "actor_user_id": "987e6543-e21b-34d3-b456-426614174111",
      "action": "device.create",
      "resource_type": "device",
      "resource_id": "456e4567-e89b-12d3-a456-426614174222",
      "result": "success",
      "safe_error_category": null,
      "description": "Added new switch BKK-SW1",
      "occurred_at": "2026-08-26T10:00:00+07:00"
    }
  ],
  "next_cursor": "2026-08-26T10:00:00+07:00_123e4567-e89b-12d3-a456-426614174000"
}
```

## 3. Data Integrity Invariants
เพื่อความถูกต้องของข้อมูล (Data Integrity) ระบบต้องตรวจสอบความสัมพันธ์ของฟิลด์ดังนี้ก่อนเขียนลง Database:
- **Rule 1:** ถ้า `result = success` แล้ว `safe_error_category` **ต้องเป็น `null` เสมอ**
- **Rule 2:** ถ้า `result = failure` แล้วค่า `safe_error_category` ต้องผ่าน Allowlist และต้องตรงกับ **Global Action Registry** (ไม่อนุญาตให้ Caller ส่งข้อความ Error อาการแปลกๆ หรือ Arbitrary detail ลงมาเอง)
- **Rule 3:** Global Action Registry จะเป็น Source of Truth ที่ตัดสินว่า Action ไหนต้องมี Category ใด หรืออนุญาตให้เป็น Null ได้หรือไม่

## 4. Data Privacy and Description Policy
เพื่อให้เป็นไปตามกฎ Data Privacy มีข้อบังคับดังนี้:
1. **การเปิดเผยฟิลด์:** ฟิลด์ `description` ได้รับอนุญาตให้ส่งออกผ่าน `GET /api/audit-logs` (Full Audit API) เท่านั้น ซึ่งต้องใช้สิทธิ์ `audit.read` (Admin) เพื่อประโยชน์ด้าน Security Audit
2. **ห้าม D&M เปิดเผย IP/Description:** API เส้น Recent Activity ของ Dashboard (`GET /api/dashboard/recent-activity`) **ห้าม**ส่ง Client IP หรือ `description` ออกไปเด็ดขาด ไม่ว่าคนเรียก API จะเป็น Admin ก็ตาม (เพื่อป้องกันกรณีมี IP หลุดมาในอนาคต)
3. **Redaction at Source:** ข้อความใน `description` ต้องผ่านกระบวนการเซ็นเซอร์ (Redaction) **ก่อน**จะส่งเข้าฟังก์ชัน `record_audit_event()` และก่อนบันทึกลง Database (ห้ามใช้ API Response เป็นตัวกรองข้อมูลความลับย้อนหลัง)
4. **Strict Ban:** หลัง Auth เปลี่ยนเป็น Opaque Session ห้ามเก็บหรือส่งออกรหัสผ่าน (Plaintext/Hash), Session Token, Cookie Header, Session Token Hash, Credential Secret, Raw Failed-login Identifier (เช่น พิมพ์ username ผิด) หรือ PII ที่ไม่จำเป็นลงใน `audit_logs` เด็ดขาด

## 5. D&M Recent Activity API (Consumer Reference)
*อ้างอิง Contract นี้นิยามไว้ที่ฝั่ง D&M (`04_API Contracts.md`)*
- D&M จะอ่านตรงผ่าน ORM
- ใช้ Cursor Pagination แบบเดียวกัน
- แสดงเฉพาะ Allowlist
- Redaction `actor_user_id` เป็น `Unknown` ถ้าระบุตัวตนไม่ได้
