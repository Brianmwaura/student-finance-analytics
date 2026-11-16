
-- =====================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 06_refunds.sql
-- PURPOSE: Create refund management table
-- DATA: SYNTHETIC PORTFOLIO DATA
-- =====================================================

CREATE TABLE refunds (
    refund_id VARCHAR(15) PRIMARY KEY,

    enrolment_id VARCHAR(15) NOT NULL
        REFERENCES enrolments(enrolment_id),

    requested_amount NUMERIC(12,2) NOT NULL
        CHECK (requested_amount > 0),

    approved_amount NUMERIC(12,2),

    refund_reason TEXT NOT NULL,

    refund_status VARCHAR(20) NOT NULL DEFAULT 'Requested'
        CHECK (
            refund_status IN (
                'Requested',
                'Approved',
                'Rejected',
                'Paid'
            )
        ),

    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    decision_at TIMESTAMP,

    paid_at TIMESTAMP,

    decision_notes TEXT,

    -- An approved amount cannot exceed the requested amount.
    CHECK (
        approved_amount IS NULL
        OR (
            approved_amount > 0
            AND approved_amount <= requested_amount
        )
    ),

    -- Enforce valid combinations of refund status and dates.
    CHECK (
        (
            refund_status = 'Requested'
            AND approved_amount IS NULL
            AND decision_at IS NULL
            AND paid_at IS NULL
        )
        OR
        (
            refund_status = 'Rejected'
            AND approved_amount IS NULL
            AND decision_at IS NOT NULL
            AND paid_at IS NULL
        )
        OR
        (
            refund_status = 'Approved'
            AND approved_amount IS NOT NULL
            AND decision_at IS NOT NULL
            AND paid_at IS NULL
        )
        OR
        (
            refund_status = 'Paid'
            AND approved_amount IS NOT NULL
            AND decision_at IS NOT NULL
            AND paid_at IS NOT NULL
        )
    )
);
