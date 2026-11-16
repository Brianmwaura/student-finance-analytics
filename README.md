# Student Finance Analytics — PostgreSQL Portfolio Project

## 1. Project Overview

**Student Finance Analytics** is a PostgreSQL portfolio project that demonstrates how relational databases and SQL can support student administration, fee tracking, payment reconciliation, refund calculations, attendance monitoring and financial reporting.

The project uses a synthetic student dataset to simulate common operational and financial scenarios in an education institution.

The main objective is to demonstrate practical skills in:

- Relational database design.
- SQL querying and data manipulation.
- Data quality checks and reconciliation.
- Financial reporting and aggregation.
- Refund eligibility calculations.
- Attendance and enrolment monitoring.
- PostgreSQL triggers and automation.
- Testing, troubleshooting and technical documentation.
- Linux terminal operations and command-line learning.

This is a learning and portfolio project. It is not a production student management system.

## 2. Business Problems Addressed

Education institutions manage several connected types of information. Poorly structured data or incorrect reporting can lead to inaccurate financial figures and operational decisions.

This project explores problems such as:

1. How to connect students, courses, intakes, enrolments, payments, refunds and attendance.
2. How to calculate the amount paid by each student.
3. How to avoid incorrect financial totals when joining tables with multiple related records.
4. How to identify outstanding balances and overpayments.
5. How to calculate maximum refund eligibility under defined business rules.
6. How to monitor attendance by enrolment and course week.
7. How to validate data and identify records requiring further investigation.
8. How to automate enrolment status changes using PostgreSQL triggers.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| PostgreSQL 18.6 | Relational database management |
| SQL | Database creation, queries, validation and reporting |
| Kali Linux | Development and terminal environment |
| Bash terminal | File management and command-line operations |
| Nano | Editing SQL, Markdown and configuration files |
| Git / GitHub | Planned version control and portfolio publication |
| Power BI | Possible future dashboard development |

## 4. Project Structure

```text
student-finance-analytics/
│
├── README.md
│
├── .gitignore
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_sample_data.sql
│   ├── 03_incorrect_report.sql
│   ├── 04_corrected_report.sql
│   ├── 05_validation.sql
│   ├── 06_refunds.sql
│   ├── 07_refund_sample_data.sql
│   ├── 08_financial_summary.sql
│   ├── 09_policy_schema_migration.sql
│   ├── 10_enrolment_automation.sql
│   ├── 11_attendance_date_validation.sql
│   ├── 12_dataset_expansion.sql
│   ├── 13_weekly_attendance_report.sql
│   └── 14_financial_summary.sql
│
└── docs/
    ├── setup_and_configuration.md
    ├── data_dictionary.md
    ├── database_design.md
    ├── execution_log.md
    ├── troubleshooting.md
    ├── learning_notes.md
    └── decisions_and_corrections.md
```

## 5. Database Design

The database contains eight main relational tables.

| Table | Purpose |
|---|---|
| students | Stores student demographic and contact information |
| student_documents | Tracks student document information |
| courses | Stores course information and fees |
| course_intakes | Stores intake dates, capacity and course scheduling information |
| enrolments | Connects students to courses and intakes and tracks enrolment status |
| payments | Stores payments made against enrolments |
| refunds | Tracks refund requests, approvals, payments and rejections |
| attendance | Stores attendance records against enrolments and dates |

### Main relationships

- One student can have multiple enrolments.
- A course can have multiple intakes.
- An intake can contain multiple enrolments.
- One enrolment can have multiple payments.
- One enrolment can have multiple attendance records.
- One enrolment can have multiple refund records.
- Student documents are associated with students.

The database uses primary keys, foreign keys, constraints and relational joins to maintain data integrity.

### Important reporting design principle

Payments, attendance and refunds can each contain multiple records for one enrolment.

Joining all these tables directly can multiply rows and produce incorrect totals.

The project therefore uses separate aggregations, including Common Table Expressions (CTEs), before combining financial and attendance results.

## 6. Synthetic Dataset

The current expanded dataset contains:

| Data | Records |
|---|---:|
| Students | 21 |
| Courses | 4 |
| Course intakes | 5 |
| Enrolments | 22 |
| Payments | 25 |
| Refunds | 4 |
| Attendance records | 6 |

All records are intended to be synthetic.

Email addresses use the reserved `example.invalid` domain. Phone placeholders are prefixed with `TEST-`.

