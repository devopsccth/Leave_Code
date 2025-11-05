-- =============================================
-- Seed Data for Leave Management System
-- Version: 2.0 - Updated with Department-Position Relationship
-- =============================================

USE master;
GO

PRINT '========================================';
PRINT 'Starting data seeding process...';
PRINT '========================================';

-- =============================================
-- INSERT DEPARTMENTS
-- =============================================
PRINT 'Inserting Departments...';
INSERT INTO dbo.Departments (DepartmentCode, DepartmentName) VALUES
('IT', 'Information Technology'),
('HR', 'Human Resources'),
('FIN', 'Finance'),
('MKT', 'Marketing'),
('OPS', 'Operations');

PRINT 'Departments inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-- =============================================
-- INSERT POSITIONS (with DepartmentId)
-- =============================================
PRINT 'Inserting Positions...';

-- IT Department Positions
INSERT INTO dbo.Positions (PositionCode, PositionName, DepartmentId)
SELECT 'IT-MGR', 'IT Manager', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'IT'
UNION ALL
SELECT 'IT-DEV', 'Developer', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'IT'
UNION ALL
SELECT 'IT-LEAD', 'Technical Lead', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'IT';

-- HR Department Positions
INSERT INTO dbo.Positions (PositionCode, PositionName, DepartmentId)
SELECT 'HR-MGR', 'HR Manager', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'HR'
UNION ALL
SELECT 'HR-SP', 'HR Specialist', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'HR'
UNION ALL
SELECT 'HR-ADM', 'HR Administrator', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'HR';

-- Finance Department Positions
INSERT INTO dbo.Positions (PositionCode, PositionName, DepartmentId)
SELECT 'FIN-MGR', 'Finance Manager', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'FIN'
UNION ALL
SELECT 'FIN-ACC', 'Accountant', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'FIN'
UNION ALL
SELECT 'FIN-ANA', 'Financial Analyst', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'FIN';

-- Marketing Department Positions
INSERT INTO dbo.Positions (PositionCode, PositionName, DepartmentId)
SELECT 'MKT-MGR', 'Marketing Manager', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'MKT'
UNION ALL
SELECT 'MKT-SP', 'Marketing Specialist', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'MKT'
UNION ALL
SELECT 'MKT-DES', 'Graphic Designer', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'MKT';

-- Operations Department Positions
INSERT INTO dbo.Positions (PositionCode, PositionName, DepartmentId)
SELECT 'OPS-MGR', 'Operations Manager', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'OPS'
UNION ALL
SELECT 'OPS-SUP', 'Operations Supervisor', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'OPS'
UNION ALL
SELECT 'OPS-COORD', 'Operations Coordinator', DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'OPS';

PRINT 'Positions inserted: 15';
GO

-- =============================================
-- INSERT EMPLOYEES
-- =============================================
PRINT 'Inserting Employees...';

-- Password: Password123! (hashed with BCrypt)
-- In production, use proper BCrypt hashing
DECLARE @PasswordHash NVARCHAR(500) = 'AQAAAAIAAYagAAAAEKxqVqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

-- System Admin (HR Department)
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, Role
)
SELECT
    'EMP001', 'admin@company.com', @PasswordHash, 'Admin', 'User', 'Other', '2020-01-01',
    d.DepartmentId, p.PositionId, 'Admin'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'HR' AND p.PositionCode = 'HR-ADM';

-- HR Manager
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, Role
)
SELECT
    'EMP002', 'hr.manager@company.com', @PasswordHash, 'สมชาย', 'ใจดี', 'Male', '2019-01-01',
    d.DepartmentId, p.PositionId, 'HR'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'HR' AND p.PositionCode = 'HR-MGR';

-- IT Manager
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, ManagerId, Role
)
SELECT
    'EMP003', 'it.manager@company.com', @PasswordHash, 'สมหญิง', 'รักงาน', 'Female', '2019-06-01',
    d.DepartmentId, p.PositionId, 1, 'Manager'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'IT' AND p.PositionCode = 'IT-MGR';

