-- =============================================================================
-- Module: 02_Device Inventory Management (3NF Compliant)
-- File: 00_enums.sql
-- Description: PostgreSQL Extensions and Enumeration Types
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Device Type Enum
DO $$ BEGIN
    CREATE TYPE device_type_enum AS ENUM (
        'router',
        'switch',
        'firewall',
        'access_point',
        'server',
        'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Device Role Enum
DO $$ BEGIN
    CREATE TYPE device_role_enum AS ENUM (
        'core',
        'distribution',
        'access',
        'edge_router',
        'management',
        'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Hardware / OS Vendor Enum
DO $$ BEGIN
    CREATE TYPE vendor_enum AS ENUM (
        'cisco',
        'mikrotik',
        'huawei',
        'juniper',
        'arista',
        'linux',
        'unknown'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 4. Device Operational Status Enum
DO $$ BEGIN
    CREATE TYPE device_status_enum AS ENUM (
        'online',
        'offline',
        'unreachable',
        'maintenance'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 5. Enrollment Status Enum
DO $$ BEGIN
    CREATE TYPE enrollment_status_enum AS ENUM (
        'pending',
        'enrolled',
        'failed',
        'rejected'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 6. Discovery Method Enum
DO $$ BEGIN
    CREATE TYPE discovery_method_enum AS ENUM (
        'manual_enrollment',
        'auto_discovery',
        'csv_import'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 7. Credential Profile Type Enum
DO $$ BEGIN
    CREATE TYPE credential_type_enum AS ENUM (
        'ssh_password',
        'ssh_key',
        'snmp_v2c',
        'snmp_v3',
        'api_token'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 8. Interface Operational / Admin Status Enum
DO $$ BEGIN
    CREATE TYPE interface_status_enum AS ENUM (
        'Up',
        'Down',
        'Testing',
        'Unknown'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 9. Interface Mode Enum (L2/L3)
DO $$ BEGIN
    CREATE TYPE interface_mode_enum AS ENUM (
        'access',
        'trunk',
        'routed',
        'loopback',
        'svi',
        'unknown'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 10. Enrollment Attempt Status Enum
DO $$ BEGIN
    CREATE TYPE enrollment_attempt_status_enum AS ENUM (
        'pending',
        'authenticating',
        'collecting',
        'succeeded',
        'failed'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
