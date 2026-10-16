# UML Sequence Diagrams

แผนภาพในโฟลเดอร์ `sequence` เรียงตาม Use Case ทั้ง 5 รายการ แต่ละรายการตรงกับกระบวนการที่มีอยู่เดิม จึงเป็นการปรับชื่อ ลำดับ และรายละเอียดตาม source code โดยไม่เพิ่ม Use Case ซ้ำ

| ลำดับ | Use Case | ไฟล์ | บทบาท |
| --- | --- | --- | --- |
| 01 | List Devices | [01-list-devices.mmd](sequence/01-list-devices.mmd) | Viewer / Operator / Admin |
| 02 | View Device Details | [02-view-device-details.mmd](sequence/02-view-device-details.mmd) | Viewer / Operator / Admin |
| 03 | Add/Edit Device | [03-add-edit-device.mmd](sequence/03-add-edit-device.mmd) | Operator / Admin |
| 04 | Discovery Network Device | [04-discovery-network-device.mmd](sequence/04-discovery-network-device.mmd) | Operator / Admin |
| 05 | Check Device Status | [05-check-device-status.mmd](sequence/05-check-device-status.mmd) | Operator / Admin |

บทบาทในแผนภาพแสดงสิทธิ์ตามขอบเขต Use Case ที่กำหนด ส่วนข้อความและลำดับการทำงานอ้างอิง source code ที่ตรวจอ่าน ไม่ได้แสดงขั้นตอนตรวจสิทธิ์ที่ไม่มีใน route ของ Backend ที่ตรวจอ่าน

## 01 List Devices

จากรูป List Devices Sequence Diagram แสดงลำดับการดูรายการอุปกรณ์ของผู้ใช้งานบทบาท Viewer, Operator และ Admin เมื่อผู้ใช้งานเปิดหน้า Devices Frontend จะส่งคำขอรายการอุปกรณ์ไปยัง Backend จากนั้น Device Inventory Service ค้นหาข้อมูลจากฐานข้อมูลตามเงื่อนไขการค้นหาและตัวกรอง เช่น Site กลุ่ม ประเภทอุปกรณ์ ผู้ผลิต และสถานะ โดยรายการปกติไม่รวมอุปกรณ์ที่เลิกใช้งาน ระบบเรียงผลลัพธ์และจำกัดจำนวนรายการก่อนส่งข้อมูลกลับไปยัง Frontend เพื่อแสดงผล หากไม่มีข้อมูลตรงเงื่อนไข ระบบจะส่งรายการว่างกลับไป

## 02 View Device Details

จากรูป View Device Details Sequence Diagram แสดงลำดับการดูรายละเอียดอุปกรณ์ของผู้ใช้งานบทบาท Viewer, Operator และ Admin ผู้ใช้งานเลือกอุปกรณ์จากหน้า Devices แล้ว Frontend ส่งคำขอรายละเอียดไปยัง Backend จากนั้น Device Inventory Service อ่านข้อมูลตามรหัสอุปกรณ์จากฐานข้อมูลและส่งรายละเอียด เช่น ข้อมูลพื้นฐาน อินเทอร์เฟซ กลุ่ม และสถานะ กลับมาแสดงผล หากไม่พบอุปกรณ์ Backend จะส่งข้อผิดพลาดให้ Frontend แจ้งผู้ใช้งาน

## 03 Add/Edit Device

