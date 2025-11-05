using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Models.ViewModels;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Services.Implementation
{
    public class LeaveRequestService : ILeaveRequestService
    {
        private readonly ILeaveRequestRepository _leaveRequestRepository;
        private readonly ILeaveBalanceRepository _leaveBalanceRepository;
        private readonly IEmailService _emailService;
        private readonly IEmployeeRepository _employeeRepository;

        public LeaveRequestService(
            ILeaveRequestRepository leaveRequestRepository,
            ILeaveBalanceRepository leaveBalanceRepository,
            IEmailService emailService,
            IEmployeeRepository employeeRepository)
        {
            _leaveRequestRepository = leaveRequestRepository;
            _leaveBalanceRepository = leaveBalanceRepository;
            _emailService = emailService;
            _employeeRepository = employeeRepository;
        }

        public async Task<LeaveRequest> CreateLeaveRequestAsync(LeaveRequestViewModel model, int employeeId)
        {
            var request = new LeaveRequest
            {
                EmployeeId = employeeId,
                LeaveTypeId = model.LeaveTypeId,
                StartDate = model.StartDate,
                EndDate = model.EndDate,
                TotalDays = model.TotalDays,
                Reason = model.Reason,
                AttachmentPath = model.AttachmentPath
            };

            var result = await _leaveRequestRepository.CreateLeaveRequestAsync(request, model.Approver1Id, model.Approver2Id);

            // Send email notification to approver(s)
            var approver1 = await _employeeRepository.GetEmployeeByIdAsync(model.Approver1Id);
            if (approver1 != null)
            {
                await _emailService.SendLeaveRequestNotificationAsync(result, approver1.Email);
            }

            return result;
        }

        public Task<IEnumerable<LeaveRequest>> GetLeaveRequestsByEmployeeAsync(int employeeId, int? year = null)
            => _leaveRequestRepository.GetLeaveRequestsByEmployeeAsync(employeeId, year);

        public Task<LeaveRequest?> GetLeaveRequestByIdAsync(int leaveRequestId)
            => _leaveRequestRepository.GetLeaveRequestByIdAsync(leaveRequestId);

        public Task<IEnumerable<LeaveRequest>> GetPendingApprovalsAsync(int approverId)
            => _leaveRequestRepository.GetPendingApprovalsAsync(approverId);

        public Task<IEnumerable<LeaveRequest>> GetAllLeaveRequestsAsync(int? year = null, string? status = null, int? departmentId = null)
            => _leaveRequestRepository.GetAllLeaveRequestsAsync(year, status, departmentId);

        public Task<int> CancelLeaveRequestAsync(int leaveRequestId, int employeeId, string cancellationReason)
            => _leaveRequestRepository.CancelLeaveRequestAsync(leaveRequestId, employeeId, cancellationReason);

        public Task<IEnumerable<LeaveBalance>> GetLeaveBalanceAsync(int employeeId, int? year = null)
            => _leaveBalanceRepository.GetLeaveBalanceAsync(employeeId, year);
    }
}
