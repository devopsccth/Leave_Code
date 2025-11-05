using System.ComponentModel.DataAnnotations;

namespace LeaveManagementSystem.Models.ViewModels
{
    public class LeaveRequestViewModel
    {
        public int LeaveRequestId { get; set; }
        public string? RequestNumber { get; set; }
        public int EmployeeId { get; set; }

        [Required(ErrorMessage = "Leave Type is required")]
        public int LeaveTypeId { get; set; }

        [Required(ErrorMessage = "Start Date is required")]
        [DataType(DataType.Date)]
        public DateTime StartDate { get; set; }

        [Required(ErrorMessage = "End Date is required")]
        [DataType(DataType.Date)]
        public DateTime EndDate { get; set; }

        [Required(ErrorMessage = "Total Days is required")]
        [Range(0.5, 365, ErrorMessage = "Total days must be between 0.5 and 365")]
        public decimal TotalDays { get; set; }

        [MaxLength(1000, ErrorMessage = "Reason cannot exceed 1000 characters")]
        public string? Reason { get; set; }

        [Required(ErrorMessage = "At least one approver is required")]
        public int Approver1Id { get; set; }

        public int? Approver2Id { get; set; }

        public string? Status { get; set; }

        // For file upload
        public IFormFile? Attachment { get; set; }
        public string? AttachmentPath { get; set; }

        // For display
        public string? LeaveTypeName { get; set; }
        public string? Approver1Name { get; set; }
        public string? Approver2Name { get; set; }
        public decimal RemainingDays { get; set; }
    }

    public class CancelLeaveRequestViewModel
    {
        public int LeaveRequestId { get; set; }
        public string RequestNumber { get; set; } = string.Empty;

        [Required(ErrorMessage = "Cancellation reason is required")]
        [MaxLength(500, ErrorMessage = "Reason cannot exceed 500 characters")]
        public string CancellationReason { get; set; } = string.Empty;
    }

    public class ApproveLeaveRequestViewModel
    {
        public int LeaveRequestId { get; set; }
        public string RequestNumber { get; set; } = string.Empty;
        public string Action { get; set; } = "Approve"; // Approve or Reject

        [MaxLength(1000, ErrorMessage = "Comments cannot exceed 1000 characters")]
        public string? Comments { get; set; }
    }
}
