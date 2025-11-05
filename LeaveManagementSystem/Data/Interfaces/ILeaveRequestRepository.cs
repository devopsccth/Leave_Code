using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Data.Interfaces
{
    public interface ILeaveRequestRepository
    {
        Task<LeaveRequest> CreateLeaveRequestAsync(LeaveRequest request, int approver1Id, int? approver2Id);
        Task<IEnumerable<LeaveRequest>> GetLeaveRequestsByEmployeeAsync(int employeeId, int? year = null);
        Task<LeaveRequest?> GetLeaveRequestByIdAsync(int leaveRequestId);
        Task<IEnumerable<LeaveRequest>> GetPendingApprovalsAsync(int approverId);
        Task<IEnumerable<LeaveRequest>> GetAllLeaveRequestsAsync(int? year = null, string? status = null, int? departmentId = null);
        Task<int> CancelLeaveRequestAsync(int leaveRequestId, int employeeId, string cancellationReason);
    }
}
