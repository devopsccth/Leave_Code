using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Services.Implementation
{
    public class DepartmentService : IDepartmentService
    {
        private readonly IDepartmentRepository _departmentRepository;

        public DepartmentService(IDepartmentRepository departmentRepository)
        {
            _departmentRepository = departmentRepository;
        }

        public Task<IEnumerable<Department>> GetAllDepartmentsAsync() => _departmentRepository.GetAllDepartmentsAsync();
        public Task<Department?> GetDepartmentByIdAsync(int departmentId) => _departmentRepository.GetDepartmentByIdAsync(departmentId);
        public Task<int> CreateDepartmentAsync(Department department) => _departmentRepository.CreateDepartmentAsync(department);
        public Task<int> UpdateDepartmentAsync(Department department) => _departmentRepository.UpdateDepartmentAsync(department);
        public Task<int> DeleteDepartmentAsync(int departmentId) => _departmentRepository.DeleteDepartmentAsync(departmentId);
    }
}
