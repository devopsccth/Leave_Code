using Dapper;
using Microsoft.Data.SqlClient;
using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using System.Data;

namespace LeaveManagementSystem.Data.Repositories
{
    public class PositionRepository : IPositionRepository
    {
        private readonly string _connectionString;

        public PositionRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        public async Task<IEnumerable<Position>> GetAllPositionsAsync()
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<Position>(
                "SP_GetAllPositions",
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<Position?> GetPositionByIdAsync(int positionId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<Position>(
                "SP_GetPositionById",
                new { PositionId = positionId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<IEnumerable<Position>> GetPositionsByDepartmentAsync(int departmentId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<Position>(
                "SP_GetPositionsByDepartment",
                new { DepartmentId = departmentId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> CreatePositionAsync(Position position)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_CreatePosition",
                new { position.PositionCode, position.PositionName, position.DepartmentId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> UpdatePositionAsync(Position position)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_UpdatePosition",
                new
                {
                    position.PositionId,
                    position.PositionCode,
                    position.PositionName,
                    position.DepartmentId,
                    position.IsActive
                },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> DeletePositionAsync(int positionId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_DeletePosition",
                new { PositionId = positionId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }
    }
}
