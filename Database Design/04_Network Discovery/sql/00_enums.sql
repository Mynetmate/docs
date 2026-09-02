-- =============================================================================
-- Module: 04_Network Discovery (3NF Compliant)
-- File: 00_enums.sql
-- Description: Extensions and Custom Enumeration Types
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Device Status Enum (Atomic status values)
DO $$ BEGIN
    CREATE TYPE device_status_enum AS ENUM ('online', 'offline', 'unreachable', 'maintenance');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Interface Operational / Admin Status Enum
DO $$ BEGIN
    CREATE TYPE interface_status_enum AS ENUM ('Up', 'Down', 'Testing', 'Unknown');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Link Discovery Protocols Enum
DO $$ BEGIN
    CREATE TYPE link_protocol_enum AS ENUM ('lldp', 'cdp', 'default_route', 'manual');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 4. Discovery Scan Status Enum
DO $$ BEGIN
    CREATE TYPE scan_status_enum AS ENUM ('pending', 'running', 'completed', 'failed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 5. Discovery Method Enum
DO $$ BEGIN
    CREATE TYPE discovery_method_enum AS ENUM ('manual_enrollment', 'auto_discovery', 'csv_import');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
