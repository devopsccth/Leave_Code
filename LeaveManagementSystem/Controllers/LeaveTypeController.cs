using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Controllers
{
    [Authorize(Policy = "HROnly")]
    public class LeaveTypeController : Controller
    {
        private readonly ILeaveTypeService _leaveTypeService;

        public LeaveTypeController(ILeaveTypeService leaveTypeService)
        {
            _leaveTypeService = leaveTypeService;
        }

        // GET: LeaveType
        public async Task<IActionResult> Index()
        {
            var leaveTypes = await _leaveTypeService.GetAllLeaveTypesAsync();
            return View(leaveTypes);
        }

        // GET: LeaveType/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: LeaveType/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(LeaveType model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                await _leaveTypeService.CreateLeaveTypeAsync(model);
                TempData["Success"] = "สร้างประเภทการลาเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"เกิดข้อผิดพลาด: {ex.Message}");
                return View(model);
            }
        }

        // GET: LeaveType/Edit/5
        public async Task<IActionResult> Edit(int id)
        {
            var leaveType = await _leaveTypeService.GetLeaveTypeByIdAsync(id);
            if (leaveType == null)
            {
                return NotFound();
            }
            return View(leaveType);
        }

        // POST: LeaveType/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, LeaveType model)
        {
            if (id != model.LeaveTypeId)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                await _leaveTypeService.UpdateLeaveTypeAsync(model);
                TempData["Success"] = "แก้ไขข้อมูลประเภทการลาเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"เกิดข้อผิดพลาด: {ex.Message}");
                return View(model);
            }
        }

        // POST: LeaveType/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _leaveTypeService.DeleteLeaveTypeAsync(id);
                TempData["Success"] = "ลบประเภทการลาเรียบร้อยแล้ว";
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"เกิดข้อผิดพลาด: {ex.Message}";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