-- IT Developers
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, ManagerId, Role
)
SELECT
    'EMP004', 'dev1@company.com', @PasswordHash, 'นายพัฒน์', 'โค้ดดี', 'Male', '2021-03-15',
    d.DepartmentId, p.PositionId, 3, 'Employee'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'IT' AND p.PositionCode = 'IT-DEV';

INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, ManagerId, Role
)
SELECT
    'EMP005', 'dev2@company.com', @PasswordHash, 'นางสาวกมล', 'เขียนเก่ง', 'Female', '2022-07-01',
    d.DepartmentId, p.PositionId, 3, 'Employee'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'IT' AND p.PositionCode = 'IT-DEV';

-- Finance Manager
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, ManagerId, Role
)
SELECT
    'EMP006', 'fin.manager@company.com', @PasswordHash, 'นายสมบูรณ์', 'เงินพอ', 'Male', '2018-01-01',
    d.DepartmentId, p.PositionId, 1, 'Manager'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'FIN' AND p.PositionCode = 'FIN-MGR';

-- Accountant
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, ManagerId, Role
)
SELECT
    'EMP007', 'accountant@company.com', @PasswordHash, 'นางสาววิไล', 'บัญชีชัด', 'Female', '2020-05-01',
    d.DepartmentId, p.PositionId, 6, 'Employee'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'FIN' AND p.PositionCode = 'FIN-ACC';

-- Marketing Manager
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, ManagerId, Role
)
SELECT
    'EMP008', 'mkt.manager@company.com', @PasswordHash, 'นางสุดา', 'ขายดี', 'Female', '2019-03-01',
    d.DepartmentId, p.PositionId, 1, 'Manager'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'MKT' AND p.PositionCode = 'MKT-MGR';

-- Operations Manager
INSERT INTO dbo.Employees (
    EmployeeCode, Email, PasswordHash, FirstName, LastName, Gender, HireDate,
    DepartmentId, PositionId, ManagerId, Role
)
SELECT
    'EMP009', 'ops.manager@company.com', @PasswordHash, 'นายประสิทธิ์', 'ทำงานเร็ว', 'Male', '2019-09-01',
    d.DepartmentId, p.PositionId, 1, 'Manager'
FROM dbo.Departments d
CROSS JOIN dbo.Positions p
WHERE d.DepartmentCode = 'OPS' AND p.PositionCode = 'OPS-MGR';

PRINT 'Employees inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-- =============================================
-- INSERT LEAVE TYPES
-- =============================================
PRINT 'Inserting Leave Types...';

INSERT INTO dbo.LeaveTypes (
    LeaveTypeCode, LeaveTypeName, Description, DefaultDays,
    IsProRated, RequiresGender, ApplicableGender, IsPaidLeave, RequiresDocumentation
) VALUES
('ANNUAL', 'วันลาพักร้อน', 'วันลาพักร้อนประจำปี คำนวณแบบ Pro-rate ตามอายุงาน (พนักงาน 5 ปีขึ้นไป ได้ 10 วันในปีถัดไป)', 10, 1, 0, NULL, 1, 0),
('SICK', 'วันลาป่วย', 'วันลาป่วย มีสิทธิ์ 30 วันต่อปี', 30, 0, 0, NULL, 1, 0),
('PERSONAL', 'วันลากิจ', 'วันลากิจส่วนตัว คำนวณแบบ Pro-rate', 3, 1, 0, NULL, 1, 0),
('MATERNITY', 'วันลาคลอดบุตร', 'วันลาคลอดบุตรสำหรับพนักงานหญิง 90 วัน', 90, 0, 1, 'Female', 1, 1),
('PATERNITY', 'วันลาเพื่อเลี้ยงดูบุตร', 'วันลาเพื่อเลี้ยงดูบุตรสำหรับพนักงานชาย 15 วัน', 15, 0, 1, 'Male', 1, 0),
('MARRIAGE', 'วันลาเพื่อทำการสมรส', 'วันลาเพื่อทำการสมรส 3 วัน', 3, 0, 0, NULL, 1, 0),
('ORDINATION', 'วันลาบวช', 'วันลาเพื่อบวชสำหรับพนักงานชาย 15 วัน', 15, 0, 1, 'Male', 1, 0),
('BEREAVEMENT', 'วันลาเพื่อการศพ', 'วันลาเพื่อไปงานศพญาติใกล้ชิด 3 วัน', 3, 0, 0, NULL, 1, 0);

