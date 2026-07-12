-- ============================================================
-- Migration: 003_reports.sql
-- Description:
-- Adds the ability for users to report discussion posts for
-- moderation. One report per user per post is enforced at the
-- database level via a unique constraint.
-- ============================================================

-- ------------------------------------------------------------
-- Create reports table
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,

    reporter_id UUID REFERENCES profiles(id) ON DELETE CASCADE,

    reason TEXT NOT NULL CHECK (reason IN ('spam', 'harassment', 'inappropriate')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (post_id, reporter_id)
);

-- Enable Row Level Security
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- RLS Policies
-- ------------------------------------------------------------

-- Users can only insert a report as themselves (can't file a
-- report on someone else's behalf).
CREATE POLICY "Users can report posts."
ON reports FOR INSERT
WITH CHECK (auth.uid() = reporter_id);

-- No SELECT policy for now: reports are write-only from the
-- client. A moderator review UI (tracked separately) will need
-- its own read policy scoped to club admins when it's built.