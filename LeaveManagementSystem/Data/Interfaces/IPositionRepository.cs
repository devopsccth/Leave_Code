using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Data.Interfaces
{
    public interface IPositionRepository
    {
        Task<IEnumerable<Position>> GetAllPositionsAsync();
        Task<Position?> GetPositionByIdAsync(int positionId);
        Task<IEnumerable<Position>> GetPositionsByDepartmentAsync(int departmentId);
        Task<int> CreatePositionAsync(Position position);
        Task<int> UpdatePositionAsync(Position position);
        Task<int> DeletePositionAsync(int positionId);
    }
}