PRINT 'Leave Types inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-- =============================================
-- CALCULATE AND INSERT LEAVE BALANCES
-- =============================================
PRINT 'Calculating Leave Balances for current year...';

DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @EmployeeId INT, @HireDate DATE, @Gender NVARCHAR(10);
DECLARE @ProRateDays DECIMAL(5,2);
DECLARE @BalanceCount INT = 0;

DECLARE employee_cursor CURSOR FOR
SELECT EmployeeId, HireDate, Gender FROM dbo.Employees WHERE IsActive = 1;

OPEN employee_cursor;
FETCH NEXT FROM employee_cursor INTO @EmployeeId, @HireDate, @Gender;

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
    -- If 5 years or more, entitled to 10 days, otherwise pro-rated
    DECLARE @AnnualDays DECIMAL(5,2) = CASE
        WHEN @YearsOfService >= 5 THEN 10
        ELSE (10.0 / 12.0) * @MonthsInYear
    END;

    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays, YearsOfService, ProRateCalculation)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, @AnnualDays, @AnnualDays, @YearsOfService, @AnnualDays
    FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'ANNUAL';
    SET @BalanceCount = @BalanceCount + @@ROWCOUNT;

    -- Personal Leave (Pro-rated)
    DECLARE @PersonalDays DECIMAL(5,2) = (3.0 / 12.0) * @MonthsInYear;

    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays, ProRateCalculation)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, @PersonalDays, @PersonalDays, @PersonalDays
    FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'PERSONAL';
    SET @BalanceCount = @BalanceCount + @@ROWCOUNT;

    -- Sick Leave (Not pro-rated)
    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, DefaultDays, DefaultDays
    FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'SICK';
    SET @BalanceCount = @BalanceCount + @@ROWCOUNT;

    -- Gender-specific leaves (if applicable)
    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
    SELECT @EmployeeId, lt.LeaveTypeId, @CurrentYear, lt.DefaultDays, lt.DefaultDays
    FROM dbo.LeaveTypes lt
    WHERE lt.RequiresGender = 1 AND lt.ApplicableGender = @Gender;
    SET @BalanceCount = @BalanceCount + @@ROWCOUNT;

    -- Other leaves (Marriage, Bereavement, Ordination)
    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
    SELECT @EmployeeId, LeaveTypeId, @CurrentYear, DefaultDays, DefaultDays
    FROM dbo.LeaveTypes
    WHERE LeaveTypeCode IN ('MARRIAGE', 'BEREAVEMENT', 'ORDINATION')
    AND (RequiresGender = 0 OR ApplicableGender = @Gender)
    AND NOT EXISTS (
        SELECT 1 FROM dbo.LeaveBalances
        WHERE EmployeeId = @EmployeeId
        AND LeaveTypeId = dbo.LeaveTypes.LeaveTypeId
        AND Year = @CurrentYear
    );
    SET @BalanceCount = @BalanceCount + @@ROWCOUNT;

    FETCH NEXT FROM employee_cursor INTO @EmployeeId, @HireDate, @Gender;
END

CLOSE employee_cursor;
DEALLOCATE employee_cursor;

PRINT 'Leave Balances inserted: ' + CAST(@BalanceCount AS NVARCHAR(10));
GO

PRINT '========================================';
PRINT 'Data seeding completed successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '- Departments: 5';
PRINT '- Positions: 15';
PRINT '- Employees: 9';
PRINT '- Leave Types: 8';
PRINT '- Leave Balances: Calculated for all employees';
PRINT '';
PRINT 'Default Login Credentials:';
PRINT 'Email: admin@company.com';
PRINT 'Password: Password123!';
PRINT '========================================';
GO
