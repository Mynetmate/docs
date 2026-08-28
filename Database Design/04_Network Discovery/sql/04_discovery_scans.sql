-- =============================================================================
-- Module: 04_Network Discovery
-- File: 04_discovery_scans.sql
-- Description: Discovery Scan History & Performance Metrics
-- Target: PostgreSQL 14+
-- =============================================================================

CREATE TABLE IF NOT EXISTS discovery_scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seed_ip INET NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',  -- 'running', 'completed', 'failed'
    devices_count INTEGER NOT NULL DEFAULT 0,
    links_count INTEGER NOT NULL DEFAULT 0,
    duration_ms INTEGER,
    error_message TEXT,
    scanned_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for scan history sorting
CREATE INDEX IF NOT EXISTS idx_discovery_scans_scanned_at ON discovery_scans(scanned_at DESC);
