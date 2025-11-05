using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Controllers
{
    [Authorize]
    public class ReportController : Controller
    {
        private readonly IReportService _reportService;
        private readonly IDepartmentService _departmentService;

        public ReportController(IReportService reportService, IDepartmentService departmentService)
        {
            _reportService = reportService;
            _departmentService = departmentService;
        }

        // GET: Report/TeamLeave - For Managers
        [Authorize(Policy = "ManagerOnly")]
        public async Task<IActionResult> TeamLeave(int? year)
        {
            var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
            year ??= DateTime.Now.Year;

            var report = await _reportService.GetTeamLeaveReportAsync(employeeId, year);

            ViewBag.Year = year;
            ViewBag.Years = Enumerable.Range(DateTime.Now.Year - 5, 6).Reverse();

            return View(report);
        }

        // GET: Report/AllEmployeesLeave - For HR/Admin
        [Authorize(Policy = "HROnly")]
        public async Task<IActionResult> AllEmployeesLeave(int? year, int? departmentId)
        {
            year ??= DateTime.Now.Year;

            var report = await _reportService.GetAllEmployeesLeaveReportPivotAsync(year, departmentId);
            var departments = await _departmentService.GetAllDepartmentsAsync();

            // Get all unique leave type codes for table headers
            var leaveTypeCodes = report
                .SelectMany(r => r.LeaveBalances.Keys)
                .Distinct()
                .OrderBy(k => k)
                .ToList();

            ViewBag.Year = year;
            ViewBag.DepartmentId = departmentId;
            ViewBag.Years = Enumerable.Range(DateTime.Now.Year - 5, 6).Reverse();
            ViewBag.Departments = departments;
            ViewBag.LeaveTypeCodes = leaveTypeCodes;

            return View(report);
        }
    }
}
