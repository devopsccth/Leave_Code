using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Data.Interfaces
{
    public interface ILeaveTypeRepository
    {
        Task<IEnumerable<LeaveType>> GetAllLeaveTypesAsync();
        Task<LeaveType?> GetLeaveTypeByIdAsync(int leaveTypeId);
        Task<IEnumerable<LeaveType>> GetLeaveTypesForEmployeeAsync(int employeeId);
        Task<int> CreateLeaveTypeAsync(LeaveType leaveType);
        Task<int> UpdateLeaveTypeAsync(LeaveType leaveType);
        Task<int> DeleteLeaveTypeAsync(int leaveTypeId);
    }
}
