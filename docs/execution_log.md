# Project Execution Log

## Project: Student Finance & Enrolment Analytics

This file records verified project activities, commands, decisions and results.

## 1. Environment Setup

| Activity | Result |
|---|---|
| Kali Linux environment | Confirmed |
| PostgreSQL 18.6 client | Confirmed |
| PostgreSQL 18/main cluster | Online |
| PostgreSQL port | 5432 |
| Project database | Created |
| PostgreSQL 17 cluster | Removed |

## 2. PostgreSQL Troubleshooting

### Collation version mismatch

**Issue:** PostgreSQL reported that the recorded collation version was 2.42 while the operating system provided 2.43.

**Actions performed:**
- Attempted database creation; initial attempt failed.
- Attempted to reindex `template1` while connected to another database; PostgreSQL rejected the command.
- Connected directly to `template1`.
- Reindexed `template1`.
- Refreshed its recorded collation version.
- Reindexed and refreshed the `postgres` database.
- Successfully created the project database.

See `troubleshooting.md` for further details.

## 3. Database Schema

File: `sql/01_schema.sql`

Six tables were created and verified:

1. students
2. student_documents
3. courses
4. course_intakes
5. enrolments
6. payments

Verification command:

```bash
sudo -u postgres psql -d student_finance_analytics -c "\dt"
```

The output confirmed all six tables.

The `course_intakes` table was also inspected to verify its columns and constraints.

## 4. Database Modelling Decisions

- E001 represents a course intake, not an individual student enrolment.
- Each student registration has its own `enrolment_id`.
- Intake capacity is stored in `course_intakes`.
- Payments reference `enrolment_id`.
- A student cannot be enrolled twice in the same intake.
- Agreed course fees are stored against individual enrolments.

See `database_design.md` and `decisions_and_corrections.md`.

## 5. Documentation Progress

| File | Status at this checkpoint |
|---|---|
| README.md | Created and populated |
| setup_and_configuration.md | Saved; 172 lines verified |
| database_design.md | Saved; 159 lines verified |
| data_dictionary.md | Saved; 174 lines verified |
| execution_log.md | Being populated |
| troubleshooting.md | Created; content pending |
| learning_notes.md | Created; content pending |
| decisions_and_corrections.md | Created and populated |

## 6. Pending Activities

- Prepare synthetic sample records.
- Execute and verify sample data insertion.
- Create an intentionally incorrect financial report query.
- Demonstrate join multiplication.
- Write the corrected reporting query.
- Create data-quality validation queries.
- Run and record validation tests.
- Prepare GitHub documentation and publish the project.
- Connect Power BI at a later stage.

## 7. Evidence and Accuracy Rules

Only record a command as executed after it has actually been run.

Only record a test as passed after its result has been checked.

Preserve relevant errors and their resolutions instead of deleting them from the project history.

## 8. Synthetic Sample Data Execution

File: `sql/02_sample_data.sql`

Execution command:

```bash
sudo -u postgres psql -v ON_ERROR_STOP=1 -d student_finance_analytics -f sql/02_sample_data.sql

```

## 9. Incorrect Financial Report — JOIN Multiplication

File: `sql/03_incorrect_report.sql`

Execution result: SUCCESS — query executed and returned 12 rows.

Purpose:
Demonstrate how joining enrolments directly to payment transactions can multiply financial values.

Observed results:
- Correct total agreed fees: KES 520,000.
- Incorrectly reported total agreed fees: KES 700,000.
- Overstatement: KES 180,000.

Examples:
- ENR001: KES 45,000 was incorrectly reported as KES 90,000.
- ENR004: KES 35,000 was incorrectly reported as KES 70,000.
- ENR011: KES 50,000 was incorrectly reported as KES 100,000.
- ENR012: KES 50,000 was incorrectly reported as KES 100,000.

Conclusion:
The one-to-many relationship between enrolments and payments caused the agreed course fee to repeat for each payment row.

