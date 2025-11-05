-- =============================================
-- Leave Request Stored Procedures
-- =============================================

-- Get Leave Balance for Employee
IF OBJECT_ID('dbo.SP_GetLeaveBalance', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetLeaveBalance;
GO

CREATE PROCEDURE dbo.SP_GetLeaveBalance
    @EmployeeId INT,
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    SELECT
        lb.LeaveBalanceId,
        lb.EmployeeId,
        lb.LeaveTypeId,
        lt.LeaveTypeCode,
        lt.LeaveTypeName,
        lb.Year,
        lb.EntitledDays,
        lb.UsedDays,
        lb.RemainingDays,
        lb.CarryForwardDays,
        lb.YearsOfService
    FROM dbo.LeaveBalances lb
    INNER JOIN dbo.LeaveTypes lt ON lb.LeaveTypeId = lt.LeaveTypeId
    WHERE lb.EmployeeId = @EmployeeId
    AND lb.Year = @Year
    ORDER BY lt.LeaveTypeName;
END
GO

-- Generate Leave Request Number
IF OBJECT_ID('dbo.FN_GenerateLeaveRequestNumber', 'FN') IS NOT NULL DROP FUNCTION dbo.FN_GenerateLeaveRequestNumber;
GO

CREATE FUNCTION dbo.FN_GenerateLeaveRequestNumber()
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Year NVARCHAR(4) = CAST(YEAR(GETDATE()) AS NVARCHAR(4));
    DECLARE @LastNumber INT;

    SELECT @LastNumber = ISNULL(MAX(CAST(RIGHT(RequestNumber, 4) AS INT)), 0)
    FROM dbo.LeaveRequests
    WHERE RequestNumber LIKE 'LR-' + @Year + '-%';

    DECLARE @NewNumber NVARCHAR(50) = 'LR-' + @Year + '-' + RIGHT('0000' + CAST(@LastNumber + 1 AS NVARCHAR(4)), 4);

    RETURN @NewNumber;
END
GO

-- Create Leave Request
IF OBJECT_ID('dbo.SP_CreateLeaveRequest', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_CreateLeaveRequest;
GO

CREATE PROCEDURE dbo.SP_CreateLeaveRequest
    @EmployeeId INT,
    @LeaveTypeId INT,
    @StartDate DATE,
    @EndDate DATE,
    @TotalDays DECIMAL(5,2),
    @Reason NVARCHAR(1000),
    @Approver1Id INT,
    @Approver2Id INT = NULL,
    @AttachmentPath NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check leave balance
        DECLARE @RemainingDays DECIMAL(5,2);
        SELECT @RemainingDays = RemainingDays
        FROM dbo.LeaveBalances
        WHERE EmployeeId = @EmployeeId
        AND LeaveTypeId = @LeaveTypeId
        AND Year = YEAR(GETDATE());

        IF @RemainingDays < @TotalDays
        BEGIN
            THROW 50001, 'Insufficient leave balance', 1;
        END

        -- Generate Request Number
        DECLARE @RequestNumber NVARCHAR(50) = dbo.FN_GenerateLeaveRequestNumber();

        -- Insert Leave Request
        INSERT INTO dbo.LeaveRequests (
            RequestNumber, EmployeeId, LeaveTypeId, StartDate, EndDate,
            TotalDays, Reason, Status, AttachmentPath
        )
        VALUES (
            @RequestNumber, @EmployeeId, @LeaveTypeId, @StartDate, @EndDate,
            @TotalDays, @Reason, 'Pending', @AttachmentPath
        );

        DECLARE @LeaveRequestId INT = SCOPE_IDENTITY();

        -- Add Approvers
        INSERT INTO dbo.LeaveApprovers (LeaveRequestId, ApproverId, ApprovalLevel, Status)
        VALUES (@LeaveRequestId, @Approver1Id, 1, 'Pending');

        IF @Approver2Id IS NOT NULL
        BEGIN
            INSERT INTO dbo.LeaveApprovers (LeaveRequestId, ApproverId, ApprovalLevel, Status)
            VALUES (@LeaveRequestId, @Approver2Id, 2, 'Pending');
        END

        -- Add to History
        INSERT INTO dbo.LeaveApprovalHistory (LeaveRequestId, ApproverId, Action, Comments)
        VALUES (@LeaveRequestId, @EmployeeId, 'Submitted', 'Leave request submitted');

        COMMIT TRANSACTION;

        -- Return the created request
        SELECT
            lr.LeaveRequestId,
            lr.RequestNumber,
            lr.EmployeeId,
            lr.LeaveTypeId,
            lr.StartDate,
            lr.EndDate,
            lr.TotalDays,
            lr.Status,
            @Approver1Id AS Approver1Id,
            @Approver2Id AS Approver2Id
        FROM dbo.LeaveRequests lr
        WHERE lr.LeaveRequestId = @LeaveRequestId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Get Leave Requests By Employee
IF OBJECT_ID('dbo.SP_GetLeaveRequestsByEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetLeaveRequestsByEmployee;
GO

CREATE PROCEDURE dbo.SP_GetLeaveRequestsByEmployee
    @EmployeeId INT,
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    SELECT
        lr.LeaveRequestId,
        lr.RequestNumber,
        lr.EmployeeId,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        lr.LeaveTypeId,
        lt.LeaveTypeName,
        lr.StartDate,
        lr.EndDate,
        lr.TotalDays,
        lr.Reason,
        lr.Status,
        lr.RequestDate,
        lr.CancellationReason,
        lr.CancellationDate,
        lr.AttachmentPath,
        (SELECT COUNT(*) FROM dbo.LeaveApprovers WHERE LeaveRequestId = lr.LeaveRequestId AND Status = 'Approved') AS ApprovedCount,
        (SELECT COUNT(*) FROM dbo.LeaveApprovers WHERE LeaveRequestId = lr.LeaveRequestId) AS TotalApprovers
    FROM dbo.LeaveRequests lr
    INNER JOIN dbo.Employees e ON lr.EmployeeId = e.EmployeeId
    INNER JOIN dbo.LeaveTypes lt ON lr.LeaveTypeId = lt.LeaveTypeId
    WHERE lr.EmployeeId = @EmployeeId
    AND YEAR(lr.RequestDate) = @Year
    ORDER BY lr.RequestDate DESC;
END
GO

-- Get Leave Request By Id
IF OBJECT_ID('dbo.SP_GetLeaveRequestById', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetLeaveRequestById;
GO

CREATE PROCEDURE dbo.SP_GetLeaveRequestById
    @LeaveRequestId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Get Request Details
    SELECT
        lr.LeaveRequestId,
        lr.RequestNumber,
        lr.EmployeeId,
        e.EmployeeCode,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.Email AS EmployeeEmail,
        d.DepartmentName,
        p.PositionName,
        lr.LeaveTypeId,
        lt.LeaveTypeName,
        lr.StartDate,
        lr.EndDate,
        lr.TotalDays,
        lr.Reason,
        lr.Status,
        lr.RequestDate,
        lr.CancellationReason,
        lr.CancellationDate,
        lr.AttachmentPath
    FROM dbo.LeaveRequests lr
    INNER JOIN dbo.Employees e ON lr.EmployeeId = e.EmployeeId
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    INNER JOIN dbo.LeaveTypes lt ON lr.LeaveTypeId = lt.LeaveTypeId
    WHERE lr.LeaveRequestId = @LeaveRequestId;

    -- Get Approvers
    SELECT
        la.LeaveApproverId,
        la.LeaveRequestId,
        la.ApproverId,
        e.FirstName + ' ' + e.LastName AS ApproverName,
        e.Email AS ApproverEmail,
        la.ApprovalLevel,
        la.Status,
        la.Comments,
        la.ActionDate
    FROM dbo.LeaveApprovers la
    INNER JOIN dbo.Employees e ON la.ApproverId = e.EmployeeId
    WHERE la.LeaveRequestId = @LeaveRequestId
    ORDER BY la.ApprovalLevel;

    -- Get History
    SELECT
        h.HistoryId,
        h.LeaveRequestId,
        h.ApproverId,
        e.FirstName + ' ' + e.LastName AS ApproverName,
        h.Action,
        h.Comments,
        h.ActionDate
    FROM dbo.LeaveApprovalHistory h
    INNER JOIN dbo.Employees e ON h.ApproverId = e.EmployeeId
    WHERE h.LeaveRequestId = @LeaveRequestId
    ORDER BY h.ActionDate DESC;
END
GO

-- Get Pending Approvals for Approver
IF OBJECT_ID('dbo.SP_GetPendingApprovals', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetPendingApprovals;
GO

CREATE PROCEDURE dbo.SP_GetPendingApprovals
    @ApproverId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        lr.LeaveRequestId,
        lr.RequestNumber,
        lr.EmployeeId,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.EmployeeCode,
        d.DepartmentName,
        p.PositionName,
        lr.LeaveTypeId,
        lt.LeaveTypeName,
        lr.StartDate,
        lr.EndDate,
        lr.TotalDays,
        lr.Reason,
        lr.Status AS RequestStatus,
        lr.RequestDate,
        la.ApprovalLevel,
        la.Status AS ApprovalStatus,
        DATEDIFF(DAY, lr.RequestDate, GETDATE()) AS DaysPending
    FROM dbo.LeaveRequests lr
    INNER JOIN dbo.Employees e ON lr.EmployeeId = e.EmployeeId
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    INNER JOIN dbo.LeaveTypes lt ON lr.LeaveTypeId = lt.LeaveTypeId
    INNER JOIN dbo.LeaveApprovers la ON lr.LeaveRequestId = la.LeaveRequestId
    WHERE la.ApproverId = @ApproverId
    AND la.Status = 'Pending'
    AND lr.Status = 'Pending'
    ORDER BY lr.RequestDate;
END
GO

-- Get All Leave Requests (for HR/Admin)
IF OBJECT_ID('dbo.SP_GetAllLeaveRequests', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_GetAllLeaveRequests;
GO

CREATE PROCEDURE dbo.SP_GetAllLeaveRequests
    @Year INT = NULL,
    @Status NVARCHAR(50) = NULL,
    @DepartmentId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    SELECT
        lr.LeaveRequestId,
        lr.RequestNumber,
        lr.EmployeeId,
        e.EmployeeCode,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.DepartmentId,
        d.DepartmentName,
        p.PositionName,
        lr.LeaveTypeId,
        lt.LeaveTypeName,
        lr.StartDate,
        lr.EndDate,
        lr.TotalDays,
        lr.Status,
        lr.RequestDate,
        (SELECT COUNT(*) FROM dbo.LeaveApprovers WHERE LeaveRequestId = lr.LeaveRequestId AND Status = 'Approved') AS ApprovedCount,
        (SELECT COUNT(*) FROM dbo.LeaveApprovers WHERE LeaveRequestId = lr.LeaveRequestId) AS TotalApprovers
    FROM dbo.LeaveRequests lr
    INNER JOIN dbo.Employees e ON lr.EmployeeId = e.EmployeeId
    INNER JOIN dbo.Departments d ON e.DepartmentId = d.DepartmentId
    INNER JOIN dbo.Positions p ON e.PositionId = p.PositionId
    INNER JOIN dbo.LeaveTypes lt ON lr.LeaveTypeId = lt.LeaveTypeId
    WHERE YEAR(lr.RequestDate) = @Year
    AND (@Status IS NULL OR lr.Status = @Status)
    AND (@DepartmentId IS NULL OR e.DepartmentId = @DepartmentId)
    ORDER BY lr.RequestDate DESC;
END
GO

-- Cancel Leave Request
IF OBJECT_ID('dbo.SP_CancelLeaveRequest', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_CancelLeaveRequest;
GO

CREATE PROCEDURE dbo.SP_CancelLeaveRequest
    @LeaveRequestId INT,
    @EmployeeId INT,
    @CancellationReason NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if request belongs to employee and is cancellable
        DECLARE @CurrentStatus NVARCHAR(50);
        SELECT @CurrentStatus = Status
        FROM dbo.LeaveRequests
        WHERE LeaveRequestId = @LeaveRequestId
        AND EmployeeId = @EmployeeId;

        IF @CurrentStatus IS NULL
        BEGIN
            THROW 50002, 'Leave request not found', 1;
        END

        IF @CurrentStatus NOT IN ('Pending', 'Approved')
        BEGIN
            THROW 50003, 'Cannot cancel this leave request', 1;
        END

        -- If approved, return leave balance
        IF @CurrentStatus = 'Approved'
        BEGIN
            DECLARE @LeaveTypeId INT, @TotalDays DECIMAL(5,2);
            SELECT @LeaveTypeId = LeaveTypeId, @TotalDays = TotalDays
            FROM dbo.LeaveRequests
            WHERE LeaveRequestId = @LeaveRequestId;

            UPDATE dbo.LeaveBalances
            SET UsedDays = UsedDays - @TotalDays,
                RemainingDays = RemainingDays + @TotalDays
            WHERE EmployeeId = @EmployeeId
            AND LeaveTypeId = @LeaveTypeId
            AND Year = YEAR(GETDATE());
        END

        -- Update request status
        UPDATE dbo.LeaveRequests
        SET Status = 'Cancelled',
            CancellationReason = @CancellationReason,
            CancellationDate = GETDATE()
        WHERE LeaveRequestId = @LeaveRequestId;

        -- Add to history
        INSERT INTO dbo.LeaveApprovalHistory (LeaveRequestId, ApproverId, Action, Comments)
        VALUES (@LeaveRequestId, @EmployeeId, 'Cancelled', @CancellationReason);

        COMMIT TRANSACTION;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT 'Leave Request stored procedures created successfully';
