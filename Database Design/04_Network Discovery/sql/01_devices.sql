-- =============================================================================
-- Module: 04_Network Discovery (3NF Compliant)
-- File: 01_devices.sql
-- Description: Discovered Network Devices Table (Core Entity)
-- Normalization: 3NF (PK: id, AK: ip. No partial or transitive dependencies)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Identification (Atomic Attributes)
    ip INET NOT NULL,                                 -- Management / Seed IP (Unique Candidate Key)
    hostname VARCHAR(255),                            -- SNMP sysName
    description TEXT,                                 -- SNMP sysDescr (OS, Firmware, Build)
    vendor VARCHAR(50) NOT NULL DEFAULT 'Unknown',    -- 'Cisco', 'MikroTik', 'Juniper', 'Unknown'
    chassis_id VARCHAR(100),                          -- LLDP/Chassis MAC
    
    -- Operational Status
    is_managed BOOLEAN NOT NULL DEFAULT TRUE,          -- TRUE: SNMP managed, FALSE: Inferred neighbor/gateway
    status device_status_enum NOT NULL DEFAULT 'online',
    
    -- Audit & Timestamps
    last_discovered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_devices_ip UNIQUE (ip)
);

-- Indexes for frequent lookup and filtering
CREATE INDEX IF NOT EXISTS idx_devices_ip ON devices(ip);
CREATE INDEX IF NOT EXISTS idx_devices_hostname ON devices(hostname);
CREATE INDEX IF NOT EXISTS idx_devices_vendor ON devices(vendor);
CREATE INDEX IF NOT EXISTS idx_devices_status ON devices(status);
