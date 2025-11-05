using Dapper;
using Microsoft.Data.SqlClient;
using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using System.Data;

namespace LeaveManagementSystem.Data.Repositories
{
    public class DepartmentRepository : IDepartmentRepository
    {
        private readonly string _connectionString;

        public DepartmentRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        public async Task<IEnumerable<Department>> GetAllDepartmentsAsync()
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<Department>(
                "SP_GetAllDepartments",
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<Department?> GetDepartmentByIdAsync(int departmentId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<Department>(
                "SP_GetDepartmentById",
                new { DepartmentId = departmentId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> CreateDepartmentAsync(Department department)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_CreateDepartment",
                new { department.DepartmentCode, department.DepartmentName },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> UpdateDepartmentAsync(Department department)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_UpdateDepartment",
                new
                {
                    department.DepartmentId,
                    department.DepartmentCode,
                    department.DepartmentName,
                    department.IsActive
                },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> DeleteDepartmentAsync(int departmentId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_DeleteDepartment",
                new { DepartmentId = departmentId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }
    }
}
