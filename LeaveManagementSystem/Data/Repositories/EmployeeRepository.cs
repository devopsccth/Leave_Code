using Dapper;
using Microsoft.Data.SqlClient;
using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using System.Data;

namespace LeaveManagementSystem.Data.Repositories
{
    public class EmployeeRepository : IEmployeeRepository
    {
        private readonly string _connectionString;

        public EmployeeRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        public async Task<Employee?> ValidateUserAsync(string email)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<Employee>(
                "SP_ValidateUser",
                new { Email = email },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task UpdateLastLoginAsync(int employeeId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.ExecuteAsync(
                "SP_UpdateLastLogin",
                new { EmployeeId = employeeId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<Employee>> GetAllEmployeesAsync()
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<Employee>(
                "SP_GetAllEmployees",
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<Employee?> GetEmployeeByIdAsync(int employeeId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryFirstOrDefaultAsync<Employee>(
                "SP_GetEmployeeById",
                new { EmployeeId = employeeId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<IEnumerable<Employee>> GetEmployeesByManagerAsync(int managerId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QueryAsync<Employee>(
                "SP_GetEmployeesByManager",
                new { ManagerId = managerId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> CreateEmployeeAsync(Employee employee)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_CreateEmployee",
                new
                {
                    employee.EmployeeCode,
                    employee.Email,
                    employee.PasswordHash,
                    employee.FirstName,
                    employee.LastName,
                    employee.Gender,
                    employee.DateOfBirth,
                    employee.HireDate,
                    employee.DepartmentId,
                    employee.PositionId,
                    employee.ManagerId,
                    employee.Role
                },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> UpdateEmployeeAsync(Employee employee)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_UpdateEmployee",
                new
                {
                    employee.EmployeeId,
                    employee.EmployeeCode,
                    employee.Email,
                    employee.FirstName,
                    employee.LastName,
                    employee.Gender,
                    employee.DateOfBirth,
                    employee.HireDate,
                    employee.DepartmentId,
                    employee.PositionId,
                    employee.ManagerId,
                    employee.Role,
                    employee.IsActive
                },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> DeleteEmployeeAsync(int employeeId)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_DeleteEmployee",
                new { EmployeeId = employeeId },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }

        public async Task<int> ChangePasswordAsync(int employeeId, string newPasswordHash)
        {
            using var connection = new SqlConnection(_connectionString);
            var result = await connection.QuerySingleAsync<int>(
                "SP_ChangePassword",
                new { EmployeeId = employeeId, NewPasswordHash = newPasswordHash },
                commandType: CommandType.StoredProcedure
            );
            return result;
        }
    }
}
