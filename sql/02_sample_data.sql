
-- =====================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- FILE: 02_sample_data.sql
-- PURPOSE: INSERT SYNTHETIC PORTFOLIO DATA
-- WARNING: ALL RECORDS ARE FICTIONAL TEST DATA
-- =====================================================

BEGIN;

-- 1. STUDENTS
INSERT INTO students (
    student_id, first_name, middle_name, last_name,
    email, phone_no, alt_phone_no,
    emergency_contact_name, emergency_contact_phone,
    emergency_contact_email, gender, dob,
    highest_education, grade,
    education_start_year, education_end_year,
    area_of_residence, county, sub_county
)
VALUES
('S001', 'Amina', 'Wanjiku', 'Kamau', 'student001@example.invalid', 'TEST-0700000001', NULL, 'Mary Kamau', 'TEST-0700000101', 'emergency001@example.invalid', 'Female', '2001-04-12', 'Secondary', 'B', 2016, 2019, 'Kahawa West', 'Nairobi', 'Kasarani'),
('S002', 'Brian', 'Otieno', 'Omondi', 'student002@example.invalid', 'TEST-0700000002', NULL, 'Peter Omondi', 'TEST-0700000102', 'emergency002@example.invalid', 'Male', '1999-08-23', 'Secondary', 'C+', 2014, 2017, 'Kisumu Central', 'Kisumu', 'Kisumu Central'),
('S003', 'Faith', 'Njeri', 'Mwangi', 'student003@example.invalid', 'TEST-0700000003', NULL, 'Grace Mwangi', 'TEST-0700000103', 'emergency003@example.invalid', 'Female', '2002-02-18', 'Secondary', 'B-', 2017, 2020, 'Thika', 'Kiambu', 'Thika'),
('S004', 'David', 'Kiptoo', 'Rono', 'student004@example.invalid', 'TEST-0700000004', NULL, 'Jane Rono', 'TEST-0700000104', 'emergency004@example.invalid', 'Male', '1998-11-05', 'Secondary', 'C', 2013, 2016, 'Eldoret', 'Uasin Gishu', 'Turbo'),
('S005', 'Mercy', 'Atieno', 'Achieng', 'student005@example.invalid', 'TEST-0700000005', NULL, 'Rose Achieng', 'TEST-0700000105', 'emergency005@example.invalid', 'Female', '2003-06-30', 'Secondary', 'B', 2018, 2021, 'Mombasa Island', 'Mombasa', 'Mvita'),
('S006', 'Kevin', 'Maina', 'Njoroge', 'student006@example.invalid', 'TEST-0700000006', NULL, 'John Njoroge', 'TEST-0700000106', 'emergency006@example.invalid', 'Male', '2000-01-14', 'Secondary', 'B-', 2015, 2018, 'Ruiru', 'Kiambu', 'Ruiru'),
('S007', 'Lydia', 'Chebet', 'Kiprotich', 'student007@example.invalid', 'TEST-0700000007', NULL, 'Esther Kiprotich', 'TEST-0700000107', 'emergency007@example.invalid', 'Female', '2001-09-09', 'Secondary', 'C+', 2016, 2019, 'Nakuru Town', 'Nakuru', 'Nakuru Town East'),
('S008', 'Samuel', 'Musa', 'Abdi', 'student008@example.invalid', 'TEST-0700000008', NULL, 'Hassan Abdi', 'TEST-0700000108', 'emergency008@example.invalid', 'Male', '1997-03-21', 'Diploma', NULL, 2018, 2020, 'Eastleigh', 'Nairobi', 'Kamukunji'),
('S009', 'Esther', 'Nyambura', 'Wairimu', 'student009@example.invalid', 'TEST-0700000009', NULL, 'Lucy Wairimu', 'TEST-0700000109', 'emergency009@example.invalid', 'Female', '2002-12-02', 'Secondary', 'B', 2017, 2020, 'Kikuyu', 'Kiambu', 'Kikuyu'),
('S010', 'Joseph', 'Mwangi', 'Karanja', 'student010@example.invalid', 'TEST-0700000010', NULL, 'Paul Karanja', 'TEST-0700000110', 'emergency010@example.invalid', 'Male', '1996-07-17', 'Diploma', NULL, 2017, 2019, 'Nyeri Town', 'Nyeri', 'Nyeri Central'),
('S011', 'Naomi', 'Wambui', 'Gathoni', 'student011@example.invalid', 'TEST-0700000011', NULL, 'Alice Gathoni', 'TEST-0700000111', 'emergency011@example.invalid', 'Female', '1999-05-26', 'Secondary', 'B+', 2014, 2017, 'Machakos Town', 'Machakos', 'Machakos Town'),
('S012', 'Peter', 'Kimani', 'Mbugua', 'student012@example.invalid', 'TEST-0700000012', NULL, 'Susan Mbugua', 'TEST-0700000112', 'emergency012@example.invalid', 'Male', '2004-10-11', 'Secondary', 'C+', 2019, 2022, 'Kitengela', 'Kajiado', 'Kajiado North');

