using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Data.Interfaces
{
    public interface ILeaveApprovalRepository
    {
        Task<LeaveRequest> ApproveLeaveRequestAsync(int leaveRequestId, int approverId, string? comments);
        Task<LeaveRequest> RejectLeaveRequestAsync(int leaveRequestId, int approverId, string comments);
    }
}
