using Dapper;
using Microsoft.Data.SqlClient;
using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using System.Data;

namespace LeaveManagementSystem.Data.Repositories
{
    public class LeaveBalanceRepository : ILeaveBalanceRepository
    {
        private readonly string _connectionString;

        public LeaveBalanceRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        public async Task<IEnumerable<LeaveBalance>> GetLeaveBalanceAsync(int employeeId, int? year = null)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveBalance>(
                "SP_GetLeaveBalance",
                new { EmployeeId = employeeId, Year = year },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<IEnumerable<LeaveBalance>> GetTeamLeaveReportAsync(int managerId, int? year = null)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveBalance>(
                "SP_GetTeamLeaveReport",
                new { ManagerId = managerId, Year = year },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<IEnumerable<LeaveBalance>> GetAllEmployeesLeaveReportAsync(int? year = null, int? departmentId = null)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<LeaveBalance>(
                "SP_GetAllEmployeesLeaveReport",
                new { Year = year, DepartmentId = departmentId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task CalculateNextYearLeaveBalancesAsync(int year)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.ExecuteAsync(
                "SP_CalculateNextYearLeaveBalances",
                new { Year = year },
                commandType: CommandType.StoredProcedure,
                commandTimeout: 120 // 2 minutes timeout for year-end calculation
            );
        }
    }
}
