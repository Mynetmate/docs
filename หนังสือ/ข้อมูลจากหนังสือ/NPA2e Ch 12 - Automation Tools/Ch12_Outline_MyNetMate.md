# 📚 Ch.12 — Automation Tools | Outline สำหรับ MyNetMate
> **หนังสือ:** Network Programmability and Automation (2nd Ed.)  
> **วัตถุประสงค์:** Outline หัวข้อใหญ่-ย่อย เพื่อนำไปให้ Gemini Pro อ่านและอธิบาย  
> **โครงงาน:** MyNetMate — Network Management System + AI Co-pilot  

---

## 🗺️ ภาพรวมบทที่ 12

บทนี้แนะนำ Automation Tools 3 ตัวหลักที่ใช้ใน Network Automation:

| Tool | ประเภท | เกี่ยวข้องกับ MyNetMate |
|------|--------|------------------------|
| **Ansible** | Configuration Management (Agentless) | 🟡 บริบท/เปรียบเทียบ |
| **Nornir** | Python Framework (Pure Code) | 🟢 ใกล้เคียงที่สุด |
| **Terraform** | Infrastructure Provisioning (IaC) | 🔵 ส่วน Cloud/Deployment |

---

## ส่วนที่ 1 — ภาพรวม Automation Tools
> *(หน้า 593-596)*

### 1.1 มิติที่ต่างกันของแต่ละ Tool
- Configuration Management vs. Infrastructure Provisioning
- Agent-based vs. Agentless
- Centralized vs. Decentralized
- Push vs. Pull vs. Event-driven
- Declarative vs. Imperative
- Mutable vs. Immutable
- State Management

### 1.2 สรุปลักษณะเด่นของแต่ละ Tool
- Ansible: Agentless, YAML-based, SSH, Push model
- Nornir: Pure Python, Multithreading, Plugin-based
- Terraform: Declarative, IaC, Provider-based, State management

> 🔗 **เชื่อมกับ MyNetMate:** FastAPI + Netmiko ของเรามีลักษณะคล้าย Nornir — เขียนด้วย Python โดยตรง ควบคุม Logic ได้เต็มที่ แต่ไม่ใช้ Framework สำเร็จรูป

---

## ส่วนที่ 2 — Ansible
> *(หน้า 597-643)*

### 2.1 Ansible Framework Overview
- Ansible Core vs. Ansible Community Package
- การทำงานบน Linux Servers (Distributed mode)
- การทำงานบน Network Devices (Local/Centralized mode)
- ข้อแตกต่างสำคัญ: Network devices ไม่ copy Python ไปรัน ใช้ SSH ส่ง CLI commands แทน

### 2.2 Inventory File — บัญชีรายชื่ออุปกรณ์
- รูปแบบ INI และ YAML
- การสร้าง Groups และ Nested Groups
- Group Variables และ Host Variables
- Variable Priority (เฉพาะ → ทั่วไป)
- Dynamic Inventory (เชื่อมกับ CMDB หรือ NMS)

### 2.3 Playbook — ชุดคำสั่งอัตโนมัติ
- โครงสร้าง: Playbook → Play → Task → Module
- Plays, Tasks, Modules คืออะไร
- Connection Types: network_cli, netconf, httpapi
- การ Execute Playbook: `ansible-playbook`
- Flags สำคัญ: `--check`, `-v`, `--limit`

### 2.4 Modules สำหรับ Network Devices
- 3 ประเภทหลัก: `command`, `config`, `facts`
  - `xos_command` — exec-level commands (เช่น show)
  - `xos_config` — configuration commands (เช่น set)
  - `xos_facts` — gather device info (OS, serial, interfaces)
- รองรับ Multi-vendor: cisco.ios, arista.eos, junipernetworks.junos

### 2.5 Variable Files — จัดการข้อมูลแบบมีระเบียบ
- `group_vars/` สำหรับ Group variables
- `host_vars/` สำหรับ Host-specific variables
- โครงสร้างไฟล์ YAML ตามชื่อ Group/Host

### 2.6 Playbooks สำหรับ Network Automation
- **Configuration Templates:** Jinja2 + YAML → สร้าง config ต่าง OS อัตโนมัติ
- **Deploy Config (Idempotency):** ส่ง config เฉพาะเมื่อจำเป็น
- **Gathering Data:** ใช้ facts module + debug module
- **Show Commands + Register:** บันทึก Output เป็น JSON ด้วย `register`
- **Compliance Checks:** `assert` module ตรวจสอบค่าที่ต้องการ
- **Report Generation:** สร้าง Markdown report ด้วย template + assemble module

### 2.7 Ansible Roles — จัดระเบียบ Playbooks
- Role คือ Capsule ของ tasks, variables, templates
- นำ Roles มา Compose เป็น Playbook ใหม่ได้
- เปรียบเหมือน Python Module/Class

### 2.8 Third-Party Collections
- **NAPALM Collection:** Multivendor, config management + operational state
- **NTC Modules:** TextFSM parsing + Netmiko backend (รองรับ ~100 device types)
- การติดตั้งผ่าน Ansible Galaxy

