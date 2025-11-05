using LeaveManagementSystem.Models;
using LeaveManagementSystem.Models.ViewModels;

namespace LeaveManagementSystem.Services.Interfaces
{
    public interface IEmployeeService
    {
        Task<IEnumerable<Employee>> GetAllEmployeesAsync();
        Task<Employee?> GetEmployeeByIdAsync(int employeeId);
        Task<IEnumerable<Employee>> GetEmployeesByManagerAsync(int managerId);
        Task<int> CreateEmployeeAsync(EmployeeViewModel model);
        Task<int> UpdateEmployeeAsync(EmployeeViewModel model);
        Task<int> DeleteEmployeeAsync(int employeeId);
    }
}
