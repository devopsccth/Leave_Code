using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LeaveManagementSystem.Models.ViewModels;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Controllers
{
    [Authorize(Policy = "ManagerOnly")]
    public class LeaveApprovalController : Controller
    {
        private readonly ILeaveRequestService _leaveRequestService;
        private readonly ILeaveApprovalService _leaveApprovalService;

        public LeaveApprovalController(
            ILeaveRequestService leaveRequestService,
            ILeaveApprovalService leaveApprovalService)
        {
            _leaveRequestService = leaveRequestService;
            _leaveApprovalService = leaveApprovalService;
        }

        // GET: LeaveApproval
        public async Task<IActionResult> Index()
        {
            var employeeId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
            var pendingApprovals = await _leaveRequestService.GetPendingApprovalsAsync(employeeId);
            return View(pendingApprovals);
        }

        // GET: LeaveApproval/Details/5
        public async Task<IActionResult> Details(int id)
        {
            var request = await _leaveRequestService.GetLeaveRequestByIdAsync(id);

            if (request == null)
            {
                return NotFound();
            }

            return View(request);
        }

        // POST: LeaveApproval/Approve
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Approve(ApproveLeaveRequestViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return RedirectToAction(nameof(Details), new { id = model.LeaveRequestId });
            }

            try
            {
                var approverId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                await _leaveApprovalService.ApproveLeaveRequestAsync(model.LeaveRequestId, approverId, model.Comments);

                TempData["Success"] = "อนุมัติคำขอลาเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"เกิดข้อผิดพลาด: {ex.Message}";
                return RedirectToAction(nameof(Details), new { id = model.LeaveRequestId });
            }
        }

        // POST: LeaveApproval/Reject
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Reject(ApproveLeaveRequestViewModel model)
        {
            if (!ModelState.IsValid || string.IsNullOrEmpty(model.Comments))
            {
                TempData["Error"] = "กรุณาระบุเหตุผลในการปฏิเสธ";
                return RedirectToAction(nameof(Details), new { id = model.LeaveRequestId });
            }

            try
            {
                var approverId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                await _leaveApprovalService.RejectLeaveRequestAsync(model.LeaveRequestId, approverId, model.Comments!);

                TempData["Success"] = "ปฏิเสธคำขอลาเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"เกิดข้อผิดพลาด: {ex.Message}";
                return RedirectToAction(nameof(Details), new { id = model.LeaveRequestId });
            }
        }
    }
}
