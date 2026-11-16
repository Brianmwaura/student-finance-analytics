
-- ============================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 09_policy_schema_migration.sql
-- PURPOSE: Apply revised course, enrolment, attendance and
--          refund business rules.
-- DATA: SYNTHETIC PORTFOLIO DATA
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. COURSE DURATION: CHANGE FROM MONTHS TO WEEKS
-- ------------------------------------------------------------

ALTER TABLE courses
ADD COLUMN course_duration_weeks INTEGER;

UPDATE courses
SET course_duration_weeks = CASE course_id
    WHEN 'C001' THEN 8
    WHEN 'C002' THEN 7
    WHEN 'C003' THEN 17
END;

ALTER TABLE courses
ALTER COLUMN course_duration_weeks SET NOT NULL;

ALTER TABLE courses
ADD CONSTRAINT courses_duration_weeks_check
CHECK (course_duration_weeks BETWEEN 1 AND 19);

ALTER TABLE courses
DROP CONSTRAINT courses_course_duration_months_check;

ALTER TABLE courses
DROP COLUMN course_duration_months;


-- ------------------------------------------------------------
-- 2. ENROLMENT STATUS: INTRODUCE ENQUIRY
-- ------------------------------------------------------------

ALTER TABLE enrolments
DROP CONSTRAINT enrolments_status_check;

UPDATE enrolments
SET status = 'Enquiry'
WHERE enrolment_id IN ('ENR005', 'ENR010')
  AND status = 'Registered';

ALTER TABLE enrolments
ADD CONSTRAINT enrolments_status_check
CHECK (
    status IN (
        'Enquiry',
        'Registered',
        'Active',
        'Completed',
        'Withdrawn'
    )
);


-- ------------------------------------------------------------
-- 3. ATTENDANCE: CREATE DAILY ATTENDANCE TABLE
-- ------------------------------------------------------------

CREATE TABLE attendance (
    attendance_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    enrolment_id VARCHAR(15) NOT NULL
        REFERENCES enrolments(enrolment_id),

    attendance_date DATE NOT NULL,

    attendance_status VARCHAR(10) NOT NULL
        CHECK (
            attendance_status IN (
                'Present',
                'Absent',
                'Excused'
            )
        ),

    remarks TEXT,

    UNIQUE (enrolment_id, attendance_date)
);

CREATE INDEX attendance_enrolment_date_idx
ON attendance (enrolment_id, attendance_date);


-- ------------------------------------------------------------
-- 4. REFUNDS: RECORD THE BASIS AND APPROVER
-- ------------------------------------------------------------

ALTER TABLE refunds
ADD COLUMN refund_basis VARCHAR(30) NOT NULL DEFAULT 'Other';

ALTER TABLE refunds
ADD COLUMN approved_by VARCHAR(100);

UPDATE refunds
SET refund_basis = CASE refund_id
    WHEN 'R001' THEN 'Attended Classes'
    WHEN 'R002' THEN 'Other'
    WHEN 'R003' THEN 'Overpayment'
    WHEN 'R004' THEN 'Overpayment'
    ELSE 'Other'
END;

UPDATE refunds
SET approved_by = 'Portfolio Management'
WHERE refund_id IN ('R001', 'R003');

ALTER TABLE refunds
ADD CONSTRAINT refunds_basis_check
CHECK (
    refund_basis IN (
        'Never Attended',
        'Attended Classes',
        'Overpayment',
        'Other'
    )
);

ALTER TABLE refunds
ADD CONSTRAINT refunds_approved_by_check
CHECK (
    refund_status IN ('Requested', 'Rejected')
    OR approved_by IS NOT NULL
);

COMMIT;
