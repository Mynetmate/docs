-- Authentication schema for fresh PostgreSQL data directories only.
-- Canonical: 02_feature/00_Authentication(Naphat)/02_Database Schema.md
-- ORM mapping: app/features/authentication/models.py
-- Docker runs this before 01_device_inventory.sql and 99_seed_data.sql.
-- Existing volumes are not upgraded by init scripts. Do not reset them.
-- Existing auth tables intentionally cause an error rather than hiding drift.
-- This file creates no users, credentials, sessions, or audit seed records.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL
        CHECK (username = lower(username))
        CHECK (username ~ '^[a-z0-9._-]{3,100}$'),
    email VARCHAR(255) UNIQUE
        CHECK (email = lower(email)),
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'operator', 'viewer')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_token_hash CHAR(64) UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    CHECK (expires_at > created_at)
);

CREATE INDEX idx_auth_sessions_user_id ON auth_sessions(user_id);
CREATE INDEX idx_auth_sessions_expires_at ON auth_sessions(expires_at);
CREATE INDEX idx_auth_sessions_active_user
    ON auth_sessions(user_id, expires_at)
    WHERE is_revoked = FALSE;

COMMIT;
