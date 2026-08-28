-- =============================================================================
-- Module: 04_Network Discovery (3NF Compliant)
-- File: 03_topology_links.sql
-- Description: Discovered Inter-Device Connections & Graph Edges
-- Normalization: 3NF (Direct relational endpoints, avoids transitive device duplication)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS topology_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Source Endpoint (Direct link from local interface where LLDP/CDP neighbor was found)
    source_interface_id UUID NOT NULL REFERENCES device_interfaces(id) ON DELETE CASCADE,
    
    -- Target Endpoint (Resolved interface for managed neighbors OR device/hints for unmanaged)
    target_interface_id UUID REFERENCES device_interfaces(id) ON DELETE CASCADE,
    target_device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    
    -- Fallback Hints for Unmanaged Neighbors / Default Gateways
    target_hostname_hint VARCHAR(255),
    target_port_hint VARCHAR(255),
    
    -- Link Metadata
    protocol link_protocol_enum NOT NULL DEFAULT 'lldp',
    discovered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_topology_link UNIQUE (source_interface_id, target_interface_id, target_port_hint)
);

-- Indexes for topology graph queries
CREATE INDEX IF NOT EXISTS idx_links_source_interface ON topology_links(source_interface_id);
CREATE INDEX IF NOT EXISTS idx_links_target_interface ON topology_links(target_interface_id);
CREATE INDEX IF NOT EXISTS idx_links_target_device ON topology_links(target_device_id);
CREATE INDEX IF NOT EXISTS idx_links_protocol ON topology_links(protocol);
