namespace LeaveManagementSystem.Models
{
    public class LeaveType
    {
        public int LeaveTypeId { get; set; }
        public string LeaveTypeCode { get; set; } = string.Empty;
        public string LeaveTypeName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal DefaultDays { get; set; }
        public bool IsProRated { get; set; }
        public bool RequiresGender { get; set; }
        public string? ApplicableGender { get; set; }
        public bool IsPaidLeave { get; set; }
        public bool RequiresDocumentation { get; set; }
        public int? MaxConsecutiveDays { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

        // For employee balance display
        public decimal RemainingDays { get; set; }
        public decimal EntitledDays { get; set; }
        public decimal UsedDays { get; set; }
    }
}
