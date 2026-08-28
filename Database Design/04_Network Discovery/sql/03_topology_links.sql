-- =============================================================================
-- Module: 04_Network Discovery
-- File: 03_topology_links.sql
-- Description: Physical & Logical Inter-Device Topology Links (LLDP / CDP)
-- Target: PostgreSQL 14+
-- =============================================================================

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

-- Indexes for fast topology traversal and graph rendering
CREATE INDEX IF NOT EXISTS idx_links_source_device ON topology_links(source_device_id);
CREATE INDEX IF NOT EXISTS idx_links_source_interface ON topology_links(source_interface_id);
CREATE INDEX IF NOT EXISTS idx_links_target_device ON topology_links(target_device_id);
CREATE INDEX IF NOT EXISTS idx_links_target_interface ON topology_links(target_interface_id);