Real student names, identification numbers, contact information, payment references and institutional records must never be published.

Realistic-looking names, dates of birth and locations must be confirmed as invented examples before public release. If any were copied or adapted from real records, anonymise them before publishing.

## 7. Business Rules and Financial Logic

The project uses defined portfolio rules to make financial calculations consistent.

These are project assumptions, not claims about the official refund policy of any real institution.

### 7.1 Enrolment registration threshold

- The registration payment threshold is KES 2,500.
- An Enquiry enrolment can move to Registered when cumulative payments reach at least KES 2,500.
- A Present attendance record can move a Registered enrolment to Active.

### 7.2 Enrolment statuses

The project uses the following statuses:

- Enquiry
- Registered
- Active
- Completed
- Withdrawn

Enquiry and Withdrawn enrolments have zero collectible balance under the project rules.

Registered, Active and Completed enrolments may have an outstanding collectible course balance.

### 7.3 Refund calculations

The project distinguishes between:

- Never-attended withdrawal refund eligibility.
- Refunds for students who attended.
- Overpayment credits.
- Requested refunds.
- Approved but unpaid refunds.
- Paid refunds.
- Rejected refunds.

For the portfolio's never-attended withdrawal scenario, KES 2,500 is retained.

Maximum refund eligibility is calculated as:

`GREATEST(total_paid - 2500.00, 0)`

For example:

| Item | Amount |
|---|---:|
| Total paid | KES 10,000 |
| Retention | KES 2,500 |
| Maximum refund eligibility | KES 7,500 |

A calculated eligible amount is not an approved or paid refund.

Attended withdrawal refunds remain subject to management decision. The project does not invent a universal percentage for these refunds.

### 7.4 Important attendance limitation

Zero Present attendance records do not necessarily prove that a student never attended.

A student may have Absent or Excused attendance records.

A production refund process should distinguish between:

1. No attendance records.
2. Attendance records exist, but none are marked Present.
3. One or more Present attendance records exist.

### 7.5 Capacity calculation

The project counts Registered, Active and Completed enrolments as occupying intake capacity.

Enquiry and Withdrawn enrolments are excluded.

### 7.6 Attendance week calculation

Weekly attendance reporting uses weeks relative to the course start date, rather than relying on ISO calendar week numbers.

The project validates attendance dates against the course duration and uses Monday-to-Friday attendance days.

## 8. SQL Scripts and Execution Guide

The SQL files are organised by purpose and should be understood as a sequence of development stages.

| Script | Purpose |
|---|---|
| `01_schema.sql` | Creates the core relational database structure |
| `02_sample_data.sql` | Inserts the initial synthetic sample data |
| `03_incorrect_report.sql` | Demonstrates incorrect reporting caused by joining multiple one-to-many tables |
| `04_corrected_report.sql` | Demonstrates corrected financial reporting |
| `05_validation.sql` | Runs data quality and reconciliation checks |
| `06_refunds.sql` | Introduces refund-related database structures and logic |
| `07_refund_sample_data.sql` | Inserts refund examples |
| `08_financial_summary.sql` | Provides an earlier financial summary report |
| `09_policy_schema_migration.sql` | Applies policy-related schema changes and attendance structure |
| `10_enrolment_automation.sql` | Creates payment and attendance triggers |
| `11_attendance_date_validation.sql` | Implements attendance date validation |
| `12_dataset_expansion.sql` | Expands the synthetic dataset |
| `13_weekly_attendance_report.sql` | Produces weekly attendance reporting |
| `14_financial_summary.sql` | Produces the expanded financial and refund summary |

### Important execution warning

Some scripts depend on earlier tables, data or schema changes.

Do not blindly execute every script again against an existing populated database.

In particular, schema migrations, sample-data inserts and dataset expansion scripts may not be safe to rerun without checking their contents and the current database state.

Use the execution log and setup documentation to understand what has already been applied.

## 9. Data Quality and Validation

The validation script is:

`sql/05_validation.sql`

The validation suite contains 24 checks.

The latest recorded execution showed:

- V01–V20: zero issues in the main error checks.
- V21: no students without enrolments.
- V22: three enrolments without payments.
- V23: one overpayment credit.
- V24: one withdrawn enrolment with refunds.

V22, V23 and V24 are informational or business-review checks. They are not automatically database errors.

The validation process demonstrates the importance of separating technical data errors from records that require business interpretation.

## 10. Enrolment Automation

