-- =============================================================================
-- Module: 02_Device Inventory Management (3NF Compliant)
-- File: 01_credentials.sql
-- Description: Device Credential Profiles (Encrypted Access Secrets)
-- Normalization: 3NF (PK: id, AK: name. Independent reusable entity)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS credential_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    name VARCHAR(100) NOT NULL,
    credential_type credential_type_enum NOT NULL DEFAULT 'ssh_password',
    
    -- SSH / CLI Credentials (Stored Encrypted via Application AES-256-GCM / KMS)
    username VARCHAR(100),
    password_encrypted TEXT,
    enable_secret_encrypted TEXT,
    
    -- SNMP Credentials (Stored Encrypted)
    snmp_community_ro_encrypted TEXT,
    snmp_community_rw_encrypted TEXT,
    
    -- Protocol Ports
    ssh_port INTEGER NOT NULL DEFAULT 22 CHECK (ssh_port BETWEEN 1 AND 65535),
    snmp_port INTEGER NOT NULL DEFAULT 161 CHECK (snmp_port BETWEEN 1 AND 65535),
    
    -- Metadata & Auditing
    description TEXT,
    created_by UUID, -- References users(id) if Auth module is present
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uq_credential_profiles_name UNIQUE (name)
);

-- Indexes for fast lookup
CREATE INDEX IF NOT EXISTS idx_credential_profiles_name ON credential_profiles(name);
CREATE INDEX IF NOT EXISTS idx_credential_profiles_type ON credential_profiles(credential_type);
