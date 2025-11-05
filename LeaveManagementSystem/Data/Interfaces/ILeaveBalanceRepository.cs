using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Data.Interfaces
{
    public interface ILeaveBalanceRepository
    {
        Task<IEnumerable<LeaveBalance>> GetLeaveBalanceAsync(int employeeId, int? year = null);
        Task<IEnumerable<LeaveBalance>> GetTeamLeaveReportAsync(int managerId, int? year = null);
        Task<IEnumerable<LeaveBalance>> GetAllEmployeesLeaveReportAsync(int? year = null, int? departmentId = null);
        Task CalculateNextYearLeaveBalancesAsync(int year);
    }
}
