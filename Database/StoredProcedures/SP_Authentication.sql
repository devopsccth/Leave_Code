-- =============================================
-- Authentication Stored Procedures
-- =============================================

-- Login / Validate User
IF OBJECT_ID('dbo.SP_ValidateUser', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_ValidateUser;
GO

CREATE PROCEDURE dbo.SP_ValidateUser
    @Email NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.Email,
        e.PasswordHash,
        e.FirstName,
        e.LastName,
        e.Gender,
        e.DepartmentId,
        e.PositionId,
        e.ManagerId,
        e.Role,
        e.IsActive,
        d.DepartmentName,
        p.PositionName,
        CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName
    FROM dbo.Employees e
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    LEFT JOIN dbo.Employees m ON e.ManagerId = m.EmployeeId
    WHERE e.Email = @Email AND e.IsActive = 1;
END
GO

-- Update Last Login Date
IF OBJECT_ID('dbo.SP_UpdateLastLogin', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_UpdateLastLogin;
GO

CREATE PROCEDURE dbo.SP_UpdateLastLogin
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Employees
    SET LastLoginDate = GETDATE()
    WHERE EmployeeId = @EmployeeId;
END
GO

-- Change Password
IF OBJECT_ID('dbo.SP_ChangePassword', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_ChangePassword;
GO

CREATE PROCEDURE dbo.SP_ChangePassword
    @EmployeeId INT,
    @NewPasswordHash NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Employees
    SET PasswordHash = @NewPasswordHash,
        UpdatedDate = GETDATE()
    WHERE EmployeeId = @EmployeeId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

PRINT 'Authentication stored procedures created successfully';
