# Learning Notes

## Project: Student Finance & Enrolment Analytics

These notes capture technical concepts, practical lessons and learning checkpoints.

## 1. PostgreSQL

**What is PostgreSQL?**

PostgreSQL is a relational database management system. It stores structured information in tables and allows users to retrieve, insert, update and analyse that information using SQL.

**What is psql?**

`psql` is a command-line tool used to communicate with PostgreSQL.

Example:

```bash
sudo -u postgres psql -d student_finance_analytics
```

This connects to the project database as the PostgreSQL administrator.

## 2. Relational Database Design

A relational database stores related information in separate tables and connects them through keys.

Example:

- Student details belong in `students`.
- Course information belongs in `courses`.
- Intake details belong in `course_intakes`.
- Registration details belong in `enrolments`.
- Payment transactions belong in `payments`.

This reduces unnecessary duplication and supports accurate reporting.

## 3. Primary Keys and Foreign Keys

**Primary key:** A column or combination of columns that uniquely identifies a record.

**Foreign key:** A column that references a key in another table.

Example:

`payments.enrolment_id` references `enrolments.enrolment_id`.

This prevents a payment from referencing an enrolment that does not exist.

## 4. Data Types

Common types used in this project:

- `VARCHAR`: variable-length text.
- `DATE`: calendar dates.
- `INTEGER`: whole numbers.
- `SMALLINT`: smaller whole numbers.
- `NUMERIC(12,2)`: precise decimal values for financial amounts.
- `TEXT`: longer descriptions.

**Why use NUMERIC for money?**

Financial calculations should use exact decimal arithmetic rather than approximate floating-point values.

## 5. Database Constraints

Constraints enforce rules on stored records.

- `NOT NULL`: a value is required.
- `UNIQUE`: prevents duplicate values.
- `PRIMARY KEY`: uniquely identifies a record.
- `FOREIGN KEY`: enforces valid relationships.
- `CHECK`: restricts values to acceptable conditions.

These rules help protect data quality.

## 6. One-to-Many Relationships

Examples:

- One student can have multiple documents.
- One course can have multiple intakes.
- One intake can have many enrolments.
- One enrolment can have many payments.

Understanding these relationships is important when writing SQL JOIN queries.


## 7. Intake Capacity

Capacity belongs to a course intake.

Example:

- Capacity: 30 students.
- Registered: 10 students.
- Active: 8 students.
- Completed: 2 students.
- Enquiry: 5 students.
- Withdrawn: 1 student.

Under the project's capacity policy:

- Registered, Active and Completed occupy capacity.
- Enquiry and Withdrawn do not occupy capacity.

Occupied capacity:

`10 + 8 + 2 = 20 students`

Available seats:

`Capacity - Occupied capacity = 30 - 20 = 10 seats`

Capacity utilisation:

`(Occupied capacity / Capacity) * 100`

Result: 66.67%.

The count must be calculated from the correct enrolment statuses.


## 8. Financial Reconciliation

An enrolment can have several payment transactions.

Example:

| Payment | Amount |
|---|---:|
| First payment | 5,000 |
| Second payment | 3,000 |
| Third payment | 2,000 |
| Total | 10,000 |

If the agreed course fee is KES 15,000:

`Outstanding balance = 15,000 - 10,000`

Result: KES 5,000 outstanding.

This is a simplified example without refunds or overpayments.

## 9. SQL JOIN Multiplication

Joining one enrolment to several payments creates multiple result rows.

If an enrolment has three payments, the enrolment details can appear three times in the joined result.

Summing the enrolment fee after this join can incorrectly multiply the fee.

This project demonstrated the problem in 03_incorrect_report.sql. The corrected approach in 04_corrected_report.sql uses a CTE to aggregate payments by enrolment before joining the results. This prevents the agreed course fee from being multiplied.

## 10. Data Quality

Data quality checks help identify:

- Missing required values.
- Duplicate records.
- Invalid foreign-key references.
- Invalid dates.
- Negative financial values.
- Over-capacity intakes.
- Payments exceeding agreed fees.
- Inconsistent or unexpected enrolment statuses.

Other checks are implemented through validation SQL, reporting queries and database triggers.

## 11. Feynman Learning Checkpoints

Answer these without copying the documentation.

### Checkpoint 1

Why do we store course intake capacity in `course_intakes` instead of repeating it for every student?

### Checkpoint 2

What problem does a foreign key prevent?

### Checkpoint 3

Why can joining enrolments directly to payments produce an incorrect financial total?

