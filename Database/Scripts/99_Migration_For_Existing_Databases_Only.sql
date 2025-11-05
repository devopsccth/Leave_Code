-- =============================================
-- MIGRATION SCRIPT - FOR EXISTING DATABASES ONLY
-- =============================================
--
-- WARNING: This script is ONLY for existing databases
-- that were created with version 1.0 schema.
--
-- DO NOT USE THIS SCRIPT FOR FRESH INSTALLATIONS!
-- For new installations, use 00_MasterDeploy.sql instead.
--
-- This script will:
-- 1. Add DepartmentId column to Positions table
-- 2. Migrate existing position data
-- 3. Create foreign key relationship
-- 4. Add performance indexes
--
-- Prerequisites:
-- - Existing database with v1.0 schema
-- - Backup your database before running this script
--
-- =============================================

USE LeaveManagementDB;
GO

PRINT '=============================================';
PRINT 'MIGRATION SCRIPT - EXISTING DATABASE';
PRINT 'Started at: ' + CONVERT(NVARCHAR(30), GETDATE(), 120);
PRINT '=============================================';
PRINT '';
PRINT 'WARNING: This will modify your existing database structure.';
PRINT 'Make sure you have a backup before proceeding!';
PRINT '';
GO

-- Add DepartmentId column to Positions table if not exists
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Positions') AND name = 'DepartmentId')
BEGIN
    ALTER TABLE dbo.Positions
    ADD DepartmentId INT NULL;

    PRINT 'DepartmentId column added to Positions table';
END

-- Update existing positions to have a default department (first department)
DECLARE @DefaultDepartmentId INT;
SELECT TOP 1 @DefaultDepartmentId = DepartmentId FROM dbo.Departments WHERE IsActive = 1 ORDER BY DepartmentId;

UPDATE dbo.Positions
SET DepartmentId = @DefaultDepartmentId
WHERE DepartmentId IS NULL;

-- Make DepartmentId NOT NULL after data migration
ALTER TABLE dbo.Positions
ALTER COLUMN DepartmentId INT NOT NULL;

-- Add Foreign Key constraint
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Positions_Department')
BEGIN
    ALTER TABLE dbo.Positions
    ADD CONSTRAINT FK_Positions_Department
    FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(DepartmentId);

    PRINT 'Foreign key FK_Positions_Department added';
END

-- Create index for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Positions_Department')
BEGIN
    CREATE INDEX IX_Positions_Department ON dbo.Positions(DepartmentId);
    PRINT 'Index IX_Positions_Department created';
END

-- Update seed data to assign positions to departments
-- IT Department positions
UPDATE dbo.Positions
SET DepartmentId = (SELECT DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'IT')
WHERE PositionCode IN ('DEV', 'ADM');

-- HR Department positions
UPDATE dbo.Positions
SET DepartmentId = (SELECT DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'HR')
WHERE PositionCode = 'HR-SP';

-- Finance Department positions
UPDATE dbo.Positions
SET DepartmentId = (SELECT DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'FIN')
WHERE PositionCode = 'ACC';

-- Marketing Department positions
UPDATE dbo.Positions
SET DepartmentId = (SELECT DepartmentId FROM dbo.Departments WHERE DepartmentCode = 'MKT')
WHERE PositionCode = 'MKT-SP';

-- Manager position can be in all departments
UPDATE dbo.Positions
SET DepartmentId = (SELECT TOP 1 DepartmentId FROM dbo.Departments WHERE IsActive = 1)
WHERE PositionCode = 'MGR' AND DepartmentId IS NULL;

PRINT '';
PRINT '=============================================';
PRINT 'MIGRATION COMPLETED SUCCESSFULLY';
PRINT 'Completed at: ' + CONVERT(NVARCHAR(30), GETDATE(), 120);
PRINT '=============================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Verify all positions have correct DepartmentId';
PRINT '2. Update stored procedures if needed';
PRINT '3. Test the application thoroughly';
PRINT '=============================================';
GO
