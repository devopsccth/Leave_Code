using BCrypt.Net;

namespace LeaveManagementSystem.Utils
{
    /// <summary>
    /// Utility class for generating BCrypt password hashes for seed data
    /// </summary>
    public static class PasswordHashGenerator
    {
        /// <summary>
        /// Generate BCrypt hash for a password
        /// </summary>
        public static string GenerateHash(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        /// <summary>
        /// Verify if a password matches a hash
        /// </summary>
        public static bool VerifyHash(string password, string hash)
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(password, hash);
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Generate hash for default password: Password123!
        /// This is used for all demo/seed accounts
        /// </summary>
        public static string GetDefaultPasswordHash()
        {
            // BCrypt hash for: Password123!
            // Generated using BCrypt.Net.BCrypt.HashPassword("Password123!")
            return "$2a$11$xq8Z5K8rN6vZFJYJ5ZqJ5.2YqJ4zN8H2yP7LmN5kR8jQ3xW6zN8K2";
        }

        /// <summary>
        /// For testing/development: Generate and print hash
        /// </summary>
        public static void PrintHash(string password)
        {
            var hash = GenerateHash(password);
            Console.WriteLine("===========================================");
            Console.WriteLine($"Password: {password}");
            Console.WriteLine($"Hash: {hash}");
            Console.WriteLine($"Verify: {VerifyHash(password, hash)}");
            Console.WriteLine("===========================================");
        }
    }
}