## 10. Corrected Financial Report — Pre-aggregation

File: `sql/04_corrected_report.sql`

Execution result: SUCCESS — query returned 12 rows.

Method:
Used a Common Table Expression (CTE) to aggregate payments by enrolment before joining payment summaries to enrolments.

Verified results:
- Total agreed fees: KES 520,000.
- Total payments: KES 270,000.
- Calculated outstanding balance: KES 250,000.
- All 12 enrolments appeared in the report.
- Enrolments without payments were retained using LEFT JOIN and COALESCE.

Conclusion:
Pre-aggregating payment transactions prevents the agreed course fee from being multiplied.

Business reporting note:
Calculated outstanding balance is not necessarily collectible debt. Withdrawal, refund and fee-waiver policies must be considered separately.


## 11. Financial Summary and Refund Reporting

### Objective
Create a consolidated financial report showing agreed fees, payments, calculated balances, collectible balances, overpayment credits and refund statuses.

### File created
`sql/08_financial_summary.sql`

### Execution command
```bash
sudo -u postgres psql -P pager=off -v ON_ERROR_STOP=1 -d student_finance_analytics -f sql/08_financial_summary.sql
```

### Execution result
- SQL executed successfully.
- Returned 12 enrolment records.
- No SQL errors were reported.

### Key verified results

| Enrolment | Key result |
|---|---|
| ENR002 | KES 50,000 paid against KES 45,000 fee; KES 5,000 overpayment |
| ENR003 | Withdrawn; KES 40,000 calculated balance; KES 0 collectible balance |
| ENR004 | KES 20,000 collectible balance; KES 5,000 refund rejected |

### Reporting logic
- Payment transactions are aggregated by enrolment before joining.
- Refund records are aggregated separately by enrolment.
- `COALESCE` converts missing payment/refund aggregates to zero.
- `GREATEST` prevents negative collectible balances and negative credit calculations.
- Withdrawn enrolments have zero collectible balance under the project's current business rule.
- Approved refunds and paid refunds are reported separately.
- Pending refund requests are not treated as completed payments.
- Pending requests are provisionally deducted when calculating credit after paid and pending requests.

### Learning outcome
A calculated outstanding balance is not necessarily collectible debt. Financial reports must apply business rules and distinguish between outstanding fees, overpayment credits, approved refunds, paid refunds and pending refund requests.

### Validation status
Financial summary output visually checked against the synthetic sample data. Dedicated automated data-quality and refund validation tests remain pending.


## 12. Schema Migration and Business Rules

### Migration 09 — Policy and schema updates

File: `sql/09_policy_schema_migration.sql`

The migration added or updated:
- Enrolment status validation.
- Course duration in weeks.
- Refund basis and approver fields.
- The attendance table.

**Execution note:** The migration was run with `--single-transaction`, while the SQL file also contained `BEGIN` and `COMMIT`. PostgreSQL reported transaction warnings because both methods attempted to control the transaction. The migration completed, but future migration scripts should use one transaction-control method only.

### Migration 11 — Attendance date validation

File: `sql/11_attendance_date_validation.sql`

Added validation to reject attendance:
- Before the course start date.
- Outside the course duration.
- On Saturdays or Sundays.
- For enrolments still in Enquiry status.

Execution used:

```bash
sudo -u postgres psql \
  -v ON_ERROR_STOP=1 \
  --single-transaction \
  -d student_finance_analytics \
  -f sql/11_attendance_date_validation.sql
```

The function was created successfully and inspected using `pg_get_functiondef()`.

## 13. Dataset Expansion

File: `sql/12_dataset_expansion.sql`

The script added:
- Data Analytics course: KES 55,000, 19 weeks.
- January 2027 intake E005: capacity 10.
- Nine additional students, S013–S021.
- Enrolments ENR013–ENR022.
- Payments P016–P025.
- An Enquiry enrolment for S012.

Verified database totals after execution:

