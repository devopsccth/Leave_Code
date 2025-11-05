-- =============================================
-- DEPRECATED - DO NOT USE THIS FILE
-- =============================================
--
-- This file is from version 1.0 and is no longer compatible
-- with the current database schema.
--
-- USE INSTEAD: 02_SeedData_Updated.sql
--
-- Reason: This file inserts Positions without DepartmentId,
-- which will fail with the new schema that requires DepartmentId.
--
-- =============================================

-- Seed Data for Leave Management System (DEPRECATED - v1.0)

-- Insert Departments
INSERT INTO dbo.Departments (DepartmentCode, DepartmentName) VALUES
('IT', 'Information Technology'),
('HR', 'Human Resources'),
('FIN', 'Finance'),
('MKT', 'Marketing'),
('OPS', 'Operations');

-- Insert Positions
INSERT INTO dbo.Positions (PositionCode, PositionName) VALUES
('MGR', 'Manager'),
('DEV', 'Developer'),
('HR-SP', 'HR Specialist'),
('ACC', 'Accountant'),
('MKT-SP', 'Marketing Specialist'),
('ADM', 'Administrator');

-- Insert Employees
-- Password: Password123! (hashed - in real implementation, use proper password hashing)
-- For demo purposes, using a simple hash representation
DECLARE @PasswordHash NVARCHAR(500) = 'AQAAAAIAAYagAAAAEKxqVqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; -- BCrypt hash

-- HR Admin
INSERT INTO dbo.Employees (EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate, DepartmentId, PositionId, Role) VALUES
('EMP001', 'admin@company.com', @PasswordHash, 'Admin', 'User', 'Other', '2020-01-01', 2, 6, 'Admin');

-- HR Manager
INSERT INTO dbo.Employees (EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate, DepartmentId, PositionId, Role) VALUES
('EMP002', 'hr.manager@company.com', @PasswordHash, 'สมชาย', 'ใจดี', 'Male', '2019-01-01', 2, 1, 'HR');

-- IT Manager
INSERT INTO dbo.Employees (EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate, DepartmentId, PositionId, ManagerId, Role) VALUES
('EMP003', 'it.manager@company.com', @PasswordHash, 'สมหญิง', 'รักงาน', 'Female', '2019-06-01', 1, 1, 1, 'Manager');

-- IT Developers
INSERT INTO dbo.Employees (EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate, DepartmentId, PositionId, ManagerId, Role) VALUES
('EMP004', 'dev1@company.com', @PasswordHash, 'นายพัฒน์', 'โค้ดดี', 'Male', '2021-03-15', 1, 2, 3, 'Employee'),
('EMP005', 'dev2@company.com', @PasswordHash, 'นางสาวกมล', 'เขียนเก่ง', 'Female', '2022-07-01', 1, 2, 3, 'Employee');

-- Finance Manager and Staff
INSERT INTO dbo.Employees (EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate, DepartmentId, PositionId, ManagerId, Role) VALUES
('EMP006', 'fin.manager@company.com', @PasswordHash, 'นายสมบูรณ์', 'เงินพอ', 'Male', '2018-01-01', 3, 1, 1, 'Manager'),
('EMP007', 'accountant@company.com', @PasswordHash, 'นางสาววิไล', 'บัญชีชัด', 'Female', '2020-05-01', 3, 4, 6, 'Employee');

