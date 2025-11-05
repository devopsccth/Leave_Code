using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Services.Interfaces
{
    public interface ILeaveApprovalService
    {
        Task<LeaveRequest> ApproveLeaveRequestAsync(int leaveRequestId, int approverId, string? comments);
        Task<LeaveRequest> RejectLeaveRequestAsync(int leaveRequestId, int approverId, string comments);
    }
}
