-- =============================================
-- Leave Approval Stored Procedures
-- =============================================

-- Approve Leave Request
IF OBJECT_ID('dbo.SP_ApproveLeaveRequest', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_ApproveLeaveRequest;
GO

CREATE PROCEDURE dbo.SP_ApproveLeaveRequest
    @LeaveRequestId INT,
    @ApproverId INT,
    @Comments NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if approver is authorized
        DECLARE @ApprovalLevel INT, @CurrentStatus NVARCHAR(50);

        SELECT @ApprovalLevel = ApprovalLevel, @CurrentStatus = Status
        FROM dbo.LeaveApprovers
        WHERE LeaveRequestId = @LeaveRequestId
        AND ApproverId = @ApproverId;

        IF @ApprovalLevel IS NULL
        BEGIN
            THROW 50004, 'You are not authorized to approve this request', 1;
        END

        IF @CurrentStatus != 'Pending'
        BEGIN
            THROW 50005, 'This approval is no longer pending', 1;
        END

        -- Check if previous approver (level 1) has approved for level 2
        IF @ApprovalLevel = 2
        BEGIN
            DECLARE @Level1Status NVARCHAR(50);
            SELECT @Level1Status = Status
            FROM dbo.LeaveApprovers
            WHERE LeaveRequestId = @LeaveRequestId
            AND ApprovalLevel = 1;

            IF @Level1Status != 'Approved'
            BEGIN
                THROW 50006, 'First approver must approve before second approver', 1;
            END
        END

        -- Update approver status
        UPDATE dbo.LeaveApprovers
        SET Status = 'Approved',
            Comments = @Comments,
            ActionDate = GETDATE()
        WHERE LeaveRequestId = @LeaveRequestId
        AND ApproverId = @ApproverId;

        -- Add to history
        INSERT INTO dbo.LeaveApprovalHistory (LeaveRequestId, ApproverId, Action, Comments)
        VALUES (@LeaveRequestId, @ApproverId, 'Approved', @Comments);

        -- Check if all required approvers have approved
        DECLARE @AllApproved BIT = 0;
        DECLARE @PendingCount INT;

        SELECT @PendingCount = COUNT(*)
        FROM dbo.LeaveApprovers
        WHERE LeaveRequestId = @LeaveRequestId
        AND Status = 'Pending'
        AND IsRequired = 1;

        IF @PendingCount = 0
        BEGIN
            SET @AllApproved = 1;

            -- Update leave request status
            UPDATE dbo.LeaveRequests
            SET Status = 'Approved'
            WHERE LeaveRequestId = @LeaveRequestId;

            -- Deduct from leave balance
            DECLARE @EmployeeId INT, @LeaveTypeId INT, @TotalDays DECIMAL(5,2);

            SELECT @EmployeeId = EmployeeId, @LeaveTypeId = LeaveTypeId, @TotalDays = TotalDays
            FROM dbo.LeaveRequests
            WHERE LeaveRequestId = @LeaveRequestId;

            UPDATE dbo.LeaveBalances
            SET UsedDays = UsedDays + @TotalDays,
                RemainingDays = RemainingDays - @TotalDays,
                UpdatedDate = GETDATE()
            WHERE EmployeeId = @EmployeeId
            AND LeaveTypeId = @LeaveTypeId
            AND Year = YEAR(GETDATE());
        END

        COMMIT TRANSACTION;

        -- Return result with email recipients
        SELECT
            lr.LeaveRequestId,
            lr.RequestNumber,
            lr.Status,
            @AllApproved AS AllApproved,
            e.EmployeeId,
            e.Email AS EmployeeEmail,
            e.FirstName + ' ' + e.LastName AS EmployeeName,
            lt.LeaveTypeName,
            lr.StartDate,
            lr.EndDate,
            lr.TotalDays,
            e.ManagerId,
            (SELECT Email FROM dbo.Employees WHERE EmployeeId = e.ManagerId) AS ManagerEmail,
            (SELECT Email FROM dbo.Employees WHERE Role = 'HR' AND IsActive = 1 FOR JSON PATH) AS HREmails
        FROM dbo.LeaveRequests lr
        INNER JOIN dbo.Employees e ON lr.EmployeeId = e.EmployeeId
        INNER JOIN dbo.LeaveTypes lt ON lr.LeaveTypeId = lt.LeaveTypeId
        WHERE lr.LeaveRequestId = @LeaveRequestId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Reject Leave Request
IF OBJECT_ID('dbo.SP_RejectLeaveRequest', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_RejectLeaveRequest;
GO

CREATE PROCEDURE dbo.SP_RejectLeaveRequest
    @LeaveRequestId INT,
    @ApproverId INT,
    @Comments NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if approver is authorized
        DECLARE @ApprovalLevel INT, @CurrentStatus NVARCHAR(50);

        SELECT @ApprovalLevel = ApprovalLevel, @CurrentStatus = Status
        FROM dbo.LeaveApprovers
        WHERE LeaveRequestId = @LeaveRequestId
        AND ApproverId = @ApproverId;

        IF @ApprovalLevel IS NULL
        BEGIN
            THROW 50004, 'You are not authorized to reject this request', 1;
        END

        IF @CurrentStatus != 'Pending'
        BEGIN
            THROW 50005, 'This approval is no longer pending', 1;
        END

        -- Update approver status
        UPDATE dbo.LeaveApprovers
        SET Status = 'Rejected',
            Comments = @Comments,
            ActionDate = GETDATE()
        WHERE LeaveRequestId = @LeaveRequestId
        AND ApproverId = @ApproverId;

        -- Update leave request status
        UPDATE dbo.LeaveRequests
        SET Status = 'Rejected'
        WHERE LeaveRequestId = @LeaveRequestId;

        -- Add to history
        INSERT INTO dbo.LeaveApprovalHistory (LeaveRequestId, ApproverId, Action, Comments)
        VALUES (@LeaveRequestId, @ApproverId, 'Rejected', @Comments);

        COMMIT TRANSACTION;

        -- Return result with employee email
        SELECT
            lr.LeaveRequestId,
            lr.RequestNumber,
            lr.Status,
            e.EmployeeId,
            e.Email AS EmployeeEmail,
            e.FirstName + ' ' + e.LastName AS EmployeeName,
            lt.LeaveTypeName,
            lr.StartDate,
            lr.EndDate,
            @Comments AS RejectionReason
        FROM dbo.LeaveRequests lr
        INNER JOIN dbo.Employees e ON lr.EmployeeId = e.EmployeeId
        INNER JOIN dbo.LeaveTypes lt ON lr.LeaveTypeId = lt.LeaveTypeId
        WHERE lr.LeaveRequestId = @LeaveRequestId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT 'Leave Approval stored procedures created successfully';
