using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Models.ViewModels;
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

        public async Task<IEnumerable<EmployeeLeaveBalancePivotViewModel>> GetAllEmployeesLeaveReportPivotAsync(int? year = null, int? departmentId = null)
        {
            var leaveBalances = await _leaveBalanceRepository.GetAllEmployeesLeaveReportAsync(year, departmentId);

            // Group by employee and pivot leave types
            var pivotData = leaveBalances
                .GroupBy(lb => new
                {
                    lb.EmployeeId,
                    lb.EmployeeCode,
                    lb.EmployeeName,
                    lb.DepartmentName,
                    lb.PositionName
                })
                .Select(g => new EmployeeLeaveBalancePivotViewModel
                {
                    EmployeeId = g.Key.EmployeeId,
                    EmployeeCode = g.Key.EmployeeCode ?? "",
                    EmployeeName = g.Key.EmployeeName ?? "",
                    DepartmentName = g.Key.DepartmentName ?? "",
                    PositionName = g.Key.PositionName ?? "",
                    LeaveBalances = g.ToDictionary(
                        lb => lb.LeaveTypeCode ?? "",
                        lb => new LeaveTypeBalance
                        {
                            LeaveTypeName = lb.LeaveTypeName ?? "",
                            EntitledDays = lb.EntitledDays,
                            UsedDays = lb.UsedDays,
                            RemainingDays = lb.RemainingDays
                        }
                    )
                })
                .OrderBy(e => e.EmployeeCode)
                .ToList();

            return pivotData;
        }
    }
}
