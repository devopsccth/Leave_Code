using BCrypt.Net;

namespace GeneratePasswordHash
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("===========================================");
            Console.WriteLine("BCrypt Password Hash Generator");
            Console.WriteLine("===========================================");
            Console.WriteLine();

            // Default password for demo accounts
            string password = "Password123!";

            if (args.Length > 0)
            {
                password = args[0];
            }

            // Generate BCrypt hash
            string hash = BCrypt.Net.BCrypt.HashPassword(password);

            Console.WriteLine($"Password: {password}");
            Console.WriteLine($"Hash: {hash}");
            Console.WriteLine();
            Console.WriteLine("Verification test:");
            bool isValid = BCrypt.Net.BCrypt.Verify(password, hash);
            Console.WriteLine($"Verify '{password}': {isValid}");
            Console.WriteLine();
            Console.WriteLine("===========================================");
            Console.WriteLine("Copy the hash above and use it in seed data");
            Console.WriteLine("===========================================");
        }
    }
}
