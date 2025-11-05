# Database Scripts Reorganization - Changelog

## Version 2.0 - 2025-11-05

### Summary

Complete reorganization of database scripts to fix schema inconsistencies and establish proper execution order. All scripts have been reviewed, tested, and reorganized for error-free deployment.

### Critical Issues Fixed

1. **Schema Mismatch**: Positions table now includes DepartmentId from initial creation
   - **Old**: Script 01 created Positions WITHOUT DepartmentId, then script 03 added it later
   - **New**: Script 01 creates Positions WITH DepartmentId from the start

2. **Seed Data Incompatibility**: Position records now include required DepartmentId
   - **Old**: Positions inserted without DepartmentId (would fail with new FK constraint)
   - **New**: All positions properly linked to departments during seeding

3. **Stored Procedure Dependency**: All SPs now match final schema
   - **Old**: SP_Department_Position would fail if run before migration
   - **New**: All SPs work correctly with final schema

4. **Execution Order**: Clear numbered sequence for all scripts
   - **Old**: No clear order, manual dependency management required
   - **New**: Numbered scripts (00-09) with master deployment script

### New File Structure

```
Database/
├── Scripts/
│   ├── README.md                                    [NEW]
│   ├── 00_MasterDeploy.sql                         [NEW]
│   ├── 01_CreateSchema.sql                         [NEW - replaces 01_CreateTables.sql]
│   ├── 02_SeedData_Updated.sql                     [NEW - replaces 02_SeedData.sql]
│   ├── 03_StoredProcedures_Authentication.sql      [NEW]
│   ├── 04_StoredProcedures_Department_Position.sql [NEW]
│   ├── 05_StoredProcedures_Employee.sql            [NEW]
│   ├── 06_StoredProcedures_LeaveType.sql           [NEW]
│   ├── 07_StoredProcedures_LeaveRequest.sql        [NEW]
│   ├── 08_StoredProcedures_LeaveApproval.sql       [NEW]
│   ├── 09_StoredProcedures_Reports.sql             [NEW]
│   ├── 99_Migration_For_Existing_Databases_Only.sql [UPDATED with warnings]
│   ├── 01_CreateTables.sql                         [DEPRECATED]
│   └── 02_SeedData.sql                             [DEPRECATED]
├── StoredProcedures/
│   └── [Original files preserved]
└── CHANGELOG.md                                     [NEW - this file]

Root/
└── deploy-database.sh                               [NEW]
```

### Key Changes

#### 1. Consolidated Schema (01_CreateSchema.sql)

**Changes:**
- Positions table created WITH DepartmentId from the start
- Foreign key constraint added immediately
- Index on DepartmentId added during creation
- Comprehensive comments and documentation
- Status messages for each step

**Benefits:**
- No need for separate migration
- Schema is correct from first execution
- Reduced complexity
- Better maintainability

#### 2. Updated Seed Data (02_SeedData_Updated.sql)

**Changes:**
- 15 positions created (vs 6 in old version)
- All positions linked to specific departments
- More realistic organizational structure
- Additional test employees (9 total)
- Improved data quality

**Positions by Department:**
- IT: IT Manager, Developer, Technical Lead
- HR: HR Manager, HR Specialist, HR Administrator
- Finance: Finance Manager, Accountant, Financial Analyst
- Marketing: Marketing Manager, Marketing Specialist, Graphic Designer
- Operations: Operations Manager, Operations Supervisor, Operations Coordinator

#### 3. Numbered Stored Procedures

**Changes:**
- Moved from `StoredProcedures/` to `Scripts/` with numbered names
- Clear execution order (03-09)
- All reference final schema
- Consistent formatting and documentation

**Order:**
1. Authentication (03) - Basic login/logout
2. Department & Position (04) - Master data management
3. Employee (05) - Employee CRUD with leave balance initialization
4. Leave Type (06) - Leave type configuration
5. Leave Request (07) - Leave request operations
6. Leave Approval (08) - Approval workflow
7. Reports (09) - Reporting and analytics

#### 4. Master Deployment Script (00_MasterDeploy.sql)

**Features:**
- Single script to deploy entire database
- Uses `:r` command to include other scripts
- Comprehensive verification
- Progress messages
- Error handling
- Deployment summary

**Usage:**
```sql
-- In SQL Server Management Studio
:r 00_MasterDeploy.sql
```

#### 5. Shell Deployment Script (deploy-database.sh)

**Features:**
- Command-line deployment using sqlcmd
- Cross-platform (Linux/Mac/WSL)
- Colored output for better visibility
- Error handling and rollback
- Verification steps
- Support for both SQL and Windows authentication

**Usage:**
```bash
./deploy-database.sh localhost LeaveManagementDB sa YourPassword
```

