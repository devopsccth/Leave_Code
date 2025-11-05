using Dapper;
using Microsoft.Data.SqlClient;
using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using System.Data;

namespace LeaveManagementSystem.Data.Repositories
{
    public class LeaveApprovalRepository : ILeaveApprovalRepository
    {
        private readonly string _connectionString;

        public LeaveApprovalRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        public async Task<LeaveRequest> ApproveLeaveRequestAsync(int leaveRequestId, int approverId, string? comments)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<LeaveRequest>(
                "SP_ApproveLeaveRequest",
                new
                {
                    LeaveRequestId = leaveRequestId,
                    ApproverId = approverId,
                    Comments = comments
                },
                commandType: CommandType.StoredProcedure
            );
            return result ?? new LeaveRequest();
        }

        public async Task<LeaveRequest> RejectLeaveRequestAsync(int leaveRequestId, int approverId, string comments)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<LeaveRequest>(
                "SP_RejectLeaveRequest",
                new
                {
                    LeaveRequestId = leaveRequestId,
                    ApproverId = approverId,
                    Comments = comments
                },
                commandType: CommandType.StoredProcedure
            );
            return result ?? new LeaveRequest();
        }
    }
}
