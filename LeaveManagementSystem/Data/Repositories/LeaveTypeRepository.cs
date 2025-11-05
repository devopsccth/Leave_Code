using Dapper;
using Microsoft.Data.SqlClient;
using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using System.Data;

namespace LeaveManagementSystem.Data.Repositories
{
    public class LeaveTypeRepository : ILeaveTypeRepository
    {
        private readonly string _connectionString;

        public LeaveTypeRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        public async Task<IEnumerable<LeaveType>> GetAllLeaveTypesAsync()
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveType>(
                "SP_GetAllLeaveTypes",
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<LeaveType?> GetLeaveTypeByIdAsync(int leaveTypeId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<LeaveType>(
                "SP_GetLeaveTypeById",
                new { LeaveTypeId = leaveTypeId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<IEnumerable<LeaveType>> GetLeaveTypesForEmployeeAsync(int employeeId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveType>(
                "SP_GetLeaveTypesForEmployee",
                new { EmployeeId = employeeId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> CreateLeaveTypeAsync(LeaveType leaveType)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_CreateLeaveType",
                new
                {
                    leaveType.LeaveTypeCode,
                    leaveType.LeaveTypeName,
                    leaveType.Description,
                    leaveType.DefaultDays,
                    leaveType.IsProRated,
                    leaveType.RequiresGender,
                    leaveType.ApplicableGender,
                    leaveType.IsPaidLeave,
                    leaveType.RequiresDocumentation,
                    leaveType.MaxConsecutiveDays
                },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> UpdateLeaveTypeAsync(LeaveType leaveType)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_UpdateLeaveType",
                new
                {
                    leaveType.LeaveTypeId,
                    leaveType.LeaveTypeCode,
                    leaveType.LeaveTypeName,
                    leaveType.Description,
                    leaveType.DefaultDays,
                    leaveType.IsProRated,
                    leaveType.RequiresGender,
                    leaveType.ApplicableGender,
                    leaveType.IsPaidLeave,
                    leaveType.RequiresDocumentation,
                    leaveType.MaxConsecutiveDays,
                    leaveType.IsActive
                },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> DeleteLeaveTypeAsync(int leaveTypeId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_DeleteLeaveType",
                new { LeaveTypeId = leaveTypeId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }
    }
}
