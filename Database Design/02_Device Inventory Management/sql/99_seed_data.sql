-- =============================================================================
-- Module: 02_Device Inventory Management (3NF Compliant)
-- File: 99_seed_data.sql
-- Description: Mock Test Seed Data for Verification & Testing
-- Target: PostgreSQL 14+
-- =============================================================================

-- 1. Insert Sample Sites
INSERT INTO sites (id, name, location_detail, description)
VALUES 
    ('11111111-1111-1111-1111-111111111101', 'HQ Bangkok', 'Data Center Floor 3, Rack A1', 'Main Headquarters Data Center'),
    ('11111111-1111-1111-1111-111111111102', 'Bangna Branch', 'Server Room B, Floor 2', 'Regional Branch Office Network')
ON CONFLICT (name) DO NOTHING;

-- 2. Insert Sample Device Groups
INSERT INTO device_groups (id, name, color_tag, description)
VALUES 
    ('22222222-2222-2222-2222-222222222201', 'Core Infrastructure', '#EF4444', 'Mission critical Core Routers & Switches'),
    ('22222222-2222-2222-2222-222222222202', 'Distribution Layer', '#F59E0B', 'Distribution & Aggregation layer devices'),
    ('22222222-2222-2222-2222-222222222203', 'Access Network', '#10B981', 'Floor Access Switches')
ON CONFLICT (name) DO NOTHING;

-- 3. Insert Sample Credential Profiles (Encrypted Mock Strings)
INSERT INTO credential_profiles (
    id, name, credential_type, username, password_encrypted, enable_secret_encrypted, snmp_community_ro_encrypted, ssh_port, snmp_port, description
)
VALUES 
    (
        '33333333-3333-3333-3333-333333333301', 
        'Cisco Lab Default', 
        'ssh_password', 
        'admin', 
        'enc_aes256_gcm_dGVzdHBhc3N3b3JkMQ==', 
        'enc_aes256_gcm_ZW5hYmxlc2VjcmV0MQ==', 
        'enc_aes256_gcm_cHVibGlj', 
        22, 
        161, 
        'Credentials profile for Cisco IOS devices in isolated lab'
    ),
    (
        '33333333-3333-3333-3333-333333333302', 
        'MikroTik RouterOS Profile', 
        'ssh_password', 
        'admin', 
        'enc_aes256_gcm_bWlrcm90aWtwYXNz', 
        NULL, 
        'enc_aes256_gcm_cHVibGlj', 
        22, 
        161, 
        'Credentials for MikroTik Edge Routers'
    )
ON CONFLICT (name) DO NOTHING;

-- 4. Insert Sample Managed Devices
INSERT INTO devices (
    id, management_ip, hostname, domain_name, device_type, role, vendor, model, os_version, serial_number, 
    chassis_mac, site_id, credential_profile_id, platform, management_vlan, default_gateway, is_managed, 
    status, enrollment_status, discovery_method, uptime_seconds, notes
)
VALUES 
    (
        '44444444-4444-4444-4444-444444444401', 
        '172.16.1.2', 
        'RT-CISCO-CORE-01', 
        'mynetmate.lab', 
        'router', 
        'core', 
        'cisco', 
        'Cisco 7200', 
        'IOS 15.2(4)M11', 
        'FTX184209LK', 
        '52:54:00:12:34:56', 
        '11111111-1111-1111-1111-111111111101', 
        '33333333-3333-3333-3333-333333333301', 
        'cisco_ios', 
        99, 
        '172.16.1.1', 
        TRUE, 
        'online', 
        'enrolled', 
        'manual_enrollment', 
        864000, 
        'Primary Core Router for HQ'
    ),
    (
        '44444444-4444-4444-4444-444444444402', 
        '172.16.2.2', 
        'SW-CISCO-ACC-01', 
        'mynetmate.lab', 
        'switch', 
        'access', 
        'cisco', 
        'Catalyst 2960', 
        'IOS 15.0(2)SE11', 
        'FCW2149L0P8', 
        '52:54:00:78:9A:BC', 
        '11111111-1111-1111-1111-111111111101', 
        '33333333-3333-3333-3333-333333333301', 
        'cisco_ios', 
        99, 
        '172.16.2.1', 
        TRUE, 
        'online', 
        'enrolled', 
        'manual_enrollment', 
        1728000, 
        'Access Switch Floor 1'
    ),
    (
        '44444444-4444-4444-4444-444444444403', 
        '161.246.0.2', 
        'RT-MIKROTIK-EDGE-01', 
        'mynetmate.lab', 
        'router', 
        'edge_router', 
        'mikrotik', 
        'RB750Gr3', 
        'RouterOS 7.14.3', 
        'HEX789012AA', 
        '52:54:00:DE:F0:12', 
        '11111111-1111-1111-1111-111111111102', 
        '33333333-3333-3333-3333-333333333302', 
        'mikrotik_routeros', 
        NULL, 
        '161.246.0.1', 
        TRUE, 
        'online', 
        'enrolled', 
        'manual_enrollment', 
        432000, 
        'Edge Gateway Router for Bangna'
    )
