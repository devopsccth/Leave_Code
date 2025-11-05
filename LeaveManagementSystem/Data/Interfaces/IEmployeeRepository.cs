using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Data.Interfaces
{
    public interface IEmployeeRepository
    {
        Task<Employee?> ValidateUserAsync(string email);
        Task UpdateLastLoginAsync(int employeeId);
        Task<IEnumerable<Employee>> GetAllEmployeesAsync();
        Task<Employee?> GetEmployeeByIdAsync(int employeeId);
        Task<IEnumerable<Employee>> GetEmployeesByManagerAsync(int managerId);
        Task<int> CreateEmployeeAsync(Employee employee);
        Task<int> UpdateEmployeeAsync(Employee employee);
        Task<int> DeleteEmployeeAsync(int employeeId);
        Task<int> ChangePasswordAsync(int employeeId, string newPasswordHash);
    }
}
