namespace LeaveManagementSystem.Models.ViewModels
{
    public class EmployeeLeaveBalancePivotViewModel
    {
        public int EmployeeId { get; set; }
        public string EmployeeCode { get; set; } = string.Empty;
        public string EmployeeName { get; set; } = string.Empty;
        public string DepartmentName { get; set; } = string.Empty;
        public string PositionName { get; set; } = string.Empty;

        // Dictionary: Key = LeaveTypeCode, Value = LeaveTypeBalance
        public Dictionary<string, LeaveTypeBalance> LeaveBalances { get; set; } = new Dictionary<string, LeaveTypeBalance>();
    }

    public class LeaveTypeBalance
    {
        public string LeaveTypeName { get; set; } = string.Empty;
        public decimal EntitledDays { get; set; }
        public decimal UsedDays { get; set; }
        public decimal RemainingDays { get; set; }

        public string DisplayText => $"{UsedDays}/{EntitledDays}";
        public decimal UsagePercentage => EntitledDays > 0 ? (UsedDays / EntitledDays * 100) : 0;
    }
}
