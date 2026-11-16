
-- ============================================================
-- FILE: 12_dataset_expansion.sql
-- PROJECT: Student Finance & Enrolment Analytics
--
-- PURPOSE:
-- 1. Add the Data Analytics course.
-- 2. Create the January 2027 Data Analytics intake.
-- 3. Increase the student dataset from 12 to 21.
-- 4. Give S012 an Enquiry enrolment.
-- 5. Register nine new students through payment transactions.
--
-- IMPORTANT BUSINESS RULES:
-- - Course fee: KES 55,000.
-- - Course duration: 19 weeks.
-- - KES 2,500 is part of the course fee.
-- - Enquiry does not occupy intake capacity.
-- - Registered, Active and Completed occupy capacity.
-- - A student becomes Active only after valid Present attendance.
--
-- TRANSACTION:
-- This script will be executed using psql --single-transaction.
-- Therefore, BEGIN and COMMIT are intentionally omitted.
-- ============================================================


-- ============================================================
-- SECTION 1: ADD THE NEW COURSE
-- ============================================================

-- INSERT adds a new row to the courses table.
-- Explicit column names make the intended data clear.
-- currency_code is included even though it has a KES default.

INSERT INTO courses (
    course_id,
    course_name,
    course_fee,
    currency_code,
    additional_info,
    course_duration_weeks
)
VALUES (
    'C004',
    'Data Analytics',
    55000.00,
    'KES',
    'Synthetic portfolio course covering data management, SQL, analysis and reporting.',
    19
);


-- ============================================================
-- SECTION 2: CREATE THE JANUARY 2027 INTAKE
-- ============================================================

-- The intake is linked to C004 using course_id.
-- The course starts on 11 January 2027.
-- 19 weeks = 133 days.
-- Attendance validation uses an exclusive end date:
-- 11 January + 133 days = 24 May 2027.
-- Therefore, 24 May itself is outside the course period.

INSERT INTO course_intakes (
    intake_id,
    course_id,
    intake_name,
    enrolment_start_date,
    enrolment_end_date,
    course_start_date,
    enrolment_capacity
)
VALUES (
    'E005',
    'C004',
    'January 2027 Data Analytics',
    DATE '2026-11-16',
    DATE '2027-01-08',
    DATE '2027-01-11',
    10
);


-- ============================================================
-- SECTION 3: ADD NINE SYNTHETIC STUDENTS
-- ============================================================

-- These records are fictional portfolio data.
-- The .invalid email domain is reserved for invalid examples.
-- Phone numbers are synthetic placeholders.
--
-- NOT NULL columns must receive values.
-- Optional columns may be left NULL.

INSERT INTO students (
    student_id,
    first_name,
    middle_name,
    last_name,
    email,
    phone_no,
    alt_phone_no,
    emergency_contact_name,
    emergency_contact_phone,
    emergency_contact_email,
    gender,
    dob,
    highest_education,
    grade,
    education_start_year,
    education_end_year,
    area_of_residence,
    county,
    sub_county
)
VALUES
(
    'S013', 'Grace', NULL, 'Wanjiku',
    'grace.wanjiku013@example.invalid',
    '+254700000013', NULL,
    'Mary Wanjiku', '+254711000013', NULL,
    'Female', DATE '1998-04-12',
    'Diploma', 'Credit', 2016, 2019,
    'Kikuyu', 'Kiambu', 'Kikuyu'
),
(
    'S014', 'Daniel', NULL, 'Mutua',
    'daniel.mutua014@example.invalid',
    '+254700000014', NULL,
    'Peter Mutua', '+254711000014', NULL,
    'Male', DATE '1996-08-21',
    'Certificate', 'Pass', 2017, 2019,
    'Rongai', 'Kajiado', 'Kajiado North'
),
(
    'S015', 'Sheila', NULL, 'Atieno',
    'sheila.atieno015@example.invalid',
    '+254700000015', NULL,
    'Jane Atieno', '+254711000015', NULL,
    'Female', DATE '2000-02-09',
    'Diploma', 'Credit', 2018, 2021,
    'Kasarani', 'Nairobi', 'Kasarani'
),
(
    'S016', 'Martin', NULL, 'Kiptoo',
    'martin.kiptoo016@example.invalid',
    '+254700000016', NULL,
    'John Kiptoo', '+254711000016', NULL,
    'Male', DATE '1997-11-03',
    'Degree', 'Second Class', 2016, 2020,
    'Eldoret', 'Uasin Gishu', 'Ainabkoi'
),
(
    'S017', 'Irene', NULL, 'Naliaka',
    'irene.naliaka017@example.invalid',
    '+254700000017', NULL,
    'Ruth Naliaka', '+254711000017', NULL,
    'Female', DATE '1995-06-17',
    'Diploma', 'Credit', 2014, 2017,
    'Kikuyu', 'Kiambu', 'Kikuyu'
),
(
    'S018', 'Patrick', NULL, 'Oduor',
    'patrick.oduor018@example.invalid',
    '+254700000018', NULL,
    'James Oduor', '+254711000018', NULL,
    'Male', DATE '1999-01-25',
    'Certificate', 'Pass', 2017, 2020,
    'Embakasi', 'Nairobi', 'Embakasi East'
),
(
    'S019', 'Esther', NULL, 'Chebet',
    'esther.chebet019@example.invalid',
    '+254700000019', NULL,
    'Alice Chebet', '+254711000019', NULL,
    'Female', DATE '1994-09-14',
    'Degree', 'Second Class', 2013, 2017,
    'Nakuru', 'Nakuru', 'Nakuru Town East'
),
(
    'S020', 'Michael', NULL, 'Mwangi',
    'michael.mwangi020@example.invalid',
    '+254700000020', NULL,
    'Joseph Mwangi', '+254711000020', NULL,
    'Male', DATE '1998-12-05',
    'Diploma', 'Credit', 2016, 2019,
    'Thika', 'Kiambu', 'Thika'
),
(
    'S021', 'Ann', NULL, 'Akinyi',
    'ann.akinyi021@example.invalid',
    '+254700000021', NULL,
    'Grace Akinyi', '+254711000021', NULL,
    'Female', DATE '1997-03-28',
    'Certificate', 'Pass', 2016, 2018,
    'Kisumu', 'Kisumu', 'Kisumu Central'
);