The automation logic is defined in:

`sql/10_enrolment_automation.sql`

The project uses PostgreSQL triggers to respond to payment and attendance changes.

### Payment trigger

The payment trigger recalculates cumulative payments and updates enrolment status according to the defined rules.

Examples:

- An Enquiry enrolment reaching KES 2,500 can become Registered if there is no Present attendance.
- An enrolment with Present attendance can become Active.
- A Registered enrolment below the payment threshold and without Present attendance can return to Enquiry.

The trigger handles payment inserts, updates and deletions.

### Attendance trigger

The attendance trigger:

- Rejects attendance for an Enquiry enrolment.
- Changes a Registered enrolment to Active when Present attendance is recorded.

The automation does not automatically change an enrolment to Withdrawn. That status was manually updated during the refund eligibility test.

## 11. Financial Reporting

The latest financial summary is:

`sql/14_financial_summary.sql`

It brings together:

- Course fees.
- Total payments.
- Collectible balances.
- Attendance information.
- Refund requests.
- Approved unpaid refunds.
- Paid refunds.
- Rejected refunds.
- Overpayment credits.
- Never-attended withdrawal retention and refund eligibility.

### Example financial scenarios

| Scenario | Result |
|---|---|
| ENR002 | KES 5,000 overpayment; KES 3,000 paid refund and KES 2,000 requested refund |
| ENR003 | Withdrawn enrolment with one Present attendance record and KES 3,000 approved but unpaid refund |
| ENR004 | KES 5,000 rejected refund; rejection does not reduce the outstanding course balance |
| ENR005 | Enquiry enrolment with no payment after the temporary test was rolled back |
| ENR007 | Attendance includes Present, Absent and Excused records |

For ENR002, the KES 5,000 overpayment is fully accounted for by the KES 3,000 paid refund and KES 2,000 requested refund.

A requested refund is not treated as approved or paid.

## 12. Refund Eligibility Test

A never-attended withdrawal test was completed using a transaction.

### Test scenario

- ENR005 initially had Enquiry status.
- It had no previous payments.
- It had no attendance records.
- A temporary KES 10,000 payment was inserted.
- The enrolment was moved to Withdrawn.
- The maximum refund eligibility was calculated.

### Result

| Measure | Expected | Actual |
|---|---:|---:|
| Temporary payment | KES 10,000 | KES 10,000 |
| Retention | KES 2,500 | KES 2,500 |
| Maximum refund eligibility | KES 7,500 | KES 7,500 |
| Refund created | No | No |
| Refund approved or paid | No | No |

The transaction was rolled back.

Final verification confirmed:

- ENR005 returned to Enquiry.
- Its total payment remained zero.
- No temporary test payment remained.
- No refund was created.

This test demonstrated transaction control, rollback, CTEs, conditional aggregation, `COALESCE` and `GREATEST`.

## 13. Weekly Attendance Reporting

The weekly attendance report is:

`sql/13_weekly_attendance_report.sql`

The report groups attendance by enrolment and course-relative week.

Examples from the recorded dataset:

- ENR003: one Present record in week 1.
- ENR007: three Present, one Absent and one Excused record in week 1.

For ENR007:

- Attendance rate excluding Excused records: 75%.
- Attendance rate including Excused records in the denominator: 60%.

The difference demonstrates why reporting definitions must be documented and consistently applied.

## 14. Project Documentation

The `docs/` directory contains supporting technical documentation.

| Document | Purpose |
|---|---|
| `setup_and_configuration.md` | Environment and database setup |
| `data_dictionary.md` | Database tables, fields and data definitions |
| `database_design.md` | Database relationships and design decisions |
| `execution_log.md` | Records script execution and test results |
| `troubleshooting.md` | Records technical problems and solutions |
| `learning_notes.md` | Captures SQL concepts and practical learning |
| `decisions_and_corrections.md` | Records business rules, corrections and design decisions |

These documents are part of the portfolio because they explain not only what was built, but also why particular decisions were made.

## 15. Linux Terminal Command Dictionary

This section records the main Linux commands and command patterns used during the project.

The examples are based on the project workflow. Some commands are shown as reusable learning patterns; they are not all evidence of having been executed already.

### 15.1 Navigation and file listing