### Checkpoint 4

If an intake has capacity 40 and 32 qualifying enrolments, what are the available seats and capacity utilisation?

### Checkpoint 5

Why do we store `agreed_course_fee` in enrolments when the standard course fee already exists in courses?

## 12. Learning Rule

Understand the purpose of each command before executing it.

For every major SQL operation:

1. Explain what it does.
2. Predict what should happen.
3. Execute it.
4. Inspect the result.
5. Explain the outcome in your own words.

The objective is to understand database operations and reporting logic, not simply memorise commands.


## 13. Common Table Expressions (CTEs)

A Common Table Expression (CTE) is a temporary named result set created with `WITH`.

It helps break a complicated SQL query into smaller, understandable steps.

Example:

```sql
WITH payment_totals AS (
    SELECT
        enrolment_id,
        SUM(amount) AS total_paid
    FROM payments
    GROUP BY enrolment_id
)
SELECT *
FROM payment_totals;
```

**What happens:**

1. PostgreSQL reads the payments table.
2. `GROUP BY enrolment_id` groups payments belonging to the same enrolment.
3. `SUM(amount)` calculates the total paid for each enrolment.
4. The result is temporarily named `payment_totals`.
5. The final SELECT displays the aggregated results.

**Project application:**

The corrected financial report aggregates payments before joining them to enrolments. This prevents one-to-many JOIN multiplication.

## 14. JOIN and LEFT JOIN

A `JOIN` combines related records from different tables.

Example:

```sql
SELECT
    e.enrolment_id,
    p.payment_id,
    p.amount
FROM enrolments e
JOIN payments p
    ON e.enrolment_id = p.enrolment_id;
```

An ordinary `JOIN` (INNER JOIN) returns matching records from both tables.

A `LEFT JOIN` retains every record from the left-hand table, even when no matching record exists on the right.

**Project application:**

A financial report should include an enrolment even if the student has not made a payment. A LEFT JOIN makes that possible.

## 15. SQL Aggregate Functions

Aggregate functions summarise multiple records.

| Function | Purpose |
|---|---|
| `COUNT()` | Counts records |
| `SUM()` | Adds numeric values |
| `AVG()` | Calculates an average |
| `MIN()` | Finds the smallest value |
| `MAX()` | Finds the largest value |

`GROUP BY` determines which records are grouped together.

Example:

```sql
SELECT
    enrolment_id,
    SUM(amount) AS total_paid,
    COUNT(*) AS payment_transactions
FROM payments
GROUP BY enrolment_id;
```

This produces one summary row per enrolment.

## 16. Useful SQL Functions

### COALESCE

Returns the first non-NULL value.

```sql
COALESCE(total_paid, 0)
```

If an enrolment has no payment summary, the report can display zero instead of NULL.

### GREATEST

Returns the largest value from its arguments.

```sql
GREATEST(total_paid - agreed_course_fee, 0)
```

This prevents a negative overpayment credit.

### NULLIF

Returns NULL when two expressions are equal.

```sql
NULLIF(total_present + total_absent, 0)
```

This protects a percentage calculation from division by zero.

### ROUND

Rounds a numeric result to a specified number of decimal places.

```sql
ROUND(attendance_rate, 2)
```

### FILTER

Allows an aggregate function to count only records that meet a condition.

Example:

```sql
COUNT(*) FILTER (
    WHERE attendance_status = 'Present'
)
```

This counts Present attendance records without needing a separate query for each status.

## 17. Database Functions and Triggers

A database function contains reusable SQL or procedural logic.

A trigger automatically executes a function when a specified database event occurs.

**Project examples:**

- A payment trigger refreshes enrolment registration status after payment changes.
- An attendance eligibility trigger checks whether attendance can be recorded.
- An attendance activation trigger changes a Registered enrolment to Active when Present attendance is recorded.

A trigger is useful when a business rule must be applied consistently, regardless of which application or user inserts the record.

## 18. Transactions, ROLLBACK and SAVEPOINT

A transaction groups database operations into a unit of work.

Example:

```sql
BEGIN;

UPDATE enrolments
SET status = 'Active'
WHERE enrolment_id = 'ENR007';

ROLLBACK;
```

`BEGIN` starts the transaction.

`ROLLBACK` cancels its changes.

`COMMIT` permanently saves its changes.

A savepoint allows a transaction to roll back part of its work without cancelling everything:

```sql
BEGIN;

SAVEPOINT test_point;

-- Perform a test operation here.

ROLLBACK TO SAVEPOINT test_point;

COMMIT;
```

