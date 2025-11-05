using System.ComponentModel.DataAnnotations;

namespace LeaveManagementSystem.Models.ViewModels
{
    public class EmployeeViewModel
    {
        public int EmployeeId { get; set; }

        [Required(ErrorMessage = "Employee Code is required")]
        public string EmployeeCode { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "First Name is required")]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Last Name is required")]
        public string LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Gender is required")]
        public string Gender { get; set; } = string.Empty;

        public DateTime? DateOfBirth { get; set; }

        [Required(ErrorMessage = "Hire Date is required")]
        public DateTime HireDate { get; set; }

        [Required(ErrorMessage = "Department is required")]
        public int DepartmentId { get; set; }

        [Required(ErrorMessage = "Position is required")]
        public int PositionId { get; set; }

        public int? ManagerId { get; set; }

        [Required(ErrorMessage = "Role is required")]
        public string Role { get; set; } = "Employee";

        public bool IsActive { get; set; } = true;

        // For new employee
        [DataType(DataType.Password)]
        public string? Password { get; set; }

        // For display
        public string? DepartmentName { get; set; }
        public string? PositionName { get; set; }
        public string? ManagerName { get; set; }
    }
}
