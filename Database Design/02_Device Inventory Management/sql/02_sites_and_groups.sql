-- =============================================================================
-- Module: 02_Device Inventory Management (3NF Compliant)
-- File: 02_sites_and_groups.sql
-- Description: Physical Sites, Organizational Groups, and Group Memberships
-- Normalization: 3NF (Many-to-Many relationship cleanly isolated via bridge table)
-- Target: PostgreSQL 14+
-- =============================================================================

-- 1. Sites Table (Physical Locations)
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


-- 2. Device Groups Table (Logical / Role-based Groups)
CREATE TABLE IF NOT EXISTS device_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    color_tag VARCHAR(20) DEFAULT '#3B82F6', -- Hex color code for UI tags
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_device_groups_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_device_groups_name ON device_groups(name);
