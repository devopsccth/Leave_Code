using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;
using System.Text.Json;

namespace LeaveManagementSystem.Services.Implementation
{
    public class LeaveApprovalService : ILeaveApprovalService
    {
        private readonly ILeaveApprovalRepository _leaveApprovalRepository;
        private readonly IEmailService _emailService;

        public LeaveApprovalService(ILeaveApprovalRepository leaveApprovalRepository, IEmailService emailService)
        {
            _leaveApprovalRepository = leaveApprovalRepository;
            _emailService = emailService;
        }

        public async Task<LeaveRequest> ApproveLeaveRequestAsync(int leaveRequestId, int approverId, string? comments)
        {
            var result = await _leaveApprovalRepository.ApproveLeaveRequestAsync(leaveRequestId, approverId, comments);

            // Send email if all approvers have approved
            if (result.AllApproved == true && result.Status == "Approved" && !string.IsNullOrEmpty(result.EmployeeEmail))
            {
                var hrEmails = new List<string>();

                // Parse HR emails from JSON if provided
                if (!string.IsNullOrEmpty(result.HREmails))
                {
                    try
                    {
                        var hrEmailObjects = JsonSerializer.Deserialize<List<Dictionary<string, string>>>(result.HREmails);
                        if (hrEmailObjects != null)
                        {
                            hrEmails = hrEmailObjects
                                .Where(obj => obj.ContainsKey("Email"))
                                .Select(obj => obj["Email"])
                                .ToList();
                        }
                    }
                    catch (JsonException)
                    {
                        // If JSON parsing fails, continue without HR emails
                        hrEmails = new List<string>();
                    }
                }

                await _emailService.SendLeaveApprovedNotificationAsync(
                    result,
                    result.EmployeeEmail,
                    result.ManagerEmail ?? "",
                    hrEmails
                );
            }

            return result;
        }

        public async Task<LeaveRequest> RejectLeaveRequestAsync(int leaveRequestId, int approverId, string comments)
        {
            var result = await _leaveApprovalRepository.RejectLeaveRequestAsync(leaveRequestId, approverId, comments);

            // Send rejection email to employee
            if (!string.IsNullOrEmpty(result.EmployeeEmail))
            {
                await _emailService.SendLeaveRejectedNotificationAsync(result, result.EmployeeEmail, comments);
            }

            return result;
        }
    }
}
