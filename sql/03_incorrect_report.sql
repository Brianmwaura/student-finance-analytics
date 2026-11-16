-- =====================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 03_incorrect_report.sql
-- PURPOSE: Demonstrate JOIN multiplication
-- WARNING: INTENTIONALLY INCORRECT FINANCIAL REPORT
-- =====================================================

SELECT
    e.enrolment_id,
    e.agreed_course_fee,
    COUNT(p.payment_id) AS payment_transactions,

    -- INTENTIONALLY WRONG:
    -- The course fee is repeated for every payment row.
    SUM(e.agreed_course_fee) AS incorrectly_reported_fee,

    COALESCE(SUM(p.amount), 0) AS total_paid

FROM enrolments e

LEFT JOIN payments p
    ON e.enrolment_id = p.enrolment_id

GROUP BY
    e.enrolment_id,
    e.agreed_course_fee

ORDER BY e.enrolment_id;
