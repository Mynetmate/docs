**มีแน่นอนครับ** และเป็น Pain Point ระดับคลาสสิกในวงการ Network Engineering เลย มีชื่อเรียกว่า **"Cutting Your Own Legs"** หรือในภาษาเทคนิคเรียกว่า **Management Plane Disconnect**

---

## 🚨 Case ที่จะเกิดขึ้นจริง

| Scenario | เกิดขึ้นยังไง | ผลที่ตามมา |
|---|---|---|
| แก้ IP Management Interface ผิด | Config ใหม่ระบุ IP `192.168.2.1` แต่ระบบของเราเชื่อมอยู่บน `192.168.1.x` | SSH ตัดทันที เข้าไม่ได้อีกเลย |
| ACL บล็อกตัวเอง | เพิ่ม ACL ที่ deny IP ของ Management Server โดยไม่ตั้งใจ | SSH ตัดทันที |
| เปลี่ยน Management VLAN | ย้าย Management Port ไปอีก VLAN หนึ่งที่ระบบเราไม่ได้อยู่ | SSH ตัดทันที |
| ปิด Interface โดยไม่ตั้งใจ | มี `shutdown` หลุดเข้าไปใน Config | ตัดการเชื่อมต่อทันที |
| เปลี่ยน Port SSH | Config กำหนด Port 8022 แต่ระบบยังต่อ Port 22 | ต่อไม่ติด |

---

## 🛡️ วิธีแก้ไข: "Commit Confirmed" Pattern

วิธีแก้ที่ถูกต้องตามมาตรฐานอุตสาหกรรม คือกลไกที่เรียกว่า **"Commit Confirmed"** หรือ **"Safe Rollback Timer"** ซึ่งอุปกรณ์หลายค่ายทำไว้แล้ว:

```
[ระบบเรา Push Config ใหม่]
          ↓
[อุปกรณ์ Apply Config ชั่วคราว]
          ↓
[เปิด Countdown Timer 5 นาที]
          ↓
    ┌─────────────────────────────────────┐
    │ ระบบเราต่อ SSH ได้ไหม?                 │
    │ ภายในเวลาที่กำหนด?                    │
    └─────────┬─────────────┬───────────┘
              │ YES         │ NO (ตัดขาตัวเอง)
              ↓             ↓
        [Confirm Commit]  [Auto-Rollback กลับ
         Config ถาวร]      Config เดิมอัตโนมัติ]
```

**อุปกรณ์ในตลาดทำแบบนี้อยู่แล้ว:**
- **Juniper JunOS:** `commit confirmed 5` → rollback อัตโนมัติใน 5 นาทีถ้าไม่ confirm
- **Cisco IOS XE:** `configure replace` + `revert timer`
- **NAPALM:** มีฟังก์ชัน `commit_config()` และ `rollback()` แต่ต้องเชื่อมต่อได้ถึงจะ rollback ได้

---

## 🔧 วิธีที่โปรเจกต์เราจะ Implement (3 Layer)

#### Layer 1 — Pre-flight Validation (ก่อน Push)
ก่อนส่ง Config ให้ Backend วิเคราะห์ Config ที่จะ Push:

```python
def pre_flight_check(new_config: str, device: Device) -> list[Warning]:
    warnings = []
    
    # ตรวจว่า IP Management ถูกแก้ไขหรือไม่
    if device.management_ip not in new_config:
        warnings.append("⚠️ Management IP อาจหายไปจาก Config ใหม่")
    
    # ตรวจว่า SSH ยังเปิดอยู่
    if "no ip ssh" in new_config or "ip ssh version" not in new_config:
        warnings.append("⚠️ Config ใหม่อาจปิด SSH")
    
    return warnings
```

#### Layer 2 — Commit Confirmed Timer (ระหว่าง Push)
เมื่อ Push Config แล้ว Backend ทำ 2 สิ่งพร้อมกัน:

1. **ส่ง Config เข้าอุปกรณ์ในโหมดชั่วคราว** (ถ้า vendor รองรับ)
2. **เปิด Background Timer** พยายาม SSH กลับเข้าอุปกรณ์ภายใน N วินาที

```python
async def safe_apply_config(device, new_config, timeout=60):
    # Push config
    driver.apply_config(new_config)
    
    # รอแล้วทดสอบว่ายัง SSH ได้ไหม
    await asyncio.sleep(5)
    
    if await can_connect(device):
        driver.commit()           # ✅ ต่อได้ → Confirm
        return {"status": "success"}
    else:
        # ⚠️ ต่อไม่ได้ → ต้องการ Out-of-Band หรือแจ้งเตือน
        return {"status": "connection_lost", "action": "manual_intervention_required"}
```

#### Layer 3 — Version Control Rollback (ฉุกเฉิน)
ถ้าเกิดเหตุการณ์แล้ว (ตัดขาตัวเองไปแล้ว) ต้องพึ่ง **Out-of-Band Management** เข้าไปอ้าง Config เก่าจาก Version Control กลับมา

---

## 📦 Feature ที่จะอยู่ใต้

แนวคิดนี้จะกระจายอยู่ใน **2 Feature** ครับ:

```
┌─────────────────────────────────────────────────┐
│  Feature: Config Generation & Apply             │
│                                                 │
│  ├── Pre-flight Check ← Layer 1 อยู่ตรงนี้     │
│  ├── Commit Confirmed ← Layer 2 อยู่ตรงนี้     │
│  └── Deploy Status Monitoring                  │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  Feature: Version Control & Rollback            │
│                                                 │
│  ├── Config Backup (Before Apply)               │
│  ├── Rollback to Previous Version ← Layer 3     │
│  └── Diff Viewer                               │
└─────────────────────────────────────────────────┘
```

---

## 💬 ประโยคที่ใช้ตอบอาจารย์

> *"ระบบเราออกแบบ Safe Deploy Workflow โดย inspired จาก Juniper JunOS 'Commit Confirmed' Pattern ซึ่งจะ Push Config แบบชั่วคราวก่อน แล้วทดสอบ SSH Connectivity กลับอัตโนมัติ ถ้าตัดการเชื่อมต่อไปเกิดขึ้น ระบบจะแจ้งเตือน Admin ทันทีและเก็บ Config เดิมไว้ใน Version Control เพื่อให้สามารถ Rollback ผ่านช่องทาง Out-of-Band Management ได้ครับ"*