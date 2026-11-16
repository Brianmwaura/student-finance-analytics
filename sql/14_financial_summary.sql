
-- ============================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 14_financial_summary.sql
-- PURPOSE: Produce a policy-aware financial reconciliation
-- DATA: SYNTHETIC PORTFOLIO DATA
--
-- BUSINESS RULES:
-- 1. Registration threshold: KES 2,500.
-- 2. Enquiry and Withdrawn have zero collectible balance.
-- 3. Registered, Active and Completed can have collectible
--    outstanding balances.
-- 4. Never-attended withdrawal retention: KES 2,500.
-- 5. Attended-class refunds follow management approval.
-- 6. Overpayment refunds are reconciled separately.
-- ============================================================


-- ------------------------------------------------------------
-- 1. AGGREGATE PAYMENTS PER ENROLMENT
-- ------------------------------------------------------------
-- One enrolment may have several payment transactions.
-- Aggregate first to prevent JOIN multiplication.

WITH payment_summary AS (
    SELECT
        enrolment_id,
        COUNT(*) AS payment_transactions,
        SUM(amount) AS total_paid
    FROM payments
    GROUP BY enrolment_id
),


-- ------------------------------------------------------------
-- 2. AGGREGATE ATTENDANCE PER ENROLMENT
-- ------------------------------------------------------------
-- Keep attendance separate from payments.
-- This also identifies students who have attended classes.

attendance_summary AS (
    SELECT
        enrolment_id,

        COUNT(*) FILTER (
            WHERE attendance_status = 'Present'
        ) AS present_days,

        COUNT(*) FILTER (
            WHERE attendance_status = 'Absent'
        ) AS absent_days,

        COUNT(*) FILTER (
            WHERE attendance_status = 'Excused'
        ) AS excused_days

    FROM attendance
    GROUP BY enrolment_id
),


-- ------------------------------------------------------------
-- 3. AGGREGATE REFUNDS PER ENROLMENT
-- ------------------------------------------------------------
-- Separate refunds by status and basis.
-- Requested, Approved and Paid are different stages.
-- Rejected refunds are not treated as payable amounts.

refund_summary AS (
    SELECT
        enrolment_id,

        -- All refund categories combined.
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
            AS rejected_refunds,

        -- Overpayment refunds at each workflow stage.
        SUM(requested_amount)
            FILTER (
                WHERE refund_basis = 'Overpayment'
                  AND refund_status = 'Requested'
            ) AS requested_overpayment_refunds,

        SUM(approved_amount)
            FILTER (
                WHERE refund_basis = 'Overpayment'
                  AND refund_status = 'Approved'
            ) AS approved_unpaid_overpayment_refunds,

        SUM(approved_amount)
            FILTER (
                WHERE refund_basis = 'Overpayment'
                  AND refund_status = 'Paid'
            ) AS paid_overpayment_refunds,

        -- Attended-class refunds at each workflow stage.
        SUM(requested_amount)
            FILTER (
                WHERE refund_basis = 'Attended Classes'
                  AND refund_status = 'Requested'
            ) AS requested_attended_refunds,

        SUM(approved_amount)
            FILTER (
                WHERE refund_basis = 'Attended Classes'
                  AND refund_status = 'Approved'
            ) AS approved_unpaid_attended_refunds,

        SUM(approved_amount)
            FILTER (
                WHERE refund_basis = 'Attended Classes'
                  AND refund_status = 'Paid'
            ) AS paid_attended_refunds

    FROM refunds
    GROUP BY enrolment_id
),