| Table | Records |
|---|---:|
| Students | 21 |
| Courses | 4 |
| Course intakes | 5 |
| Enrolments | 22 |
| Payments | 25 |

For intake E005, nine enrolments occupy capacity, one remains Enquiry, and one place is available under the agreed capacity policy.

S013 has two separate payments of KES 1,500 each. The payment trigger correctly considered their cumulative value of KES 3,000.

## 14. Enrolment Automation Tests

File: `sql/10_enrolment_automation.sql`

Verified behaviour:
- Payments totalling at least KES 2,500 move an Enquiry to Registered.
- Reducing the total below KES 2,500 can return Registered to Enquiry when no Present attendance exists.
- A Present attendance record moves Registered to Active.
- Attendance for an Enquiry enrolment is rejected.
- Multiple payments are aggregated before the registration status is refreshed.

Temporary test transactions were rolled back. ENR005 was checked afterwards and returned to Enquiry with zero payments and zero attendance records.

## 15. Attendance Validation Tests

ENR007 was used for attendance validation testing.

Verified:
- A valid weekday attendance date was accepted.
- A date before the course start was rejected.
- A Saturday was rejected.
- A date outside the course period was rejected.

An unexpected temporary test record was subsequently identified and explicitly deleted. ENR007 was restored to Registered before the final demonstration attendance records were inserted.

Normal transaction rollback and savepoint rollback were also tested. Both left ENR007 with no temporary attendance records and Registered status.

## 16. Synthetic Attendance Demonstration

Six attendance records are currently stored.

ENR003:
- One historical Present record dated 19 May 2026.
- This supports the synthetic attended-classes refund example.
- Its enrolment status remains Withdrawn.

ENR007:
- Five weekday records dated 21–25 September 2026.
- Three Present, one Absent and one Excused.
- The first Present record activated the enrolment.

## 17. Weekly Attendance Report

File: `sql/13_weekly_attendance_report.sql`

Execution command:

```bash
sudo -u postgres psql \
  -v ON_ERROR_STOP=1 \
  -P pager=off \
  -d student_finance_analytics \
  -f sql/13_weekly_attendance_report.sql
```

Execution result: SUCCESS.

Verified results:

| Enrolment | Present | Absent | Excused | Recorded |
|---|---:|---:|---:|---:|
| ENR003 | 1 | 0 | 0 | 1 |
| ENR007 | 3 | 1 | 1 | 5 |

The report uses course-relative weeks rather than ISO calendar weeks. Excused days are excluded from the primary attendance-rate denominator.

ENR003's 100% result is based on one recorded day only. It must not be interpreted as a full-course attendance rate.

## 18. Never-Attended Withdrawal Refund Eligibility Test

### Objective
Verify the maximum refund eligibility for a student who withdraws before recording any attendance.

### Test setup
- Enrolment: ENR005
- Initial status: Enquiry
- Agreed course fee: KES 35,000
- Initial total paid: KES 0
- Initial attendance records: 0
- Temporary test payment: KES 10,000

### Test procedure
1. Started a database transaction.
2. Inserted a temporary KES 10,000 payment.
3. Confirmed that the payment trigger changed the enrolment status from Enquiry to Registered.
4. Changed the enrolment status to Withdrawn.
5. Calculated refund eligibility using the KES 2,500 retention policy.
6. Rolled back the transaction.

### Expected and actual result

| Measure | Expected | Actual |
|---|---:|---:|
| Temporary payment | KES 10,000 | KES 10,000 |
| Retention | KES 2,500 | KES 2,500 |
| Maximum refund eligibility | KES 7,500 | KES 7,500 |
| Refund created | No | No |
| Refund approved or paid | No | No |

### Rollback verification
After rollback:
- ENR005 returned to Enquiry.
- Total payments returned to KES 0.
- No temporary test payment remained.

### Result
The test passed. The transaction rollback preserved the original database state.

This test calculates maximum eligibility only. It does not automatically approve or pay a refund.
