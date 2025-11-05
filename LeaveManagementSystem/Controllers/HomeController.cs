using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        private readonly ILeaveRequestService _leaveRequestService;
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILeaveRequestService leaveRequestService, ILogger<HomeController> logger)
        {
            _leaveRequestService = leaveRequestService;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
            var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;

            ViewBag.EmployeeName = User.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value;
            ViewBag.Role = role;

            // Get leave balance
            var leaveBalances = await _leaveRequestService.GetLeaveBalanceAsync(employeeId);
            ViewBag.LeaveBalances = leaveBalances;

            // Get recent leave requests
            var recentRequests = await _leaveRequestService.GetLeaveRequestsByEmployeeAsync(employeeId);
            ViewBag.RecentRequests = recentRequests.Take(5);

            // Get pending approvals (if manager/hr/admin)
            if (role == "Manager" || role == "HR" || role == "Admin")
            {
                var pendingApprovals = await _leaveRequestService.GetPendingApprovalsAsync(employeeId);
                ViewBag.PendingApprovals = pendingApprovals.Take(5);
            }

            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View();
        }
    }
}
