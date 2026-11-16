
-- =====================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 07_refund_sample_data.sql
-- PURPOSE: Test refunds and overpayments
-- DATA: SYNTHETIC PORTFOLIO DATA
-- =====================================================

BEGIN;

-- 1. Create an overpayment for ENR002.
INSERT INTO payments (
    payment_id,
    enrolment_id,
    payment_date,
    amount,
    payment_reference
)
VALUES (
    'P015',
    'ENR002',
    '2026-11-10',
    5000.00,
    'TEST-OVERPAY-001'
);

-- 2. Withdrawn student: partial refund approved.
INSERT INTO refunds (
    refund_id,
    enrolment_id,
    requested_amount,
    approved_amount,
    refund_reason,
    refund_status,
    requested_at,
    decision_at,
    decision_notes
)
VALUES (
    'R001',
    'ENR003',
    5000.00,
    3000.00,
    'Withdrawal refund request',
    'Approved',
    '2026-11-10 09:00:00',
    '2026-11-12 10:00:00',
    'Partial refund approved under the assumed portfolio refund policy.'
);

-- 3. Refund request rejected.
INSERT INTO refunds (
    refund_id,
    enrolment_id,
    requested_amount,
    refund_reason,
    refund_status,
    requested_at,
    decision_at,
    decision_notes
)
VALUES (
    'R002',
    'ENR004',
    5000.00,
    'Fee adjustment request',
    'Rejected',
    '2026-11-10 11:00:00',
    '2026-11-11 14:00:00',
    'Refund rejected under the assumed portfolio policy.'
);

-- 4. Overpayment: refund approved and paid.
INSERT INTO refunds (
    refund_id,
    enrolment_id,
    requested_amount,
    approved_amount,
    refund_reason,
    refund_status,
    requested_at,
    decision_at,
    paid_at,
    decision_notes
)
VALUES (
    'R003',
    'ENR002',
    3000.00,
    3000.00,
    'Refund of excess payment',
    'Paid',
    '2026-11-09 09:00:00',
    '2026-11-10 10:00:00',
    '2026-11-12 12:00:00',
    'Refund approved and paid.'
);

-- 5. Remaining overpayment: refund requested, pending decision.
INSERT INTO refunds (
    refund_id,
    enrolment_id,
    requested_amount,
    refund_reason,
    refund_status,
    requested_at,
    decision_notes
)
VALUES (
    'R004',
    'ENR002',
    2000.00,
    'Refund of remaining excess payment',
    'Requested',
    '2026-11-13 09:00:00',
    'Awaiting institutional approval.'
);

COMMIT;
