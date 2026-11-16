-- ============================================================
-- PROJECT: Student Finance & Enrolment Analytics
-- FILE: 13_weekly_attendance_report.sql
-- PURPOSE: Weekly attendance summary for all enrolments.
-- METHOD: Course-relative weeks, Monday to Friday attendance.
-- NOTE: Excused days are counted separately.
-- DATA: Synthetic portfolio demonstration records.
-- ============================================================

-- ============================================================
-- WEEKLY ATTENDANCE REPORT
-- Purpose: Summarise attendance by course-relative week.
-- Week 1 starts on the course_start_date.
-- Excused days are reported separately.
-- ============================================================

WITH attendance_by_week AS (
    SELECT
        e.enrolment_id,
        s.first_name,
        s.last_name,
        ci.intake_name,

        -- Calculate the week number relative to course start.
        -- This is not the ISO calendar week number.
        FLOOR(
            (a.attendance_date - ci.course_start_date) / 7.0
        )::INTEGER + 1 AS course_week,

        -- Count each attendance category separately.
        COUNT(*) FILTER (
            WHERE a.attendance_status = 'Present'
        ) AS present_days,

        COUNT(*) FILTER (
            WHERE a.attendance_status = 'Absent'
        ) AS absent_days,

        COUNT(*) FILTER (
            WHERE a.attendance_status = 'Excused'
        ) AS excused_days

    FROM attendance a
    JOIN enrolments e
        ON e.enrolment_id = a.enrolment_id
    JOIN students s
        ON s.student_id = e.student_id
    JOIN course_intakes ci
        ON ci.intake_id = e.intake_id

    GROUP BY
        e.enrolment_id,
        s.first_name,
        s.last_name,
        ci.intake_name,
        ci.course_start_date,
        FLOOR(
            (a.attendance_date - ci.course_start_date) / 7.0
        )::INTEGER + 1
)

SELECT
    enrolment_id,
    first_name,
    last_name,
    intake_name,
    course_week,
    present_days,
    absent_days,
    excused_days,

    -- Total recorded attendance days.
    present_days + absent_days + excused_days AS recorded_days,

    -- Present percentage excluding excused days.
    ROUND(
        100.0 * present_days /
        NULLIF(present_days + absent_days, 0),
        2
    ) AS attendance_rate_percent,

    -- Present percentage including excused days.
    ROUND(
        100.0 * present_days /
        NULLIF(present_days + absent_days + excused_days, 0),
        2
    ) AS present_rate_including_excused_percent

FROM attendance_by_week
-- Sort consistently by enrolment, then course-relative week.
ORDER BY enrolment_id, course_week;
