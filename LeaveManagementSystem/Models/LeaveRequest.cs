namespace LeaveManagementSystem.Models
{
    public class LeaveRequest
    {
        public int LeaveRequestId { get; set; }
        public string RequestNumber { get; set; } = string.Empty;
        public int EmployeeId { get; set; }
        public int LeaveTypeId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal TotalDays { get; set; }
        public string? Reason { get; set; }
        public string Status { get; set; } = "Pending";
        public DateTime RequestDate { get; set; }
        public string? CancellationReason { get; set; }
        public DateTime? CancellationDate { get; set; }
        public string? AttachmentPath { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

        // Navigation properties (from joins)
        public string? EmployeeName { get; set; }
        public string? EmployeeCode { get; set; }
        public string? EmployeeEmail { get; set; }
        public string? DepartmentName { get; set; }
        public string? PositionName { get; set; }
        public string? LeaveTypeName { get; set; }

        // Manager info (for email notifications)
        public int? ManagerId { get; set; }
        public string? ManagerEmail { get; set; }

        // HR emails (JSON array from stored procedure)
        public string? HREmails { get; set; }

        // Approval info
        public int ApprovedCount { get; set; }
        public int TotalApprovers { get; set; }
        public int? DaysPending { get; set; }
        public bool? AllApproved { get; set; }

        // Approvers
        public int? Approver1Id { get; set; }
        public int? Approver2Id { get; set; }
        public List<LeaveApprover>? Approvers { get; set; }
        public List<LeaveApprovalHistory>? History { get; set; }
    }
}
