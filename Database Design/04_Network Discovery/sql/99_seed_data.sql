-- =============================================================================
-- Module: 04_Network Discovery
-- File: 99_seed_data.sql
-- Description: Mock Seed Data for Testing Discovery & Topology Rendering
-- Target: PostgreSQL 14+
-- =============================================================================

-- 1. Seed Discovery Scan Log
INSERT INTO discovery_scans (id, seed_ip, status, devices_count, links_count, duration_ms, scanned_at)
VALUES 
    ('d1000000-0000-0000-0000-000000000001', '192.168.1.1', 'completed', 2, 1, 420, NOW())
ON CONFLICT (id) DO NOTHING;

-- 2. Seed Devices
INSERT INTO devices (id, ip, hostname, description, vendor, chassis_id, is_managed, status)
VALUES 
    ('a0000000-0000-0000-0000-000000000001', '192.168.1.1', 'SW-CORE-01', 'Cisco IOS Software, C3750 Software (C3750-IPSERVICESK9-M)', 'Cisco', '00:1A:2B:3C:4D:01', TRUE, 'online'),
    ('a0000000-0000-0000-0000-000000000002', '192.168.1.2', 'RT-EDGE-01', 'MikroTik RouterOS 7.12.1 (CHR)', 'MikroTik', '00:1A:2B:3C:4D:02', TRUE, 'online')
ON CONFLICT (ip) DO NOTHING;

-- 3. Seed Interfaces
INSERT INTO device_interfaces (id, device_id, if_index, name, mac_address, admin_status, oper_status)
VALUES 
    ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 1, 'GigabitEthernet1/0/1', '00:1A:2B:3C:4D:11', 'Up', 'Up'),
    ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 2, 'GigabitEthernet1/0/2', '00:1A:2B:3C:4D:12', 'Up', 'Up'),
    ('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000002', 1, 'ether1', '00:1A:2B:3C:4D:21', 'Up', 'Up')
ON CONFLICT (device_id, if_index) DO NOTHING;

-- 4. Seed Topology Link (SW-CORE-01 Gi1/0/1 <--> RT-EDGE-01 ether1)
INSERT INTO topology_links (id, source_device_id, source_interface_id, target_device_id, target_interface_id, protocol)
VALUES 
    ('c0000000-0000-0000-0000-000000000001', 
     'a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 
     'a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000003', 
     'lldp')
ON CONFLICT DO NOTHING;
