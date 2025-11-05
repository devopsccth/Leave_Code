using System.ComponentModel.DataAnnotations;

namespace LeaveManagementSystem.Models.ViewModels
{
    public class ChangePasswordViewModel
    {
        [Required(ErrorMessage = "กรุณากรอกรหัสผ่านปัจจุบัน")]
        [DataType(DataType.Password)]
        [Display(Name = "รหัสผ่านปัจจุบัน")]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "กรุณากรอกรหัสผ่านใหม่")]
        [DataType(DataType.Password)]
        [MinLength(8, ErrorMessage = "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d]).{8,}$",
            ErrorMessage = "รหัสผ่านต้องประกอบด้วย ตัวพิมพ์เล็ก ตัวพิมพ์ใหญ่ ตัวเลข และอักขระพิเศษ")]
        [Display(Name = "รหัสผ่านใหม่")]
        public string NewPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "กรุณายืนยันรหัสผ่านใหม่")]
        [DataType(DataType.Password)]
        [Compare("NewPassword", ErrorMessage = "รหัสผ่านใหม่และยืนยันรหัสผ่านไม่ตรงกัน")]
        [Display(Name = "ยืนยันรหัสผ่านใหม่")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}
