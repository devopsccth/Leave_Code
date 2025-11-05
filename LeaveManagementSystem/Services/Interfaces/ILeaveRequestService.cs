using LeaveManagementSystem.Models;
using LeaveManagementSystem.Models.ViewModels;

namespace LeaveManagementSystem.Services.Interfaces
{
    public interface ILeaveRequestService
    {
        Task<LeaveRequest> CreateLeaveRequestAsync(LeaveRequestViewModel model, int employeeId);
        Task<IEnumerable<LeaveRequest>> GetLeaveRequestsByEmployeeAsync(int employeeId, int? year = null);
        Task<LeaveRequest?> GetLeaveRequestByIdAsync(int leaveRequestId);
        Task<IEnumerable<LeaveRequest>> GetPendingApprovalsAsync(int approverId);
        Task<IEnumerable<LeaveRequest>> GetAllLeaveRequestsAsync(int? year = null, string? status = null, int? departmentId = null);
        Task<int> CancelLeaveRequestAsync(int leaveRequestId, int employeeId, string cancellationReason);
        Task<IEnumerable<LeaveBalance>> GetLeaveBalanceAsync(int employeeId, int? year = null);
    }
}
