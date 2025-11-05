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

            // Return empty list if no data
            if (!leaveBalances.Any())
            {
                return new List<EmployeeLeaveBalancePivotViewModel>();
            }

            // Group by employee and pivot leave types
            var pivotData = leaveBalances
                .Where(lb => lb.EmployeeId > 0) // Filter out invalid records
                .GroupBy(lb => new
                {
                    lb.EmployeeId,
                    EmployeeCode = lb.EmployeeCode ?? "N/A",
                    EmployeeName = lb.EmployeeName ?? "Unknown",
                    DepartmentName = lb.DepartmentName ?? "N/A",
                    PositionName = lb.PositionName ?? "N/A"
                })
                .Select(g =>
                {
                    try
                    {
                        var leaveBalances = new Dictionary<string, LeaveTypeBalance>();

                        foreach (var lb in g)
                        {
                            var key = lb.LeaveTypeCode ?? $"LT_{lb.LeaveTypeId}";

                            // Skip if key already exists (duplicate)
                            if (!leaveBalances.ContainsKey(key))
                            {
                                leaveBalances[key] = new LeaveTypeBalance
                                {
                                    LeaveTypeName = lb.LeaveTypeName ?? key,
                                    EntitledDays = lb.EntitledDays,
                                    UsedDays = lb.UsedDays,
                                    RemainingDays = lb.RemainingDays
                                };
                            }
                        }

                        return new EmployeeLeaveBalancePivotViewModel
                        {
                            EmployeeId = g.Key.EmployeeId,
                            EmployeeCode = g.Key.EmployeeCode,
                            EmployeeName = g.Key.EmployeeName,
                            DepartmentName = g.Key.DepartmentName,
                            PositionName = g.Key.PositionName,
                            LeaveBalances = leaveBalances
                        };
                    }
                    catch
                    {
                        // Return a default record if there's an error
                        return new EmployeeLeaveBalancePivotViewModel
                        {
                            EmployeeId = g.Key.EmployeeId,
                            EmployeeCode = g.Key.EmployeeCode,
                            EmployeeName = g.Key.EmployeeName,
                            DepartmentName = g.Key.DepartmentName,
                            PositionName = g.Key.PositionName,
                            LeaveBalances = new Dictionary<string, LeaveTypeBalance>()
                        };
                    }
                })
                .Where(e => e.EmployeeId > 0) // Filter out any invalid results
                .OrderBy(e => e.EmployeeCode)
                .ToList();

            return pivotData;
        }
    }
}