| Command | Meaning | Example |
|---|---|---|
| `pwd` | Prints the current working directory | `pwd` |
| `cd` | Changes directory | `cd ~/Desktop` |
| `ls` | Lists files and directories | `ls` |
| `ls -lah` | Lists files, including hidden files, with details and readable sizes | `ls -lah` |
| `find` | Searches for files and directories | `find . -type f` |
| `sort` | Sorts lines of text | `find . -type f \| sort` |

**Understanding `ls -lah`:**

- `-l`: long listing format, showing permissions, owner, size and date.
- `-a`: includes hidden files such as `.gitignore`.
- `-h`: displays file sizes in readable units such as K and M.

### 15.2 Reading files

| Command | Meaning | Example |
|---|---|---|
| `cat` | Displays the contents of a file | `cat .gitignore` |
| `less` | Opens a file for scrollable reading | `less README.md` |
| `head` | Displays the beginning of a file | `head -n 20 README.md` |
| `tail` | Displays the end of a file | `tail -n 30 docs/learning_notes.md` |
| `sed -n` | Prints selected lines without automatically displaying the entire file | `sed -n '285,430p' README.md` |

**Understanding `sed -n '285,430p' README.md`:**

- `sed`: stream editor.
- `-n`: disables automatic printing of every line.
- `285,430`: selects lines 285 through 430.
- `p`: prints the selected lines.
- `README.md`: the file being inspected.

This is useful when a document is long and only one section needs to be inspected.

### 15.3 Searching files and text

| Command | Meaning | Example |
|---|---|---|
| `grep` | Searches for text patterns | `grep 'Project Status' README.md` |
| `grep -n` | Shows matching line numbers | `grep -n 'Project Status' README.md` |
| `grep -i` | Ignores uppercase/lowercase differences | `grep -i 'password' README.md` |
| `grep -E` | Supports extended regular expressions | `grep -E 'cat\|dog' file.txt` |
| `grep -R` | Searches recursively through directories | `grep -Rni 'password' .` |
| `grep -A` | Displays lines after a match | `grep -A 20 'Project Status' README.md` |
| `grep -B` | Displays lines before a match | `grep -B 5 'Project Status' README.md` |
| `grep -nE` | Combines line numbers and extended regular expressions | `grep -nE 'error\|warning' file.log` |

**Understanding the project search command:**

```bash
grep -n -A35 -B3 -E '^## 11\. Project Status|^## 13\. Latest Project Progress' README.md
```

- `grep`: searches text.
- `-n`: displays line numbers.
- `-A35`: displays 35 lines after each matching line.
- `-B3`: displays 3 lines before each matching line.
- `-E`: enables extended regular expressions.
- `^`: matches the beginning of a line.
- `\.`: matches a literal full stop.
- `|`: means OR in the regular expression.

This command finds two README headings and displays enough surrounding content to inspect them.

### 15.4 File discovery with `find`

| Command | Meaning | Example |
|---|---|---|
| `find . -type f` | Finds files below the current directory | `find . -type f` |
| `find . -type d` | Finds directories | `find . -type d` |
| `find . -maxdepth 3 -type f` | Searches files up to three directory levels deep | `find . -maxdepth 3 -type f` |
| `find . -name "*.sql"` | Finds files ending in `.sql` | `find . -name "*.sql"` |
| `find . -printf '%p\n'` | Prints each matching file path | `find . -type f -printf '%p\n'` |

**Project backup check:**

```bash
find . -type f \( -name "*.save" -o -name "*.bak" -o -name "*.backup" -o -name "*.dump" -o -name "*.sql~" \) -print
```

This searches for unwanted backup and database export files.

- `\(` and `\)` group conditions.
- `-name` checks a filename pattern.
- `-o` means OR.
- `-print` displays matching paths.

### 15.5 Editing and deleting files

| Command | Meaning | Example |
|---|---|---|
| `nano` | Opens a terminal text editor | `nano README.md` |
| `rm` | Deletes files | `rm sql/02_sample_data.sql.save` |
| `sed -i` | Edits a file in place | `sed -i 's/old/new/' file.txt` |

**Important:** `rm` deletes files. Always confirm the filename before running it.

`sed -i` changes the actual file, unlike `sed -n`, which was used to inspect selected lines.

### 15.6 Pipes and command combinations

A pipe (`|`) sends the output of one command into another command.

Example:

```bash
find . -type f -printf '%p\n' | sort
```

What happens:

1. `find` discovers files.
2. `-printf` displays their paths.
3. `|` passes the output to the next command.
4. `sort` arranges the paths alphabetically.

Another example:

