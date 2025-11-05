using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Data.Interfaces
{
    public interface IDepartmentRepository
    {
        Task<IEnumerable<Department>> GetAllDepartmentsAsync();
        Task<Department?> GetDepartmentByIdAsync(int departmentId);
        Task<int> CreateDepartmentAsync(Department department);
        Task<int> UpdateDepartmentAsync(Department department);
        Task<int> DeleteDepartmentAsync(int departmentId);
    }
}
