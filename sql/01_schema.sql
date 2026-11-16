
-- =====================================================
-- PROJECT: STUDENT FINANCE & ENROLMENT ANALYTICS
-- DATABASE: PostgreSQL
-- DATA: SYNTHETIC PORTFOLIO DATA
-- =====================================================

-- 1. STUDENTS
-- One record per student.

CREATE TABLE students (
    student_id VARCHAR(15) PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,

    email VARCHAR(100) NOT NULL UNIQUE,
    phone_no VARCHAR(20) NOT NULL,
    alt_phone_no VARCHAR(20),

    emergency_contact_name VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(20) NOT NULL,
    emergency_contact_email VARCHAR(100),

    gender VARCHAR(25) NOT NULL
        CHECK (gender IN (
            'Female',
            'Male',
            'Other',
            'Prefer not to say'
        )),

    dob DATE NOT NULL,

    highest_education VARCHAR(100),
    grade VARCHAR(30),
    education_start_year SMALLINT,
    education_end_year SMALLINT,

    area_of_residence VARCHAR(100),
    county VARCHAR(100),
    sub_county VARCHAR(100),

    CHECK (
        education_start_year IS NULL
        OR education_start_year BETWEEN 1950 AND 2100
    ),

    CHECK (
        education_end_year IS NULL
        OR education_end_year BETWEEN 1950 AND 2100
    ),

    CHECK (
        education_start_year IS NULL
        OR education_end_year IS NULL
        OR education_end_year >= education_start_year
    )
);


-- 2. STUDENT DOCUMENTS
-- One student can have multiple documents.

CREATE TABLE student_documents (
    document_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    student_id VARCHAR(15) NOT NULL
        REFERENCES students(student_id),

    document_type VARCHAR(30) NOT NULL
        CHECK (document_type IN (
            'National ID',
            'Birth Certificate',
            'Passport'
        )),

    document_number VARCHAR(50) NOT NULL,

    UNIQUE (document_type, document_number)
);


-- 3. COURSES
-- One record per course.

CREATE TABLE courses (
    course_id VARCHAR(15) PRIMARY KEY,

    course_name VARCHAR(100) NOT NULL UNIQUE,

    course_duration_months INTEGER NOT NULL
        CHECK (course_duration_months > 0),

    course_fee NUMERIC(12,2) NOT NULL
        CHECK (course_fee >= 0),

    currency_code VARCHAR(3) NOT NULL DEFAULT 'KES',

    additional_info TEXT
);


-- 4. COURSE INTAKES
-- One record per course intake/cohort.
-- Capacity is stored here, not in individual enrolments.

CREATE TABLE course_intakes (
    intake_id VARCHAR(15) PRIMARY KEY,

    course_id VARCHAR(15) NOT NULL
        REFERENCES courses(course_id),

    intake_name VARCHAR(50) NOT NULL,

    enrolment_start_date DATE NOT NULL,
    enrolment_end_date DATE NOT NULL,

    course_start_date DATE NOT NULL,

    enrolment_capacity INTEGER NOT NULL
        CHECK (enrolment_capacity > 0),

    UNIQUE (course_id, intake_name),

    CHECK (enrolment_end_date >= enrolment_start_date),

    CHECK (course_start_date >= enrolment_start_date)
);


-- 5. ENROLMENTS
-- One record per student registered in an intake.

CREATE TABLE enrolments (
    enrolment_id VARCHAR(15) PRIMARY KEY,

    student_id VARCHAR(15) NOT NULL
        REFERENCES students(student_id),

    intake_id VARCHAR(15) NOT NULL
        REFERENCES course_intakes(intake_id),

    enrolment_date DATE NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'Registered'
        CHECK (status IN (
            'Registered',
            'Active',
            'Completed',
            'Withdrawn'
        )),

    agreed_course_fee NUMERIC(12,2) NOT NULL
        CHECK (agreed_course_fee >= 0),

    UNIQUE (student_id, intake_id)
);


-- 6. PAYMENTS
-- One enrolment can have multiple payment transactions.

CREATE TABLE payments (
    payment_id VARCHAR(15) PRIMARY KEY,

    enrolment_id VARCHAR(15) NOT NULL
        REFERENCES enrolments(enrolment_id),

    payment_date DATE NOT NULL,

    amount NUMERIC(12,2) NOT NULL
        CHECK (amount > 0),

    payment_reference VARCHAR(50)
);
