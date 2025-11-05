using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Services.Implementation
{
    public class LeaveTypeService : ILeaveTypeService
    {
        private readonly ILeaveTypeRepository _leaveTypeRepository;

        public LeaveTypeService(ILeaveTypeRepository leaveTypeRepository)
        {
            _leaveTypeRepository = leaveTypeRepository;
        }

        public Task<IEnumerable<LeaveType>> GetAllLeaveTypesAsync() => _leaveTypeRepository.GetAllLeaveTypesAsync();
        public Task<LeaveType?> GetLeaveTypeByIdAsync(int leaveTypeId) => _leaveTypeRepository.GetLeaveTypeByIdAsync(leaveTypeId);
        public Task<IEnumerable<LeaveType>> GetLeaveTypesForEmployeeAsync(int employeeId) => _leaveTypeRepository.GetLeaveTypesForEmployeeAsync(employeeId);
        public Task<int> CreateLeaveTypeAsync(LeaveType leaveType) => _leaveTypeRepository.CreateLeaveTypeAsync(leaveType);
        public Task<int> UpdateLeaveTypeAsync(LeaveType leaveType) => _leaveTypeRepository.UpdateLeaveTypeAsync(leaveType);
        public Task<int> DeleteLeaveTypeAsync(int leaveTypeId) => _leaveTypeRepository.DeleteLeaveTypeAsync(leaveTypeId);
    }
}
