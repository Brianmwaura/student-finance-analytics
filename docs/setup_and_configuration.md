# Setup and Configuration

## 1. Project Environment

| Item | Configuration |
|---|---|
| Operating system | Kali Linux |
| Database | PostgreSQL |
| PostgreSQL version | 18.6 |
| PostgreSQL cluster | 18/main |
| Port | 5432 |
| Database name | student_finance_analytics |
| Project directory | `~/Desktop/Win_Folder/student-finance-analytics` |

## 2. Starting PostgreSQL

Start the PostgreSQL 18 cluster:

```bash
sudo pg_ctlcluster 18 main start
```

Enable PostgreSQL startup through systemd:

```bash
sudo systemctl enable postgresql
```

Verify the cluster:

```bash
sudo pg_lsclusters
```

Expected verified state:

- PostgreSQL version: 18
- Cluster: main
- Port: 5432
- Status: online

Check whether PostgreSQL accepts connections:

```bash
pg_isready
```

## 3. Database Creation

Connect as the PostgreSQL administrator:

```bash
sudo -u postgres psql
```

Create the project database:

```sql
CREATE DATABASE student_finance_analytics;
```

Verify that it exists:

```bash
sudo -u postgres psql -Atc "SELECT datname FROM pg_database WHERE datname = 'student_finance_analytics';"
```

## 4. PostgreSQL Collation Version Issue

### Problem encountered

PostgreSQL initially reported a collation version mismatch:

- Database recorded version: 2.42
- Operating system provided version: 2.43

The first attempt to create the project database failed because the template database had a collation version mismatch.

### Resolution steps performed

Connected to the template database:

```bash
sudo -u postgres psql -d template1
```

Executed:

```sql
REINDEX DATABASE template1;
ALTER DATABASE template1 REFRESH COLLATION VERSION;
```

The PostgreSQL `postgres` database was also reindexed and its collation version refreshed:

```sql
REINDEX DATABASE postgres;
ALTER DATABASE postgres REFRESH COLLATION VERSION;
```

The project database was subsequently created successfully.

**Learning point:** Collation controls how text is sorted and compared. When the operating system's collation library changes, PostgreSQL may require affected database indexes to be rebuilt and the recorded collation version refreshed.

## 5. PostgreSQL 17 Cluster Removal

The PostgreSQL 17 cluster was removed:

```bash
sudo pg_dropcluster --stop 17 main
```

Verification showed PostgreSQL 18/main online.

**Important:** Removing the PostgreSQL 17 cluster does not necessarily uninstall the PostgreSQL 17 software package. Package removal has not been verified in this project log.

## 6. Creating the Project Tables

Navigate to the project directory:

```bash
cd ~/Desktop/Win_Folder/student-finance-analytics
```

Execute the schema file:

```bash
sudo -u postgres psql -v ON_ERROR_STOP=1 --single-transaction -d student_finance_analytics -f sql/01_schema.sql
```

Command explanation:

- `sudo -u postgres`: execute as the PostgreSQL administrator.
- `psql`: PostgreSQL command-line client.
- `-v ON_ERROR_STOP=1`: stop execution if an SQL error occurs.
- `--single-transaction`: execute the script as one transaction.
- `-d`: specify the target database.
- `-f`: read SQL commands from the specified file.

Verify the tables:

```bash
sudo -u postgres psql -d student_finance_analytics -c "\dt"
```

Six tables were confirmed:

1. students
2. student_documents
3. courses
4. course_intakes
5. enrolments
6. payments

## 7. Current Configuration Status

| Component | Status |
|---|---|
| PostgreSQL 18 cluster | Verified online |
| Project database | Verified created |
| Six database tables | Verified created |
| Schema file | Created and executed |
| Sample data | Pending |
| Reporting queries | Pending |
| Validation tests | Pending |
| Power BI connection | Future stage |

## 8. Important Data Protection Rule

This is a portfolio project.

Use fictional student names, synthetic contact details and fictional payment records. Do not upload real student, employee, identity-document or financial information to GitHub.