จากรูป Add/Edit Device Sequence Diagram แสดงลำดับการเพิ่มและแก้ไขอุปกรณ์ของผู้ใช้งานบทบาท Operator และ Admin สำหรับการเพิ่มอุปกรณ์ Frontend ส่งข้อมูลไปยัง Backend เพื่อตรวจสอบ Management IP ซ้ำและข้อมูลอ้างอิง เช่น Site, Credential Profile และ Group เมื่อผ่านการตรวจสอบ Collection Service จะสร้างประวัติการเก็บข้อมูลและติดต่ออุปกรณ์ผ่าน SNMP จากนั้นบันทึก Device, Interface และข้อมูล Neighbor ที่รวบรวมได้ หากการเก็บข้อมูลหรือการตรวจสอบ identity ล้มเหลว ระบบจะยกเลิกการบันทึก snapshot ที่ผิดพลาดและเก็บประวัติความล้มเหลวไว้ สำหรับการแก้ไข ระบบค้นหาอุปกรณ์ ตรวจสอบข้อมูลอ้างอิง และบันทึกข้อมูลที่แก้ไขก่อนส่งข้อมูลล่าสุดกลับมา โดยการแก้ไขข้อมูลไม่ได้เรียกเก็บ snapshot ผ่าน SNMP ใหม่

## 04 Discovery Network Device

จากรูป Discovery Network Device Sequence Diagram แสดงลำดับการค้นหาอุปกรณ์เครือข่ายของผู้ใช้งานบทบาท Operator และ Admin ผู้ใช้งานระบุ Scan IP และ Credential Profile ผ่าน Frontend แล้วส่งคำขอไปยัง Backend เพื่อตรวจสอบ Credential และสร้าง Discovery Scan จากนั้น Network Discovery Library สำรวจอุปกรณ์และความเชื่อมโยงบนเครือข่าย Collection Service เก็บข้อมูลแต่ละอุปกรณ์ผ่าน SNMP ภายใต้ข้อจำกัดจำนวนอุปกรณ์และความลึก พร้อมสร้างหรืออัปเดต Device, Interface และ LLDP Observation หากเก็บข้อมูลไม่สำเร็จจะบันทึกประวัติความล้มเหลวไว้ ระบบบันทึกสถานะ Scan รวมทั้งข้อมูล Unmanaged Neighbor และ Default Route ก่อนส่งผลการค้นหาพร้อม Device และ Link กลับไปยัง Frontend เพื่อจัดตำแหน่งและแสดง Topology แผนภาพแสดงกระบวนการในภาพรวม โดยย่อรายละเอียดการส่งข้อมูลระหว่างสแกน

## 05 Check Device Status

จากรูป Check Device Status Sequence Diagram แสดงลำดับการตรวจสอบสถานะอุปกรณ์ของผู้ใช้งานบทบาท Operator และ Admin ผู้ใช้งานกดปุ่ม Check Status แล้ว Frontend ส่งคำขอไปยัง Backend เพื่ออ่านข้อมูลอุปกรณ์และ Credential จากฐานข้อมูล เมื่อ Credential ใช้งานได้ ระบบจะตรวจสอบการเชื่อมต่อผ่าน SNMP และกำหนดสถานะเป็น reachable หากติดต่อได้ หรือ unreachable หากติดต่อไม่ได้ ส่วนกรณีไม่สามารถตรวจสอบได้ เช่น Credential ใช้งานไม่ได้หรือเกิดข้อผิดพลาด ระบบจะกำหนดสถานะเป็น unknown หลังตรวจสอบเสร็จ Backend บันทึกสถานะอุปกรณ์และเวลาตรวจสอบลงฐานข้อมูล แล้วส่งผลกลับไปยัง Frontend เพื่อแสดงสถานะล่าสุด

## Source Code ที่ใช้อ้างอิง

- Backend: `app/features/devices/router.py`, `service.py` และ `services/inventory.py`, `services/health.py`, `services/snapshot.py`
- Backend Discovery: `app/features/network_device_discovery/router.py` และ `service.py`
- Frontend: `src/features/devices/DeviceInventoryPage.tsx`, `components/AddDeviceModal.tsx`, `components/DeviceDetailDrawer.tsx` และ `src/features/topology/hooks/useNetworkScan.ts`

ทุกไฟล์ใช้ activation bar แสดงช่วงการทำงาน สามารถนำเนื้อหาไปวางใน Mermaid renderer เพื่อสร้างภาพได้
