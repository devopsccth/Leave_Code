#!/usr/bin/env dotnet-script
#r "nuget: BCrypt.Net-Next, 4.0.3"

using BCrypt.Net;

// Generate BCrypt hash for Password123!
var password = "Password123!";
var hash = BCrypt.Net.BCrypt.HashPassword(password);

Console.WriteLine("===========================================");
Console.WriteLine("BCrypt Password Hash Generator");
Console.WriteLine("===========================================");
Console.WriteLine($"Password: {password}");
Console.WriteLine($"Hash: {hash}");
Console.WriteLine("===========================================");
Console.WriteLine();
Console.WriteLine("Verification test:");
var isValid = BCrypt.Net.BCrypt.Verify(password, hash);
Console.WriteLine($"Verify '{password}': {isValid}");
Console.WriteLine("===========================================");
