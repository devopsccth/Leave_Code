using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Controllers
{
    [Authorize(Policy = "HROnly")]
    public class PositionController : Controller
    {
        private readonly IPositionService _positionService;
        private readonly IDepartmentService _departmentService;

        public PositionController(IPositionService positionService, IDepartmentService departmentService)
        {
            _positionService = positionService;
            _departmentService = departmentService;
        }

        // GET: Position
        public async Task<IActionResult> Index()
        {
            var positions = await _positionService.GetAllPositionsAsync();
            return View(positions);
        }

        // GET: Position/Create
        public async Task<IActionResult> Create()
        {
            await LoadDepartmentsAsync();
            return View();
        }

        // POST: Position/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Position model)
        {
            if (!ModelState.IsValid)
            {
                await LoadDepartmentsAsync();
                return View(model);
            }

            try
            {
                await _positionService.CreatePositionAsync(model);
                TempData["Success"] = "สร้างตำแหน่งเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"เกิดข้อผิดพลาด: {ex.Message}");
                await LoadDepartmentsAsync();
                return View(model);
            }
        }

        // GET: Position/Edit/5
        public async Task<IActionResult> Edit(int id)
        {
            var position = await _positionService.GetPositionByIdAsync(id);
            if (position == null)
            {
                return NotFound();
            }
            await LoadDepartmentsAsync();
            return View(position);
        }

        // POST: Position/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Position model)
        {
            if (id != model.PositionId)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                await LoadDepartmentsAsync();
                return View(model);
            }

            try
            {
                await _positionService.UpdatePositionAsync(model);
                TempData["Success"] = "แก้ไขข้อมูลตำแหน่งเรียบร้อยแล้ว";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"เกิดข้อผิดพลาด: {ex.Message}");
                await LoadDepartmentsAsync();
                return View(model);
            }
        }

        // POST: Position/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _positionService.DeletePositionAsync(id);
                TempData["Success"] = "ลบตำแหน่งเรียบร้อยแล้ว";
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"เกิดข้อผิดพลาด: {ex.Message}";
            }
            return RedirectToAction(nameof(Index));
        }

        // Helper method to load departments
        private async Task LoadDepartmentsAsync()
        {
            var departments = await _departmentService.GetAllDepartmentsAsync();
            ViewBag.Departments = departments;
        }
    }
}
