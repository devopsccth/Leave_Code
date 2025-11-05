namespace LeaveManagementSystem.Models
{
    public class Employee
    {
        public int EmployeeId { get; set; }
        public string EmployeeCode { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Gender { get; set; } = string.Empty;
        public DateTime? DateOfBirth { get; set; }
        public DateTime HireDate { get; set; }
        public int DepartmentId { get; set; }
        public int PositionId { get; set; }
        public int? ManagerId { get; set; }
        public bool IsActive { get; set; }
        public string Role { get; set; } = "Employee";
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public DateTime? LastLoginDate { get; set; }

        // Navigation properties (populated from joins)
        public string? DepartmentName { get; set; }
        public string? PositionName { get; set; }
        public string? ManagerName { get; set; }

        public string FullName => $"{FirstName} {LastName}";
    }
}
