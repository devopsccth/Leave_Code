-- =============================================
-- Report Stored Procedures
-- =============================================

-- Get Leave Report By Team (for Managers)
IF OBJECT_ID('dbo.SP_GetTeamLeaveReport', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetTeamLeaveReport;
GO

CREATE PROCEDURE dbo.SP_GetTeamLeaveReport
    @ManagerId INT,
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        d.DepartmentName,
        p.PositionName,
        lt.LeaveTypeName,
        lb.EntitledDays,
        lb.UsedDays,
        lb.RemainingDays,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            WHERE lr.EmployeeId = e.EmployeeId
            AND lr.LeaveTypeId = lb.LeaveTypeId
            AND YEAR(lr.RequestDate) = @Year
            AND lr.Status = 'Approved'
        ) AS ApprovedRequests,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            WHERE lr.EmployeeId = e.EmployeeId
            AND lr.LeaveTypeId = lb.LeaveTypeId
            AND YEAR(lr.RequestDate) = @Year
            AND lr.Status = 'Pending'
        ) AS PendingRequests
    FROM dbo.Employees e
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    INNER JOIN dbo.LeaveBalances lb ON e.EmployeeId = lb.EmployeeId
    INNER JOIN dbo.LeaveTypes lt ON lb.LeaveTypeId = lt.LeaveTypeId
    WHERE e.ManagerId = @ManagerId
    AND e.IsActive = 1
    AND lb.Year = @Year
    ORDER BY e.EmployeeCode, lt.LeaveTypeName;
END
GO

-- Get Leave Report for All Employees (for HR/Admin)
IF OBJECT_ID('dbo.SP_GetAllEmployeesLeaveReport', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetAllEmployeesLeaveReport;
GO

CREATE PROCEDURE dbo.SP_GetAllEmployeesLeaveReport
    @Year INT = NULL,
    @DepartmentId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    SELECT
        e.EmployeeId,
        e.EmployeeCode,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.Email,
        d.DepartmentId,
        d.DepartmentName,
        p.PositionName,
        e.HireDate,
        DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
        lt.LeaveTypeId,
        lt.LeaveTypeName,
        lb.EntitledDays,
        lb.UsedDays,
        lb.RemainingDays,
        lb.CarryForwardDays,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            WHERE lr.EmployeeId = e.EmployeeId
            AND lr.LeaveTypeId = lb.LeaveTypeId
            AND YEAR(lr.RequestDate) = @Year
        ) AS TotalRequests,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            WHERE lr.EmployeeId = e.EmployeeId
            AND lr.LeaveTypeId = lb.LeaveTypeId
            AND YEAR(lr.RequestDate) = @Year
            AND lr.Status = 'Approved'
        ) AS ApprovedRequests
    FROM dbo.Employees e
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    LEFT JOIN dbo.LeaveBalances lb ON e.EmployeeId = lb.EmployeeId AND lb.Year = @Year
    LEFT JOIN dbo.LeaveTypes lt ON lb.LeaveTypeId = lt.LeaveTypeId
    WHERE e.IsActive = 1
    AND (@DepartmentId IS NULL OR e.DepartmentId = @DepartmentId)
    ORDER BY d.DepartmentName, e.EmployeeCode, lt.LeaveTypeName;
END
GO

-- Get Leave Summary by Leave Type
IF OBJECT_ID('dbo.SP_GetLeaveSummaryByType', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetLeaveSummaryByType;
GO

CREATE PROCEDURE dbo.SP_GetLeaveSummaryByType
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    SELECT
        lt.LeaveTypeId,
        lt.LeaveTypeName,
        COUNT(DISTINCT lb.EmployeeId) AS TotalEmployees,
        SUM(lb.EntitledDays) AS TotalEntitled,
        SUM(lb.UsedDays) AS TotalUsed,
        SUM(lb.RemainingDays) AS TotalRemaining,
        CAST(CASE
            WHEN SUM(lb.EntitledDays) > 0
            THEN (SUM(lb.UsedDays) / SUM(lb.EntitledDays)) * 100
            ELSE 0
        END AS DECIMAL(5,2)) AS UtilizationPercent,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            WHERE lr.LeaveTypeId = lt.LeaveTypeId
            AND YEAR(lr.RequestDate) = @Year
            AND lr.Status = 'Pending'
        ) AS PendingRequests,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            WHERE lr.LeaveTypeId = lt.LeaveTypeId
            AND YEAR(lr.RequestDate) = @Year
            AND lr.Status = 'Approved'
        ) AS ApprovedRequests
    FROM dbo.LeaveTypes lt
    INNER JOIN dbo.LeaveBalances lb ON lt.LeaveTypeId = lb.LeaveTypeId
    WHERE lb.Year = @Year
    AND lt.IsActive = 1
    GROUP BY lt.LeaveTypeId, lt.LeaveTypeName
    ORDER BY lt.LeaveTypeName;
