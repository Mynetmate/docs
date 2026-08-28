-- =============================================================================
-- Module: 04_Network Discovery (3NF Compliant)
-- File: 04_discovery_scans.sql
-- Description: Audit Log & Performance Metrics for Discovery Scan Runs
-- Normalization: 3NF (Direct dependence on Scan Execution ID)
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS discovery_scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seed_ip INET NOT NULL,
    status scan_status_enum NOT NULL DEFAULT 'completed',
    devices_count INTEGER NOT NULL DEFAULT 0,
    links_count INTEGER NOT NULL DEFAULT 0,
    duration_ms INTEGER,
    error_message TEXT,
    scanned_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for audit trail and scan reporting
CREATE INDEX IF NOT EXISTS idx_discovery_scans_seed_ip ON discovery_scans(seed_ip);
CREATE INDEX IF NOT EXISTS idx_discovery_scans_status ON discovery_scans(status);
CREATE INDEX IF NOT EXISTS idx_discovery_scans_scanned_at ON discovery_scans(scanned_at DESC);
