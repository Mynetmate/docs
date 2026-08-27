# NTV Document Status and AI Reading Guide

เอกสารนี้กำหนดลำดับและขอบเขตการอ่านเอกสาร Network Topology Visualization (NTV) เพื่อป้องกันไม่ให้ AI หรือสมาชิกทีมตีความงานออกแบบว่าเป็นคำยืนยันการส่งมอบ

## สถานะการพัฒนา

- สถานะการทำ NTV แบบ Full-stack ในเทอมนี้: **Undecided — ยังไม่ยืนยัน**
- เอกสารในโฟลเดอร์นี้เป็น Design Baseline และ Candidate Contract สำหรับใช้ตัดสินใจและเตรียมการพัฒนา
- การมี MVP, Schema, Component Diagram, API หรือ Acceptance Test ไม่ได้หมายความว่า NTV ถูก Commit ให้พัฒนาในเทอมนี้

## Protocol Baseline

- ใช้ **SNMP** สำหรับอ่านข้อมูลอุปกรณ์ตามขอบเขตของ Network Discovery/Collection
- ใช้ **LLDP** เป็นหลักฐาน Neighbor สำหรับสร้าง Physical/L2 Topology
- **CDP ไม่อยู่ในขอบเขตการพัฒนาปัจจุบัน** เพราะทีมเลือกใช้โปรโตคอลมาตรฐานที่รองรับหลาย Vendor

## ลำดับการอ่านสำหรับ AI

1. อ่าน `01_MVP - MyNetMate NTV.md` เพื่อเข้าใจขอบเขตและ Business Rules
2. อ่านเอกสารตามงานที่กำลังทำเท่านั้น:
   - Database/Backend: `02_Database Schema.md`
   - Architecture: `03_Component Diagram.md`
   - API: `04_NTV - API.md`
   - Testing: `05_Acceptance Tests.md`
3. เปิด `คำอธิบายคำศัพท์ NTV.md` เฉพาะเมื่อต้องการความหมายของคำศัพท์ โดยห้ามใช้แทน Source of Truth ด้าน Schema
4. ไม่ใช้ไฟล์ใน `Lib ที่เพื่อนแนะนำ/` เป็น Requirement หรือ Technology Decision จนกว่าทีมจะอนุมัติ Library

## Source of Truth และข้อห้าม

- ขอบเขต Feature: `01_MVP - MyNetMate NTV.md`
- ชื่อตารางและความสัมพันธ์: `02_Database Schema.md`
- ขอบเขต Component: `03_Component Diagram.md`
- Endpoint ใน `04_NTV - API.md` ยังเป็น Candidate API
- หัวข้อที่ติดป้าย `Future Extension` ไม่ใช่ MVP และห้ามสร้างเป็นตาราง, API หรือ Implementation Task โดยอัตโนมัติ
- NTV อ่าน Device, Interface และ Neighbor Observation จากเจ้าของข้อมูลเดิม ไม่สร้างข้อมูลเหล่านี้ซ้ำ

