-- =============================================
-- Leave Type Management Stored Procedures
-- =============================================

-- Get All Leave Types
IF OBJECT_ID('dbo.SP_GetAllLeaveTypes', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetAllLeaveTypes;
GO

CREATE PROCEDURE dbo.SP_GetAllLeaveTypes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        LeaveTypeId,
        LeaveTypeCode,
        LeaveTypeName,
        Description,
        DefaultDays,
        IsProRated,
        RequiresGender,
        ApplicableGender,
        IsPaidLeave,
        RequiresDocumentation,
        MaxConsecutiveDays,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM dbo.LeaveTypes
    ORDER BY LeaveTypeName;
END
GO

-- Get Leave Type By Id
IF OBJECT_ID('dbo.SP_GetLeaveTypeById', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetLeaveTypeById;
GO

CREATE PROCEDURE dbo.SP_GetLeaveTypeById
    @LeaveTypeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        LeaveTypeId,
        LeaveTypeCode,
        LeaveTypeName,
        Description,
        DefaultDays,
        IsProRated,
        RequiresGender,
        ApplicableGender,
        IsPaidLeave,
        RequiresDocumentation,
        MaxConsecutiveDays,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM dbo.LeaveTypes
    WHERE LeaveTypeId = @LeaveTypeId;
END
GO

-- Get Active Leave Types For Employee (considering gender)
IF OBJECT_ID('dbo.SP_GetLeaveTypesForEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetLeaveTypesForEmployee;
GO

CREATE PROCEDURE dbo.SP_GetLeaveTypesForEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        lt.LeaveTypeId,
        lt.LeaveTypeCode,
        lt.LeaveTypeName,
        lt.Description,
        lt.DefaultDays,
        lt.IsProRated,
        lt.IsPaidLeave,
        ISNULL(lb.RemainingDays, 0) AS RemainingDays,
        ISNULL(lb.EntitledDays, 0) AS EntitledDays,
        ISNULL(lb.UsedDays, 0) AS UsedDays
    FROM dbo.LeaveTypes lt
    LEFT JOIN dbo.LeaveBalances lb ON lt.LeaveTypeId = lb.LeaveTypeId
        AND lb.EmployeeId = @EmployeeId
        AND lb.Year = YEAR(GETDATE())
    INNER JOIN dbo.Employees e ON e.EmployeeId = @EmployeeId
    WHERE lt.IsActive = 1
    AND (lt.RequiresGender = 0 OR lt.ApplicableGender = e.Gender)
    ORDER BY lt.LeaveTypeName;
END
GO

-- Create Leave Type
IF OBJECT_ID('dbo.SP_CreateLeaveType', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_CreateLeaveType;
GO

CREATE PROCEDURE dbo.SP_CreateLeaveType
    @LeaveTypeCode NVARCHAR(50),
    @LeaveTypeName NVARCHAR(200),
    @Description NVARCHAR(500),
    @DefaultDays DECIMAL(5,2),
    @IsProRated BIT,
    @RequiresGender BIT,
    @ApplicableGender NVARCHAR(10),
    @IsPaidLeave BIT,
    @RequiresDocumentation BIT,
    @MaxConsecutiveDays INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.LeaveTypes (
        LeaveTypeCode, LeaveTypeName, Description, DefaultDays,
        IsProRated, RequiresGender, ApplicableGender, IsPaidLeave,
        RequiresDocumentation, MaxConsecutiveDays
    )
    VALUES (
        @LeaveTypeCode, @LeaveTypeName, @Description, @DefaultDays,
        @IsProRated, @RequiresGender, @ApplicableGender, @IsPaidLeave,
        @RequiresDocumentation, @MaxConsecutiveDays
    );

    DECLARE @NewLeaveTypeId INT = SCOPE_IDENTITY();

    -- Auto-create leave balances for all applicable employees
    DECLARE @CurrentYear INT = YEAR(GETDATE());

    INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
    SELECT
        e.EmployeeId,
        @NewLeaveTypeId,
        @CurrentYear,
        CASE
            WHEN @IsProRated = 1 THEN
                (@DefaultDays / 12.0) * (13 - MONTH(e.HireDate))
            ELSE
                @DefaultDays
        END,
        CASE
            WHEN @IsProRated = 1 THEN
                (@DefaultDays / 12.0) * (13 - MONTH(e.HireDate))
            ELSE
                @DefaultDays
        END
    FROM dbo.Employees e
    WHERE e.IsActive = 1
    AND (@RequiresGender = 0 OR @ApplicableGender = e.Gender);

    SELECT @NewLeaveTypeId AS LeaveTypeId;
END
GO

-- Update Leave Type
IF OBJECT_ID('dbo.SP_UpdateLeaveType', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_UpdateLeaveType;
GO

CREATE PROCEDURE dbo.SP_UpdateLeaveType
    @LeaveTypeId INT,
    @LeaveTypeCode NVARCHAR(50),
    @LeaveTypeName NVARCHAR(200),
    @Description NVARCHAR(500),
    @DefaultDays DECIMAL(5,2),
    @IsProRated BIT,
    @RequiresGender BIT,
    @ApplicableGender NVARCHAR(10),
    @IsPaidLeave BIT,
    @RequiresDocumentation BIT,
    @MaxConsecutiveDays INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LeaveTypes
    SET
        LeaveTypeCode = @LeaveTypeCode,
        LeaveTypeName = @LeaveTypeName,
        Description = @Description,
        DefaultDays = @DefaultDays,
        IsProRated = @IsProRated,
        RequiresGender = @RequiresGender,
        ApplicableGender = @ApplicableGender,
        IsPaidLeave = @IsPaidLeave,
        RequiresDocumentation = @RequiresDocumentation,
        MaxConsecutiveDays = @MaxConsecutiveDays,
        IsActive = @IsActive,
        UpdatedDate = GETDATE()
    WHERE LeaveTypeId = @LeaveTypeId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Delete Leave Type
IF OBJECT_ID('dbo.SP_DeleteLeaveType', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_DeleteLeaveType;
GO

CREATE PROCEDURE dbo.SP_DeleteLeaveType
    @LeaveTypeId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if leave type is used in any leave requests
    IF EXISTS (SELECT 1 FROM dbo.LeaveRequests WHERE LeaveTypeId = @LeaveTypeId)
    BEGIN
        -- Soft delete
        UPDATE dbo.LeaveTypes
        SET IsActive = 0, UpdatedDate = GETDATE()
        WHERE LeaveTypeId = @LeaveTypeId;
    END
    ELSE
    BEGIN
        -- Can hard delete if not used
        DELETE FROM dbo.LeaveBalances WHERE LeaveTypeId = @LeaveTypeId;
        DELETE FROM dbo.LeaveTypes WHERE LeaveTypeId = @LeaveTypeId;
    END

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

PRINT 'Leave Type stored procedures created successfully';