> 🔗 **เชื่อมกับ MyNetMate:**  
> - Section 2.4 (xos_facts) = ไอเดียเดียวกับที่เราใช้ Netmiko + TextFSM ดึง device info  
> - Section 2.6 (Compliance Checks) = แนวคิดเดียวกับ Impact Analysis ของ MyNetMate  
> - Section 2.8 (NAPALM) = เราใช้แนวคิด Multivendor abstraction แบบเดียวกัน แต่ build เอง  

---

## ส่วนที่ 3 — Nornir
> *(หน้า 614-658)*

### 3.1 ทำไมถึงมี Nornir?
- ข้อจำกัดของ Ansible: Debug ยาก, Logic ซับซ้อนใน YAML ทำไม่ได้
- Nornir = Pure Python Framework ไม่ใช่ DSL
- ข้อดีเทียบกับ Ansible: Debug ง่าย, Speed สูง, Logic ซับซ้อนได้, Extensible

### 3.2 โครงสร้าง Inventory ของ Nornir
- `config.yaml` — ตั้งค่า Plugin และ Runner
- `hosts.yaml` — บัญชีอุปกรณ์ (hostname, platform, groups, data)
- `groups.yaml` — กลุ่มและตัวแปรที่ใช้ร่วม
- SimpleInventory Plugin vs. Dynamic Inventory Plugin (เช่น Nautobot)
- Variable Inheritance: เฉพาะ (host) > กลุ่ม (group) > ทั่วไป (global)
- การ Filter Inventory: `nr.filter(platform="ios")`

### 3.3 Nornir Tasks และ Results
- Task คืออะไร: Function ที่รับ `Task` object และ return `Result`
- การ Run Tasks: `nr.run(task=my_function)`
- Multithreading by Default: รันทุก Host แบบ Parallel (ลด execution time)
- `print_result()` จาก nornir-utils

### 3.4 Plugin System ของ Nornir
- ประเภท Plugin: Functions, Connection, Inventory, Processors, Tasks, Runners
- Plugin สำคัญ: nornir-napalm, nornir-jinja2, nornir-netmiko, nornir-netconf
- Dynamic Inventory Plugin: Nautobot, NetBox, เป็นต้น

### 3.5 NAPALM คืออะไร?
- Network Automation and Programmability Abstraction Layer with Multivendor support
- Normalize ข้อมูลจากทุก Vendor ให้เหมือนกัน
- APIs ที่รองรับ: SSH (IOS), eAPI (Arista), NETCONF (Junos), NX-API (NXOS)
- Methods หลัก: `get_facts()`, `get_interfaces()`, `get_lldp_neighbors()`, `get_bgp_neighbors()`

### 3.6 Configuration Management ด้วย NAPALM
- **Configuration Merge:** ส่ง partial config ไปเพิ่ม (สำหรับ Traditional devices)
- **Configuration Replace (Declarative):** ส่ง full config ไปแทนที่ทั้งหมด
- `napalm_configure` task ใน Nornir: รองรับทั้ง merge และ replace
- Dry Run: ดูผลลัพธ์ก่อน commit จริง

### 3.7 Nornir + NAPALM + Jinja2 รวมกัน
- Flow: Inventory data → Jinja2 Template → Config string → napalm_configure → Device
- Multi-task: render template แล้ว push config ในชุดเดียวกัน

> 🔗 **เชื่อมกับ MyNetMate:**  
> - **Nornir คือ Python Framework** เหมือน MyNetMate ที่ใช้ FastAPI + Netmiko (Pure Python)  
> - **NAPALM's Multivendor Abstraction** = แนวคิดเดียวกับที่เราพยายามทำสำหรับ Cisco/MikroTik/Huawei  
> - **Configuration Merge vs Replace** = การตัดสินใจ Deploy config ที่ MyNetMate ต้องเผชิญ  
> - **Multithreading ของ Nornir** = เราควร implement ใน MyNetMate เมื่อ poll หลาย device พร้อมกัน  

---

## ส่วนที่ 4 — Terraform
> *(หน้า 632-718)*

### 4.1 Infrastructure as Code (IaC) คืออะไร?
- Dynamic Infrastructure: สร้าง/ทำลาย resource ผ่าน API ได้ทันที
- Declarative Approach: บอก "อยากได้อะไร" ไม่ใช่ "ทำยังไง"
- Terraform vs. AWS CloudFormation: Terraform ทำงานได้กับ 1,700+ providers

### 4.2 Terraform Architecture
- **HCL (HashiCorp Configuration Language):** DSL ของ Terraform
- **Providers:** Plugin เชื่อมกับแต่ละ Infrastructure Platform
- **Resources:** Infrastructure Object ที่ต้องการสร้าง
- **Variables:** Input ปรับแต่ง Configuration
- **Outputs:** ข้อมูลที่ Expose หลัง Execution
- **State:** Mapping ระหว่าง Config กับ Infrastructure จริง