```bash
grep -Rni 'password' --exclude-dir=.git .
```

This searches the project recursively, ignores letter case, displays line numbers and excludes the Git metadata directory.

### 15.7 PostgreSQL terminal commands

| Command | Meaning |
|---|---|
| `sudo -u postgres psql` | Opens PostgreSQL's interactive terminal as the postgres operating-system user |
| `psql` | Starts the PostgreSQL interactive command-line client |
| `\l` | Lists databases inside psql |
| `\c student_finance_analytics` | Connects to the project database |
| `\dt` | Lists tables in the current database |
| `\d students` | Displays the structure of the students table |
| `\q` | Exits psql |

The commands beginning with a backslash are PostgreSQL psql meta-commands, not ordinary Linux shell commands.

### 15.8 SQL commands are different from Linux commands

Some commands used in this project belong to SQL rather than Linux.

| SQL command or function | Purpose |
|---|---|
| `SELECT` | Retrieves data |
| `INSERT` | Adds records |
| `UPDATE` | Changes records |
| `DELETE` | Deletes records |
| `CREATE TABLE` | Creates a table |
| `ALTER TABLE` | Changes a table structure |
| `JOIN` | Combines related tables |
| `GROUP BY` | Groups records for aggregation |
| `WITH` | Defines a Common Table Expression |
| `COALESCE` | Replaces NULL with a fallback value |
| `GREATEST` | Returns the greatest supplied value |
| `FILTER` | Applies a condition to an aggregate |
| `BEGIN` | Starts a transaction |
| `COMMIT` | Saves a transaction |
| `ROLLBACK` | Reverses uncommitted transaction changes |

The distinction matters: Linux commands manage the development environment and files, while SQL commands manage and analyse database information.

## 16. GitHub Publication Status

The project has been prepared for version control with a `.gitignore` file.

The `.gitignore` excludes:

- Environment files.
- Private keys.
- Database backups and exports.
- Temporary editor files.
- Python virtual environments and caches.
- Log files.

The repository has not yet been confirmed as published to GitHub.

Before publication:

1. Review all files for real personal or institutional information.
2. Confirm that all sample records are synthetic.
3. Review `.gitignore`.
4. Check the staged files before committing.
5. Confirm the GitHub repository and remote before pushing.

## 17. Current Project Status

| Milestone | Status |
|---|---|
| PostgreSQL environment configured | Complete |
| Project database created | Complete |
| Eight relational tables created | Complete |
| Synthetic sample data loaded | Complete |
| Incorrect and corrected reports tested | Complete |
| Data validation suite executed | Complete |
| Refund structures and sample records | Complete |
| Payment and attendance triggers | Complete |
| Attendance date validation | Complete |
| Weekly attendance report | Complete |
| Expanded financial summary | Complete |
| Never-attended withdrawal test | Complete |
| Technical documentation | Prepared; final review ongoing |
| Linux command dictionary | Included in this README |
| Power BI dashboard | Future enhancement |
| GitHub repository publication | Pending |

## 18. Learning Outcomes

This project has provided practical experience with:

- Designing a relational PostgreSQL database.
- Understanding primary keys and foreign keys.
- Writing SQL queries across multiple related tables.
- Identifying incorrect aggregate results caused by one-to-many joins.
- Using CTEs to organise complex queries.
- Building validation and reconciliation checks.
- Creating PostgreSQL triggers.
- Applying transaction control and rollback.
- Calculating financial balances and refund eligibility.
- Documenting business rules and technical decisions.
- Using Linux commands to inspect, search, edit and organise project files.

The project also demonstrates the importance of documenting assumptions, separating calculated values from approved financial actions, and validating data before using it for reporting.

## 19. Future Enhancements

Potential next stages include:

1. Publish the verified SQL portfolio to GitHub.
2. Develop a Power BI dashboard using the financial and attendance reports.
3. Build a browser-based administrative interface for adding and viewing records.
4. Introduce secure backend/API access rather than exposing PostgreSQL directly to a browser.
5. Add role-based access for administrators, academic management, trainers, finance and students.
6. Introduce audit trails for sensitive record changes.
7. Expand automated testing and data quality checks.

These are future enhancements, not features currently claimed as complete.

---

**Project:** Student Finance Analytics  
**Database:** PostgreSQL 18.6  
**Environment:** Kali Linux  
**Dataset:** Synthetic portfolio data  
**Last documented project update:** 16 November 2026
