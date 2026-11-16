# Decisions and Corrections

## 001 - Revised Sample Data Model

### Previous design
The original sample data used simplified student and course records.

It also used E001 as an enrolment identifier.

### Problem
The original INSERT statements did not match the revised table structures.
They also used Student A, Student B and Student C placeholders.

### Decision
Retain the old file as a historical reference only.
Do not execute it.

Prepare new synthetic sample data using the current six-table schema.

### Revised design
E001 represents a course intake, not an individual student enrolment.

Each student registration receives its own enrolment_id.
Each payment references the relevant enrolment_id.
---

## 002 - British English Spelling Standard

### Previous naming
Some earlier references used American English spelling:
- enrollment_start_date
- enrollment_end_date
- enrollment_capacity

### Correction
The project uses British English consistently.

Final column names:
- enrolment_start_date
- enrolment_end_date
- enrolment_capacity

### Decision
Use `enrolment` consistently in SQL identifiers, documentation and reports.

---

## 003 - Intake Capacity Design

### Initial consideration
Capacity could have been repeated in individual student enrolment records.

### Problem
Repeating capacity for every student would duplicate the same intake information and could lead to inconsistent values.

### Decision
Store `enrolment_capacity` once in `course_intakes`.

Calculate registered students from qualifying enrolment records.

Calculate available seats as:

Available seats = Intake capacity - Registered students

Capacity utilisation = (Registered students / Intake capacity) * 100

### Limitation
The current schema does not automatically block enrolments above capacity. A validation query will identify over-capacity intakes.

---

## 004 - Payment Relationship

### Previous design
The simplified sample data did not fully represent the relationship between student registrations and payments.

### Decision
Each payment references `enrolment_id`, rather than referencing only `student_id`.

### Reason
One student may enrol in multiple courses or intakes. Payments must be associated with the correct registration.

One enrolment can have multiple payment transactions.

---

## 005 - Course Fee and Agreed Fee

### Decision
Store the standard course fee in `courses.course_fee`.

Store the actual agreed fee for each registration in `enrolments.agreed_course_fee`.

### Reason
The fee agreed with a student may differ from the current standard course fee. Keeping the agreed fee against the enrolment preserves that registration's fee information.

---

## 006 - Synthetic Portfolio Data

### Decision
Use fictional student, contact, document and payment details.

### Reason
The project is intended for public portfolio use and GitHub publication.

Real student, employee, identity-document and financial information must not be included.


---

## 007. Calculated Balance vs Collectible Balance

Decision:
The current MVP calculates a basic balance using:

Agreed course fee - Total payments received.

This is a calculated balance, not necessarily a confirmed collectible debt.

Reason:
Withdrawn students may have refunds, fee waivers or other financial adjustments.

Future implementation:
Financial reporting will distinguish between:
- Calculated balance.
- Collectible balance.
- Excess payments or student credit.
- Refunds requested.
- Refunds approved.
- Refunds paid.

## 008. Refund and Overpayment Management

Decision:
Introduce a separate refunds table linked to enrolments.

Business rules:
1. Withdrawn enrolments have zero collectible balance.
2. Withdrawal does not automatically approve a refund.
3. Refunds must follow institutional financial policy.
4. Overpayments must be flagged as student credit.
5. Refunds must be recorded separately from payments.
6. Refunds paid must have policy approval.
7. Cumulative refunds must not exceed payments received.

Purpose:
Provide accurate financial reporting and distinguish institutional revenue, outstanding fees, student credits and refund obligations.


## Decision 009: Separate Financial Balances from Refund Statuses

### Decision
Keep payments and refunds in separate tables and aggregate each independently before combining them in financial reports.

### Reason
Joining multiple one-to-many tables directly can multiply rows and inflate financial totals.

### Business rules
1. Withdrawn enrolments have zero collectible balance in the current portfolio reporting model.
2. An approved refund is not considered paid until its status becomes `Paid`.
3. An overpayment creates a credit; it does not automatically trigger a refund.
4. A pending refund request is not an approved refund.
5. Rejected refund requests remain visible for audit purposes but do not reduce collectible balances.
6. Pending requests may be provisionally reserved against available credit, but this does not mean the refund has been approved.

### Limitation
The current database has row-level refund constraints. Cross-record checks, such as ensuring total refunds do not exceed payments received, still require validation queries.


## Decision 010: Never-Attended Withdrawal Refund Eligibility

### Context
The project needs a consistent way to calculate maximum refund eligibility when a student withdraws before attending.

### Decision
For this portfolio scenario, retain KES 2,500 where a student withdraws before recording any attendance.

Calculate maximum refund eligibility as:

`GREATEST(total_paid - 2500.00, 0)`

### Controls
- A calculated eligible amount is not an approved refund.
- Approval and payment remain separate actions.
- No refund record should be created automatically from this calculation alone.
- The transaction test must leave the original database unchanged after rollback.

### Limitation
Zero Present attendance records do not necessarily prove that a student never attended. Absent or Excused records may exist.

A production implementation should distinguish between:
- No attendance records.
- Attendance records exist, but none are marked Present.
- One or more Present records exist.

### Scope
The KES 2,500 retention is a portfolio test policy, not a claim about an actual institution's official refund policy.