### 4.3 Terraform Workflow
- `write` → `init` → `plan` → `apply` → `destroy`
- `terraform init` — ดาวน์โหลด Providers
- `terraform validate` — ตรวจ syntax
- `terraform plan` — Dry run ดูว่าจะเปลี่ยนอะไร
- `terraform apply` — ทำจริง
- `terraform destroy` — ลบ Infrastructure

### 4.4 Resources และ Dependencies
- Resource Definition: `resource "type" "name" { ... }`
- Implicit Dependencies: อ้างอิง attribute ของ resource อื่น
- Explicit Dependencies: `depends_on`
- Terraform Functions: `cidrsubnet()`, built-in functions อื่นๆ
- Loop ด้วย `count` meta-argument

### 4.5 Terraform State Management
- State File: `terraform.tfstate` — JSON format
- Refresh: อัพเดต State ก่อนทุก Operation
- Remote State: ใช้ Backend สำหรับ Team (ป้องกัน Race Condition)
- State Locking: ป้องกัน Concurrent Modification
- `terraform import`: กู้คืน State จาก Infrastructure ที่มีอยู่แล้ว

### 4.6 Managing Terraform at Scale
- **Data Sources:** อ่านข้อมูลจาก Infrastructure ที่ไม่ได้จัดการเอง
- **Terraform Variables:** Input variables, Type, Validation, Default
- **Variable Sources:** tfvars file, Environment variables, CLI flags
- **Workspaces:** แยก State สำหรับ dev/staging/production
- **Modules:** Package ของ Resources ที่ Reusable (เหมือน Function/Library)

### 4.7 Terraform ใช้กับ Network Devices
- Cloud Network Services: AWS VPC, Azure VNet, GCP VPC
- Network Controllers: Cisco ACI, Arista CloudVision, VMware NSX
- Experimental: IOSXE Provider (RESTCONF), Junos JTAF
- Terraform Provisioners: local-exec, remote-exec, file (ใช้เมื่อจำเป็นจริงๆ)
- Ansible + Terraform ทำงานร่วมกัน: Terraform Provision, Ansible Configure

> 🔗 **เชื่อมกับ MyNetMate:**  
> - **Terraform State = PostgreSQL (SoT) ของเรา** — ทั้งคู่เป็น Source of Truth ว่า infrastructure เป็นยังไง  
> - **Terraform Workflow (plan → apply)** = MyNetMate ควรมี Preview ก่อน Deploy config  
> - **Terraform Modules** = ไอเดียการแยก FastAPI router เป็น module ต่าง vendor  
> - **Terraform ใช้กับ Network Devices** = แนวโน้มอนาคตที่ MyNetMate อาจ integrate  

---

## 📊 สรุปเปรียบเทียบ 3 Tools กับ MyNetMate

| Feature | Ansible | Nornir | Terraform | MyNetMate |
|---------|---------|--------|-----------|-----------|
| **Language** | YAML DSL | Python | HCL DSL | Python (FastAPI) |
| **Multi-vendor** | ✅ (modules) | ✅ (NAPALM) | ✅ (providers) | ✅ (3 vendors) |
| **State Management** | ❌ | ❌ | ✅ | ✅ (PostgreSQL) |
| **Configuration Deploy** | ✅ | ✅ | ✅ | ✅ (Netmiko) |
| **Config Parsing** | ❌ (จำกัด) | ✅ (TextFSM) | ❌ | ✅ (TextFSM) |
| **AI Integration** | ❌ | ❌ | ❌ | ✅ (Gemini) |
| **Idempotency** | ✅ | ⚠️ (manual) | ✅ | ⚠️ (ต้อง implement) |
| **Multithreading** | ✅ | ✅ | ✅ | ⚠️ (ต้อง implement) |
| **Web UI** | AWX (แยก) | ❌ | Terraform Cloud | ✅ (React) |

> **ข้อสรุป:** MyNetMate มีจุดแข็งที่ไม่มีใน Tool อื่น คือ AI Co-pilot และ Web UI ในตัว  
> แต่ต้องระวังเรื่อง Idempotency และ Multithreading ที่ Tool อื่น implement ให้แล้ว  

---

## 🎯 Key Takeaways สำหรับ MyNetMate

1. **Nornir คือตัวอย่างที่ใกล้เคียงที่สุด** กับ Architecture ของ MyNetMate — Pure Python, Plugin-based, ควบคุม Logic เองได้
2. **NAPALM's Multivendor Abstraction** = แนวทางที่ MyNetMate ควรยึดถือ — Normalize output จากทุก vendor ให้เหมือนกัน
3. **Idempotency ของ Ansible** = MyNetMate ควรตรวจก่อนส่ง config — อย่า push ซ้ำถ้า config ถูกอยู่แล้ว
4. **Terraform's Plan → Apply Workflow** = MyNetMate ควรมี Preview step ก่อน Deploy config (Safety net)
5. **Dynamic Inventory ใน Nornir/Ansible** = PostgreSQL ของ MyNetMate ทำหน้าที่นี้ — Single Source of Truth

---

*Outline นี้สร้างโดย Antigravity AI | วันที่: 2026-07-21*  
*ไฟล์ต้นฉบับ: Ch.12 — Automation Tools (p.593).md (4,158 บรรทัด, 221 KB)*
