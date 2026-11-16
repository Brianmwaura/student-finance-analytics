
-- =====================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 04_corrected_report.sql
-- PURPOSE: Correct financial reporting using pre-aggregation
-- =====================================================

-- STEP 1: Calculate payment totals separately.
WITH payment_summary AS (
    SELECT
        enrolment_id,
        COUNT(payment_id) AS payment_transactions,
        SUM(amount) AS total_paid
    FROM payments
    GROUP BY enrolment_id
)

-- STEP 2: Join the payment summary to enrolments.
SELECT
    e.enrolment_id,
    e.agreed_course_fee,
    COALESCE(ps.payment_transactions, 0) AS payment_transactions,
    COALESCE(ps.total_paid, 0) AS total_paid,

    -- Remaining amount due
    e.agreed_course_fee - COALESCE(ps.total_paid, 0) AS balance_due

FROM enrolments e

LEFT JOIN payment_summary ps
    ON e.enrolment_id = ps.enrolment_id

ORDER BY e.enrolment_id;
