#!/bin/bash
# =============================================
# Database Deployment Script
# Leave Management System
# =============================================
#
# This script deploys the complete database schema and data
# using sqlcmd command-line tool
#
# Prerequisites:
# - SQL Server running and accessible
# - sqlcmd installed
# - Database created or will be created
#
# Usage:
#   ./deploy-database.sh [server] [database] [username] [password]
#
# Example:
#   ./deploy-database.sh localhost LeaveManagementDB sa YourPassword
# =============================================

set -e  # Exit on any error

# Default values
SERVER="${1:-localhost}"
DATABASE="${2:-LeaveManagementDB}"
USERNAME="${3:-sa}"
PASSWORD="${4}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/Database/Scripts"

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}LEAVE MANAGEMENT SYSTEM - DATABASE DEPLOYMENT${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo "Server: $SERVER"
echo "Database: $DATABASE"
echo "Username: $USERNAME"
echo ""

# Check if password is provided
if [ -z "$PASSWORD" ]; then
    echo -e "${YELLOW}Password not provided. Will use Windows Authentication.${NC}"
    CONNECTION="-S $SERVER -d $DATABASE -E"
else
    CONNECTION="-S $SERVER -d $DATABASE -U $USERNAME -P $PASSWORD"
fi

# Function to execute SQL file
execute_sql() {
    local file=$1
    local description=$2

    echo -e "${YELLOW}Executing: $description${NC}"

    if sqlcmd $CONNECTION -i "$SCRIPT_DIR/$file" -b; then
        echo -e "${GREEN}✓ Success: $description${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed: $description${NC}"
        return 1
    fi
}

# Check if database exists, create if not
echo -e "${YELLOW}Checking if database exists...${NC}"
sqlcmd -S $SERVER -U $USERNAME -P $PASSWORD -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$DATABASE') CREATE DATABASE $DATABASE" -b

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database ready${NC}"
else
    echo -e "${RED}✗ Failed to create/verify database${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}-------------------------------------------${NC}"
echo -e "${BLUE}STEP 1: Creating Database Schema${NC}"
echo -e "${BLUE}-------------------------------------------${NC}"
execute_sql "01_CreateSchema.sql" "Create Tables, Constraints, and Indexes"

echo ""
echo -e "${BLUE}-------------------------------------------${NC}"
echo -e "${BLUE}STEP 2: Seeding Initial Data${NC}"
echo -e "${BLUE}-------------------------------------------${NC}"
execute_sql "02_SeedData_Updated.sql" "Insert Departments, Positions, Employees, Leave Types"

echo ""
echo -e "${BLUE}-------------------------------------------${NC}"
echo -e "${BLUE}STEP 3: Creating Stored Procedures${NC}"
echo -e "${BLUE}-------------------------------------------${NC}"

execute_sql "03_StoredProcedures_Authentication.sql" "Authentication Procedures"
execute_sql "04_StoredProcedures_Department_Position.sql" "Department & Position Procedures"
execute_sql "05_StoredProcedures_Employee.sql" "Employee Procedures"
execute_sql "06_StoredProcedures_LeaveType.sql" "Leave Type Procedures"
execute_sql "07_StoredProcedures_LeaveRequest.sql" "Leave Request Procedures"
execute_sql "08_StoredProcedures_LeaveApproval.sql" "Leave Approval Procedures"
execute_sql "09_StoredProcedures_Reports.sql" "Report Procedures"

echo ""
echo -e "${BLUE}-------------------------------------------${NC}"
echo -e "${BLUE}DEPLOYMENT VERIFICATION${NC}"
echo -e "${BLUE}-------------------------------------------${NC}"

# Verify deployment
sqlcmd $CONNECTION -Q "
    DECLARE @TableCount INT, @ProcCount INT, @EmpCount INT;
    SELECT @TableCount = COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME IN ('Departments', 'Positions', 'Employees', 'LeaveTypes', 'LeaveBalances', 'LeaveRequests', 'LeaveApprovers', 'LeaveApprovalHistory');
    SELECT @ProcCount = COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME LIKE 'SP_%';
    SELECT @EmpCount = COUNT(*) FROM dbo.Employees;
    PRINT 'Tables created: ' + CAST(@TableCount AS NVARCHAR(10)) + ' / 8';
    PRINT 'Stored Procedures: ' + CAST(@ProcCount AS NVARCHAR(10));
    PRINT 'Employees seeded: ' + CAST(@EmpCount AS NVARCHAR(10));
" -b

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=============================================${NC}"
    echo -e "${GREEN}DEPLOYMENT COMPLETED SUCCESSFULLY!${NC}"
    echo -e "${GREEN}=============================================${NC}"
    echo ""
    echo "Next Steps:"
    echo "1. Update connection string in appsettings.json"
    echo "2. Run the .NET application"
    echo "3. Login with: admin@company.com / Password123!"
    echo ""
else
    echo ""
    echo -e "${RED}=============================================${NC}"
    echo -e "${RED}DEPLOYMENT FAILED - CHECK ERRORS ABOVE${NC}"
    echo -e "${RED}=============================================${NC}"
    echo ""
    exit 1
fi
