# BCrypt Password Hash Generator

This tool generates BCrypt hashes for passwords to use in database seed data.

## Usage

```bash
# Generate hash for default password (Password123!)
dotnet run

# Generate hash for custom password
dotnet run "YourPassword"
```

## Example Output

```
===========================================
BCrypt Password Hash Generator
===========================================

Password: Password123!
Hash: $2a$11$xyz...
```

## For Database Seed Data

1. Run this tool to generate a hash
2. Copy the generated hash
3. Replace the placeholder hash in `Database/Scripts/02_SeedData_Updated.sql`
4. Update line with `@PasswordHash` variable

## Default Password

The default password for all demo/seed accounts is: `Password123!`

**IMPORTANT:** Change these passwords in production!
