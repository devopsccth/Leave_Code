namespace LeaveManagementSystem.Models
{
    public class LeaveApprover
    {
        public int LeaveApproverId { get; set; }
        public int LeaveRequestId { get; set; }
        public int ApproverId { get; set; }
        public int ApprovalLevel { get; set; }
        public string Status { get; set; } = "Pending";
        public string? Comments { get; set; }
        public DateTime? ActionDate { get; set; }
        public bool IsRequired { get; set; }
        public DateTime CreatedDate { get; set; }

        // Navigation properties
        public string? ApproverName { get; set; }
        public string? ApproverEmail { get; set; }
    }

    public class LeaveApprovalHistory
    {
        public int HistoryId { get; set; }
        public int LeaveRequestId { get; set; }
        public int ApproverId { get; set; }
        public string Action { get; set; } = string.Empty;
        public string? Comments { get; set; }
        public DateTime ActionDate { get; set; }

        // Navigation properties
        public string? ApproverName { get; set; }
    }
}
