-- =============================================================================
-- Module: 04_Network Discovery (3NF Compliant)
-- File: 01_devices.sql
-- Description: Discovered Network Devices Table (Core Entity reconciled with 02_Device Inventory)
-- Normalization: 3NF (PK: id, AK: management_ip. No partial or transitive dependencies)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification (Atomic Attributes - Unified with Master Inventory)
    management_ip INET NOT NULL,                      -- Management / Seed IP (Unique Candidate Key)
    hostname VARCHAR(255),                            -- SNMP sysName / Device Hostname
    description TEXT,                                 -- SNMP sysDescr (OS, Firmware, Build)
    vendor VARCHAR(50) NOT NULL DEFAULT 'Unknown',    -- 'cisco', 'mikrotik', 'huawei', 'juniper', 'Unknown'
    chassis_mac MACADDR,                              -- LLDP Chassis MAC
    chassis_id VARCHAR(100),                          -- LLDP Chassis Subtype/ID fallback
    
    -- Operational & Discovery Status
    is_managed BOOLEAN NOT NULL DEFAULT TRUE,          -- TRUE: SNMP managed, FALSE: Inferred neighbor/gateway
    status device_status_enum NOT NULL DEFAULT 'online',
    discovery_method discovery_method_enum NOT NULL DEFAULT 'auto_discovery',
    
    -- Audit & Timestamps
    last_discovered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_devices_management_ip UNIQUE (management_ip)
);

-- Indexes for frequent lookup and filtering
CREATE INDEX IF NOT EXISTS idx_devices_management_ip ON devices(management_ip);
CREATE INDEX IF NOT EXISTS idx_devices_hostname ON devices(hostname);
CREATE INDEX IF NOT EXISTS idx_devices_vendor ON devices(vendor);
CREATE INDEX IF NOT EXISTS idx_devices_status ON devices(status);
CREATE INDEX IF NOT EXISTS idx_devices_chassis_mac ON devices(chassis_mac);