ON CONFLICT (management_ip) DO NOTHING;

-- 5. Insert Group Memberships
INSERT INTO device_group_members (device_id, group_id)
VALUES 
    ('44444444-4444-4444-4444-444444444401', '22222222-2222-2222-2222-222222222201'),
    ('44444444-4444-4444-4444-444444444402', '22222222-2222-2222-2222-222222222203'),
    ('44444444-4444-4444-4444-444444444403', '22222222-2222-2222-2222-222222222201')
ON CONFLICT DO NOTHING;

-- 6. Insert Interfaces for Core Router & Access Switch
INSERT INTO device_interfaces (
    id, device_id, if_index, name, mac_address, ip_address, subnet_mask, description, mode, vlan_id, admin_status, oper_status, speed_bps
)
VALUES 
    (
        '55555555-5555-5555-5555-555555555501', 
        '44444444-4444-4444-4444-444444444401', 
        1, 
        'Ethernet0/1', 
        '52:54:00:12:34:57', 
        '172.16.1.2', 
        '255.255.255.252', 
        'Link to MikroTik Edge ether3', 
        'routed', 
        NULL, 
        'Up', 
        'Up', 
        1000000000
    ),
    (
        '55555555-5555-5555-5555-555555555502', 
        '44444444-4444-4444-4444-444444444401', 
        2, 
        'Ethernet0/2', 
        '52:54:00:12:34:58', 
        '172.16.3.1', 
        '255.255.255.252', 
        'Link to Cisco Switch eth0/2', 
        'routed', 
        NULL, 
        'Up', 
        'Up', 
        1000000000
    ),
    (
        '55555555-5555-5555-5555-555555555503', 
        '44444444-4444-4444-4444-444444444402', 
        1, 
        'Ethernet0/1', 
        '52:54:00:78:9A:BD', 
        '172.16.2.2', 
        '255.255.255.252', 
        'Uplink to MikroTik Edge ether4', 
        'trunk', 
        NULL, 
        'Up', 
        'Up', 
        1000000000
    ),
    (
        '55555555-5555-5555-5555-555555555504', 
        '44444444-4444-4444-4444-444444444402', 
        2, 
        'Ethernet0/2', 
        '52:54:00:78:9A:BE', 
        '172.16.3.2', 
        '255.255.255.252', 
        'Link to Cisco Core eth0/2', 
        'trunk', 
        NULL, 
        'Up', 
        'Up', 
        1000000000
    ),
    (
        '55555555-5555-5555-5555-555555555505', 
        '44444444-4444-4444-4444-444444444402', 
        3, 
        'FastEthernet0/1', 
        '52:54:00:78:9A:BF', 
        NULL, 
        NULL, 
        'User Port VLAN 10', 
        'access', 
        10, 
        'Up', 
        'Up', 
        100000000
    )
ON CONFLICT (device_id, if_index) DO NOTHING;

-- 7. Insert Sample Enrollment Attempt Log
INSERT INTO device_enrollment_attempts (
    id, target_ip, credential_profile_id, status, error_message, collected_hostname, collected_vendor, collected_model, collected_os_version, duration_ms
)
VALUES 
    (
        '66666666-6666-6666-6666-666666666601', 
        '172.16.1.2', 
        '33333333-3333-3333-3333-333333333301', 
        'succeeded', 
        NULL, 
        'RT-CISCO-CORE-01', 
        'cisco', 
        'Cisco 7200', 
        'IOS 15.2(4)M11', 
        750
    )
ON CONFLICT DO NOTHING;
