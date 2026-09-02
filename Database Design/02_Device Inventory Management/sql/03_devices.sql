-- =============================================================================
-- Module: 02_Device Inventory Management (3NF Compliant)
-- File: 03_devices.sql
-- Description: Core Managed Devices Entity & Group Memberships Bridge
-- Normalization: 3NF (PK: id, Candidate Key: management_ip. Clean foreign keys)
-- Target: PostgreSQL 14+
-- =============================================================================

-- 1. Core Devices Table
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification & Addressing (Candidate Key: management_ip)
    management_ip INET NOT NULL,
    hostname VARCHAR(255) NOT NULL,
    domain_name VARCHAR(255),
    description TEXT,                                 -- SNMP sysDescr (OS, Firmware, Build)
    
    -- Categorization & Classification
    device_type device_type_enum NOT NULL DEFAULT 'switch',
    role device_role_enum NOT NULL DEFAULT 'access',
    vendor vendor_enum NOT NULL DEFAULT 'unknown',
    
    -- Hardware & Software Inventory
    model VARCHAR(100),
    os_version VARCHAR(100),
    serial_number VARCHAR(100),
    chassis_mac MACADDR,
    chassis_id VARCHAR(100),
    
    -- Organizational References (FKs)
    site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
    credential_profile_id UUID REFERENCES credential_profiles(id) ON DELETE SET NULL,
    
    -- Connection Configuration
    platform VARCHAR(50) DEFAULT 'cisco_ios', -- Netmiko driver (e.g. 'cisco_ios', 'mikrotik_routeros')
    management_vlan INTEGER CHECK (management_vlan BETWEEN 1 AND 4094),
    default_gateway INET,
    
    -- Management & Lifecycle Status
    is_managed BOOLEAN NOT NULL DEFAULT TRUE,
    status device_status_enum NOT NULL DEFAULT 'online',
    enrollment_status enrollment_status_enum NOT NULL DEFAULT 'enrolled',
    discovery_method discovery_method_enum NOT NULL DEFAULT 'manual_enrollment',
    
    -- Telemetry & Health Timestamps
    last_discovered_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    last_collected_at TIMESTAMPTZ DEFAULT NOW(),
    uptime_seconds BIGINT DEFAULT 0,
    
    -- Metadata & Auditing
    notes TEXT,
    created_by UUID, -- References users(id)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_devices_management_ip UNIQUE (management_ip)
);

-- Indexes for frequent queries and dashboard filters
CREATE INDEX IF NOT EXISTS idx_devices_management_ip ON devices(management_ip);
CREATE INDEX IF NOT EXISTS idx_devices_hostname ON devices(hostname);
CREATE INDEX IF NOT EXISTS idx_devices_vendor ON devices(vendor);
CREATE INDEX IF NOT EXISTS idx_devices_type ON devices(device_type);
CREATE INDEX IF NOT EXISTS idx_devices_role ON devices(role);
CREATE INDEX IF NOT EXISTS idx_devices_status ON devices(status);
CREATE INDEX IF NOT EXISTS idx_devices_enrollment_status ON devices(enrollment_status);
CREATE INDEX IF NOT EXISTS idx_devices_site_id ON devices(site_id);
CREATE INDEX IF NOT EXISTS idx_devices_credential_profile_id ON devices(credential_profile_id);
CREATE INDEX IF NOT EXISTS idx_devices_chassis_mac ON devices(chassis_mac);


-- 2. Device Group Memberships Bridge Table (Many-to-Many: 3NF Compliant)
CREATE TABLE IF NOT EXISTS device_group_members (
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES device_groups(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (device_id, group_id)
);

CREATE INDEX IF NOT EXISTS idx_group_members_device ON device_group_members(device_id);
CREATE INDEX IF NOT EXISTS idx_group_members_group ON device_group_members(group_id);
