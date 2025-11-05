using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;
using System.Net;
using System.Net.Mail;

namespace LeaveManagementSystem.Services.Implementation
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendLeaveRequestNotificationAsync(LeaveRequest request, string approverEmail)
        {
            var subject = $"Leave Request Pending Approval - {request.RequestNumber}";
            var body = $@"
                <h2>New Leave Request Pending Your Approval</h2>
                <p><strong>Request Number:</strong> {request.RequestNumber}</p>
                <p><strong>Employee:</strong> {request.EmployeeName}</p>
                <p><strong>Leave Type:</strong> {request.LeaveTypeName}</p>
                <p><strong>Start Date:</strong> {request.StartDate:dd/MM/yyyy}</p>
                <p><strong>End Date:</strong> {request.EndDate:dd/MM/yyyy}</p>
                <p><strong>Total Days:</strong> {request.TotalDays}</p>
                <p><strong>Reason:</strong> {request.Reason}</p>
                <p>Please log in to the system to approve or reject this request.</p>
            ";

            await SendEmailAsync(approverEmail, subject, body);
        }

        public async Task SendLeaveApprovedNotificationAsync(LeaveRequest request, string employeeEmail, string managerEmail, List<string> hrEmails)
        {
            var subject = $"Leave Request Approved - {request.RequestNumber}";
            var body = $@"
                <h2>Leave Request Approved</h2>
                <p><strong>Request Number:</strong> {request.RequestNumber}</p>
                <p><strong>Employee:</strong> {request.EmployeeName}</p>
                <p><strong>Leave Type:</strong> {request.LeaveTypeName}</p>
                <p><strong>Start Date:</strong> {request.StartDate:dd/MM/yyyy}</p>
                <p><strong>End Date:</strong> {request.EndDate:dd/MM/yyyy}</p>
                <p><strong>Total Days:</strong> {request.TotalDays}</p>
                <p>Your leave request has been approved.</p>
            ";

            // Send to employee
            await SendEmailAsync(employeeEmail, subject, body);

            // Send to manager
            if (!string.IsNullOrEmpty(managerEmail))
            {
                await SendEmailAsync(managerEmail, subject, body);
            }

            // Send to HR
            foreach (var hrEmail in hrEmails)
            {
                if (!string.IsNullOrEmpty(hrEmail))
                {
                    await SendEmailAsync(hrEmail, subject, body);
                }
            }
        }

        public async Task SendLeaveRejectedNotificationAsync(LeaveRequest request, string employeeEmail, string reason)
        {
            var subject = $"Leave Request Rejected - {request.RequestNumber}";
            var body = $@"
                <h2>Leave Request Rejected</h2>
                <p><strong>Request Number:</strong> {request.RequestNumber}</p>
                <p><strong>Leave Type:</strong> {request.LeaveTypeName}</p>
                <p><strong>Start Date:</strong> {request.StartDate:dd/MM/yyyy}</p>
                <p><strong>End Date:</strong> {request.EndDate:dd/MM/yyyy}</p>
                <p><strong>Total Days:</strong> {request.TotalDays}</p>
                <p><strong>Rejection Reason:</strong> {reason}</p>
                <p>Your leave request has been rejected. Please contact your manager for more details.</p>
            ";

            await SendEmailAsync(employeeEmail, subject, body);
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            try
            {
                var smtpServer = _configuration["EmailSettings:SmtpServer"];
                var smtpPort = int.Parse(_configuration["EmailSettings:SmtpPort"] ?? "587");
                var senderEmail = _configuration["EmailSettings:SenderEmail"];
                var senderName = _configuration["EmailSettings:SenderName"];
                var username = _configuration["EmailSettings:Username"];
                var password = _configuration["EmailSettings:Password"];
                var enableSsl = bool.Parse(_configuration["EmailSettings:EnableSsl"] ?? "true");

                using var client = new SmtpClient(smtpServer, smtpPort)
                {
                    Credentials = new NetworkCredential(username, password),
                    EnableSsl = enableSsl
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(senderEmail ?? "", senderName ?? ""),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true
                };

                mailMessage.To.Add(toEmail);

                await client.SendMailAsync(mailMessage);

                _logger.LogInformation($"Email sent successfully to {toEmail}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send email to {toEmail}: {ex.Message}");
                // Don't throw exception - email failure shouldn't break the application
            }
        }
    }
}
