using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Services.Implementation
{
    public class ReportService : IReportService
    {
        private readonly ILeaveBalanceRepository _leaveBalanceRepository;

        public ReportService(ILeaveBalanceRepository leaveBalanceRepository)
        {
            _leaveBalanceRepository = leaveBalanceRepository;
        }

        public Task<IEnumerable<LeaveBalance>> GetTeamLeaveReportAsync(int managerId, int? year = null)
            => _leaveBalanceRepository.GetTeamLeaveReportAsync(managerId, year);

        public Task<IEnumerable<LeaveBalance>> GetAllEmployeesLeaveReportAsync(int? year = null, int? departmentId = null)
            => _leaveBalanceRepository.GetAllEmployeesLeaveReportAsync(year, departmentId);
    }
}
