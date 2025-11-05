-- Leave Management System Database Schema
-- Created for .NET 8 MVC Application

-- Drop existing tables if they exist (for development)
IF OBJECT_ID('dbo.LeaveApprovalHistory', 'U') IS NOT NULL DROP TABLE dbo.LeaveApprovalHistory;
IF OBJECT_ID('dbo.LeaveApprovers', 'U') IS NOT NULL DROP TABLE dbo.LeaveApprovers;
IF OBJECT_ID('dbo.LeaveRequests', 'U') IS NOT NULL DROP TABLE dbo.LeaveRequests;
IF OBJECT_ID('dbo.LeaveBalances', 'U') IS NOT NULL DROP TABLE dbo.LeaveBalances;
IF OBJECT_ID('dbo.LeaveTypes', 'U') IS NOT NULL DROP TABLE dbo.LeaveTypes;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Positions', 'U') IS NOT NULL DROP TABLE dbo.Positions;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;

-- Departments Table
CREATE TABLE dbo.Departments (
    DepartmentId INT PRIMARY KEY IDENTITY(1,1),
    DepartmentCode NVARCHAR(50) NOT NULL UNIQUE,
    DepartmentName NVARCHAR(200) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL
);

-- Positions Table
CREATE TABLE dbo.Positions (
    PositionId INT PRIMARY KEY IDENTITY(1,1),
    PositionCode NVARCHAR(50) NOT NULL UNIQUE,
    PositionName NVARCHAR(200) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL
);

-- Employees Table (includes authentication)
CREATE TABLE dbo.Employees (
    EmployeeId INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(200) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(500) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    DateOfBirth DATE NULL,
    HireDate DATE NOT NULL,
    DepartmentId INT NOT NULL,
    PositionId INT NOT NULL,
    ManagerId INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    Role NVARCHAR(50) NOT NULL DEFAULT 'Employee' CHECK (Role IN ('Employee', 'Manager', 'HR', 'Admin')),
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL,
    LastLoginDate DATETIME NULL,
    CONSTRAINT FK_Employees_Department FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(DepartmentId),
    CONSTRAINT FK_Employees_Position FOREIGN KEY (PositionId) REFERENCES dbo.Positions(PositionId),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerId) REFERENCES dbo.Employees(EmployeeId)
);

-- Leave Types Table
CREATE TABLE dbo.LeaveTypes (
    LeaveTypeId INT PRIMARY KEY IDENTITY(1,1),
    LeaveTypeCode NVARCHAR(50) NOT NULL UNIQUE,
    LeaveTypeName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NULL,
    DefaultDays DECIMAL(5,2) NOT NULL DEFAULT 0,
    IsProRated BIT NOT NULL DEFAULT 0, -- For Annual Leave and Personal Leave
    RequiresGender BIT NOT NULL DEFAULT 0, -- For Maternity/Paternity Leave
    ApplicableGender NVARCHAR(10) NULL CHECK (ApplicableGender IN ('Male', 'Female', NULL)),
    IsPaidLeave BIT NOT NULL DEFAULT 1,
    RequiresDocumentation BIT NOT NULL DEFAULT 0,
    MaxConsecutiveDays INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL
);

-- Leave Balances Table
CREATE TABLE dbo.LeaveBalances (
    LeaveBalanceId INT PRIMARY KEY IDENTITY(1,1),
    EmployeeId INT NOT NULL,
    LeaveTypeId INT NOT NULL,
    Year INT NOT NULL,
    EntitledDays DECIMAL(5,2) NOT NULL DEFAULT 0, -- Total days entitled
    UsedDays DECIMAL(5,2) NOT NULL DEFAULT 0, -- Days used
    RemainingDays DECIMAL(5,2) NOT NULL DEFAULT 0, -- Days remaining
    ProRateCalculation DECIMAL(5,2) NULL, -- For pro-rated leaves
    CarryForwardDays DECIMAL(5,2) NOT NULL DEFAULT 0, -- Carried forward from previous year
    YearsOfService INT NULL, -- For 5-year bonus calculation
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL,
    CONSTRAINT FK_LeaveBalances_Employee FOREIGN KEY (EmployeeId) REFERENCES dbo.Employees(EmployeeId),
    CONSTRAINT FK_LeaveBalances_LeaveType FOREIGN KEY (LeaveTypeId) REFERENCES dbo.LeaveTypes(LeaveTypeId),
    CONSTRAINT UQ_LeaveBalance_Employee_Year UNIQUE (EmployeeId, LeaveTypeId, Year)
);

