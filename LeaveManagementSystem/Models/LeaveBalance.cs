namespace LeaveManagementSystem.Models
{
    public class LeaveBalance
    {
        public int LeaveBalanceId { get; set; }
        public int EmployeeId { get; set; }
        public int LeaveTypeId { get; set; }
        public int Year { get; set; }
        public decimal EntitledDays { get; set; }
        public decimal UsedDays { get; set; }
        public decimal RemainingDays { get; set; }
        public decimal? ProRateCalculation { get; set; }
        public decimal CarryForwardDays { get; set; }
        public int? YearsOfService { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

        // Navigation properties
        public string? LeaveTypeCode { get; set; }
        public string? LeaveTypeName { get; set; }

        // Employee navigation properties (populated from joins)
        public string? EmployeeCode { get; set; }
        public string? EmployeeName { get; set; }
        public string? DepartmentName { get; set; }
        public string? PositionName { get; set; }
    }
}
