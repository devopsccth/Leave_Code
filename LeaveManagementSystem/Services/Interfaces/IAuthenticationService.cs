using LeaveManagementSystem.Models;
using System.Security.Claims;

namespace LeaveManagementSystem.Services.Interfaces
{
    public interface IAuthenticationService
    {
        Task<Employee?> ValidateCredentialsAsync(string email, string password);
        Task<ClaimsPrincipal> CreateClaimsPrincipalAsync(Employee employee);
        Task UpdateLastLoginAsync(int employeeId);
        Task<bool> ChangePasswordAsync(int employeeId, string currentPassword, string newPassword);
        string HashPassword(string password);
        bool VerifyPassword(string password, string hashedPassword);
    }
}
