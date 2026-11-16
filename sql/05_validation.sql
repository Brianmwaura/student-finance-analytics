
-- ==========================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 05_validation.sql
-- PURPOSE: Data quality, integrity and business-rule checks
-- DATA: SYNTHETIC PORTFOLIO DATA
-- ==========================================================

WITH test_results AS (

    -- V01: Duplicate student emails
    SELECT
        'V01' AS test_id,
        'Duplicate student emails' AS test_name,
        'ERROR' AS severity,
        COUNT(*) AS records_found
    FROM (
        SELECT email
        FROM students
        GROUP BY email
        HAVING COUNT(*) > 1
    ) x

    UNION ALL

    -- V02: Missing mandatory student fields
    SELECT 'V02', 'Missing mandatory student fields', 'ERROR', COUNT(*)
    FROM students
    WHERE first_name IS NULL OR TRIM(first_name) = ''
       OR last_name IS NULL OR TRIM(last_name) = ''
       OR email IS NULL OR TRIM(email) = ''
       OR phone_no IS NULL OR TRIM(phone_no) = ''
       OR emergency_contact_name IS NULL
       OR emergency_contact_phone IS NULL
       OR gender IS NULL
       OR dob IS NULL

    UNION ALL

    -- V03: Invalid gender values
    SELECT 'V03', 'Invalid gender values', 'ERROR', COUNT(*)
    FROM students
    WHERE gender NOT IN ('Female', 'Male', 'Other', 'Prefer not to say')

    UNION ALL

    -- V04: Invalid education years
    SELECT 'V04', 'Invalid education year ranges', 'ERROR', COUNT(*)
    FROM students
    WHERE (education_start_year IS NOT NULL
           AND education_start_year NOT BETWEEN 1950 AND 2100)
       OR (education_end_year IS NOT NULL
           AND education_end_year NOT BETWEEN 1950 AND 2100)
       OR (education_start_year IS NOT NULL
           AND education_end_year IS NOT NULL
           AND education_end_year < education_start_year)

    UNION ALL

    -- V05: Student documents without a valid student
    SELECT 'V05', 'Orphan student documents', 'ERROR', COUNT(*)
    FROM student_documents d
    LEFT JOIN students s ON d.student_id = s.student_id
    WHERE s.student_id IS NULL

    UNION ALL

    -- V06: Duplicate document numbers for the same document type
    SELECT 'V06', 'Duplicate document numbers', 'ERROR', COUNT(*)
    FROM (
        SELECT document_type, document_number
        FROM student_documents
        GROUP BY document_type, document_number
        HAVING COUNT(*) > 1
    ) x

    UNION ALL

    -- V07: Invalid course fees or durations
    -- Course duration must be between 1 and 19 weeks.
    -- This matches the courses table CHECK constraint.
    SELECT 'V07', 'Invalid course fees or durations', 'ERROR', COUNT(*)
    FROM courses
    WHERE course_duration_weeks NOT BETWEEN 1 AND 19
       OR course_fee < 0
    UNION ALL

    -- V08: Intakes without a valid course
    SELECT 'V08', 'Intakes without valid courses', 'ERROR', COUNT(*)
    FROM course_intakes ci
    LEFT JOIN courses c ON ci.course_id = c.course_id
    WHERE c.course_id IS NULL

    UNION ALL

    -- V09: Invalid intake dates
    SELECT 'V09', 'Invalid intake date sequence', 'ERROR', COUNT(*)
    FROM course_intakes
    WHERE enrolment_end_date < enrolment_start_date
       OR course_start_date < enrolment_start_date

    UNION ALL

    -- V10: Invalid intake capacity
    SELECT 'V10', 'Invalid intake capacity', 'ERROR', COUNT(*)
    FROM course_intakes
    WHERE enrolment_capacity <= 0

    UNION ALL

    -- V11: Duplicate student registrations in the same intake
    SELECT 'V11', 'Duplicate student intake registrations', 'ERROR', COUNT(*)
    FROM (
        SELECT student_id, intake_id
        FROM enrolments
        GROUP BY student_id, intake_id
        HAVING COUNT(*) > 1
    ) x

    UNION ALL

    -- V12: Enrolments without valid students or intakes
    SELECT 'V12', 'Enrolments with missing references', 'ERROR', COUNT(*)
    FROM enrolments e
    LEFT JOIN students s ON e.student_id = s.student_id
    LEFT JOIN course_intakes ci ON e.intake_id = ci.intake_id
    WHERE s.student_id IS NULL
       OR ci.intake_id IS NULL

    UNION ALL

    -- V13: Invalid enrolment fees
    SELECT 'V13', 'Invalid agreed course fees', 'ERROR', COUNT(*)
    FROM enrolments
    WHERE agreed_course_fee < 0

    UNION ALL

    -- V14: Payments without valid enrolments
    SELECT 'V14', 'Payments with missing enrolments', 'ERROR', COUNT(*)
    FROM payments p
    LEFT JOIN enrolments e ON p.enrolment_id = e.enrolment_id
    WHERE e.enrolment_id IS NULL

    UNION ALL

    -- V15: Invalid payment amounts
    SELECT 'V15', 'Non-positive payment amounts', 'ERROR', COUNT(*)
    FROM payments
    WHERE amount <= 0

    UNION ALL

    -- V16: Refunds without valid enrolments
    SELECT 'V16', 'Refunds with missing enrolments', 'ERROR', COUNT(*)
    FROM refunds r
    LEFT JOIN enrolments e ON r.enrolment_id = e.enrolment_id
    WHERE e.enrolment_id IS NULL

    UNION ALL

    -- V17: Invalid refund amounts
    SELECT 'V17', 'Invalid refund amounts', 'ERROR', COUNT(*)
    FROM refunds
    WHERE requested_amount <= 0
       OR (approved_amount IS NOT NULL AND approved_amount <= 0)
       OR (approved_amount IS NOT NULL
           AND approved_amount > requested_amount)

    UNION ALL

    -- V18: Refunds with inconsistent status/date information
    SELECT 'V18', 'Inconsistent refund status dates', 'ERROR', COUNT(*)
    FROM refunds
    WHERE
        (refund_status = 'Requested'
         AND (approved_amount IS NOT NULL
              OR decision_at IS NOT NULL
              OR paid_at IS NOT NULL))
        OR
        (refund_status = 'Rejected'
         AND (approved_amount IS NOT NULL
              OR decision_at IS NULL
              OR paid_at IS NOT NULL))
        OR
        (refund_status = 'Approved'
         AND (approved_amount IS NULL
              OR decision_at IS NULL
              OR paid_at IS NOT NULL))
        OR
        (refund_status = 'Paid'
         AND (approved_amount IS NULL
              OR decision_at IS NULL
              OR paid_at IS NULL))

    UNION ALL

    -- V19: Refund exposure must not exceed payments received
    SELECT
        'V19',
        'Refund exposure exceeds payments received',
        'ERROR',
        COUNT(*)
    FROM (
        SELECT
            e.enrolment_id,
            COALESCE(p.total_paid, 0) AS total_paid,
            COALESCE(r.refund_exposure, 0) AS refund_exposure
        FROM enrolments e

        LEFT JOIN (
            SELECT enrolment_id, SUM(amount) AS total_paid
            FROM payments
            GROUP BY enrolment_id
        ) p ON e.enrolment_id = p.enrolment_id

        LEFT JOIN (
            SELECT
                enrolment_id,
                SUM(
                    CASE
                        WHEN refund_status = 'Requested'
                            THEN requested_amount
                        WHEN refund_status IN ('Approved', 'Paid')
                            THEN COALESCE(approved_amount, 0)
                        ELSE 0
                    END
                ) AS refund_exposure
            FROM refunds
            GROUP BY enrolment_id
        ) r ON e.enrolment_id = r.enrolment_id
    ) x
    WHERE refund_exposure > total_paid

    UNION ALL

    -- V20: Intake capacity exceeded
    SELECT
        'V20',
        'Intakes exceeding capacity',
        'ERROR',
        COUNT(*)
    FROM (
        SELECT
            ci.intake_id,
            ci.enrolment_capacity,
            COUNT(e.enrolment_id) AS registered_students
        FROM course_intakes ci
        LEFT JOIN enrolments e
            ON ci.intake_id = e.intake_id
           AND e.status IN ('Registered', 'Active', 'Completed')
        GROUP BY ci.intake_id, ci.enrolment_capacity
        HAVING COUNT(e.enrolment_id) > ci.enrolment_capacity
    ) x

    UNION ALL

    -- V21: Students without enrolments (business exception)
    SELECT 'V21', 'Students without enrolments', 'INFO', COUNT(*)
    FROM students s
    LEFT JOIN enrolments e ON s.student_id = e.student_id
    WHERE e.enrolment_id IS NULL

    UNION ALL

    -- V22: Enrolments without payments (business exception)
    SELECT 'V22', 'Enrolments without payments', 'INFO', COUNT(*)
    FROM enrolments e
    LEFT JOIN payments p ON e.enrolment_id = p.enrolment_id
    WHERE p.payment_id IS NULL

    UNION ALL

    -- V23: Enrolments with overpayments (business exception)
    SELECT 'V23', 'Enrolments with overpayment credit', 'INFO', COUNT(*)
    FROM (
        SELECT
            e.enrolment_id,
            e.agreed_course_fee,
            COALESCE(SUM(p.amount), 0) AS total_paid
        FROM enrolments e
        LEFT JOIN payments p ON e.enrolment_id = p.enrolment_id
        GROUP BY e.enrolment_id, e.agreed_course_fee
        HAVING COALESCE(SUM(p.amount), 0) > e.agreed_course_fee
    ) x

    UNION ALL

    -- V24: Withdrawn enrolments with refund records (business exception)
    SELECT 'V24', 'Withdrawn enrolments with refund records', 'INFO', COUNT(*)
    FROM enrolments e
    JOIN refunds r ON e.enrolment_id = r.enrolment_id
    WHERE e.status = 'Withdrawn'
)

SELECT
    test_id,
    test_name,
    severity,
    records_found,
    CASE
        WHEN severity = 'INFO' THEN 'INFO'
        WHEN records_found = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM test_results
ORDER BY test_id;
