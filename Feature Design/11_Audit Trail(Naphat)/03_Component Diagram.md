# Component Diagram

แผนภาพนี้แสดงปฏิสัมพันธ์ระหว่าง Feature ต่างๆ (Producers), ตาราง Audit Logs, และ Consumers (Admin API & Dashboard)

```mermaid
flowchart TD
    %% Producers
    subgraph Producers ["Producers (Business Logic)"]
        Auth[Authentication & RBAC]
        Device[Device Inventory]
        Config[Config Gen & Deploy]
        CIS[CIS Benchmark]
        Settings[System Settings]
    end

    %% Audit Interface
    recordFn(("internal:\nrecord_audit_event()"))
    
    %% Storage
    subgraph Storage ["PostgreSQL (Central Schema)"]
        DB[(audit_logs table)]
    end

    %% Consumers
    subgraph Consumers ["Consumers (Read APIs)"]
        FullAPI["GET /api/audit-logs\n(Full Audit Trail)"]
        DMAPI["GET /api/dashboard/recent-activity\n(D&M)"]
    end
    
    %% UI
    subgraph UI ["Frontend / Users"]
        Admin[Admin Only]
        Dashboard["All Roles (via Dashboard)"]
    end

    %% Connections - Write Flow
    Auth -.->|Same DB Transaction| recordFn
    Device -.->|Same DB Transaction| recordFn
    Config -.->|Same DB Transaction| recordFn
    CIS -.->|Same DB Transaction| recordFn
    Settings -.->|Same DB Transaction| recordFn
    
    recordFn == "Insert Only (Append)" ==> DB

    %% Connections - Read Flow
    DB == "Full Read" === FullAPI
    DB -. "Read-only ORM\nPositive Allowlist\nCursor Pagination\nRedacted Fields" .-> DMAPI

    FullAPI --- Admin
    DMAPI --- Dashboard
```

## สาระสำคัญของ Architecture
1. **Internal Contract (`record_audit_event`)**: ทุก Producer ต้องเรียกผ่านฟังก์ชันนี้ในระดับ Application Layer เพื่อให้มั่นใจว่าจะไม่มีการเขียนตรงๆ ที่ผิดมาตรฐาน (เช่น ลืมทำ Redaction) และต้องใช้ Database Session (Transaction) เดียวกัน
2. **D&M Direct Read**: Dashboard & Monitoring สามารถใช้ SQLAlchemy Query จากตาราง `audit_logs` ได้โดยตรง ไม่ต้องผ่าน Full Audit API เพื่อความสะดวก แต่ต้องทำตาม Contract การ Redaction ข้อมูลและการใช้ Cursor Pagination อย่างเคร่งครัด
