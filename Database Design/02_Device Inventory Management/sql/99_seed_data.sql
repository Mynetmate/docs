-- Mock data only; NEW test database. Secret placeholders are NOT usable ciphertext.
INSERT INTO sites (id,name) VALUES ('11111111-1111-1111-1111-111111111101','Isolated lab');
INSERT INTO device_groups (id,name,color_tag) VALUES ('22222222-2222-2222-2222-222222222201','Lab infrastructure','#3B82F6');
INSERT INTO credential_profiles (id,name,snmp_community_ro_encrypted)
VALUES ('33333333-3333-3333-3333-333333333301','Mock SNMP profile','MOCK_NOT_A_REAL_ENCRYPTED_SECRET');
INSERT INTO devices (id,management_ip,hostname,device_type,vendor,site_id,credential_profile_id,enrollment_source,last_collected_at)
VALUES
('44444444-4444-4444-4444-444444444401','192.168.10.1','SW-01','switch','cisco','11111111-1111-1111-1111-111111111101','33333333-3333-3333-3333-333333333301','manual_enrollment','2026-09-13 01:00:05+00'),
('44444444-4444-4444-4444-444444444402','192.168.10.2','SW-02','switch','mikrotik','11111111-1111-1111-1111-111111111101','33333333-3333-3333-3333-333333333301','auto_discovery','2026-09-13 01:00:05+00');
INSERT INTO device_group_members (device_id,group_id)
SELECT id,'22222222-2222-2222-2222-222222222201'::uuid FROM devices;
INSERT INTO device_interfaces (id,device_id,if_index,name,collected_at)
VALUES
('55555555-5555-5555-5555-555555555501','44444444-4444-4444-4444-444444444401',1,'GigabitEthernet0/1','2026-09-13 01:00:05+00'),
('55555555-5555-5555-5555-555555555502','44444444-4444-4444-4444-444444444402',1,'ether1','2026-09-13 01:00:05+00');
INSERT INTO interface_ip_addresses (interface_id,address) VALUES
('55555555-5555-5555-5555-555555555501','192.168.10.1/24'),
('55555555-5555-5555-5555-555555555501','2001:db8::1/64');