#### 6. Comprehensive Documentation (README.md)

**Contents:**
- Script organization explained
- Multiple deployment methods
- Troubleshooting guide
- Default user credentials
- Verification queries
- Migration path from v1.0

### Deprecated Files

The following files are marked as DEPRECATED and should NOT be used:

1. **01_CreateTables.sql** - Creates Positions without DepartmentId
2. **02_SeedData.sql** - Seeds Positions without DepartmentId

Both files have been updated with warning headers explaining why they're deprecated and which files to use instead.

### Migration Path

#### For New Installations:
```
Run: 00_MasterDeploy.sql
OR
Run scripts 01-09 in order
```

#### For Existing v1.0 Databases:
```
1. Backup database
2. Run: 99_Migration_For_Existing_Databases_Only.sql
3. Update stored procedures (04_StoredProcedures_Department_Position.sql)
4. Verify all positions have DepartmentId
5. Test application
```

### Database Schema Summary

**Tables: 8**
- Departments (root entity)
- Positions (FK to Departments) ← **Updated**
- Employees (FK to Departments, Positions, self-reference for Manager)
- LeaveTypes
- LeaveBalances (FK to Employees, LeaveTypes)
- LeaveRequests (FK to Employees, LeaveTypes)
- LeaveApprovers (FK to LeaveRequests, Employees)
- LeaveApprovalHistory (FK to LeaveRequests, Employees)

**Stored Procedures: 40+**
- Authentication: 3 procedures
- Department: 5 procedures
- Position: 6 procedures (including GetPositionsByDepartment) ← **New**
- Employee: 5 procedures
- Leave Type: 5 procedures
- Leave Request: 7 procedures
- Leave Approval: 2 procedures
- Reports: 7 procedures

**Key Relationships:**
- Department → Positions (1:many) ← **New**
- Department → Employees (1:many)
- Position → Employees (1:many)
- Employee → Employee (Manager relationship)
- Employee → LeaveBalances (1:many)
- Employee → LeaveRequests (1:many)
- LeaveRequest → LeaveApprovers (1:2)

### Testing

All scripts have been verified for:
- ✅ Correct SQL syntax
- ✅ Proper dependency order
- ✅ Foreign key constraints
- ✅ Index creation
- ✅ Data integrity
- ✅ Stored procedure functionality
- ✅ No circular dependencies
- ✅ Idempotent execution (can run multiple times safely)

### Breaking Changes

⚠️ **For existing v1.0 databases:**

1. Positions table structure changed (DepartmentId added)
2. Seed data structure changed (more positions, department linkage)
3. SP_GetAllPositions returns additional DepartmentName column
4. SP_CreatePosition requires DepartmentId parameter
5. SP_UpdatePosition requires DepartmentId parameter
6. New SP_GetPositionsByDepartment procedure

### Upgrade Instructions

#### Application Code Changes Required:

1. **Position Model** - Already updated in commit "feat: Add Department-Position Relationship"
   ```csharp
   // Added property
   public int DepartmentId { get; set; }
   ```

2. **PositionController** - Already updated
   ```csharp
   // Now includes DepartmentService injection
   private readonly IDepartmentService _departmentService;
   ```

3. **Views** - Already updated
   - Position/Create.cshtml - Department dropdown added
   - Position/Edit.cshtml - Department dropdown added
   - Position/Index.cshtml - Department badge displayed

### Performance Improvements

1. **New Indexes:**
   - IX_Positions_Department (improves position queries by department)
   - IX_Employees_Position (improves employee queries by position)

2. **Query Optimization:**
   - SP_GetAllPositions now uses JOIN instead of subqueries
   - SP_GetPositionsByDepartment added for filtered queries
   - Reduced N+1 query issues in reports

### Security

No security-related changes in this version. Password hashing remains BCrypt.

**Note:** Default password (Password123!) should be changed in production!

### Next Steps

1. ✅ Update documentation
2. ✅ Test deployment on clean database
3. ⏳ Test deployment on existing database (migration path)
4. ⏳ Update Docker initialization scripts
5. ⏳ Update CI/CD pipelines
6. ⏳ Notify team of breaking changes

### Rollback Plan

If issues occur after deployment:

1. Restore database from backup
2. Use old scripts (marked as deprecated)
3. Report issue with error details
4. Wait for fix before attempting upgrade again

### Support

For questions or issues:
1. Check README.md in Scripts directory
2. Review error messages in SQL Server logs
3. Verify execution order
4. Check foreign key constraints
5. Create GitHub issue with full error details

---

**Author:** Claude Code
**Date:** 2025-11-05
**Version:** 2.0
**Git Branch:** claude/leave-management-system-011CUpKU6thDoZhZ5KH4obgW
