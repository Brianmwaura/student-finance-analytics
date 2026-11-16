# Database Design

## 1. Project Overview

The Student Finance & Enrolment Analytics database uses a relational model.

The purpose is to connect student records, courses, course intakes, enrolments and payment transactions while reducing duplicated data.

## 2. Database Tables

| Table | Purpose | One row represents |
|---|---|---|
| students | Stores student details | One student |
| student_documents | Stores identity document records | One document |
| courses | Stores course information and standard fees | One course |
| course_intakes | Stores intake dates and capacity | One course intake |
| enrolments | Records student registrations | One student in one intake |
| payments | Records financial transactions | One payment |

## 3. Table Relationships

### Students → Student Documents

One student can have multiple documents.

Relationship: One-to-Many.

`student_documents.student_id` references `students.student_id`.

### Courses → Course Intakes

One course can have multiple intakes.

Relationship: One-to-Many.

`course_intakes.course_id` references `courses.course_id`.

### Students → Enrolments

One student can enrol in multiple intakes over time.

Relationship: One-to-Many.

`enrolments.student_id` references `students.student_id`.

### Course Intakes → Enrolments

One intake can contain many student enrolments.

Relationship: One-to-Many.

`enrolments.intake_id` references `course_intakes.intake_id`.

### Enrolments → Payments

One enrolment can have multiple payment transactions.

Relationship: One-to-Many.

`payments.enrolment_id` references `enrolments.enrolment_id`.

## 4. Simplified Relationship Diagram

```text
STUDENTS
   |
   |----< STUDENT_DOCUMENTS
   |
   |----< ENROLMENTS >---- COURSE_INTAKES >---- COURSES
                 |
                 |
                 |----< PAYMENTS
```

`1` represents one parent record. `<` represents many related records.

## 5. Primary Keys and Foreign Keys

A primary key uniquely identifies a record in a table.

Examples:
- `students.student_id`
- `courses.course_id`
- `enrolments.enrolment_id`
- `payments.payment_id`

A foreign key links a record to a valid record in another table.

Examples:
- `enrolments.student_id` links to a student.
- `enrolments.intake_id` links to an intake.
- `payments.enrolment_id` links to an enrolment.

Foreign keys help prevent orphan records.

## 6. Important Business Rules

1. A student must exist before an enrolment can reference them.
2. A course must exist before an intake can reference it.
3. An intake must exist before an enrolment can reference it.
4. An enrolment must exist before a payment can reference it.
5. A student cannot be enrolled twice in the same intake.
6. Each intake has a defined enrolment capacity.
7. Payments must be greater than zero.
8. Course fees and agreed enrolment fees cannot be negative.

## 7. Capacity Management

Capacity belongs to the course intake, not to individual students.

Example:

| Intake | Capacity | Registered |
|---|---:|---:|
| E001 | 30 | 24 |

Available seats:

`30 - 24 = 6`

Capacity utilisation:

`(24 / 30) * 100 = 80%`

The registered count must be calculated from qualifying enrolment records.

The current schema does not automatically prevent an intake from exceeding capacity. A validation query will be used to identify over-capacity intakes.

## 8. Financial Design

The `courses` table stores the standard course fee.

The `enrolments` table stores `agreed_course_fee`, which records the fee agreed for a particular student's enrolment.

This preserves the historical fee even if the standard course fee changes later.

The `payments` table stores individual payment transactions against an enrolment.

Total payments can therefore be compared with the agreed course fee to calculate outstanding balances.

## 9. Join Multiplication Risk

An enrolment can have several payment records.

Joining enrolments directly to payments produces one result row per matching payment.

For example, an enrolment with three payment transactions appears three times in the joined result.

If enrolment fees are summed after this join without controlling the row multiplication, the fees may be overstated.

The reporting stage will demonstrate an incorrect query and a corrected query.

## 10. Design Limitations and Future Improvements

- Intake capacity is not yet enforced automatically.
- Payment currency is not separately stored; the MVP assumes KES.
- Payment reversals, refunds and transaction statuses are not yet modelled.
- Course fee history is partially preserved through the agreed fee on each enrolment.
- More advanced audit history and role-based access can be added later.
