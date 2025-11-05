# Database Scripts - Leave Management System

## Overview

This directory contains all database scripts organized in correct execution order for the Leave Management System.

## Script Organization

### Fresh Installation (Recommended)

For new database installations, use these scripts in order:

```
00_MasterDeploy.sql          - Master deployment script (runs all scripts below)
01_CreateSchema.sql          - Creates all tables with final structure
02_SeedData_Updated.sql      - Inserts initial data
03_StoredProcedures_Authentication.sql
04_StoredProcedures_Department_Position.sql
05_StoredProcedures_Employee.sql
06_StoredProcedures_LeaveType.sql
07_StoredProcedures_LeaveRequest.sql
08_StoredProcedures_LeaveApproval.sql
09_StoredProcedures_Reports.sql
```

### Migration for Existing Databases

If you have an existing database from version 1.0:

```
99_Migration_For_Existing_Databases_Only.sql
```

**WARNING:** Only use this migration script if you already have a database created with the old schema (without DepartmentId in Positions table).

## Deployment Methods

### Method 1: Using SQL Server Management Studio (SSMS)

1. Open SSMS and connect to your SQL Server instance
2. Create a new database (if needed):
   ```sql
   CREATE DATABASE LeaveManagementDB;
   GO
   USE LeaveManagementDB;
   GO
   ```
3. Open and execute `00_MasterDeploy.sql`
4. The script will automatically execute all other scripts in order

### Method 2: Using sqlcmd (Command Line)

```bash
# Navigate to the Scripts directory
cd /path/to/Leave_Code/Database/Scripts

# Execute the master deployment script
sqlcmd -S localhost -d LeaveManagementDB -i 00_MasterDeploy.sql
```

### Method 3: Manual Execution (Individual Scripts)

Execute each script manually in the numbered order:

```bash
sqlcmd -S localhost -d LeaveManagementDB -i 01_CreateSchema.sql
sqlcmd -S localhost -d LeaveManagementDB -i 02_SeedData_Updated.sql
sqlcmd -S localhost -d LeaveManagementDB -i 03_StoredProcedures_Authentication.sql
# ... continue with remaining scripts
```

### Method 4: Using Docker

If using Docker Compose:

```bash
# The deployment script will automatically run during container initialization
docker-compose up -d
```

## Database Schema

### Tables Created (8 tables)

1. **Departments** - Organization departments
2. **Positions** - Job positions (linked to departments)
3. **Employees** - Employee information and authentication
4. **LeaveTypes** - Types of leave (Annual, Sick, etc.)
5. **LeaveBalances** - Employee leave balances per year
6. **LeaveRequests** - Leave request records
7. **LeaveApprovers** - Multi-level approval workflow
8. **LeaveApprovalHistory** - Audit trail for approvals

### Key Features

- **Department-Position Relationship**: Each position belongs to a department (1-to-many)
- **Pro-rated Leave Calculation**: Automatic calculation based on hire date
- **5-Year Bonus**: Employees with 5+ years get 10 days annual leave
- **Multi-level Approval**: Support for 1-2 approvers
- **Gender-specific Leaves**: Maternity/Paternity leave
- **Audit Trail**: Complete history of all leave actions

## Default Users

After seeding, the following users are available:

| Email | Password | Role | Department |
|-------|----------|------|------------|
| admin@company.com | Password123! | Admin | HR |
| hr.manager@company.com | Password123! | HR | HR |
| it.manager@company.com | Password123! | Manager | IT |
| dev1@company.com | Password123! | Employee | IT |
| dev2@company.com | Password123! | Employee | IT |
| fin.manager@company.com | Password123! | Manager | Finance |
| accountant@company.com | Password123! | Employee | Finance |
| mkt.manager@company.com | Password123! | Manager | Marketing |
| ops.manager@company.com | Password123! | Manager | Operations |

**IMPORTANT:** Change these passwords in production!

## Verification

After deployment, verify the installation:

```sql
-- Check tables
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Check stored procedures
SELECT ROUTINE_NAME
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;

-- Check data
SELECT 'Departments' AS TableName, COUNT(*) AS RecordCount FROM Departments
UNION ALL
SELECT 'Positions', COUNT(*) FROM Positions
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL
SELECT 'LeaveTypes', COUNT(*) FROM LeaveTypes
UNION ALL
SELECT 'LeaveBalances', COUNT(*) FROM LeaveBalances;
```

Expected results:
- 8 tables
- 40+ stored procedures
- 5 departments
- 15 positions
- 9 employees
- 8 leave types
- Multiple leave balance records

## Troubleshooting

### Issue: "Object already exists" errors

**Solution:** The scripts include DROP statements. If you get errors, manually drop all objects and run again:

```sql
-- Drop all objects (use with caution!)
EXEC sp_MSforeachtable 'DROP TABLE ?'
```

### Issue: "Cannot drop table because it is referenced by a foreign key constraint"

**Solution:** The scripts drop tables in the correct order (child tables first). If you still get errors, disable constraints:

```sql
-- Disable all constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
-- Then drop tables
-- Then re-enable
EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
```

### Issue: Seed data fails with FK constraint errors

**Solution:** Ensure you run `01_CreateSchema.sql` BEFORE `02_SeedData_Updated.sql`. The seed data depends on tables being created first.

### Issue: Stored procedures reference missing objects

**Solution:** Ensure all tables are created before creating stored procedures. Run scripts in numbered order.

## Changes from Version 1.0

### What Changed:

1. **Consolidated Schema**: Positions table now includes DepartmentId from the start
2. **Updated Seed Data**: All positions are linked to departments
3. **Reorganized Scripts**: Clear numbered order for execution
4. **Master Deployment**: Single script to run everything
5. **Better Documentation**: Comprehensive README and comments

### Migration Path:

If you have an existing v1.0 database:
1. Backup your database
2. Run `99_Migration_For_Existing_Databases_Only.sql`
3. Update existing positions to link to departments
4. Re-create stored procedures with `04_StoredProcedures_Department_Position.sql`

## Support

For issues or questions:
1. Check the logs in SQL Server Management Studio
2. Review the error messages carefully
3. Ensure SQL Server version is 2019 or later
4. Verify user has appropriate permissions

## License

This is part of the Leave Management System project.
