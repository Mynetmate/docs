**UML Component Diagram**
	ใช้สำหรับอธิบาย “โครงสร้างระดับสถาปัตยกรรม” ของระบบ ว่าระบบประกอบด้วยโมดูลอะไรบ้าง แต่ละโมดูลรับผิดชอบอะไร และเชื่อมต่อ/พึ่งพากันอย่างไร โดยเน้นภาพรวมมากกว่ารายละเอียดภายในของ class หรือ method [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

## สาระสำคัญที่ควรรู้เวลาเขียน UML Component Diagram

สิ่งแรกคือให้คิดว่า 
	**Component = ส่วนประกอบหรือโมดูลของระบบที่สามารถแยกความรับผิดชอบออกจากกันได้** เช่น `User Interface`, `Authentication Service`, `Order Service`, `Payment Service` หรือ `Database Access` 
	โดย Component อาจเป็น class หลายตัวรวมกัน เป็น subsystem หรือ service ก็ได้ จุดประสงค์คือทำให้ระบบมีความเป็น modular และสามารถพัฒนา/แก้ไขแต่ละส่วนได้ค่อนข้างอิสระ [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

ตัวอย่างแนวคิด:

![[Pasted image 20260809194152.png]]
```
┌──────────────────────┐
│ <<component>>        │
│ Order Service        │
└──────────────────────┘
```

อย่าเขียนทุก class เป็น Component เพราะ Component Diagram ไม่ได้มีเป้าหมายเพื่อแสดงรายละเอียดระดับ class หากต้องการดู attribute, method หรือความสัมพันธ์ของ class ควรใช้ **Class Diagram** แทน

---

## 1. Component ระบบมี “ส่วนหลัก” อะไรบ้าง

ก่อนวาด ให้แตกระบบออกเป็นหน้าที่หลัก เช่น สมมติทำระบบ E-Commerce:

```
E-Commerce System
│
├── Web UI
├── Authentication Service
├── Product Service
├── Order Service
├── Payment Service
└── Database
```

จากนั้นจึงเปลี่ยนแต่ละส่วนให้เป็น Component

```
┌─────────────────────┐
│ <<component>>       │
│ Web UI              │
└─────────────────────┘

┌─────────────────────┐
│ <<component>>       │
│ Order Service       │
└─────────────────────┘

┌─────────────────────┐
│ <<component>>       │
│ Payment Service     │
└─────────────────────┘
```

หลักคิดที่ใช้ได้ง่ายมากคือถามว่า:

> **“ถ้าฉันแยกระบบนี้ออกเป็นโมดูลใหญ่ ๆ แต่ละโมดูลรับผิดชอบเรื่องอะไร?”**

คำตอบเหล่านั้นมักจะกลายเป็น Component

---

## 2. Interface  Component ให้บริการอะไรแก่ Component อื่น

Component ไม่ควรเชื่อมกันแบบมั่ว ๆ แต่ควรระบุว่า “เชื่อมผ่านอะไร”

UML แบ่ง interface ที่สำคัญเป็น 2 แบบคือ

- **Provided Interface** → สิ่งที่ Component “ให้บริการ”
- **Required Interface** → สิ่งที่ Component “ต้องการจาก Component อื่น”

บทความใช้สัญลักษณ์ 
	**วงกลมแบบ lollipop** สำหรับ Provided Interface 
	**ครึ่งวงกลมแบบ socket** สำหรับ Required Interface [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

เช่น `Payment Service` ให้บริการ

```
Payment API
```

ขณะที่ `Order Service` ต้องใช้ Payment API

แนวคิดคือ:

```
Order Service
     │
     │ requires
     ▼
 Payment API
     ▲
     │ provides
Payment Service
```

ดังนั้น Interface เปรียบเสมือน **Contract ระหว่าง Component**
ตัวอย่างในระบบจริงอาจเป็น:

```
REST API
GraphQL API
gRPC
Payment API
Authentication API
Repository Interface
```
![[Pasted image 20260809194340.png]]
---

## 3. Relationship / Dependency  ใครพึ่งพาใคร

เส้นใน Component Diagram มีความหมาย จึงไม่ควรวาดทุกอย่างเป็นเส้นธรรมดา

รูปแบบที่สำคัญคือ **Dependency**

```
A ---------> B
```

หมายความว่า

> A ต้องพึ่งพาหรือใช้งาน B

ใน UML โดยทั่วไป dependency แสดงด้วย **เส้นประพร้อมลูกศร** [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

ตัวอย่าง:

```
Order Service -----> Payment Service
```

แปลว่า:

> Order Service ต้องใช้ Payment Service

อีกตัวอย่าง:

```
Web UI
  |
  v
Authentication Service

Web UI
  |
  v
Product Service

Web UI
  |
  v
Order Service

Order Service
  |
  v
Payment Service
```

เมื่อดู diagram แล้วเราจึงเห็น architecture ของระบบทันที
![[Pasted image 20260809194546.png]]

#### Association & Assembly Connector

**Association** และ **Assembly Connector** ใช้แสดงการเชื่อมต่อระหว่าง Components แต่มีความหมายต่างกัน

#### 1. Association

**Association** คือความสัมพันธ์โดยตรงระหว่าง Component ใช้ **เส้นทึบ (Solid Line)** เชื่อม Component เข้าด้วยกัน

```
┌─────────────┐             ┌─────────────┐
│   Order     │─────────────│   Product   │
│ Component   │             │ Component   │
└─────────────┘             └─────────────┘
```

หมายความว่า `Order` และ `Product` มีความสัมพันธ์หรือมีการติดต่อกัน

ตัวอย่างเช่น:

> `Order Component` ติดต่อกับ `Product Component` เพื่อเข้าถึงข้อมูลสินค้าที่ใช้ในการสร้างคำสั่งซื้อ

Association เหมาะสำหรับการแสดง **ความสัมพันธ์ในภาพรวม** โดยไม่จำเป็นต้องระบุรายละเอียดว่า Component ต้องการหรือให้ Interface อะไร

---
#### 2. Assembly Connector

**Assembly Connector** มีความเฉพาะเจาะจงกว่า Association เพราะใช้เชื่อม

> **Required Interface ของ Component หนึ่ง → Provided Interface ของอีก Component หนึ่ง**

แนวคิดคือ

```
Component A
Requires Interface
       ↓
      ( )
       │
       ○
       ↑
Provides Interface
Component B
```

โดยทั่วไป:

- `○` = **Provided Interface** — บริการที่ Component มีให้
- `⊂` หรือ socket = **Required Interface** — บริการที่ Component ต้องการใช้

ตัวอย่าง:

```
┌────────────────┐          ┌─────────────────┐
│ Order          │          │ Payment         │
│ Component      │───⊂──○───│ Component       │
└────────────────┘          └─────────────────┘
       Requires                  Provides
      Payment API               Payment API
```

หมายความว่า:

> `Order Component` ต้องการใช้ `Payment API` และ `Payment Component` เป็นผู้ให้บริการ `Payment API`

หรือมองในเชิง Software Architecture:

```
Order Component
      │
      │ requires
      ▼
  Payment API
      ▲
      │ provides
Payment Component
```

ดังนั้น Assembly Connector จะแสดง **interface contract** ระหว่าง Component ชัดกว่า Association

---

### Association vs Assembly Connector

|Relationship|สัญลักษณ์|ใช้เมื่อ|
|---|---|---|
|**Association**|เส้นทึบ `────`|ต้องการบอกว่า Components มีความสัมพันธ์กัน|
|**Assembly Connector**|Required ↔ Provided Interface|ต้องการบอกว่า Component หนึ่งใช้ Interface ที่อีก Component ให้บริการ|

จำง่าย ๆ:

> **Association = “A เกี่ยวข้องกับ B”**  
> **Assembly Connector = “A ต้องการบริการที่ B มีให้”**

ตัวอย่างใน `OnlineStore`:

```
Customer ───────── Order
                     │
                     │ requires
                     ▼
                 Product API
                     ▲
                     │ provides
                  Product
```

ดังนั้นถ้าต้องการวาด Component Diagram ในระดับ Architecture ให้ชัดเจน การใช้ **Assembly Connector** จะให้ข้อมูลมากกว่าเส้น Association ธรรมดา เพราะทำให้เห็นทั้ง **Dependency และ Interface ที่ใช้เชื่อม Component** ในเวลาเดียวกัน

---

## 4. Ports  จุดเชื่อมต่อเฉพาะของ Component

ถ้าต้องการอธิบายละเอียดขึ้น สามารถใช้ **Port**

Port แสดงเป็นสี่เหลี่ยมเล็ก ๆ บนขอบ Component และใช้บอกว่า Component ติดต่อกับภายนอกผ่าน “จุดไหน” [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

เช่น Service หนึ่งตัวอาจมี

```
Payment Service
│
├── REST Port
├── Event Port
└── Database Port
```

แนวคิดคือ:

```
              REST API
                 │
        ┌────────□─────────┐
        │ Payment Service  │
        │                  │
        └────────□─────────┘
                 │
             Database
```

Port เหมาะเมื่อ Architecture เริ่มซับซ้อน แต่ถ้าเป็น diagram ระดับพื้นฐาน **ไม่จำเป็นต้องใส่ Port ทุกครั้ง**
![[Pasted image 20260809194707.png]]
---
## 5. Artifact  ไฟล์หรือสิ่งที่ถูกสร้างขึ้นจริง

Artifact ต่างจาก Component ตรงที่ Component เป็นแนวคิดเชิง logical ส่วน Artifact คือสิ่งที่เป็นไฟล์หรือของที่ deploy ได้จริง เช่น

```
payment-service.jar
frontend.bundle.js
config.yaml
database.sql
Docker image
```

UML มักเขียนว่า

```
<<artifact>>
payment-service.jar
```

บทความอธิบายว่า Artifact ใช้แสดงไฟล์หรือข้อมูลทางกายภาพที่เกี่ยวข้องกับ Component [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

จำง่าย ๆ ว่า:

```
Component
   ↓ implemented/deployed as
Artifact
```

เช่น

```
Payment Service
      ↓
payment-service.jar
```
![[Pasted image 20260809194816.png]]
---

## 6. Node  Component ทำงาน “ที่ไหน”

Node คือ environment ที่ Component ถูกนำไปรัน เช่น

```
Server
VM
Container
Mobile Device
Cloud Instance
Kubernetes Node
```

บทความอธิบายว่า Node ใช้แทน physical หรือ virtual execution environment ของระบบ [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)
ตัวอย่าง:

```
┌───────────────────────────┐
│ Web Server                │
│                           │
│   <<component>>           │
│   Web Application         │
└───────────────────────────┘

            │
            ▼

┌───────────────────────────┐
│ Application Server        │
│                           │
│   <<component>>           │
│   Order Service           │
│                           │
│   <<component>>           │
│   Payment Service         │
└───────────────────────────┘
```

อย่างไรก็ตาม ถ้าเน้นเรื่อง “Component อยู่บน Server ไหน” มาก ๆ จริง ๆ จะเริ่มเข้าเขตของ **Deployment Diagram**
![[Pasted image 20260809194844.png]]

---

# (Best practices)วิธีคิดก่อนเขียน Component Diagram

แทนที่จะเริ่มจากการวาดกล่อง แนะนำให้ตอบคำถามตามลำดับนี้:

```
1. ระบบของเราคืออะไร?
        ↓
2. ระบบแบ่งออกเป็นโมดูลอะไร?
        ↓
3. แต่ละโมดูลรับผิดชอบอะไร?
        ↓
4. แต่ละโมดูลให้ Interface อะไร?
        ↓
5. แต่ละโมดูลต้องใช้ Interface อะไร?
        ↓
6. Component ไหนพึ่งพา Component ไหน?
        ↓
7. มี External System อะไรบ้าง?
```

ตัวอย่างสมมติเป็น **Online Learning System**

```
Student Web
Teacher Web
Authentication Service
Course Service
Assignment Service
Notification Service
Database
```

จากนั้นหา dependency:

```
Student Web
    ↓
Authentication Service

Student Web
    ↓
Course Service
    ↓
Assignment Service

Assignment Service
    ↓
Notification Service

Course Service
    ↓
Database

Assignment Service
    ↓
Database
```

เมื่อจัดเป็น Component Diagram ก็จะได้ภาพประมาณนี้:

```
                ┌─────────────────┐
                │ <<component>>   │
                │ Student Web     │
                └────────┬────────┘
                         │
             ┌───────────┼───────────┐
             ▼                       ▼
┌────────────────────┐    ┌────────────────────┐
│ <<component>>      │    │ <<component>>      │
│ Authentication    │    │ Course Service     │
└────────────────────┘    └─────────┬──────────┘
                                    │
                                    ▼
                          ┌────────────────────┐
                          │ <<component>>      │
                          │ Assignment Service │
                          └─────────┬──────────┘
                                    │
                                    ▼
                          ┌────────────────────┐
                          │ <<component>>      │
                          │ Notification       │
                          │ Service            │
                          └────────────────────┘
```

ตรงนี้คือแก่นของ Component Diagram:

> **ไม่ได้สนใจว่า `AssignmentService` มี method อะไร แต่สนใจว่า `Assignment Service` อยู่ตรงไหนของระบบ และต้องคุยกับใคร**

---

# กฎสำคัญในการวาด

บทความแนะนำแนวทางสำคัญหลายอย่าง ได้แก่ **เข้าใจ requirement ก่อนวาด, ทำ diagram ให้ง่าย, ตั้งชื่อให้สม่ำเสมอ และระบุ interface ให้ชัดเจน** [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

ผมสรุปให้เป็นกฎใช้งานจริงได้ว่า:

| หลักการ                     | ความหมาย                                                     |
| --------------------------- | ------------------------------------------------------------ |
| **High-level**              | อย่าใส่รายละเอียด class/method มากเกินไป                     |
| **Clear Responsibility**    | 1 Component ควรมีหน้าที่ชัด                                  |
| **Clear Dependency**        | ต้องมองออกว่าใครใช้ใคร                                       |
| **Clear Interface**         | ถ้าสำคัญ ควรแสดงว่าติดต่อกันผ่านอะไร                         |
| **Consistent Naming**       | เช่นใช้ `Order Service`, `Payment Service` ให้รูปแบบเดียวกัน |
| **Avoid Spaghetti Diagram** | อย่าให้ทุก Component ต่อหากันหมด                             |
| **Show External Systems**   | API, Payment Gateway, Email Service ฯลฯ ควรแยกให้เห็น        |
| **Keep it Simple**          | Diagram มีไว้สื่อสาร ไม่ใช่แสดงทุกอย่างในระบบ                |

---

## แยกให้ออกระหว่าง UML ที่มักสับสนกัน

สิ่งนี้สำคัญมากเวลาเรียน UML:

```
Use Case Diagram
        ↓
"ใครทำอะไรกับระบบ?"

Class Diagram
        ↓
"ระบบมี Class / Attribute / Method อะไร?"

Sequence Diagram
        ↓
"ตอนทำงานหนึ่งเรื่อง Message วิ่งตามลำดับอย่างไร?"

Component Diagram
        ↓
"ระบบแบ่งเป็นโมดูลอะไร และโมดูลเหล่านั้นเชื่อมกันอย่างไร?"

Deployment Diagram
        ↓
"Software เหล่านั้นถูก Deploy อยู่ที่ไหน?"
```

ดังนั้นจำสั้น ๆ ได้ว่า:

> **Component Diagram = Software Architecture View**

หรือถ้าเอาไปเขียนใน Obsidian ผมแนะนำให้จำสูตรความคิดนี้:

```
Component Diagram
= Components
+ Responsibilities
+ Interfaces
+ Dependencies
+ External Systems
```

และเป้าหมายสำคัญที่สุดคือ

> **ดู Diagram แล้วสามารถตอบได้ว่า “ระบบแบ่งออกเป็นส่วนอะไร และแต่ละส่วนทำงานร่วมกันอย่างไร”**

นี่คือสาระสำคัญที่สุดของบทความ GeeksforGeeks และเป็นหลักที่ควรใช้เวลาคุณลงมือเขียน UML Component Diagram จริง ๆ [GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/component-based-diagram/)

## Example of Component Based Diagram
### 1. OnlineStore Component

`OnlineStore` คือ **Component หลักหรือขอบเขตของระบบร้านค้าออนไลน์** ภายในประกอบด้วย Component ย่อยสำคัญ ได้แก่ `Order`, `Customer` และ `Product`

พูดง่าย ๆ คือ OnlineStore เป็น “ระบบใหญ่” ที่ครอบ component หลักของร้านค้าไว้

```
OnlineStore
├── Order
├── Customer
└── Product
```

---

### 2. Order Component

`Order` มีหน้าที่จัดการเรื่องที่เกี่ยวข้องกับ **คำสั่งซื้อ** เช่น การสร้างรายการสั่งซื้อ การตรวจสอบสินค้าในคำสั่งซื้อ หรือการผูกคำสั่งซื้อกับลูกค้า

มันเชื่อมกับ `Product` เพื่อดึงข้อมูลสินค้า เช่น ราคา ชื่อสินค้า หรือสินค้าที่มีอยู่ และเชื่อมกับ `Customer` เพื่อระบุว่า order นี้เป็นของลูกค้าคนไหน

แนวคิดประมาณนี้:

```
Customer
   │
   ▼
 Order ──────► Product
```

เช่น ลูกค้า A สั่งสินค้า X ดังนั้น `Order` ต้องรู้ทั้งข้อมูลของ `Customer A` และข้อมูลของ `Product X`

ข้อความที่ว่า **Uses delegate connectors** หมายถึง บางคำขอที่เข้ามายัง Component หนึ่งอาจไม่ได้ถูกประมวลผลตรงนั้น แต่ถูก **ส่งต่อ (delegate)** ไปยัง Component ภายในหรือระบบอื่นที่รับผิดชอบจริง

---

### 3. Customer Component

`Customer` มีหน้าที่จัดการ **ข้อมูลและกิจกรรมของลูกค้า** เช่น ข้อมูลส่วนตัว ข้อมูลลูกค้า หรือความสัมพันธ์ระหว่างลูกค้ากับ order

มันเชื่อมกับ `Order` เพราะลูกค้าหนึ่งคนสามารถมีคำสั่งซื้อได้

```
Customer ──────► Order
```

นอกจากนี้ `Customer` ยังเชื่อมกับ `Account` ซึ่งอยู่นอกระบบ OnlineStore

```
OnlineStore
┌──────────────────────────────┐
│                              │
│ Customer ───────────────┐    │
│                         │    │
└─────────────────────────│────┘
                          ▼
                       Account
```

แนวคิดคือ `Customer` อาจต้องการข้อมูลบัญชี เช่น username, account status หรือข้อมูล authentication แต่ OnlineStore ไม่ได้จัดการ Account เอง จึงส่งต่อไปให้ `Account Component`

---

### 4. Product Component

`Product` รับผิดชอบ **ข้อมูลสินค้า** เช่น

- ชื่อสินค้า
- ราคา
- รายละเอียดสินค้า
- จำนวนสินค้า
- รหัสสินค้า

มันเชื่อมกับ `Order` เพราะเวลาสร้าง Order ระบบต้องรู้ว่าสั่งสินค้าอะไร

```
Order ──────► Product
```

เช่น:

```
Order #001
├── Product A
├── Product B
└── Product C
```

ดังนั้น Order ไม่ควรเก็บรายละเอียดสินค้าเองทั้งหมด แต่ไปอ้างอิง `Product Component`

---

### 5. Account Component

`Account` เป็น Component ที่ **อยู่นอกขอบเขต OnlineStore**

นี่เป็นจุดที่สำคัญในการอ่าน Component Diagram

```
┌──────────── OnlineStore ────────────┐
│                                     │
│ Customer                            │
│ Order                               │
│ Product                             │
│                                     │
└─────────────────────────────────────┘

                    Account
               (External Component)
```

หมายความว่า OnlineStore อาศัยบริการจากระบบภายนอกบางอย่าง

`Customer` ติดต่อ `Account` ผ่าน delegate relationship เพื่อให้ Account จัดการเรื่องที่เกี่ยวกับบัญชี

ตัวอย่างเช่น:

```
Customer
   │
   │ request account information
   ▼
Account
   │
   └── Username
   └── Account Status
   └── Authentication
```

ดังนั้นแนวคิดคือ

> `Customer` จัดการเรื่อง “ลูกค้า” ส่วน `Account` จัดการเรื่อง “บัญชีผู้ใช้”

สองอย่างนี้เกี่ยวข้องกัน แต่ไม่จำเป็นต้องเป็น Component เดียวกัน

---

## Delegate Connector คืออะไร?

ส่วนนี้น่าจะเป็นจุดที่ควรทำความเข้าใจเพิ่ม

**Delegation Connector** ใช้แสดงว่า การเรียกใช้งานที่เข้ามาทาง interface/port ของ Component ใหญ่ ถูก **ส่งต่อไปยัง Component ภายในที่รับผิดชอบจริง**

คิดเหมือนกับ receptionist

```
Request
   │
   ▼
OnlineStore
   │
   │ delegate
   ▼
Customer
```

ผู้ใช้งานภายนอกอาจเห็นเพียง `OnlineStore` แต่ภายใน OnlineStore ส่งงานให้ `Customer`

เช่น

```
getCustomerAccount()
        │
        ▼
OnlineStore
        │
        │ delegate
        ▼
Customer
        │
        ▼
Account
```

ดังนั้นคำว่า **delegate ไม่ได้หมายถึง dependency ธรรมดา** แต่เน้นการ “ส่งต่อ responsibility / request” จาก interface หนึ่งไปยังอีกส่วนหนึ่งของระบบ

---

## ภาพรวมของตัวอย่างนี้

ถ้าสรุป Component Diagram ที่บทความกำลังอธิบาย จะได้ประมาณนี้:


![[Pasted image 20260809195120.png]]
สิ่งที่ diagram นี้ต้องการสื่อไม่ใช่ algorithm ของการซื้อสินค้า แต่ต้องการให้เห็นว่า

> **OnlineStore แบ่งออกเป็น Component อะไร และแต่ละ Component ต้องติดต่อกับใคร**

---

## Tools สำหรับสร้าง Component Diagram

ส่วนหลังของข้อความเป็นเพียงการแนะนำโปรแกรมที่สามารถใช้วาด UML Component Diagram ได้

| Tool                                | อธิบาย                                                                  |
| ----------------------------------- | ----------------------------------------------------------------------- |
| **Lucidchart**                      | เครื่องมือออนไลน์สำหรับวาด diagram ใช้ง่ายและทำงานร่วมกันได้            |
| **Microsoft Visio**                 | โปรแกรมของ Microsoft สำหรับวาด diagram หลากหลายชนิด รวม UML             |
| **Visual Paradigm**                 | เครื่องมือที่เน้น UML และ Software Design โดยเฉพาะ                      |
| **Enterprise Architect**            | เครื่องมือ UML/Software Architecture ระดับมืออาชีพ เหมาะกับระบบขนาดใหญ่ |
| **IBM Rational Software Architect** | IDE และ Modeling Tool สำหรับออกแบบ architecture และ UML                 |

สำหรับการเรียน ผมมองว่า **ไม่จำเป็นต้องใช้เครื่องมือใหญ่เหล่านี้ทั้งหมด** สิ่งสำคัญกว่าคือเข้าใจความหมายของ diagram

ถ้าคุณใช้ **Obsidian** อยู่แล้ว อีกทางเลือกที่สะดวกมากคือเขียนด้วย PlantUML เช่น:

```
@startuml

package "OnlineStore" {
    component Order
    component Customer
    component Product

    Order --> Customer
    Order --> Product
}

component Account

Customer --> Account : delegate

@enduml
```

จะเหมาะกับการจดโน้ตเรียนมาก เพราะสามารถเก็บ **UML + คำอธิบาย + source code** ไว้ใน note เดียวกันได้ และแก้ diagram ได้ด้วย text แทนการลากกล่องด้วยเมาส์

### **Applications of Component-Based Diagrams** 
 คือ UML Component Diagram ไม่ได้มีไว้แค่ “วาดโครงสร้างระบบ” แต่ใช้ช่วยตั้งแต่ช่วงออกแบบ พัฒนา ไปจนถึงดูแลระบบหลังใช้งาน

### 1. System Design and Architecture

ใช้ช่วยในการ **ออกแบบโครงสร้างและสถาปัตยกรรมของระบบ**

ทำให้ Software Architect เห็นว่า:

- ระบบประกอบด้วย Component อะไรบ้าง
- แต่ละ Component ติดต่อกันอย่างไร
- Component ไหนพึ่งพา Component ไหน
- ส่วนไหนเป็น internal / external system

เช่น:

```
Web UI
  ↓
Order Service
  ↓
Payment Service
  ↓
Payment Gateway
```

เมื่อดู Diagram ก็จะเข้าใจ architecture โดยไม่ต้องเปิดดู source code ทั้งหมด

---
### 2. Requirements Analysis

ใช้ช่วยในการ **วิเคราะห์ Requirement**

ทั้งผู้พัฒนาและ stakeholder สามารถดูว่า requirement ต่าง ๆ ควรถูกจัดการโดย Component ใด

เช่น Requirement:

```
"ลูกค้าต้องสามารถชำระเงินออนไลน์ได้"
```

อาจนำไปสู่ Component:

```
Customer
   ↓
Order
   ↓
Payment
```

จึงช่วยเชื่อมแนวคิดจาก

```
Requirement
    ↓
System Function
    ↓
Component
```

นอกจากนี้ยังช่วยพิจารณา **Non-functional Requirements** เช่น Security, Scalability หรือ Availability ว่าควรจัดการที่ส่วนใดของ architecture

---

### 3. System Documentation

ใช้เป็น **เอกสารอ้างอิงของระบบ**

Component Diagram สามารถบันทึกว่า architecture ถูกออกแบบอย่างไร เช่น:

```
Frontend
   ↓
API Gateway
   ↓
Authentication Service
   ↓
Database
```

เมื่อมี developer ใหม่เข้าทีม เขาไม่จำเป็นต้องเริ่มต้นจากการอ่าน code หลายพันบรรทัด แต่สามารถดู Component Diagram เพื่อเข้าใจภาพรวมก่อน

ดังนั้นมันทำหน้าที่คล้าย:

> **แผนที่ของ Software Architecture**

---

### 4. Software Development

ช่วย developer กำหนด **ขอบเขตความรับผิดชอบของแต่ละส่วน**

ตัวอย่าง:

```
Order Service
- createOrder()
- cancelOrder()
- getOrder()

Payment Service
- processPayment()
- refundPayment()
```

Developer จึงรู้ว่า function ไหนควรอยู่ใน Component ไหน

สิ่งนี้ช่วยลดปัญหา เช่น

```
Order Service
├── Order logic
├── Payment logic
├── User authentication
├── Email sending
└── Inventory management
```

ซึ่งจะกลายเป็น Component ที่รับผิดชอบมากเกินไป

Component Diagram ช่วยให้แบ่งออกเป็น:

```
Order Service
Payment Service
Auth Service
Notification Service
Inventory Service
```

จึงสนับสนุนแนวคิด **Separation of Concerns**

---

### 5. Code Generation and Implementation

UML บางเครื่องมือสามารถนำ model ไปช่วยสร้าง code เริ่มต้นได้

ตัวอย่างจาก Component:

```
Order Service
Payment Service
Customer Service
```

เครื่องมือ Modeling บางชนิดอาจช่วยสร้างโครงสร้าง project หรือ interface เบื้องต้น เช่น

```
OrderService
PaymentService
CustomerService
```

อย่างไรก็ตามควรเข้าใจว่า Component Diagram ไม่ได้หมายความว่าจะสามารถ generate application ที่สมบูรณ์ได้ทันที

มันทำหน้าที่เป็น **Blueprint** หรือ foundation สำหรับ implementation มากกว่า

```
UML Model
    ↓
Architecture
    ↓
Code Structure
    ↓
Implementation
```

---

### 6. System Maintenance and Evolution

ข้อดีสำคัญอีกอย่างคือช่วยตอน **แก้ไขและพัฒนาระบบในอนาคต**

สมมติระบบเดิมมี:

```
Order
  ↓
Payment
```

วันหนึ่งต้องเพิ่มระบบ Refund:

```
Order
  ↓
Payment
  ↓
Refund Service
```

จาก Component Diagram เราสามารถวิเคราะห์ก่อนว่า:

- ต้องเพิ่ม Component ใด
- Component ใหม่จะเชื่อมกับใคร
- ส่วนไหนได้รับผลกระทบ
- มี dependency ใหม่เกิดขึ้นหรือไม่

ดังนั้นช่วยทำ **Impact Analysis** ได้ง่ายขึ้น

---

