-- =============================================
-- MASTER DEPLOYMENT SCRIPT
-- Leave Management System - Complete Database Setup
-- =============================================
--
-- This script will execute all database scripts in the correct order:
-- 1. Create Schema (Tables, Constraints, Indexes)
-- 2. Seed Initial Data
-- 3. Create Stored Procedures
--
-- Prerequisites:
-- - SQL Server 2019 or later
-- - Database should exist or be created
-- - Execute with appropriate permissions (db_owner or sysadmin)
--
-- Usage:
-- Execute this script from SQL Server Management Studio or sqlcmd
-- =============================================

SET NOCOUNT ON;
GO

PRINT '';
PRINT '=============================================';
PRINT 'LEAVE MANAGEMENT SYSTEM - DATABASE DEPLOYMENT';
PRINT 'Version: 2.0';
PRINT 'Started at: ' + CONVERT(NVARCHAR(30), GETDATE(), 120);
PRINT '=============================================';
PRINT '';

-- =============================================
-- STEP 1: CREATE SCHEMA
-- =============================================
PRINT '-------------------------------------------';
PRINT 'STEP 1: Creating Database Schema';
PRINT '-------------------------------------------';

:r 01_CreateSchema.sql

PRINT 'Schema creation completed.';
PRINT '';

-- =============================================
-- STEP 2: SEED DATA
-- =============================================
PRINT '-------------------------------------------';
PRINT 'STEP 2: Seeding Initial Data';
PRINT '-------------------------------------------';

:r 02_SeedData_Updated.sql

PRINT 'Data seeding completed.';
PRINT '';

-- =============================================
-- STEP 3: CREATE STORED PROCEDURES
-- =============================================
PRINT '-------------------------------------------';
PRINT 'STEP 3: Creating Stored Procedures';
PRINT '-------------------------------------------';

-- Authentication
PRINT '  3.1 Creating Authentication Procedures...';
:r 03_StoredProcedures_Authentication.sql

-- Department & Position
PRINT '  3.2 Creating Department & Position Procedures...';
:r 04_StoredProcedures_Department_Position.sql

-- Employee
PRINT '  3.3 Creating Employee Procedures...';
:r 05_StoredProcedures_Employee.sql

-- Leave Type
PRINT '  3.4 Creating Leave Type Procedures...';
:r 06_StoredProcedures_LeaveType.sql

-- Leave Request
PRINT '  3.5 Creating Leave Request Procedures...';
:r 07_StoredProcedures_LeaveRequest.sql

-- Leave Approval
PRINT '  3.6 Creating Leave Approval Procedures...';
:r 08_StoredProcedures_LeaveApproval.sql

-- Reports
PRINT '  3.7 Creating Report Procedures...';
:r 09_StoredProcedures_Reports.sql

PRINT 'Stored procedures creation completed.';
PRINT '';

-- =============================================
-- DEPLOYMENT VERIFICATION
-- =============================================
PRINT '-------------------------------------------';
PRINT 'DEPLOYMENT VERIFICATION';
PRINT '-------------------------------------------';

-- Count tables
DECLARE @TableCount INT;
SELECT @TableCount = COUNT(*)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
AND TABLE_NAME IN (
    'Departments', 'Positions', 'Employees', 'LeaveTypes',
    'LeaveBalances', 'LeaveRequests', 'LeaveApprovers', 'LeaveApprovalHistory'
);

PRINT 'Tables created: ' + CAST(@TableCount AS NVARCHAR(10)) + ' / 8';

-- Count stored procedures
DECLARE @ProcCount INT;
SELECT @ProcCount = COUNT(*)
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
AND ROUTINE_NAME LIKE 'SP_%';

PRINT 'Stored Procedures created: ' + CAST(@ProcCount AS NVARCHAR(10));

-- Count employees
DECLARE @EmpCount INT;
SELECT @EmpCount = COUNT(*) FROM dbo.Employees;
PRINT 'Employees seeded: ' + CAST(@EmpCount AS NVARCHAR(10));

-- Count departments
DECLARE @DeptCount INT;
SELECT @DeptCount = COUNT(*) FROM dbo.Departments;
PRINT 'Departments seeded: ' + CAST(@DeptCount AS NVARCHAR(10));

-- Count positions
DECLARE @PosCount INT;
SELECT @PosCount = COUNT(*) FROM dbo.Positions;
PRINT 'Positions seeded: ' + CAST(@PosCount AS NVARCHAR(10));

-- Count leave types
DECLARE @LeaveTypeCount INT;
SELECT @LeaveTypeCount = COUNT(*) FROM dbo.LeaveTypes;
PRINT 'Leave Types seeded: ' + CAST(@LeaveTypeCount AS NVARCHAR(10));

PRINT '';
PRINT '=============================================';
PRINT 'DEPLOYMENT COMPLETED SUCCESSFULLY!';
PRINT 'Completed at: ' + CONVERT(NVARCHAR(30), GETDATE(), 120);
PRINT '=============================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Update connection string in appsettings.json';
PRINT '2. Run the .NET application';
PRINT '3. Login with: admin@company.com / Password123!';
PRINT '';
PRINT 'For existing databases, use:';
PRINT '99_Migration_For_Existing_Databases_Only.sql';
PRINT '=============================================';
GO
