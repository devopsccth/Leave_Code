# Password Hash Fix Instructions

## Problem

The database seed data contains a **placeholder BCrypt hash** that doesn't work with the actual password `Password123!`

**Placeholder hash (INVALID):**
```
AQAAAAIAAYagAAAAEKxqVqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

This is NOT a valid BCrypt hash and will always fail authentication.

## Solution

You need to generate a **valid BCrypt hash** for the password `Password123!` and update the database.

## Quick Fix (3 Steps)

### Step 1: Generate Valid BCrypt Hash

**Option A: Using C# Tool (Recommended)**

```bash
cd Tools/GeneratePasswordHash
dotnet run "Password123!"
```

This will output:
```
===========================================
BCrypt Password Hash Generator
===========================================

Password: Password123!
Hash: $2a$11$xyz...abc (COPY THIS!)

Verification test:
Verify 'Password123!': True
===========================================
```

**Option B: Using Online Generator**

1. Visit: https://bcrypt-generator.com/
2. Enter password: `Password123!`
3. Select rounds: `11`
4. Click "Generate"
5. Copy the generated hash (starts with `$2a$` or `$2b$`)

**Example Valid Hash:**
```
$2a$11$vN5Z.Y5YY5Y5Y5Y5Y5Y5YeY5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5
```

### Step 2: Update Database

**Method A: Using SQL Script (Recommended)**

1. Open `Database/Scripts/10_Fix_Password_Hash.sql`
2. Find line: `DECLARE @NewPasswordHash NVARCHAR(500) = 'YOUR_BCRYPT_HASH_HERE';`
3. Replace `YOUR_BCRYPT_HASH_HERE` with your generated hash
4. Run the script in SQL Server Management Studio or sqlcmd:
   ```bash
   sqlcmd -S localhost -d LeaveManagementDB -i Database/Scripts/10_Fix_Password_Hash.sql
   ```

**Method B: Direct SQL Update**

```sql
USE master;
GO

DECLARE @NewPasswordHash NVARCHAR(500) = '$2a$11$YOUR_GENERATED_HASH_HERE';

UPDATE dbo.Employees
SET PasswordHash = @NewPasswordHash,
    UpdatedDate = GETDATE()
WHERE EmployeeCode IN ('EMP001', 'EMP002', 'EMP003', 'EMP004', 'EMP005', 'EMP006', 'EMP007', 'EMP008', 'EMP009');
```

### Step 3: Test Login

Try logging in with:
- **Email:** `admin@company.com`
- **Password:** `Password123!`

Should work now! ✅

## For Future Seed Data

To avoid this issue in future deployments:

### Option 1: Update Seed Data File

1. Generate hash (Step 1 above)
2. Edit `Database/Scripts/02_SeedData_Updated.sql`
3. Find line (around line 23):
   ```sql
   DECLARE @PasswordHash NVARCHAR(500) = 'AQAAAAIAAYagAAAAEKxqVqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
   ```
4. Replace with your valid hash:
   ```sql
   DECLARE @PasswordHash NVARCHAR(500) = '$2a$11$YOUR_GENERATED_HASH_HERE';
   ```
5. Save and commit

### Option 2: Use Environment Variable

Modify seed script to read from environment:
```sql
DECLARE @PasswordHash NVARCHAR(500) = '$(DEFAULT_PASSWORD_HASH)';
```

Then pass when running:
```bash
sqlcmd -S localhost -d LeaveManagementDB -v DEFAULT_PASSWORD_HASH="$2a$11$xyz..." -i seed.sql
```

## Understanding BCrypt Hashes

### Valid BCrypt Hash Format

```
$2a$11$N7pq6tUxF2oDJ5YoY5YoYOYJGJ0nN8H2yP7LmN5kR8jQ3xW6zN8K2
 │   │   └─────────────────────────────────┬────────────────────────┘
 │   │                                     │
 │   │                                     └─ Hash (22 chars salt + 31 chars hash)
 │   └─ Cost factor (11 = 2^11 iterations)
 └─ Algorithm version (2a or 2b)
```

### Key Points

- **Different each time**: BCrypt generates a new salt, so the same password creates different hashes
- **All valid**: Any hash generated from "Password123!" will verify correctly
- **Length**: BCrypt hashes are always 60 characters
- **Format**: Must start with `$2a$` or `$2b$`

### Invalid Hash Examples

❌ `AQAAAAIAAYagAAAAEKxqVqxxxxxxxxx...` (Not BCrypt format)
❌ `$2a$10$` (Too short)
❌ `password123!` (Plain text)
❌ `MD5 hash` (Wrong algorithm)

### Valid Hash Examples

✅ `$2a$11$N7pq6tUxF2oDJ5YoY5YoYOYJGJ0nN8H2yP7LmN5kR8jQ3xW6zN8K2`
✅ `$2b$12$Abc123xyz...` (60 characters total)
✅ `$2a$10$...` (Any cost factor from 4-31)

## Troubleshooting

### Error: "Password is incorrect"

**Cause:** Hash in database is invalid or doesn't match password

**Solution:**
1. Verify you're using the correct password: `Password123!` (case-sensitive, with exclamation mark)
2. Check hash in database starts with `$2a$` or `$2b$`
3. Re-generate hash and update database

### Error: "Invalid BCrypt hash format"

**Cause:** Hash doesn't follow BCrypt format

**Solution:**
1. Use the C# tool or online generator (links above)
2. Don't modify the generated hash
3. Copy entire hash including `$2a$` prefix

### Error: "Account locked" or "User not found"

**Cause:** Different issue, not related to password hash

**Solution:**
1. Check employee exists: `SELECT * FROM Employees WHERE Email = 'admin@company.com'`
2. Check account is active: `WHERE IsActive = 1`
3. Check email is correct (case-insensitive but must match exactly)

## Production Deployment

**⚠️ IMPORTANT:**

1. **Never use** `Password123!` in production
2. **Force password change** on first login
3. **Generate unique hashes** for each environment
4. **Use strong passwords** (12+ characters, mixed case, numbers, symbols)
5. **Store hashes securely** (environment variables, Azure Key Vault, etc.)

### Recommended Production Password Policy

```csharp
// Minimum requirements
- Length: 12+ characters
- Uppercase: 1+
- Lowercase: 1+
- Numbers: 1+
- Special chars: 1+
- Not in common password list
- Not same as previous 3 passwords
```

## Additional Resources

- BCrypt.Net Documentation: https://github.com/BcryptNet/bcrypt.net
- BCrypt Explained: https://en.wikipedia.org/wiki/Bcrypt
- Password Hashing Best Practices: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html

## Support

If you still have issues after following these instructions:

1. Check application logs for detailed error messages
2. Verify BCrypt.Net package is installed: `BCrypt.Net-Next 4.0.3`
3. Test hash generation tool works: `dotnet run` in Tools/GeneratePasswordHash
4. Check AuthenticationService.cs is using BCrypt.Net.BCrypt.Verify()

---

**Last Updated:** 2025-11-05
**Tested With:** .NET 8, BCrypt.Net-Next 4.0.3, SQL Server 2022