END
GO

-- Get Department Leave Statistics
IF OBJECT_ID('dbo.SP_GetDepartmentLeaveStats', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetDepartmentLeaveStats;
GO

CREATE PROCEDURE dbo.SP_GetDepartmentLeaveStats
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    SELECT
        d.DepartmentId,
        d.DepartmentName,
        COUNT(DISTINCT e.EmployeeId) AS TotalEmployees,
        SUM(lb.UsedDays) AS TotalDaysUsed,
        CAST(AVG(lb.UsedDays) AS DECIMAL(5,2)) AS AvgDaysUsedPerEmployee,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            INNER JOIN dbo.Employees emp ON lr.EmployeeId = emp.EmployeeId
            WHERE emp.DepartmentId = d.DepartmentId
            AND YEAR(lr.RequestDate) = @Year
            AND lr.Status = 'Pending'
        ) AS PendingRequests,
        (
            SELECT COUNT(*)
            FROM dbo.LeaveRequests lr
            INNER JOIN dbo.Employees emp ON lr.EmployeeId = emp.EmployeeId
            WHERE emp.DepartmentId = d.DepartmentId
            AND YEAR(lr.RequestDate) = @Year
            AND lr.Status = 'Approved'
        ) AS ApprovedRequests
    FROM dbo.Departments d
    INNER JOIN dbo.Employees e ON d.DepartmentId = e.DepartmentId
    LEFT JOIN dbo.LeaveBalances lb ON e.EmployeeId = lb.EmployeeId AND lb.Year = @Year
    WHERE e.IsActive = 1
    AND d.IsActive = 1
    GROUP BY d.DepartmentId, d.DepartmentName
    ORDER BY d.DepartmentName;
END
GO

