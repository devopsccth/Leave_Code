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

        public PositionController(IPositionService positionService)
        {
            _positionService = positionService;
        }

        // GET: Position
        public async Task<IActionResult> Index()
        {
            var positions = await _positionService.GetAllPositionsAsync();
            return View(positions);
        }

        // GET: Position/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Position/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Position model)
        {
            if (!ModelState.IsValid)
            {
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
    }
}