-- ============================================================
-- SECTION 4: CREATE TEN ENROLMENT RECORDS
-- ============================================================

-- Nine new students receive Enquiry status initially.
-- The payment trigger will promote them to Registered
-- when their cumulative payments reach KES 2,500.
--
-- S012 receives an Enquiry record without a payment.
-- This represents an interested student who has not
-- yet reached the registration threshold.
--
-- All enrolments are linked to intake E005.

INSERT INTO enrolments (
    enrolment_id,
    student_id,
    intake_id,
    enrolment_date,
    status,
    agreed_course_fee
)
VALUES
('ENR013', 'S013', 'E005', DATE '2026-11-20', 'Enquiry', 55000.00),
('ENR014', 'S014', 'E005', DATE '2026-11-20', 'Enquiry', 55000.00),
('ENR015', 'S015', 'E005', DATE '2026-11-21', 'Enquiry', 55000.00),
('ENR016', 'S016', 'E005', DATE '2026-11-21', 'Enquiry', 55000.00),
('ENR017', 'S017', 'E005', DATE '2026-11-22', 'Enquiry', 55000.00),
('ENR018', 'S018', 'E005', DATE '2026-11-22', 'Enquiry', 55000.00),
('ENR019', 'S019', 'E005', DATE '2026-11-23', 'Enquiry', 55000.00),
('ENR020', 'S020', 'E005', DATE '2026-11-23', 'Enquiry', 55000.00),
('ENR021', 'S021', 'E005', DATE '2026-11-24', 'Enquiry', 55000.00),
('ENR022', 'S012', 'E005', DATE '2026-11-24', 'Enquiry', 55000.00);


-- ============================================================
-- SECTION 5: RECORD PAYMENT TRANSACTIONS
-- ============================================================

-- Payment amounts are deliberately varied.
-- ENR013 has two separate payments:
-- KES 1,500 + KES 1,500 = KES 3,000.
--
-- This demonstrates why financial reports must aggregate
-- individual payment transactions per enrolment.
--
-- The payment trigger recalculates registration status
-- after each inserted payment.
--
-- P016-P025 follow the existing payment ID sequence.

INSERT INTO payments (
    payment_id,
    enrolment_id,
    payment_date,
    amount,
    payment_reference
)
VALUES
('P016', 'ENR013', DATE '2026-11-21', 1500.00, 'SYNTH-DA-013-A'),
('P017', 'ENR013', DATE '2026-11-25', 1500.00, 'SYNTH-DA-013-B'),
('P018', 'ENR014', DATE '2026-11-22', 5000.00, 'SYNTH-DA-014-A'),
('P019', 'ENR015', DATE '2026-11-23', 2500.00, 'SYNTH-DA-015-A'),
('P020', 'ENR016', DATE '2026-11-24', 7500.00, 'SYNTH-DA-016-A'),
('P021', 'ENR017', DATE '2026-11-25', 15000.00, 'SYNTH-DA-017-A'),
('P022', 'ENR018', DATE '2026-11-26', 3000.00, 'SYNTH-DA-018-A'),
('P023', 'ENR019', DATE '2026-11-27', 25000.00, 'SYNTH-DA-019-A'),
('P024', 'ENR020', DATE '2026-11-28', 5000.00, 'SYNTH-DA-020-A'),
('P025', 'ENR021', DATE '2026-11-29', 12000.00, 'SYNTH-DA-021-A');


-- ============================================================
-- END OF DATASET EXPANSION
-- ============================================================

-- Validation will be performed separately after execution.
-- The psql --single-transaction option commits all changes
-- only if the entire script succeeds.
