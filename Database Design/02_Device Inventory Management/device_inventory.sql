-- =============================================================================
-- Module: 02_Device Inventory Management (Master Combined DDL)
-- File: device_inventory.sql
-- Description: Complete 3NF Normalized Database Schema for Device Inventory
-- Target: PostgreSQL 14+
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Extensions & Enums
-- -----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$ BEGIN
    CREATE TYPE device_type_enum AS ENUM (
        'router', 'switch', 'firewall', 'access_point', 'server', 'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE device_role_enum AS ENUM (
        'core', 'distribution', 'access', 'edge_router', 'management', 'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE vendor_enum AS ENUM (
        'cisco', 'mikrotik', 'huawei', 'juniper', 'arista', 'linux', 'unknown'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE device_status_enum AS ENUM (
        'online', 'offline', 'unreachable', 'maintenance'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE enrollment_status_enum AS ENUM (
        'pending', 'enrolled', 'failed', 'rejected'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE discovery_method_enum AS ENUM (
        'manual_enrollment', 'auto_discovery', 'csv_import'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE credential_type_enum AS ENUM (
        'ssh_password', 'ssh_key', 'snmp_v2c', 'snmp_v3', 'api_token'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE interface_status_enum AS ENUM (
        'Up', 'Down', 'Testing', 'Unknown'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE interface_mode_enum AS ENUM (
        'access', 'trunk', 'routed', 'loopback', 'svi', 'unknown'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE enrollment_attempt_status_enum AS ENUM (
        'pending', 'authenticating', 'collecting', 'succeeded', 'failed'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- -----------------------------------------------------------------------------
-- 1. Table: credential_profiles
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS credential_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    credential_type credential_type_enum NOT NULL DEFAULT 'ssh_password',
    username VARCHAR(100),
    password_encrypted TEXT,
    enable_secret_encrypted TEXT,
    snmp_community_ro_encrypted TEXT,
    snmp_community_rw_encrypted TEXT,
    ssh_port INTEGER NOT NULL DEFAULT 22 CHECK (ssh_port BETWEEN 1 AND 65535),
    snmp_port INTEGER NOT NULL DEFAULT 161 CHECK (snmp_port BETWEEN 1 AND 65535),
    description TEXT,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_credential_profiles_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_credential_profiles_name ON credential_profiles(name);
CREATE INDEX IF NOT EXISTS idx_credential_profiles_type ON credential_profiles(credential_type);

-- -----------------------------------------------------------------------------
-- 2. Table: sites & device_groups
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    location_detail VARCHAR(255),
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_sites_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_sites_name ON sites(name);

CREATE TABLE IF NOT EXISTS device_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    color_tag VARCHAR(20) DEFAULT '#3B82F6',
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_device_groups_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_device_groups_name ON device_groups(name);

-- -----------------------------------------------------------------------------
-- 3. Table: devices
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    management_ip INET NOT NULL,
    hostname VARCHAR(255) NOT NULL,
    domain_name VARCHAR(255),
    description TEXT,
    device_type device_type_enum NOT NULL DEFAULT 'switch',
    role device_role_enum NOT NULL DEFAULT 'access',
    vendor vendor_enum NOT NULL DEFAULT 'unknown',
    model VARCHAR(100),
    os_version VARCHAR(100),
    serial_number VARCHAR(100),
    chassis_mac MACADDR,
    chassis_id VARCHAR(100),
    site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
    credential_profile_id UUID REFERENCES credential_profiles(id) ON DELETE SET NULL,
    platform VARCHAR(50) DEFAULT 'cisco_ios',
    management_vlan INTEGER CHECK (management_vlan BETWEEN 1 AND 4094),
    default_gateway INET,
    is_managed BOOLEAN NOT NULL DEFAULT TRUE,
    status device_status_enum NOT NULL DEFAULT 'online',
    enrollment_status enrollment_status_enum NOT NULL DEFAULT 'enrolled',
    discovery_method discovery_method_enum NOT NULL DEFAULT 'manual_enrollment',
    last_discovered_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    last_collected_at TIMESTAMPTZ DEFAULT NOW(),
    uptime_seconds BIGINT DEFAULT 0,
    notes TEXT,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_devices_management_ip UNIQUE (management_ip)
);

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

-- -----------------------------------------------------------------------------
-- 4. Table: device_group_members (Many-to-Many Bridge)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS device_group_members (
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES device_groups(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (device_id, group_id)
);

CREATE INDEX IF NOT EXISTS idx_group_members_device ON device_group_members(device_id);
CREATE INDEX IF NOT EXISTS idx_group_members_group ON device_group_members(group_id);

-- -----------------------------------------------------------------------------
-- 5. Table: device_interfaces
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS device_interfaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    if_index INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    mac_address MACADDR,
    ip_address INET,
    subnet_mask INET,
    description VARCHAR(255),
    mode interface_mode_enum NOT NULL DEFAULT 'access',
    vlan_id INTEGER CHECK (vlan_id BETWEEN 1 AND 4094),
    admin_status interface_status_enum NOT NULL DEFAULT 'Up',
    oper_status interface_status_enum NOT NULL DEFAULT 'Up',
    speed_bps BIGINT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_device_interfaces_device_if_index UNIQUE (device_id, if_index)
);

CREATE INDEX IF NOT EXISTS idx_device_interfaces_device_id ON device_interfaces(device_id);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_mac ON device_interfaces(mac_address);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_ip ON device_interfaces(ip_address);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_oper_status ON device_interfaces(oper_status);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_vlan ON device_interfaces(vlan_id);

-- -----------------------------------------------------------------------------
-- 6. Table: device_enrollment_attempts
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS device_enrollment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_ip INET NOT NULL,
    credential_profile_id UUID REFERENCES credential_profiles(id) ON DELETE SET NULL,
    status enrollment_attempt_status_enum NOT NULL DEFAULT 'pending',
    error_message TEXT,
    collected_hostname VARCHAR(255),
    collected_vendor VARCHAR(50),
    collected_model VARCHAR(100),
    collected_os_version VARCHAR(100),
    duration_ms INTEGER,
    initiated_by UUID,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_enrollment_attempts_ip ON device_enrollment_attempts(target_ip);
CREATE INDEX IF NOT EXISTS idx_enrollment_attempts_status ON device_enrollment_attempts(status);
CREATE INDEX IF NOT EXISTS idx_enrollment_attempts_time ON device_enrollment_attempts(attempted_at);
