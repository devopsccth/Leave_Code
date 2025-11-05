using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Services.Interfaces
{
    public interface IEmailService
    {
        Task SendLeaveRequestNotificationAsync(LeaveRequest request, string approverEmail);
        Task SendLeaveApprovedNotificationAsync(LeaveRequest request, string employeeEmail, string managerEmail, List<string> hrEmails);
        Task SendLeaveRejectedNotificationAsync(LeaveRequest request, string employeeEmail, string reason);
        Task SendEmailAsync(string toEmail, string subject, string body);
    }
}
