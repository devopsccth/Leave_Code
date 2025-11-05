using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Models.ViewModels;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Services.Implementation
{
    public class EmployeeService : IEmployeeService
    {
        private readonly IEmployeeRepository _employeeRepository;
        private readonly IAuthenticationService _authService;

        public EmployeeService(IEmployeeRepository employeeRepository, IAuthenticationService authService)
        {
            _employeeRepository = employeeRepository;
            _authService = authService;
        }

        public async Task<IEnumerable<Employee>> GetAllEmployeesAsync()
        {
            return await _employeeRepository.GetAllEmployeesAsync();
        }

        public async Task<Employee?> GetEmployeeByIdAsync(int employeeId)
        {
            return await _employeeRepository.GetEmployeeByIdAsync(employeeId);
        }

        public async Task<IEnumerable<Employee>> GetEmployeesByManagerAsync(int managerId)
        {
            return await _employeeRepository.GetEmployeesByManagerAsync(managerId);
        }

        public async Task<int> CreateEmployeeAsync(EmployeeViewModel model)
        {
            var employee = new Employee
            {
                EmployeeCode = model.EmployeeCode,
                Email = model.Email,
                PasswordHash = _authService.HashPassword(model.Password ?? "Password123!"),
                FirstName = model.FirstName,
                LastName = model.LastName,
                Gender = model.Gender,
                DateOfBirth = model.DateOfBirth,
                HireDate = model.HireDate,
                DepartmentId = model.DepartmentId,
                PositionId = model.PositionId,
                ManagerId = model.ManagerId,
                Role = model.Role,
                IsActive = model.IsActive
            };

            return await _employeeRepository.CreateEmployeeAsync(employee);
        }

        public async Task<int> UpdateEmployeeAsync(EmployeeViewModel model)
        {
            var employee = new Employee
            {
                EmployeeId = model.EmployeeId,
                EmployeeCode = model.EmployeeCode,
                Email = model.Email,
                FirstName = model.FirstName,
                LastName = model.LastName,
                Gender = model.Gender,
                DateOfBirth = model.DateOfBirth,
                HireDate = model.HireDate,
                DepartmentId = model.DepartmentId,
                PositionId = model.PositionId,
                ManagerId = model.ManagerId,
                Role = model.Role,
                IsActive = model.IsActive
            };

            return await _employeeRepository.UpdateEmployeeAsync(employee);
        }

        public async Task<int> DeleteEmployeeAsync(int employeeId)
        {
            return await _employeeRepository.DeleteEmployeeAsync(employeeId);
        }
    }
}
