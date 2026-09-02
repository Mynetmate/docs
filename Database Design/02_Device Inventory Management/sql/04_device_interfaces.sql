-- =============================================================================
-- Module: 02_Device Inventory Management (3NF Compliant)
-- File: 04_device_interfaces.sql
-- Description: Device Physical & Logical Ports / Interfaces (Weak Entity)
-- Normalization: 3NF (PK: id, Composite AK: device_id + if_index)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS device_interfaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    
    -- Candidate Key Component (Unique per device)
    if_index INTEGER NOT NULL,
    
    -- Physical & Layer 2 Identification
    name VARCHAR(255) NOT NULL, -- e.g. 'GigabitEthernet0/1', 'ether1', 'Vlan10'
    mac_address MACADDR,
    
    -- Layer 3 Addressing (Optional / If Assigned)
    ip_address INET,
    subnet_mask INET,
    
    -- Configuration Attributes
    description VARCHAR(255),
    mode interface_mode_enum NOT NULL DEFAULT 'access',
    vlan_id INTEGER CHECK (vlan_id BETWEEN 1 AND 4094),
    
    -- Operational & Administrative Status
    admin_status interface_status_enum NOT NULL DEFAULT 'Up',
    oper_status interface_status_enum NOT NULL DEFAULT 'Up',
    speed_bps BIGINT,
    
    -- Timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_device_interfaces_device_if_index UNIQUE (device_id, if_index)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_device_interfaces_device_id ON device_interfaces(device_id);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_mac ON device_interfaces(mac_address);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_ip ON device_interfaces(ip_address);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_oper_status ON device_interfaces(oper_status);
CREATE INDEX IF NOT EXISTS idx_device_interfaces_vlan ON device_interfaces(vlan_id);
