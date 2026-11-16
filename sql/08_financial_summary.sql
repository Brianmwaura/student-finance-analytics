
-- =====================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 08_financial_summary.sql
-- PURPOSE: Reconcile fees, payments, balances and refunds
-- DATA: SYNTHETIC PORTFOLIO DATA
-- =====================================================

WITH payment_summary AS (
    SELECT
        enrolment_id,
        COUNT(*) AS payment_transactions,
        SUM(amount) AS total_paid
    FROM payments
    GROUP BY enrolment_id
),

refund_summary AS (
    SELECT
        enrolment_id,

        SUM(requested_amount)
            FILTER (WHERE refund_status = 'Requested')
            AS refunds_requested,

        SUM(approved_amount)
            FILTER (WHERE refund_status = 'Approved')
            AS approved_refunds_unpaid,

        SUM(approved_amount)
            FILTER (WHERE refund_status = 'Paid')
            AS refunds_paid,

        SUM(requested_amount)
            FILTER (WHERE refund_status = 'Rejected')
            AS rejected_refunds

    FROM refunds
    GROUP BY enrolment_id
),

enrolment_financials AS (
    SELECT
        e.enrolment_id,
        s.first_name,
        s.last_name,
        ci.intake_name,
        c.course_name,
        e.status,
        e.agreed_course_fee,

        COALESCE(p.payment_transactions, 0)
            AS payment_transactions,

        COALESCE(p.total_paid, 0)
            AS total_paid,

        e.agreed_course_fee - COALESCE(p.total_paid, 0)
            AS calculated_balance,

        GREATEST(
            e.agreed_course_fee - COALESCE(p.total_paid, 0),
            0
        ) AS balance_before_status_rule,

        CASE
            WHEN e.status = 'Withdrawn' THEN 0
            ELSE GREATEST(
                e.agreed_course_fee - COALESCE(p.total_paid, 0),
                0
            )
        END AS collectible_balance,

        GREATEST(
            COALESCE(p.total_paid, 0) - e.agreed_course_fee,
            0
        ) AS overpayment_credit,

        COALESCE(r.refunds_requested, 0)
            AS refunds_requested,

        COALESCE(r.approved_refunds_unpaid, 0)
            AS approved_refunds_unpaid,

        COALESCE(r.refunds_paid, 0)
            AS refunds_paid,

        COALESCE(r.rejected_refunds, 0)
            AS rejected_refunds

    FROM enrolments e
    JOIN students s
        ON e.student_id = s.student_id
    JOIN course_intakes ci
        ON e.intake_id = ci.intake_id
    JOIN courses c
        ON ci.course_id = c.course_id

    LEFT JOIN payment_summary p
        ON e.enrolment_id = p.enrolment_id

    LEFT JOIN refund_summary r
        ON e.enrolment_id = r.enrolment_id
)

SELECT
    enrolment_id,
    first_name,
    last_name,
    intake_name,
    course_name,
    status,
    agreed_course_fee,
    payment_transactions,
    total_paid,
    calculated_balance,
    collectible_balance,
    overpayment_credit,
    refunds_requested,
    approved_refunds_unpaid,
    refunds_paid,
    rejected_refunds,

    GREATEST(
        overpayment_credit - refunds_paid,
        0
    ) AS credit_after_paid_refunds,

    GREATEST(
        overpayment_credit - refunds_paid - refunds_requested,
        0
    ) AS credit_after_paid_and_pending_requests

FROM enrolment_financials
ORDER BY enrolment_id;