-- 2. STUDENT DOCUMENTS
INSERT INTO student_documents (
    student_id, document_type, document_number
)
VALUES
('S001', 'National ID', 'TEST-NID-001'),
('S001', 'Birth Certificate', 'TEST-BC-001'),
('S002', 'National ID', 'TEST-NID-002'),
('S003', 'National ID', 'TEST-NID-003'),
('S004', 'Passport', 'TEST-PASS-004'),
('S005', 'Birth Certificate', 'TEST-BC-005'),
('S006', 'National ID', 'TEST-NID-006'),
('S007', 'National ID', 'TEST-NID-007'),
('S008', 'Passport', 'TEST-PASS-008'),
('S009', 'National ID', 'TEST-NID-009'),
('S010', 'National ID', 'TEST-NID-010'),
('S011', 'Birth Certificate', 'TEST-BC-011'),
('S012', 'National ID', 'TEST-NID-012');

-- 3. COURSES
INSERT INTO courses (
    course_id, course_name, course_duration_months,
    course_fee, currency_code, additional_info
)
VALUES
('C001', 'Caregiving', 6, 45000.00, 'KES', 'Includes practical training and supervised attachment.'),
('C002', 'Childcare', 5, 35000.00, 'KES', 'Includes childcare practice and assessment.'),
('C003', 'Business Administration', 9, 50000.00, 'KES', 'Includes business operations and administration modules.');

-- 4. COURSE INTAKES
INSERT INTO course_intakes (
    intake_id, course_id, intake_name,
    enrolment_start_date, enrolment_end_date,
    course_start_date, enrolment_capacity
)
VALUES
('E001', 'C001', 'May 2026 Caregiving', '2026-03-01', '2026-05-15', '2026-05-18', 8),
('E002', 'C002', 'June 2026 Childcare', '2026-04-01', '2026-06-15', '2026-06-20', 6),
('E003', 'C001', 'September 2026 Caregiving', '2026-07-01', '2026-09-15', '2026-09-21', 8),
('E004', 'C003', 'January 2025 Business Administration', '2024-11-01', '2025-01-15', '2025-01-20', 5);

-- 5. ENROLMENTS
INSERT INTO enrolments (
    enrolment_id, student_id, intake_id,
    enrolment_date, status, agreed_course_fee
)
VALUES
('ENR001', 'S001', 'E001', '2026-04-02', 'Active', 45000.00),
('ENR002', 'S002', 'E001', '2026-04-05', 'Active', 45000.00),
('ENR003', 'S003', 'E001', '2026-04-08', 'Withdrawn', 45000.00),
('ENR004', 'S004', 'E002', '2026-05-02', 'Active', 35000.00),
('ENR005', 'S005', 'E002', '2026-05-07', 'Registered', 35000.00),
('ENR006', 'S006', 'E002', '2026-05-10', 'Active', 35000.00),
('ENR007', 'S001', 'E003', '2026-08-01', 'Registered', 45000.00),
('ENR008', 'S007', 'E003', '2026-08-03', 'Active', 45000.00),
('ENR009', 'S008', 'E003', '2026-08-06', 'Active', 45000.00),
('ENR010', 'S009', 'E003', '2026-08-09', 'Registered', 45000.00),
('ENR011', 'S010', 'E004', '2024-12-01', 'Completed', 50000.00),
('ENR012', 'S011', 'E004', '2024-12-05', 'Completed', 50000.00);

-- 6. PAYMENTS
INSERT INTO payments (
    payment_id, enrolment_id, payment_date,
    amount, payment_reference
)
VALUES
('P001', 'ENR001', '2026-04-10', 15000.00, 'TEST-REF-001'),
('P002', 'ENR001', '2026-05-10', 10000.00, 'TEST-REF-002'),
('P003', 'ENR002', '2026-05-12', 45000.00, 'TEST-REF-003'),
('P004', 'ENR003', '2026-04-12', 5000.00, 'TEST-REF-004'),
('P005', 'ENR004', '2026-05-15', 10000.00, 'TEST-REF-005'),
('P006', 'ENR004', '2026-06-15', 5000.00, 'TEST-REF-006'),
('P007', 'ENR006', '2026-06-20', 35000.00, 'TEST-REF-007'),
('P008', 'ENR007', '2026-08-10', 10000.00, 'TEST-REF-008'),
('P009', 'ENR008', '2026-08-15', 20000.00, 'TEST-REF-009'),
('P010', 'ENR009', '2026-08-20', 15000.00, 'TEST-REF-010'),
('P011', 'ENR011', '2025-01-15', 25000.00, 'TEST-REF-011'),
('P012', 'ENR011', '2025-03-15', 25000.00, 'TEST-REF-012'),
('P013', 'ENR012', '2025-02-15', 30000.00, 'TEST-REF-013'),
('P014', 'ENR012', '2025-04-15', 20000.00, 'TEST-REF-014');

COMMIT;
