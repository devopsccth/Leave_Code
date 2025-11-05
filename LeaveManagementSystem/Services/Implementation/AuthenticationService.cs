using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;
using System.Security.Claims;
using BCrypt.Net;

namespace LeaveManagementSystem.Services.Implementation
{
    public class AuthenticationService : IAuthenticationService
    {
        private readonly IEmployeeRepository _employeeRepository;

        public AuthenticationService(IEmployeeRepository employeeRepository)
        {
            _employeeRepository = employeeRepository;
        }

        public async Task<Employee?> ValidateCredentialsAsync(string email, string password)
        {
            var employee = await _employeeRepository.ValidateUserAsync(email);

            if (employee == null || !employee.IsActive)
                return null;

            // Verify password
            if (!VerifyPassword(password, employee.PasswordHash))
                return null;

            return employee;
        }

        public async Task<ClaimsPrincipal> CreateClaimsPrincipalAsync(Employee employee)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, employee.EmployeeId.ToString()),
                new Claim(ClaimTypes.Email, employee.Email),
                new Claim(ClaimTypes.Name, employee.FullName),
                new Claim(ClaimTypes.Role, employee.Role),
                new Claim("EmployeeCode", employee.EmployeeCode),
                new Claim("DepartmentId", employee.DepartmentId.ToString()),
                new Claim("PositionId", employee.PositionId.ToString())
            };

            if (employee.ManagerId.HasValue)
            {
                claims.Add(new Claim("ManagerId", employee.ManagerId.Value.ToString()));
            }

            var identity = new ClaimsIdentity(claims, "Cookie");
            return new ClaimsPrincipal(identity);
        }

        public async Task UpdateLastLoginAsync(int employeeId)
        {
            await _employeeRepository.UpdateLastLoginAsync(employeeId);
        }

        public async Task<bool> ChangePasswordAsync(int employeeId, string currentPassword, string newPassword)
        {
            var employee = await _employeeRepository.GetEmployeeByIdAsync(employeeId);

            if (employee == null || !VerifyPassword(currentPassword, employee.PasswordHash))
                return false;

            var newPasswordHash = HashPassword(newPassword);
            var result = await _employeeRepository.ChangePasswordAsync(employeeId, newPasswordHash);

            return result > 0;
        }

        public string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        public bool VerifyPassword(string password, string hashedPassword)
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(password, hashedPassword);
            }
            catch
            {
                return false;
            }
        }
    }
}
