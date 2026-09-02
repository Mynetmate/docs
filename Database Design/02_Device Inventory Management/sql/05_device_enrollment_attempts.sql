-- =============================================================================
-- Module: 02_Device Inventory Management (3NF Compliant)
-- File: 05_device_enrollment_attempts.sql
-- Description: Audit Log for Manual Device Enrollment & Connection Attempts
-- Normalization: 3NF (PK: id, strictly functional to single connection attempt event)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS device_enrollment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Target & Credentials Tested
    target_ip INET NOT NULL,
    credential_profile_id UUID REFERENCES credential_profiles(id) ON DELETE SET NULL,
    
    -- Execution State & Error Diagnostics
    status enrollment_attempt_status_enum NOT NULL DEFAULT 'pending',
    error_message TEXT,
    
    -- Telemetry Gathered (Before Promotion to Managed Device)
    collected_hostname VARCHAR(255),
    collected_vendor VARCHAR(50),
    collected_model VARCHAR(100),
    collected_os_version VARCHAR(100),
    
    -- Performance & Auditing
    duration_ms INTEGER,
    initiated_by UUID, -- References users(id)
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for audit reporting
CREATE INDEX IF NOT EXISTS idx_enrollment_attempts_ip ON device_enrollment_attempts(target_ip);
CREATE INDEX IF NOT EXISTS idx_enrollment_attempts_status ON device_enrollment_attempts(status);
CREATE INDEX IF NOT EXISTS idx_enrollment_attempts_time ON device_enrollment_attempts(attempted_at);