-- Get Employee Leave History
IF OBJECT_ID('dbo.SP_GetEmployeeLeaveHistory', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetEmployeeLeaveHistory;
GO

CREATE PROCEDURE dbo.SP_GetEmployeeLeaveHistory
    @EmployeeId INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL SET @StartDate = DATEADD(YEAR, -1, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();

    SELECT
        lr.LeaveRequestId,
        lr.RequestNumber,
        lt.LeaveTypeName,
        lr.StartDate,
        lr.EndDate,
        lr.TotalDays,
        lr.Reason,
        lr.Status,
        lr.RequestDate,
        (
            SELECT STRING_AGG(e.FirstName + ' ' + e.LastName, ', ')
            FROM dbo.LeaveApprovers la
            INNER JOIN dbo.Employees e ON la.ApproverId = e.EmployeeId
            WHERE la.LeaveRequestId = lr.LeaveRequestId
        ) AS Approvers,
        (
            SELECT MAX(ActionDate)
            FROM dbo.LeaveApprovalHistory
            WHERE LeaveRequestId = lr.LeaveRequestId
            AND Action IN ('Approved', 'Rejected')
        ) AS FinalActionDate
    FROM dbo.LeaveRequests lr
    INNER JOIN dbo.LeaveTypes lt ON lr.LeaveTypeId = lt.LeaveTypeId
    WHERE lr.EmployeeId = @EmployeeId
    AND lr.RequestDate BETWEEN @StartDate AND @EndDate
    ORDER BY lr.RequestDate DESC;
END
GO

-- Calculate and Update Leave Balances for Next Year
IF OBJECT_ID('dbo.SP_CalculateNextYearLeaveBalances', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_CalculateNextYearLeaveBalances;
GO

CREATE PROCEDURE dbo.SP_CalculateNextYearLeaveBalances
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Process for each active employee
        DECLARE @EmployeeId INT, @HireDate DATE, @Gender NVARCHAR(10);
        DECLARE @YearsOfService INT, @AnnualDays DECIMAL(5,2), @PersonalDays DECIMAL(5,2);

        DECLARE employee_cursor CURSOR FOR
        SELECT EmployeeId, HireDate, Gender FROM dbo.Employees WHERE IsActive = 1;

        OPEN employee_cursor;
        FETCH NEXT FROM employee_cursor INTO @EmployeeId, @HireDate, @Gender;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @YearsOfService = DATEDIFF(YEAR, @HireDate, DATEFROMPARTS(@Year, 1, 1));

            -- Annual Leave calculation
            -- If 5 years or more, get 10 days, otherwise pro-rated
            IF @YearsOfService >= 5
                SET @AnnualDays = 10;
            ELSE
                SET @AnnualDays = 10;

            -- Check for carry forward (max 5 days example)
            DECLARE @CarryForward DECIMAL(5,2) = 0;
            SELECT @CarryForward = CASE
                WHEN RemainingDays > 5 THEN 5
                ELSE RemainingDays
            END
            FROM dbo.LeaveBalances
            WHERE EmployeeId = @EmployeeId
            AND LeaveTypeId = (SELECT LeaveTypeId FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'ANNUAL')
            AND Year = @Year - 1;

            SET @CarryForward = ISNULL(@CarryForward, 0);

            -- Insert or update Annual Leave
            MERGE dbo.LeaveBalances AS target
            USING (SELECT @EmployeeId AS EmployeeId, @Year AS Year) AS source
            ON target.EmployeeId = source.EmployeeId
                AND target.Year = source.Year
                AND target.LeaveTypeId = (SELECT LeaveTypeId FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'ANNUAL')
            WHEN MATCHED THEN
                UPDATE SET
                    EntitledDays = @AnnualDays + @CarryForward,
                    RemainingDays = @AnnualDays + @CarryForward,
                    CarryForwardDays = @CarryForward,
                    YearsOfService = @YearsOfService,
                    UpdatedDate = GETDATE()
            WHEN NOT MATCHED THEN
                INSERT (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays, CarryForwardDays, YearsOfService)
                VALUES (
                    @EmployeeId,
                    (SELECT LeaveTypeId FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'ANNUAL'),
                    @Year,
                    @AnnualDays + @CarryForward,
                    @AnnualDays + @CarryForward,
                    @CarryForward,
                    @YearsOfService
                );

            -- Personal Leave (Pro-rated)
            SET @PersonalDays = 3;

            MERGE dbo.LeaveBalances AS target
            USING (SELECT @EmployeeId AS EmployeeId, @Year AS Year) AS source
            ON target.EmployeeId = source.EmployeeId
                AND target.Year = source.Year
                AND target.LeaveTypeId = (SELECT LeaveTypeId FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'PERSONAL')
            WHEN MATCHED THEN
                UPDATE SET EntitledDays = @PersonalDays, RemainingDays = @PersonalDays, UpdatedDate = GETDATE()
            WHEN NOT MATCHED THEN
                INSERT (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
                VALUES (
                    @EmployeeId,
                    (SELECT LeaveTypeId FROM dbo.LeaveTypes WHERE LeaveTypeCode = 'PERSONAL'),
                    @Year,
                    @PersonalDays,
                    @PersonalDays
                );

            -- Other leave types (Sick, etc.)
            INSERT INTO dbo.LeaveBalances (EmployeeId, LeaveTypeId, Year, EntitledDays, RemainingDays)
            SELECT
                @EmployeeId,
                LeaveTypeId,
                @Year,
                DefaultDays,
                DefaultDays
            FROM dbo.LeaveTypes
            WHERE LeaveTypeCode NOT IN ('ANNUAL', 'PERSONAL')
            AND IsActive = 1
            AND (RequiresGender = 0 OR ApplicableGender = @Gender)
            AND NOT EXISTS (
                SELECT 1 FROM dbo.LeaveBalances
                WHERE EmployeeId = @EmployeeId
                AND LeaveTypeId = dbo.LeaveTypes.LeaveTypeId
                AND Year = @Year
            );

            FETCH NEXT FROM employee_cursor INTO @EmployeeId, @HireDate, @Gender;
        END

        CLOSE employee_cursor;
        DEALLOCATE employee_cursor;

        COMMIT TRANSACTION;

        SELECT 'Leave balances calculated successfully for year ' + CAST(@Year AS NVARCHAR(4)) AS Result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF CURSOR_STATUS('global', 'employee_cursor') >= 0
        BEGIN
            CLOSE employee_cursor;
            DEALLOCATE employee_cursor;
        END
        THROW;
    END CATCH
END
GO

PRINT 'Report stored procedures created successfully';
