# Data Dictionary

## Project: Student Finance & Enrolment Analytics

Database: `student_finance_analytics`

This document describes the six relational database tables, their columns, data types and business rules.

---

## 1. students

**Purpose:** Stores one record per student.

| Column | Data type | Rule / purpose |
|---|---|---|
| student_id | VARCHAR(15) | Primary key |
| first_name | VARCHAR(50) | Required |
| middle_name | VARCHAR(50) | Optional |
| last_name | VARCHAR(50) | Required |
| email | VARCHAR(100) | Required, unique |
| phone_no | VARCHAR(20) | Required |
| alt_phone_no | VARCHAR(20) | Optional |
| emergency_contact_name | VARCHAR(100) | Required |
| emergency_contact_phone | VARCHAR(20) | Required |
| emergency_contact_email | VARCHAR(100) | Optional |
| gender | VARCHAR(25) | Restricted to defined values |
| dob | DATE | Required |
| highest_education | VARCHAR(100) | Optional |
| grade | VARCHAR(30) | Optional |
| education_start_year | SMALLINT | Optional; year education started |
| education_end_year | SMALLINT | Optional; year education ended |
| area_of_residence | VARCHAR(100) | Optional |
| county | VARCHAR(100) | Optional |
| sub_county | VARCHAR(100) | Optional |

**Important rules:**
- Student ID uniquely identifies a student.
- Email addresses must be unique.
- Education end year cannot be earlier than education start year when both are provided.
- Education years must fall between 1950 and 2100.

## 2. student_documents

**Purpose:** Stores identity documents belonging to students. A student may have multiple documents.

| Column | Data type | Rule / purpose |
|---|---|---|
| document_id | INTEGER | Generated identity primary key |
| student_id | VARCHAR(15) | Foreign key to students |
| document_type | VARCHAR(30) | National ID, Birth Certificate or Passport |
| document_number | VARCHAR(50) | Required |

**Important rules:**
- Every document must belong to an existing student.
- A combination of document type and document number must be unique.

## 3. courses

**Purpose:** Stores the institution's course catalogue.

| Column | Data type | Rule / purpose |
|---|---|---|
| course_id | VARCHAR(15) | Primary key |
| course_name | VARCHAR(100) | Required, unique |
| course_duration_months | INTEGER | Must be greater than zero |
| course_fee | NUMERIC(12,2) | Standard course fee; cannot be negative |
| currency_code | VARCHAR(3) | Defaults to KES |
| additional_info | TEXT | Optional course details |

**Important rules:**
- Course duration is stored in months.
- Course fee represents the standard fee, not necessarily the fee agreed with every student.

## 4. course_intakes

**Purpose:** Stores individual course intakes, their dates and registration capacity.

| Column | Data type | Rule / purpose |
|---|---|---|
| intake_id | VARCHAR(15) | Primary key |
| course_id | VARCHAR(15) | Foreign key to courses |
| intake_name | VARCHAR(50) | Intake/cohort name |
| enrolment_start_date | DATE | Registration opening date |
| enrolment_end_date | DATE | Registration closing date |
| course_start_date | DATE | Actual course start date |
| enrolment_capacity | INTEGER | Maximum planned capacity; greater than zero |

**Important rules:**
- An intake belongs to an existing course.
- The same course cannot have duplicate intake names.
- Registration end date cannot be earlier than registration start date.
- Course start date cannot be earlier than registration start date.
- Capacity is stored once per intake.

## 5. enrolments

**Purpose:** Records a student's registration in a particular course intake.

| Column | Data type | Rule / purpose |
|---|---|---|
| enrolment_id | VARCHAR(15) | Primary key |
| student_id | VARCHAR(15) | Foreign key to students |
| intake_id | VARCHAR(15) | Foreign key to course_intakes |
| enrolment_date | DATE | Registration date |
| status | VARCHAR(20) | Registered, Active, Completed or Withdrawn |
| agreed_course_fee | NUMERIC(12,2) | Fee agreed for this enrolment; cannot be negative |

**Important rules:**
- Student and intake must already exist.
- A student can have multiple enrolments in different intakes.
- A student cannot be enrolled twice in the same intake.
- The agreed course fee preserves the fee for that particular enrolment.

## 6. payments

**Purpose:** Stores individual payment transactions made against enrolments.

| Column | Data type | Rule / purpose |
|---|---|---|
| payment_id | VARCHAR(15) | Primary key |
| enrolment_id | VARCHAR(15) | Foreign key to enrolments |
| payment_date | DATE | Transaction date |
| amount | NUMERIC(12,2) | Payment amount; must be greater than zero |
| payment_reference | VARCHAR(50) | Optional payment reference |

**Important rules:**
- Every payment must reference an existing enrolment.
- One enrolment can have multiple payment transactions.
- Payment amounts must be positive.

---

## 7. Key Database Terms

| Term | Meaning |
|---|---|
| Primary key (PK) | Uniquely identifies a record in a table |
| Foreign key (FK) | Connects a record to another table |
| UNIQUE | Prevents duplicate values or combinations |
| NOT NULL | Requires a value |
| CHECK | Restricts values according to a condition |
| VARCHAR | Stores variable-length text |
| DATE | Stores a calendar date |
| NUMERIC(12,2) | Stores precise decimal values, suitable for money |
| SMALLINT | Stores a small whole number |
| INTEGER | Stores a whole number |
| TEXT | Stores longer text |

## 8. Reporting Definitions

**Registered students:** Count of enrolments in the selected intake that qualify under the reporting status rules.

**Available seats:**

`Enrolment capacity - Registered students`

**Capacity utilisation:**

`(Registered students / Enrolment capacity) * 100`

**Total payments:** Sum of payment transactions associated with an enrolment.

**Outstanding balance:**

`Agreed course fee - Total payments`

These are reporting definitions. The actual status inclusion rules and treatment of refunds or overpayments must be documented when the reporting SQL is implemented.

## 9. Data Protection

All portfolio records must be synthetic.

Do not use actual student names, telephone numbers, email addresses, identity document numbers or payment references.
