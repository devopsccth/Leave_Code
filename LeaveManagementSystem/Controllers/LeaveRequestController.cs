using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LeaveManagementSystem.Models.ViewModels;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Controllers
{
    [Authorize]
    public class LeaveRequestController : Controller
    {
        private readonly ILeaveRequestService _leaveRequestService;
        private readonly ILeaveTypeService _leaveTypeService;
        private readonly IEmployeeService _employeeService;

        public LeaveRequestController(
            ILeaveRequestService leaveRequestService,
            ILeaveTypeService leaveTypeService,
            IEmployeeService employeeService)
        {
            _leaveRequestService = leaveRequestService;
            _leaveTypeService = leaveTypeService;
            _employeeService = employeeService;
        }

        // GET: LeaveRequest
        public async Task<IActionResult> Index()
        {
            var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
            var requests = await _leaveRequestService.GetLeaveRequestsByEmployeeAsync(employeeId);
            return View(requests);
        }

        // GET: LeaveRequest/Create
        public async Task<IActionResult> Create()
        {
            var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");

            // Get leave types available for employee
            var leaveTypes = await _leaveTypeService.GetLeaveTypesForEmployeeAsync(employeeId);
            ViewBag.LeaveTypes = leaveTypes;

            // Get potential approvers (managers, HR, admins)
            var employees = await _employeeService.GetAllEmployeesAsync();
            var approvers = employees.Where(e => e.Role == "Manager" || e.Role == "HR" || e.Role == "Admin");
            ViewBag.Approvers = approvers;

            return View();
        }

        // POST: LeaveRequest/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(LeaveRequestViewModel model)
        {
            if (!ModelState.IsValid)
            {
                var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                var leaveTypes = await _leaveTypeService.GetLeaveTypesForEmployeeAsync(employeeId);
                ViewBag.LeaveTypes = leaveTypes;
                var employees = await _employeeService.GetAllEmployeesAsync();
                var approvers = employees.Where(e => e.Role == "Manager" || e.Role == "HR" || e.Role == "Admin");
                ViewBag.Approvers = approvers;
                return View(model);
            }

            try
            {
                var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                await _leaveRequestService.CreateLeaveRequestAsync(model, employeeId);

                TempData["Success"] = "ส่งคำขอลาเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"เกิดข้อผิดพลาด: {ex.Message}");
                return View(model);
            }
        }

        // GET: LeaveRequest/Details/5
        public async Task<IActionResult> Details(int id)
        {
            var request = await _leaveRequestService.GetLeaveRequestByIdAsync(id);

            if (request == null)
            {
                return NotFound();
            }

            var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
            var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;

            // Check authorization
            if (request.EmployeeId != employeeId && role != "HR" && role != "Admin")
            {
                return Forbid();
            }

            return View(request);
        }

        // POST: LeaveRequest/Cancel
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Cancel(CancelLeaveRequestViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return RedirectToAction(nameof(Details), new { id = model.LeaveRequestId });
            }

            try
            {
                var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                await _leaveRequestService.CancelLeaveRequestAsync(model.LeaveRequestId, employeeId, model.CancellationReason);

                TempData["Success"] = "ยกเลิกคำขอลาเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"เกิดข้อผิดพลาด: {ex.Message}";
                return RedirectToAction(nameof(Details), new { id = model.LeaveRequestId });
            }
        }

        // GET: LeaveRequest/MyBalance
        public async Task<IActionResult> MyBalance()
        {
            var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
            var balances = await _leaveRequestService.GetLeaveBalanceAsync(employeeId);
            return View(balances);
        }
    }
}
