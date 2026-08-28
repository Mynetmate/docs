-- =============================================================================
-- Database Schema: 04_Network Discovery (Focused & Minimal)
-- Feature: Network Device Discovery & Topology Graph (Oxian Engine Output)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 1. ENUMS (Status & Protocol Types)
-- -----------------------------------------------------------------------------
DO $$ BEGIN
    CREATE TYPE device_status_enum AS ENUM ('online', 'offline', 'unreachable');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE interface_status_enum AS ENUM ('Up', 'Down', 'Testing', 'Unknown');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE link_protocol_enum AS ENUM ('lldp', 'cdp', 'default_route', 'manual');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- -----------------------------------------------------------------------------
-- 2. TABLE: devices (Discovered Network Devices)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Identification
    ip INET NOT NULL,                                 -- Management / Seed IP
    hostname VARCHAR(255),                            -- SNMP sysName
    description TEXT,                                 -- SNMP sysDescr (OS, Firmware, Build)
    vendor VARCHAR(50) NOT NULL DEFAULT 'Unknown',    -- 'Cisco', 'MikroTik', 'Juniper', 'Unknown'
    chassis_id VARCHAR(100),                          -- LLDP/Chassis MAC
    
    -- Status
    is_managed BOOLEAN NOT NULL DEFAULT TRUE,          -- TRUE: SNMP managed, FALSE: Inferred neighbor/gateway
    status device_status_enum NOT NULL DEFAULT 'online',
    
    -- Timestamps
    last_discovered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_devices_ip UNIQUE (ip)
);

CREATE INDEX IF NOT EXISTS idx_devices_ip ON devices(ip);
CREATE INDEX IF NOT EXISTS idx_devices_hostname ON devices(hostname);
CREATE INDEX IF NOT EXISTS idx_devices_vendor ON devices(vendor);

-- -----------------------------------------------------------------------------
-- 3. TABLE: device_interfaces (Network Interfaces / Ports)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS device_interfaces (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    
    if_index INTEGER NOT NULL,                        -- SNMP ifIndex (1, 2, 3...)
    name VARCHAR(255) NOT NULL,                       -- ifDescr (e.g. 'GigabitEthernet0/1', 'ether1')
    mac_address MACADDR,                              -- ifPhysAddress
    
    admin_status interface_status_enum NOT NULL DEFAULT 'Up',
    oper_status interface_status_enum NOT NULL DEFAULT 'Up',
    
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_device_if_index UNIQUE (device_id, if_index)
);

CREATE INDEX IF NOT EXISTS idx_interfaces_device_id ON device_interfaces(device_id);
CREATE INDEX IF NOT EXISTS idx_interfaces_mac ON device_interfaces(mac_address);

-- -----------------------------------------------------------------------------
-- 4. TABLE: topology_links (Resolved Physical / Logical Links)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS topology_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Source Endpoint
    source_device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    source_interface_id UUID REFERENCES device_interfaces(id) ON DELETE CASCADE,
    
    -- Target Endpoint
    target_device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    target_interface_id UUID REFERENCES device_interfaces(id) ON DELETE CASCADE,
    
    -- Fallback Hints for Unmanaged / Gateway Neighbors
    target_hostname_hint VARCHAR(255),
    target_port_hint VARCHAR(255),
    
    protocol link_protocol_enum NOT NULL DEFAULT 'lldp',
    discovered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_topology_link UNIQUE (source_device_id, source_interface_id, target_device_id, target_interface_id, target_port_hint)
);

CREATE INDEX IF NOT EXISTS idx_links_source_device ON topology_links(source_device_id);
CREATE INDEX IF NOT EXISTS idx_links_source_interface ON topology_links(source_interface_id);
CREATE INDEX IF NOT EXISTS idx_links_target_device ON topology_links(target_device_id);
CREATE INDEX IF NOT EXISTS idx_links_target_interface ON topology_links(target_interface_id);

-- -----------------------------------------------------------------------------
-- 5. TABLE: discovery_scans (Discovery Scan History & Audit)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS discovery_scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seed_ip INET NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',  -- 'running', 'completed', 'failed'
    devices_count INTEGER NOT NULL DEFAULT 0,
    links_count INTEGER NOT NULL DEFAULT 0,
    duration_ms INTEGER,
    error_message TEXT,
    scanned_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
