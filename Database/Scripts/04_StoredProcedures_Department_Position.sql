-- =============================================
-- Department & Position Management Stored Procedures
-- =============================================

-- ============= DEPARTMENT PROCEDURES =============

-- Get All Departments
IF OBJECT_ID('dbo.SP_GetAllDepartments', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetAllDepartments;
GO

CREATE PROCEDURE dbo.SP_GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DepartmentId,
        DepartmentCode,
        DepartmentName,
        IsActive,
        CreatedDate,
        UpdatedDate,
        (SELECT COUNT(*) FROM dbo.Employees WHERE DepartmentId = d.DepartmentId AND IsActive = 1) AS EmployeeCount
    FROM dbo.Departments d
    ORDER BY DepartmentName;
END
GO

-- Get Department By Id
IF OBJECT_ID('dbo.SP_GetDepartmentById', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetDepartmentById;
GO

CREATE PROCEDURE dbo.SP_GetDepartmentById
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DepartmentId,
        DepartmentCode,
        DepartmentName,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM dbo.Departments
    WHERE DepartmentId = @DepartmentId;
END
GO

-- Create Department
IF OBJECT_ID('dbo.SP_CreateDepartment', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_CreateDepartment;
GO

CREATE PROCEDURE dbo.SP_CreateDepartment
    @DepartmentCode NVARCHAR(50),
    @DepartmentName NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Departments (DepartmentCode, DepartmentName)
    VALUES (@DepartmentCode, @DepartmentName);

    SELECT SCOPE_IDENTITY() AS DepartmentId;
END
GO

-- Update Department
IF OBJECT_ID('dbo.SP_UpdateDepartment', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_UpdateDepartment;
GO

CREATE PROCEDURE dbo.SP_UpdateDepartment
    @DepartmentId INT,
    @DepartmentCode NVARCHAR(50),
    @DepartmentName NVARCHAR(200),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Departments
    SET
        DepartmentCode = @DepartmentCode,
        DepartmentName = @DepartmentName,
        IsActive = @IsActive,
        UpdatedDate = GETDATE()
    WHERE DepartmentId = @DepartmentId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Delete Department
IF OBJECT_ID('dbo.SP_DeleteDepartment', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_DeleteDepartment;
GO

CREATE PROCEDURE dbo.SP_DeleteDepartment
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if department has employees
    IF EXISTS (SELECT 1 FROM dbo.Employees WHERE DepartmentId = @DepartmentId)
    BEGIN
        -- Soft delete
        UPDATE dbo.Departments
        SET IsActive = 0, UpdatedDate = GETDATE()
        WHERE DepartmentId = @DepartmentId;
    END
    ELSE
    BEGIN
        -- Hard delete if no employees
        DELETE FROM dbo.Departments WHERE DepartmentId = @DepartmentId;
    END

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ============= POSITION PROCEDURES =============

-- Get All Positions
IF OBJECT_ID('dbo.SP_GetAllPositions', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetAllPositions;
GO

CREATE PROCEDURE dbo.SP_GetAllPositions
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PositionId,
        p.PositionCode,
        p.PositionName,
        p.DepartmentId,
        d.DepartmentName,
        p.IsActive,
        p.CreatedDate,
        p.UpdatedDate,
        (SELECT COUNT(*) FROM dbo.Employees WHERE PositionId = p.PositionId AND IsActive = 1) AS EmployeeCount
    FROM dbo.Positions p
    INNER JOIN dbo.Departments d ON p.DepartmentId = d.DepartmentId
    ORDER BY d.DepartmentName, p.PositionName;
END
GO

-- Get Position By Id
IF OBJECT_ID('dbo.SP_GetPositionById', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetPositionById;
GO

CREATE PROCEDURE dbo.SP_GetPositionById
    @PositionId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PositionId,
        p.PositionCode,
        p.PositionName,
        p.DepartmentId,
        d.DepartmentName,
        p.IsActive,
        p.CreatedDate,
        p.UpdatedDate
    FROM dbo.Positions p
    INNER JOIN dbo.Departments d ON p.DepartmentId = d.DepartmentId
    WHERE p.PositionId = @PositionId;
END
GO

-- Create Position
IF OBJECT_ID('dbo.SP_CreatePosition', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_CreatePosition;
GO

CREATE PROCEDURE dbo.SP_CreatePosition
    @PositionCode NVARCHAR(50),
    @PositionName NVARCHAR(200),
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Positions (PositionCode, PositionName, DepartmentId)
    VALUES (@PositionCode, @PositionName, @DepartmentId);

    SELECT SCOPE_IDENTITY() AS PositionId;
END
GO

-- Update Position
IF OBJECT_ID('dbo.SP_UpdatePosition', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_UpdatePosition;
GO

CREATE PROCEDURE dbo.SP_UpdatePosition
    @PositionId INT,
    @PositionCode NVARCHAR(50),
    @PositionName NVARCHAR(200),
    @DepartmentId INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Positions
    SET
        PositionCode = @PositionCode,
        PositionName = @PositionName,
        DepartmentId = @DepartmentId,
        IsActive = @IsActive,
        UpdatedDate = GETDATE()
    WHERE PositionId = @PositionId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Delete Position
IF OBJECT_ID('dbo.SP_DeletePosition', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_DeletePosition;
GO

CREATE PROCEDURE dbo.SP_DeletePosition
    @PositionId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if position has employees
    IF EXISTS (SELECT 1 FROM dbo.Employees WHERE PositionId = @PositionId)
    BEGIN
        -- Soft delete
        UPDATE dbo.Positions
        SET IsActive = 0, UpdatedDate = GETDATE()
        WHERE PositionId = @PositionId;
    END
    ELSE
    BEGIN
        -- Hard delete if no employees
        DELETE FROM dbo.Positions WHERE PositionId = @PositionId;
    END

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Get Positions By Department
IF OBJECT_ID('dbo.SP_GetPositionsByDepartment', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetPositionsByDepartment;
GO

CREATE PROCEDURE dbo.SP_GetPositionsByDepartment
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PositionId,
        p.PositionCode,
        p.PositionName,
        p.DepartmentId,
        d.DepartmentName,
        p.IsActive,
        p.CreatedDate,
        p.UpdatedDate,
        (SELECT COUNT(*) FROM dbo.Employees WHERE PositionId = p.PositionId AND IsActive = 1) AS EmployeeCount
    FROM dbo.Positions p
    INNER JOIN dbo.Departments d ON p.DepartmentId = d.DepartmentId
    WHERE p.DepartmentId = @DepartmentId
    AND p.IsActive = 1
    ORDER BY p.PositionName;
END
GO

PRINT 'Department and Position stored procedures created successfully';
