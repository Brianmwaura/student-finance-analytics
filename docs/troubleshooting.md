# Troubleshooting Log

## Project: Student Finance & Enrolment Analytics

This document records actual technical problems encountered, their causes and the resolutions performed.

## 1. PostgreSQL Collation Version Mismatch

**Error observed:**

PostgreSQL reported:
- Database collation version: 2.42
- Operating system collation version: 2.43

**Impact:**

Creating the project database initially failed because the template database had a collation version mismatch.

**Cause:**

The operating system's collation library version had changed, while PostgreSQL databases still recorded the previous version.

**Resolution performed:**

Connected to `template1`:

```bash
sudo -u postgres psql -d template1
```

Executed:

```sql
REINDEX DATABASE template1;
ALTER DATABASE template1 REFRESH COLLATION VERSION;
```

The `postgres` database was also reindexed and refreshed.

The project database was subsequently created successfully.

**Learning point:**

`REINDEX` rebuilds indexes. Refreshing the collation version updates PostgreSQL's recorded version. These actions serve different purposes.

## 2. REINDEX Executed Against the Wrong Database

**Error observed:**

```text
ERROR: can only reindex the currently open database
```

**Cause:**

The command `REINDEX DATABASE template1;` was initially executed while connected to `postgres`, not `template1`.

**Resolution:**

Connect to the correct database first:

```bash
sudo -u postgres psql -d template1
```

Then execute:

```sql
REINDEX DATABASE template1;
```

**Learning point:**

`REINDEX DATABASE` operates on the database to which the current session is connected.

## 3. Old Sample Data Incompatible With Revised Schema

**Problem identified:**

The old `02_sample_data.sql.save` script contained simplified records that did not match the current database structure.

Examples:
- Student INSERT statements supplied only two columns.
- Course INSERT statements supplied only two columns.
- Enrolments referenced course IDs directly instead of intake IDs.
- No course intake records were included.
- Placeholder names such as Student A were present.

**Resolution:**

The old script was retained as a historical reference and not executed.

A replacement synthetic dataset was created in `sql/02_sample_data.sql` and successfully executed against the revised schema. Later, `sql/12_dataset_expansion.sql` expanded the dataset to 21 students and 22 enrolments.

**Learning point:**

When a database schema changes, existing INSERT statements must be reviewed and updated. Old data scripts should not be assumed compatible.

## 4. PostgreSQL 17 and PostgreSQL 18 Clusters

**Problem:**

Both PostgreSQL 17 and PostgreSQL 18 clusters were initially present.

**Resolution performed:**

```bash
sudo pg_dropcluster --stop 17 main
```

Verification:

```bash
sudo pg_lsclusters
```

The PostgreSQL 18/main cluster was confirmed online.

**Important distinction:**

Removing a PostgreSQL cluster is not the same as uninstalling its software package. Removal of the PostgreSQL 17 package has not been verified.

## 5. Troubleshooting Procedure for Future SQL Errors

When a SQL command fails:

1. Read the complete PostgreSQL error message.
2. Identify the affected database and table.
3. Check whether the referenced table and columns exist.
4. Check data types, constraints and foreign keys.
5. Correct the underlying issue.
6. Rerun the command.
7. Verify the result independently.
8. Record the error, correction and successful test.

## 6. Documentation Rule

Do not remove an error from the project history simply because it has been fixed.

Document what happened, why it happened, what resolved it and how the result was verified.


## 7. Transaction-Control Warning During Schema Migration

**Issue observed:**

During execution of `sql/09_policy_schema_migration.sql`, PostgreSQL displayed:

```text
WARNING: there is already a transaction in progress
WARNING: there is no transaction in progress
```

**Cause:**

The migration file contained `BEGIN` and `COMMIT`, while the execution command also used `--single-transaction`.

Both methods attempted to manage the transaction.

**Outcome:**

The migration completed and its changes were verified. However, the warnings showed that transaction control was duplicated.

**Resolution for future migrations:**

When executing a script with:

```bash
--single-transaction
```

do not also put `BEGIN` and `COMMIT` inside the SQL file.

This allows the command-line client to manage the transaction consistently.

## 8. Attendance Test Record Found After Rollback

**Problem observed:**

During attendance validation testing, a temporary ENR007 attendance record was subsequently found in the database, despite an earlier test transcript showing `ROLLBACK`.

**Investigation:**

The record was inspected using its attendance ID, enrolment ID and temporary test remark.

**Resolution performed:**

The temporary record was explicitly deleted inside a transaction. ENR007 was restored to Registered because no Present attendance records remained.

The database was queried again to confirm zero attendance records for ENR007 at that checkpoint.

**Further verification:**

A controlled transaction rollback test and a separate savepoint rollback test were performed. Both left ENR007 with Registered status and zero temporary attendance records.

**Learning point:**

Never rely on a displayed transaction message alone when unexpected records appear. Query the database to verify its actual state.

## 9. Attendance Date Validation

**Tests performed:**

ENR007 was used to test the attendance eligibility function.

| Test case | Expected behaviour | Observed result |
|---|---|---|
| Valid weekday | Accept attendance | Accepted |
| Date before course start | Reject attendance | Rejected |
| Saturday | Reject attendance | Rejected |
| Date outside course period | Reject attendance | Rejected |

**Learning point:**

A foreign key alone does not guarantee that attendance is valid for a particular course. Business rules can require additional checks involving dates, course duration and enrolment status.

## 10. Outdated Column Name in Validation Script

**Problem identified:**

The validation script initially referenced `course_duration_months`, although the revised database schema used `course_duration_weeks`.

**Resolution:**

The validation condition was updated to use:

```sql
course_duration_weeks NOT BETWEEN 1 AND 19
```

The script was searched for the old column name and rerun.

**Verification:**

The old column reference was no longer found, and all 24 validation checks executed.

## 11. Shell Heredoc and Markdown Editing Confusion

**Problem observed:**

While attempting to append content to `README.md`, the shell displayed continuation prompts such as:

```text
heredoc>
bquote>
```

**Cause:**

A shell heredoc had not received its terminating `EOF` marker. A later unmatched backtick also caused the shell to wait for more input.

**Resolution:**

`Ctrl+C` was used to cancel unfinished shell input. The README was inspected using `wc`, `grep` and `tail`.

The document was subsequently updated using nano and the new section was verified.

**Learning point:**

A shell heredoc is not the same as editing a file inside nano. When using a heredoc, its terminating marker must appear by itself on a line. When uncertain, cancel unfinished input and inspect the file before continuing.
