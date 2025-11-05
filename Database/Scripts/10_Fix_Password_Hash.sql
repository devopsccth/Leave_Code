-- =============================================
-- Fix Password Hash for Seed Accounts
-- =============================================
--
-- PROBLEM: The seed data uses a placeholder hash that doesn't work
-- SOLUTION: Generate a valid BCrypt hash and update all accounts
--
-- HOW TO USE THIS SCRIPT:
-- 1. Run the password hash generator tool:
--    cd Tools/GeneratePasswordHash
--    dotnet run "Password123!"
-- 2. Copy the generated hash
-- 3. Replace the @PasswordHash value below
-- 4. Run this script
--
-- =============================================

USE master;
GO

PRINT '===========================================';
PRINT 'FIXING PASSWORD HASH FOR SEED ACCOUNTS';
PRINT '===========================================';
PRINT '';

-- STEP 1: Generate valid BCrypt hash
-- TODO: Replace this with actual BCrypt hash from generator tool
-- The placeholder hash below WILL NOT WORK
-- You MUST generate a real hash using: dotnet run in Tools/GeneratePasswordHash

-- OPTION A: Use the hash generator tool (RECOMMENDED)
-- cd Tools/GeneratePasswordHash && dotnet run "Password123!"

-- OPTION B: Use online BCrypt generator
-- Visit: https://bcrypt-generator.com/
-- Input: Password123!
-- Rounds: 11
-- Copy the generated hash

-- PASTE YOUR GENERATED HASH HERE:
DECLARE @NewPasswordHash NVARCHAR(500) = 'YOUR_BCRYPT_HASH_HERE';

-- Validate that hash was updated
IF @NewPasswordHash = 'YOUR_BCRYPT_HASH_HERE'
BEGIN
    PRINT 'ERROR: You must generate a BCrypt hash first!';
    PRINT '';
    PRINT 'Steps:';
    PRINT '1. cd Tools/GeneratePasswordHash';
    PRINT '2. dotnet run "Password123!"';
    PRINT '3. Copy the generated hash';
    PRINT '4. Replace @NewPasswordHash value in this script';
    PRINT '5. Run this script again';
    PRINT '';
    RAISERROR('BCrypt hash not generated. See instructions above.', 16, 1);
    RETURN;
END

-- Validate hash format (BCrypt starts with $2a$ or $2b$)
IF @NewPasswordHash NOT LIKE '$2[ab]$%'
BEGIN
    PRINT 'ERROR: Invalid BCrypt hash format!';
    PRINT 'BCrypt hash must start with $2a$ or $2b$';
    PRINT '';
    PRINT 'Example valid hash:';
    PRINT '$2a$11$abcdefghijk...';
    PRINT '';
    RAISERROR('Invalid BCrypt hash format', 16, 1);
    RETURN;
END

PRINT 'Valid BCrypt hash detected.';
PRINT 'Hash: ' + LEFT(@NewPasswordHash, 20) + '...';
PRINT '';

-- STEP 2: Update all seed accounts
PRINT 'Updating password hash for all seed accounts...';

UPDATE dbo.Employees
SET PasswordHash = @NewPasswordHash,
    UpdatedDate = GETDATE()
WHERE EmployeeCode IN (
    'EMP001', -- Admin
    'EMP002', -- HR Manager
    'EMP003', -- IT Manager
    'EMP004', -- Developer 1
    'EMP005', -- Developer 2
    'EMP006', -- Finance Manager
    'EMP007', -- Accountant
    'EMP008', -- Marketing Manager
    'EMP009'  -- Operations Manager
);

DECLARE @UpdatedCount INT = @@ROWCOUNT;

PRINT 'Password hash updated for ' + CAST(@UpdatedCount AS NVARCHAR(10)) + ' accounts.';
PRINT '';
PRINT '===========================================';
PRINT 'PASSWORD HASH UPDATE COMPLETED';
PRINT '===========================================';
PRINT '';
PRINT 'All seed accounts now use password: Password123!';
PRINT '';
PRINT 'Test Accounts:';
PRINT '- Admin: admin@company.com / Password123!';
PRINT '- Employee: dev1@company.com / Password123!';
PRINT '- Manager: it.manager@company.com / Password123!';
PRINT '';
PRINT 'IMPORTANT: Change these passwords in production!';
PRINT '===========================================';
GO
