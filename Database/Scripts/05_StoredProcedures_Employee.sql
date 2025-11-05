-- =============================================
-- Employee Management Stored Procedures
-- =============================================

-- Get All Employees
IF OBJECT_ID('dbo.SP_GetAllEmployees', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetAllEmployees;
GO

CREATE PROCEDURE dbo.SP_GetAllEmployees
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.Email,
        e.FirstName,
        e.LastName,
        e.Gender,
        e.DateOfBirth,
        e.HireDate,
        e.DepartmentId,
        d.DepartmentName,
        e.PositionId,
        p.PositionName,
        e.ManagerId,
        CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName,
        e.Role,
        e.IsActive,
        e.CreatedDate,
        e.LastLoginDate
    FROM dbo.Employees e
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    LEFT JOIN dbo.Employees m ON e.ManagerId = m.EmployeeId
    ORDER BY e.EmployeeCode;
END
GO

-- Get Employee By Id
IF OBJECT_ID('dbo.SP_GetEmployeeById', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetEmployeeById;
GO

CREATE PROCEDURE dbo.SP_GetEmployeeById
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.Email,
        e.FirstName,
        e.LastName,
        e.Gender,
        e.DateOfBirth,
        e.HireDate,
        e.DepartmentId,
        d.DepartmentName,
        e.PositionId,
        p.PositionName,
        e.ManagerId,
        CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName,
        e.Role,
        e.IsActive,
        e.CreatedDate,
        e.UpdatedDate,
        e.LastLoginDate
    FROM dbo.Employees e
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    LEFT JOIN dbo.Employees m ON e.ManagerId = m.EmployeeId
    WHERE e.EmployeeId = @EmployeeId;
END
GO

-- Get Employees By Manager
IF OBJECT_ID('dbo.SP_GetEmployeesByManager', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetEmployeesByManager;
GO

CREATE PROCEDURE dbo.SP_GetEmployeesByManager
    @ManagerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.Email,
        e.FirstName,
        e.LastName,
        e.Gender,
        e.HireDate,
        e.DepartmentId,
        d.DepartmentName,
        e.PositionId,
        p.PositionName,
        e.Role,
        e.IsActive
    FROM dbo.Employees e
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    WHERE e.ManagerId = @ManagerId AND e.IsActive = 1
    ORDER BY e.EmployeeCode;
END
GO

-- Create Employee
IF OBJECT_ID('dbo.SP_CreateEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_CreateEmployee;
GO

CREATE PROCEDURE dbo.SP_CreateEmployee
    @EmployeeCode NVARCHAR(50),
    @Email NVARCHAR(200),
    @PasswordHash NVARCHAR(500),
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Gender NVARCHAR(10),
    @DateOfBirth DATE,
    @HireDate DATE,
    @DepartmentId INT,
    @PositionId INT,
    @ManagerId INT,
    @Role NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert Employee
        INSERT INTO dbo.Employees (
            EmployeeCode, Email, PasswordHash, FirstName, LastName,
            Gender, DateOfBirth, HireDate, DepartmentId, PositionId,
            ManagerId, Role
        )
        VALUES (
            @EmployeeCode, @Email, @PasswordHash, @FirstName, @LastName,
            @Gender, @DateOfBirth, @HireDate, @DepartmentId, @PositionId,
            @ManagerId, @Role
        );

        DECLARE @NewEmployeeId INT = SCOPE_IDENTITY();

        -- Initialize Leave Balances for current year
        DECLARE @CurrentYear INT = YEAR(GETDATE());
        DECLARE @MonthsInYear INT = 13 - MONTH(@HireDate);
        DECLARE @YearsOfService INT = DATEDIFF(YEAR, @HireDate, GETDATE());

        -- Annual Leave (Pro-rated)
        DECLARE @AnnualDays DECIMAL(5,2) = (10.0 / 12.0) * @MonthsInYear;
        INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays, ProRateCalculation, YearsOfService)
        SELECT @NewEmployeeId, LeaveTypeId, @CurrentYear, @AnnualDays, @AnnualDays, @AnnualDays, @YearsOfService
        FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'ANNUAL';

        -- Personal Leave (Pro-rated)
        DECLARE @PersonalDays DECIMAL(5,2) = (3.0 / 12.0) * @MonthsInYear;
        INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays, ProRateCalculation)
        SELECT @NewEmployeeId, LeaveTypeId, @CurrentYear, @PersonalDays, @PersonalDays, @PersonalDays
        FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'PERSONAL';

        -- Sick Leave and other leaves
        INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
        SELECT @NewEmployeeId, LeaveTypeId, @CurrentYear, DefaultDays, DefaultDays
        FROM dbo.LeaveTypes
        WHERE LeaveTypeCode NOT IN ('ANNUAL', 'PERSONAL')
        AND (RequiresGender = 0 OR ApplicableGender = @Gender);

        COMMIT TRANSACTION;

        SELECT @NewEmployeeId AS EmployeeId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Update Employee
IF OBJECT_ID('dbo.SP_UpdateEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_UpdateEmployee;
GO

CREATE PROCEDURE dbo.SP_UpdateEmployee
    @EmployeeId INT,
    @EmployeeCode NVARCHAR(50),
    @Email NVARCHAR(200),
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Gender NVARCHAR(10),
    @DateOfBirth DATE,
    @HireDate DATE,
    @DepartmentId INT,
    @PositionId INT,
    @ManagerId INT,
    @Role NVARCHAR(50),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Employees
    SET
        EmployeeCode = @EmployeeCode,
        Email = @Email,
        FirstName = @FirstName,
        LastName = @LastName,
        Gender = @Gender,
        DateOfBirth = @DateOfBirth,
        HireDate = @HireDate,
        DepartmentId = @DepartmentId,
        PositionId = @PositionId,
        ManagerId = @ManagerId,
        Role = @Role,
        IsActive = @IsActive,
        UpdatedDate = GETDATE()
    WHERE EmployeeId = @EmployeeId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Delete Employee (Soft Delete)
IF OBJECT_ID('dbo.SP_DeleteEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_DeleteEmployee;
GO

CREATE PROCEDURE dbo.SP_DeleteEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Employees
    SET IsActive = 0,
        UpdatedDate = GETDATE()
    WHERE EmployeeId = @EmployeeId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

PRINT 'Employee stored procedures created successfully';