-- ------------------------------------------------------------
-- 4. COMBINE THE INDEPENDENT SUMMARIES
-- ------------------------------------------------------------
-- Each CTE contains at most one row per enrolment.
-- LEFT JOIN keeps enrolments with no payments, attendance
-- or refunds in the report.

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

        COALESCE(a.present_days, 0)
            AS present_days,

        COALESCE(a.absent_days, 0)
            AS absent_days,

        COALESCE(a.excused_days, 0)
            AS excused_days,

        COALESCE(r.refunds_requested, 0)
            AS refunds_requested,

        COALESCE(r.approved_refunds_unpaid, 0)
            AS approved_refunds_unpaid,

        COALESCE(r.refunds_paid, 0)
            AS refunds_paid,

        COALESCE(r.rejected_refunds, 0)
            AS rejected_refunds,

        COALESCE(r.requested_overpayment_refunds, 0)
            AS requested_overpayment_refunds,

        COALESCE(r.approved_unpaid_overpayment_refunds, 0)
            AS approved_unpaid_overpayment_refunds,

        COALESCE(r.paid_overpayment_refunds, 0)
            AS paid_overpayment_refunds,

        COALESCE(r.requested_attended_refunds, 0)
            AS requested_attended_refunds,

        COALESCE(r.approved_unpaid_attended_refunds, 0)
            AS approved_unpaid_attended_refunds,

        COALESCE(r.paid_attended_refunds, 0)
            AS paid_attended_refunds

    FROM enrolments e

    JOIN students s
        ON e.student_id = s.student_id

    JOIN course_intakes ci
        ON e.intake_id = ci.intake_id

    JOIN courses c
        ON ci.course_id = c.course_id

    LEFT JOIN payment_summary p
        ON e.enrolment_id = p.enrolment_id

    LEFT JOIN attendance_summary a
        ON e.enrolment_id = a.enrolment_id

    LEFT JOIN refund_summary r
        ON e.enrolment_id = r.enrolment_id
),


-- ------------------------------------------------------------
-- 5. CALCULATE FINANCIAL MEASURES
-- ------------------------------------------------------------

calculated_financials AS (
    SELECT
        *,

        -- Has the enrolment reached the payment threshold?
        total_paid >= 2500 AS payment_threshold_met,

        GREATEST(2500 - total_paid, 0)
            AS payment_threshold_shortfall,

        -- Fee less payments.
        -- A negative result indicates an overpayment.
        agreed_course_fee - total_paid
            AS calculated_balance,

        -- Outstanding balance before applying status policy.
        GREATEST(agreed_course_fee - total_paid, 0)
            AS balance_before_status_rule,

        -- Only Registered, Active and Completed enrolments
        -- have collectible balances under this project's policy.
        CASE
            WHEN status IN ('Registered', 'Active', 'Completed')
            THEN GREATEST(agreed_course_fee - total_paid, 0)
            ELSE 0
        END AS collectible_balance,

        -- Payments above the agreed course fee.
        GREATEST(total_paid - agreed_course_fee, 0)
            AS overpayment_credit,

        -- Never-attended withdrawal calculation.
        -- This is maximum eligibility, not an approved refund.
        CASE
            WHEN status = 'Withdrawn'
             AND present_days = 0
            THEN GREATEST(total_paid - 2500, 0)
            ELSE 0
        END AS never_attended_refund_eligibility,

        -- Retention is limited to the amount actually paid.
        CASE
            WHEN status = 'Withdrawn'
             AND present_days = 0
            THEN LEAST(total_paid, 2500)
            ELSE 0
        END AS never_attended_retention_amount,

        -- Account for requested, approved-unpaid and already-paid
        -- overpayment refunds against the original overpayment credit.
        requested_overpayment_refunds
        + approved_unpaid_overpayment_refunds
        + paid_overpayment_refunds
            AS overpayment_refunds_accounted_for

    FROM enrolment_financials
)


-- ------------------------------------------------------------
-- 6. FINAL MANAGEMENT FINANCIAL REPORT
-- ------------------------------------------------------------

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

    payment_threshold_met,
    payment_threshold_shortfall,

    calculated_balance,
    balance_before_status_rule,
    collectible_balance,

    present_days,
    absent_days,
    excused_days,

    never_attended_retention_amount,
    never_attended_refund_eligibility,

    overpayment_credit,
    requested_overpayment_refunds,
    approved_unpaid_overpayment_refunds,
    paid_overpayment_refunds,
    overpayment_refunds_accounted_for,

    GREATEST(
        overpayment_credit - overpayment_refunds_accounted_for,
        0
    ) AS overpayment_credit_remaining,

    overpayment_refunds_accounted_for > overpayment_credit
        AS overpayment_refunds_exceeds_credit,

    requested_attended_refunds,
    approved_unpaid_attended_refunds,
    paid_attended_refunds,

    refunds_requested,
    approved_refunds_unpaid,
    refunds_paid,
    rejected_refunds

FROM calculated_financials
ORDER BY enrolment_id;