**Project application:**

Temporary payment and attendance tests used transactions and savepoints so test records could be removed without leaving unwanted changes in the demonstration dataset.

## 19. Course-relative Date Calculations

The attendance report calculates weeks relative to the course start date.

The formula is:

```sql
FLOOR(
    (attendance_date - course_start_date) / 7.0
)::INTEGER + 1
```

Example:

- Course starts Monday, 21 September 2026.
- 21–27 September is course week 1.
- 28 September–4 October is course week 2.

This is different from ISO calendar week numbering, which follows the calendar year rather than each student's course start date.

The course duration check uses an exclusive end date:

```sql
attendance_date < course_start_date
                 + (course_duration_weeks * 7)
```

This means the date at the end boundary is not included in the course period.

The attendance trigger also restricts attendance to Monday–Friday.

## 20. Attendance Rate Calculations

The project calculates attendance rates using two definitions.

**Primary attendance rate — excludes Excused days:**

\[
\frac{Present}{Present + Absent}\times100
\]

**Alternative rate — includes Excused days:**

\[
\frac{Present}{Present + Absent + Excused}\times100
\]

For ENR007:

- Present: 3
- Absent: 1
- Excused: 1

Primary attendance rate:

\[
\frac{3}{3+1}\times100=75\%
\]

Alternative rate:

\[
\frac{3}{3+1+1}\times100=60\%
\]

The reporting definition must be stated clearly because different denominators produce different results.

## 21. Data Validation and Reconciliation

Data validation checks whether records meet expected technical and business rules.

Examples from this project include:

- Duplicate email checks.
- Required student information checks.
- Foreign-key and orphan-record checks.
- Valid course durations and fees.
- Valid intake dates and capacities.
- Duplicate enrolment checks.
- Payment and refund checks.
- Attendance eligibility checks.

Reconciliation goes further by comparing related records to establish whether totals agree.

For example:

- Compare agreed course fees with payments received.
- Identify outstanding balances.
- Identify overpayment credits.
- Compare refund requests with approved and paid refunds.

A report can execute without SQL errors and still contain incorrect business results. That is why both technical validation and business-rule validation are important.

## 22. Practical Learning Checkpoints

Try answering these questions without looking at the examples above.

1. Why does a CTE help prevent JOIN multiplication in the financial report?
2. What is the difference between JOIN and LEFT JOIN?
3. Why do we use COALESCE when reporting payments?
4. What is the difference between a database function and a trigger?
5. Why did we use ROLLBACK when testing ENR005?
6. Why is course-relative week numbering better than ISO week numbering for this attendance report?
7. Why does the attendance rate change from 75% to 60% when Excused days are included?
8. What is the difference between data validation and financial reconciliation?

## 23. Current Learning Milestone

The project has provided practical experience with:

- Relational database design.
- PostgreSQL administration and psql.
- SQL data insertion, updates and deletion.
- Primary keys, foreign keys and constraints.
- JOINs, CTEs and aggregate functions.
- Financial reconciliation and data-quality checks.
- PostgreSQL functions and triggers.
- Transactions, rollback and savepoints.
- Date validation and attendance reporting.
- Technical documentation and troubleshooting.

Further learning will focus on refining financial reporting, testing edge cases, publishing the portfolio project and connecting the database to a BI dashboard.

## 24. Never-Attended Withdrawal Refund Test

I tested a withdrawal scenario using enrolment ENR005.

### Test scenario
- The student had no previous payments.
- The student had no attendance records.
- A temporary payment of KES 10,000 was inserted.
- The enrolment was moved to Withdrawn.
- The portfolio policy retains KES 2,500 for a student who withdraws before attending.

### Refund eligibility calculation

Maximum refund eligibility is calculated as:

`GREATEST(total_paid - 2500.00, 0)`

For this test:

- Total paid: KES 10,000
- Retention: KES 2,500
- Maximum refund eligibility: KES 7,500

### What I learned

- Payment triggers can automatically update enrolment status.
- A transaction allows temporary test data to be rolled back.
- CTEs help organise payment and attendance calculations.
- `COALESCE` handles missing values.
- `FILTER` allows conditional aggregation.
- `GREATEST` prevents a negative refund eligibility amount.
- `ROLLBACK` restored the original database state.

### Important limitation

Zero recorded Present attendance does not always prove that a student never attended. Absent or Excused records may exist. A production refund process should distinguish between no attendance records and attendance records without a Present entry.

No refund was created, approved or paid during this test.
