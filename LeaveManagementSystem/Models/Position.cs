namespace LeaveManagementSystem.Models
{
    public class Position
    {
        public int PositionId { get; set; }
        public string PositionCode { get; set; } = string.Empty;
        public string PositionName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

        // For display purposes
        public int EmployeeCount { get; set; }
    }
}
