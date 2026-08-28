-- =============================================================================
-- Module: 04_Network Discovery
-- File: 00_enums.sql
-- Description: Extensions and Custom Enumeration Types
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Device Status
DO $$ BEGIN
    CREATE TYPE device_status_enum AS ENUM ('online', 'offline', 'unreachable');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Interface Operational / Admin Status
DO $$ BEGIN
    CREATE TYPE interface_status_enum AS ENUM ('Up', 'Down', 'Testing', 'Unknown');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Link Discovery Protocols
DO $$ BEGIN
    CREATE TYPE link_protocol_enum AS ENUM ('lldp', 'cdp', 'default_route', 'manual');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