-- Leave Requests Table
CREATE TABLE dbo.LeaveRequests (
    LeaveRequestId INT PRIMARY KEY IDENTITY(1,1),
    RequestNumber NVARCHAR(50) NOT NULL UNIQUE, -- e.g., LR-2024-0001
    EmployeeId INT NOT NULL,
    LeaveTypeId INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    TotalDays DECIMAL(5,2) NOT NULL,
    Reason NVARCHAR(1000) NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    RequestDate DATETIME NOT NULL DEFAULT GETDATE(),
    CancellationReason NVARCHAR(500) NULL,
    CancellationDate DATETIME NULL,
    AttachmentPath NVARCHAR(500) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL,
    CONSTRAINT FK_LeaveRequests_Employee FOREIGN KEY (EmployeeId) REFERENCES dbo.Employees(EmployeeId),
    CONSTRAINT FK_LeaveRequests_LeaveType FOREIGN KEY (LeaveTypeId) REFERENCES dbo.LeaveTypes(LeaveTypeId)
);

-- Leave Approvers Table (1-2 approvers)
CREATE TABLE dbo.LeaveApprovers (
    LeaveApproverId INT PRIMARY KEY IDENTITY(1,1),
    LeaveRequestId INT NOT NULL,
    ApproverId INT NOT NULL,
    ApprovalLevel INT NOT NULL CHECK (ApprovalLevel IN (1, 2)), -- First or Second approver
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved', 'Rejected')),
    Comments NVARCHAR(1000) NULL,
    ActionDate DATETIME NULL,
    IsRequired BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_LeaveApprovers_Request FOREIGN KEY (LeaveRequestId) REFERENCES dbo.LeaveRequests(LeaveRequestId),
    CONSTRAINT FK_LeaveApprovers_Approver FOREIGN KEY (ApproverId) REFERENCES dbo.Employees(EmployeeId),
    CONSTRAINT UQ_LeaveApprover_Request_Level UNIQUE (LeaveRequestId, ApprovalLevel)
);

-- Leave Approval History Table
CREATE TABLE dbo.LeaveApprovalHistory (
    HistoryId INT PRIMARY KEY IDENTITY(1,1),
    LeaveRequestId INT NOT NULL,
    ApproverId INT NOT NULL,
    Action NVARCHAR(50) NOT NULL CHECK (Action IN ('Submitted', 'Approved', 'Rejected', 'Cancelled')),
    Comments NVARCHAR(1000) NULL,
    ActionDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_LeaveHistory_Request FOREIGN KEY (LeaveRequestId) REFERENCES dbo.LeaveRequests(LeaveRequestId),
    CONSTRAINT FK_LeaveHistory_Approver FOREIGN KEY (ApproverId) REFERENCES dbo.Employees(EmployeeId)
);

-- Create Indexes for better performance
CREATE INDEX IX_Employees_Manager ON dbo.Employees(ManagerId);
CREATE INDEX IX_Employees_Department ON dbo.Employees(DepartmentId);
CREATE INDEX IX_Employees_Email ON dbo.Employees(Email);
CREATE INDEX IX_LeaveRequests_Employee ON dbo.LeaveRequests(EmployeeId);
CREATE INDEX IX_LeaveRequests_Status ON dbo.LeaveRequests(Status);
CREATE INDEX IX_LeaveRequests_Date ON dbo.LeaveRequests(StartDate, EndDate);
CREATE INDEX IX_LeaveBalances_Employee_Year ON dbo.LeaveBalances(EmployeeId, Year);
CREATE INDEX IX_LeaveApprovers_Approver ON dbo.LeaveApprovers(ApproverId, Status);

PRINT 'Database tables created successfully';
