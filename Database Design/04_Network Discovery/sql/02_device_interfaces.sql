-- =============================================================================
-- Module: 04_Network Discovery (3NF Compliant)
-- File: 02_device_interfaces.sql
-- Description: Device Interfaces / Ports Table (Weak Entity of devices)
-- Normalization: 3NF (PK: id, Composite AK: device_id + if_index. No partial dependencies)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS device_interfaces (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    
    -- Candidate Key component (SNMP ifIndex uniquely identifies port on this device)
    if_index INTEGER NOT NULL,
    
    -- Port Attributes (Atomic & Directly dependent on device_id + if_index)
    name VARCHAR(255) NOT NULL,                       -- ifDescr / ifName (e.g. 'GigabitEthernet0/1', 'ether1')
    mac_address MACADDR,                              -- ifPhysAddress
    
    admin_status interface_status_enum NOT NULL DEFAULT 'Up',
    oper_status interface_status_enum NOT NULL DEFAULT 'Up',
    
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_device_if_index UNIQUE (device_id, if_index)
);

-- Indexes for interface resolution
CREATE INDEX IF NOT EXISTS idx_interfaces_device_id ON device_interfaces(device_id);
CREATE INDEX IF NOT EXISTS idx_interfaces_mac ON device_interfaces(mac_address);
CREATE INDEX IF NOT EXISTS idx_interfaces_oper_status ON device_interfaces(oper_status);
