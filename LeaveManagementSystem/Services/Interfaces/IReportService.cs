using LeaveManagementSystem.Models;
using LeaveManagementSystem.Models.ViewModels;

namespace LeaveManagementSystem.Services.Interfaces
{
    public interface IReportService
    {
        Task<IEnumerable<LeaveBalance>> GetTeamLeaveReportAsync(int managerId, int? year = null);
        Task<IEnumerable<LeaveBalance>> GetAllEmployeesLeaveReportAsync(int? year = null, int? departmentId = null);
        Task<IEnumerable<EmployeeLeaveBalancePivotViewModel>> GetAllEmployeesLeaveReportPivotAsync(int? year = null, int? departmentId = null);
    }
}
