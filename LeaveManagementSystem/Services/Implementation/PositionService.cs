using LeaveManagementSystem.Data.Interfaces;
using LeaveManagementSystem.Models;
using LeaveManagementSystem.Services.Interfaces;

namespace LeaveManagementSystem.Services.Implementation
{
    public class PositionService : IPositionService
    {
        private readonly IPositionRepository _positionRepository;

        public PositionService(IPositionRepository positionRepository)
        {
            _positionRepository = positionRepository;
        }

        public Task<IEnumerable<Position>> GetAllPositionsAsync() => _positionRepository.GetAllPositionsAsync();
        public Task<Position?> GetPositionByIdAsync(int positionId) => _positionRepository.GetPositionByIdAsync(positionId);
        public Task<int> CreatePositionAsync(Position position) => _positionRepository.CreatePositionAsync(position);
        public Task<int> UpdatePositionAsync(Position position) => _positionRepository.UpdatePositionAsync(position);
        public Task<int> DeletePositionAsync(int positionId) => _positionRepository.DeletePositionAsync(positionId);
    }
}
