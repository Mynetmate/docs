-- =============================================================================
-- Module: 04_Network Discovery
-- File: 01_devices.sql
-- Description: Discovered Network Devices (SNMP / Oxian Engine)
-- Target: PostgreSQL 14+
-- =============================================================================

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

-- Indexes for querying by IP, Hostname, and Vendor
CREATE INDEX IF NOT EXISTS idx_devices_ip ON devices(ip);
CREATE INDEX IF NOT EXISTS idx_devices_hostname ON devices(hostname);
CREATE INDEX IF NOT EXISTS idx_devices_vendor ON devices(vendor);