-- Insert Leave Types
INSERT INTO dbo.LeaveTypes (LeaveTypeCode, LeaveTypeName, Description, DefaultDays, IsProRated, RequiresGender, ApplicableGender) VALUES
('ANNUAL', 'วันลาพักร้อน', 'วันลาพักร้อนประจำปี คำนวณแบบ Pro-rate ตามอายุงาน', 10, 1, 0, NULL),
('SICK', 'วันลาป่วย', 'วันลาป่วย มีสิทธิ์ 30 วันต่อปี', 30, 0, 0, NULL),
('PERSONAL', 'วันลากิจ', 'วันลากิจส่วนตัว คำนวณแบบ Pro-rate', 3, 1, 0, NULL),
('MATERNITY', 'วันลาคลอดบุตร', 'วันลาคลอดบุตรสำหรับพนักงานหญิง 90 วัน', 90, 0, 1, 'Female'),
('PATERNITY', 'วันลาเพื่อเลี้ยงดูบุตร', 'วันลาเพื่อเลี้ยงดูบุตรสำหรับพนักงานชาย 15 วัน', 15, 0, 1, 'Male'),
('MARRIAGE', 'วันลาเพื่อทำการสมรส', 'วันลาเพื่อทำการสมรส 3 วัน', 3, 0, 0, NULL),
('ORDINATION', 'วันลาบวช', 'วันลาเพื่อบวชสำหรับพนักงานชาย 15 วัน', 15, 0, 1, 'Male'),
('BEREAVEMENT', 'วันลาเพื่อการศพ', 'วันลาเพื่อไปงานศพญาติใกล้ชิด 3 วัน', 3, 0, 0, NULL);

-- Insert Leave Balances for current year (2025)
DECLARE @CurrentYear INT = YEAR(GETDATE());

-- Calculate pro-rated days for employees based on hire date
DECLARE @EmployeeId INT, @HireDate DATE, @ProRateDays DECIMAL(5,2);

DECLARE employee_cursor CURSOR FOR
SELECT EmployeeId, HireDate FROM dbo.Employees WHERE IsActive = 1;

OPEN employee_cursor;
FETCH NEXT FROM employee_cursor INTO @EmployeeId, @HireDate;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Calculate years of service
    DECLARE @YearsOfService INT = DATEDIFF(YEAR, @HireDate, GETDATE());
    DECLARE @MonthsInYear INT = 12;

    -- If hired in current year, calculate pro-rate
    IF YEAR(@HireDate) = @CurrentYear
    BEGIN
        SET @MonthsInYear = 13 - MONTH(@HireDate);
    END

    -- Annual Leave (Pro-rated)
    -- If 5 years or more, entitled to 10 days next year, otherwise 10 days pro-rated
    DECLARE @AnnualDays DECIMAL(5,2) = CASE
        WHEN @YearsOfService >= 5 THEN 10
        ELSE (10.0 / 12.0) * @MonthsInYear
    END;

    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays, YearsOfService, ProRateCalculation)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, @AnnualDays, @AnnualDays, @YearsOfService, @AnnualDays
    FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'ANNUAL';

    -- Personal Leave (Pro-rated)
    DECLARE @PersonalDays DECIMAL(5,2) = (3.0 / 12.0) * @MonthsInYear;

    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays, ProRateCalculation)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, @PersonalDays, @PersonalDays, @PersonalDays
    FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'PERSONAL';

    -- Sick Leave (Not pro-rated)
    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, DefaultDays, DefaultDays
    FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'SICK';

    -- Gender-specific leaves (if applicable)
    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
    SELECT @EmployeeId, lt.LeaveTypeId, @CurrentYear, lt.DefaultDays, lt.DefaultDays
    FROM dbo.LeaveTypes lt
    INNER JOIN dbo.Employees e ON @EmployeeId = e.EmployeeId
    WHERE lt.RequiresGender = 1 AND (lt.ApplicableGender = e.Gender OR lt.ApplicableGender IS NULL);

    -- Other leaves (Marriage, Bereavement, etc.)
    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, DefaultDays, DefaultDays
    FROM dbo.LeaveTypes
    WHERE LeaveTypeCode IN ('MARRIAGE', 'BEREAVEMENT')
    AND NOT EXISTS (
        SELECT 1 FROM dbo.LeaveBalances
        WHERE EmployeeId = @EmployeeId
        AND LeaveTypeId = dbo.LeaveTypes.LeaveTypeId
        AND Year = @CurrentYear
    );

    FETCH NEXT FROM employee_cursor INTO @EmployeeId, @HireDate;
END

CLOSE employee_cursor;
DEALLOCATE employee_cursor;

PRINT 'Seed data inserted successfully';
