-- Depends on Inventory seed; never inserts devices/interfaces here.
INSERT INTO discovery_scans (id,seed_ip,credential_profile_id,status,max_depth,max_devices,environment,requested_at,started_at,finished_at)
VALUES ('77777777-7777-7777-7777-777777777701','192.168.10.1','33333333-3333-3333-3333-333333333301','partial',3,20,'emulated','2026-09-13 01:00:00+00','2026-09-13 01:00:01+00','2026-09-13 01:00:10+00');
INSERT INTO collection_runs (id,discovery_scan_id,device_id,target_ip,credential_profile_id,purpose,transport,environment,status,neighbor_status,requested_at,started_at,finished_at)
VALUES
('88888888-8888-8888-8888-888888888801','77777777-7777-7777-7777-777777777701','44444444-4444-4444-4444-444444444401','192.168.10.1','33333333-3333-3333-3333-333333333301','discovery','snmp','emulated','succeeded','succeeded','2026-09-13 01:00:01+00','2026-09-13 01:00:02+00','2026-09-13 01:00:05+00'),
('88888888-8888-8888-8888-888888888802','77777777-7777-7777-7777-777777777701','44444444-4444-4444-4444-444444444402','192.168.10.2','33333333-3333-3333-3333-333333333301','discovery','snmp','emulated','succeeded','succeeded','2026-09-13 01:00:01+00','2026-09-13 01:00:02+00','2026-09-13 01:00:05+00');
-- Failed enrollment without a device: not a verified Inventory node.
INSERT INTO collection_runs (id,target_ip,credential_profile_id,purpose,transport,environment,status,error_message,requested_at,started_at,finished_at)
VALUES ('88888888-8888-8888-8888-888888888803','192.168.10.99','33333333-3333-3333-3333-333333333301','manual_enrollment','snmp','emulated','failed','SNMP timeout','2026-09-13 01:00:00+00','2026-09-13 01:00:01+00','2026-09-13 01:00:03+00');
-- A failed scan target makes the overall scan partial.
INSERT INTO collection_runs (id,discovery_scan_id,target_ip,credential_profile_id,purpose,transport,environment,status,neighbor_status,error_message,requested_at,started_at,finished_at)
VALUES ('88888888-8888-8888-8888-888888888804','77777777-7777-7777-7777-777777777701','192.168.10.3','33333333-3333-3333-3333-333333333301','discovery','snmp','emulated','failed','not_attempted','SNMP timeout','2026-09-13 01:00:06+00','2026-09-13 01:00:07+00','2026-09-13 01:00:09+00');
-- Raw evidence. The third neighbor has no management IP and no Inventory node.
INSERT INTO neighbor_observations (id,collection_run_id,local_device_id,local_interface_id,observation_key,remote_chassis_id_subtype,remote_chassis_id,remote_port_id_subtype,remote_port_id,remote_system_name,observed_at)
VALUES
('99999999-9999-9999-9999-999999999901','88888888-8888-8888-8888-888888888801','44444444-4444-4444-4444-444444444401','55555555-5555-5555-5555-555555555501','lldp:0:1:1',4,'00:11:22:33:44:02',5,'ether1','SW-02','2026-09-13 01:00:04+00'),
('99999999-9999-9999-9999-999999999902','88888888-8888-8888-8888-888888888802','44444444-4444-4444-4444-444444444402','55555555-5555-5555-5555-555555555502','lldp:0:1:1',4,'00:11:22:33:44:01',5,'GigabitEthernet0/1','SW-01','2026-09-13 01:00:04+00'),
('99999999-9999-9999-9999-999999999903','88888888-8888-8888-8888-888888888801','44444444-4444-4444-4444-444444444401','55555555-5555-5555-5555-555555555501','lldp:0:1:2',7,'unknown-chassis',5,'port1',NULL,'2026-09-13 01:00:04+00');
