
-- ============================================================
-- FILE: 11_attendance_date_validation.sql
-- PURPOSE:
-- Extend attendance eligibility validation.
--
-- RULES:
-- 1. Enquiry enrolments cannot receive attendance.
-- 2. Attendance must be Monday to Friday.
-- 3. Attendance cannot precede the course start date.
-- 4. Attendance must fall within the course duration.
--
-- IMPORTANT:
-- We are replacing the existing function definition.
-- The existing BEFORE INSERT OR UPDATE trigger will continue
-- calling this function. We do not create another trigger.
-- ============================================================

CREATE OR REPLACE FUNCTION trg_check_attendance_eligibility()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $function$

DECLARE
    -- Variables used to retrieve the enrolment's course details.
    v_status VARCHAR(20);
    v_course_start_date DATE;
    v_course_duration_weeks INTEGER;

BEGIN

    -- STEP 1:
    -- Find the enrolment status, course start date and duration.
    -- JOIN connects the enrolment to its intake and course.
    SELECT
        e.status,
        ci.course_start_date,
        c.course_duration_weeks
    INTO
        v_status,
        v_course_start_date,
        v_course_duration_weeks
    FROM enrolments e
    JOIN course_intakes ci
        ON ci.intake_id = e.intake_id
    JOIN courses c
        ON c.course_id = ci.course_id
    WHERE e.enrolment_id = NEW.enrolment_id;

    -- STEP 2:
    -- Prevent attendance for students who are still enquiries.
    IF v_status = 'Enquiry' THEN
        RAISE EXCEPTION
            'Attendance cannot be recorded for enrolment % while its status is Enquiry',
            NEW.enrolment_id;
    END IF;

    -- STEP 3:
    -- Reject attendance before the course officially starts.
    IF NEW.attendance_date < v_course_start_date THEN
        RAISE EXCEPTION
            'Attendance date % is before course start date % for enrolment %',
            NEW.attendance_date,
            v_course_start_date,
            NEW.enrolment_id;
    END IF;

    -- STEP 4:
    -- Reject dates on or after the end of the course duration.
    -- Example: 8 weeks = 8 * 7 = 56 days from the start date.
    IF NEW.attendance_date >=
       v_course_start_date + (v_course_duration_weeks * 7) THEN

        RAISE EXCEPTION
            'Attendance date % is outside the % week course period for enrolment %',
            NEW.attendance_date,
            v_course_duration_weeks,
            NEW.enrolment_id;
    END IF;

    -- STEP 5:
    -- ISO weekday numbers: Monday = 1, Sunday = 7.
    -- Only Monday (1) through Friday (5) are accepted.
    IF EXTRACT(ISODOW FROM NEW.attendance_date) NOT BETWEEN 1 AND 5 THEN
        RAISE EXCEPTION
            'Attendance date % is not a valid weekday for enrolment %',
            NEW.attendance_date,
            NEW.enrolment_id;
    END IF;

    -- All validation rules passed.
    -- Return NEW allows PostgreSQL to continue the INSERT or UPDATE.
    RETURN NEW;

END;
$function$;
