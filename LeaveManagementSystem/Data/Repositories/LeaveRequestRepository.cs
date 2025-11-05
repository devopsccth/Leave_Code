using Dapper;
using Microsoft.Data.SqlClient;
using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using System.Data;

namespace LeaveManagementSystem.Data.Repositories
{
    public class LeaveRequestRepository : ILeaveRequestRepository
    {
        private readonly string _connectionString;

        public LeaveRequestRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        public async Task<LeaveRequest> CreateLeaveRequestAsync(LeaveRequest request, int approver1Id, int? approver2Id)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<LeaveRequest>(
                "SP_CreateLeaveRequest",
                new
                {
                    request.EmployeeId,
                    request.LeaveTypeId,
                    request.StartDate,
                    request.EndDate,
                    request.TotalDays,
                    request.Reason,
                    Approver1Id = approver1Id,
                    Approver2Id = approver2Id,
                    request.AttachmentPath
                },
                commandType: CommandType.StoredProcedure
            );
            return result ?? new LeaveRequest();
        }

        public async Task<IEnumerable<LeaveRequest>> GetLeaveRequestsByEmployeeAsync(int employeeId, int? year = null)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveRequest>(
                "SP_GetLeaveRequestsByEmployee",
                new { EmployeeId = employeeId, Year = year },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<LeaveRequest?> GetLeaveRequestByIdAsync(int leaveRequestId)
        {
            using var connection = new SqlConnection(_connectionString);

            using var multi = await connection.QueryMultipleAsync(
                "SP_GetLeaveRequestById",
                new { LeaveRequestId = leaveRequestId },
                commandType: CommandType.StoredProcedure
            );

            var request = await multi.ReadFirstOrDefaultAsync<LeaveRequest>();
            if (request != null)
            {
                request.Approvers = (await multi.ReadAsync<LeaveApprover>()).ToList();
                request.History = (await multi.ReadAsync<LeaveApprovalHistory>()).ToList();
            }

            return request;
        }

        public async Task<IEnumerable<LeaveRequest>> GetPendingApprovalsAsync(int approverId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveRequest>(
                "SP_GetPendingApprovals",
                new { ApproverId = approverId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<IEnumerable<LeaveRequest>> GetAllLeaveRequestsAsync(int? year = null, string? status = null, int? departmentId = null)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveRequest>(
                "SP_GetAllLeaveRequests",
                new { Year = year, Status = status, DepartmentId = departmentId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> CancelLeaveRequestAsync(int leaveRequestId, int employeeId, string cancellationReason)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_CancelLeaveRequest",
                new
                {
                    LeaveRequestId = leaveRequestId,
                    EmployeeId = employeeId,
                    CancellationReason = cancellationReason
                },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }
    }
}
