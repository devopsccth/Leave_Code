using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LeaveManagementSystem.Models.ViewModels;
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
            try
            {
                year ??= DateTime.Now.Year;

                var report = await _reportService.GetAllEmployeesLeaveReportPivotAsync(year, departmentId);
                var departments = await _departmentService.GetAllDepartmentsAsync();

                // Get all unique leave type codes for table headers
                var leaveTypeCodes = new List<string>();
                if (report != null && report.Any())
                {
                    leaveTypeCodes = report
                        .SelectMany(r => r.LeaveBalances?.Keys ?? new List<string>())
                        .Where(k => !string.IsNullOrEmpty(k))
                        .Distinct()
                        .OrderBy(k => k)
                        .ToList();
                }

                ViewBag.Year = year;
                ViewBag.DepartmentId = departmentId;
                ViewBag.Years = Enumerable.Range(DateTime.Now.Year - 5, 6).Reverse();
                ViewBag.Departments = departments;
                ViewBag.LeaveTypeCodes = leaveTypeCodes;

                return View(report);
            }
            catch (Exception ex)
            {
                // Log error and show friendly message
                TempData["Error"] = $"เกิดข้อผิดพลาดในการโหลดรายงาน: {ex.Message}";

                // Set ViewBag values for the view to render properly
                ViewBag.Year = year ?? DateTime.Now.Year;
                ViewBag.DepartmentId = departmentId;
                ViewBag.Years = Enumerable.Range(DateTime.Now.Year - 5, 6).Reverse();
                ViewBag.Departments = await _departmentService.GetAllDepartmentsAsync();
                ViewBag.LeaveTypeCodes = new List<string>();

                return View(new List<EmployeeLeaveBalancePivotViewModel>());
            }
        }
    }
}
