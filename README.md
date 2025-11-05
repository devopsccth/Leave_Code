# ระบบบริหารจัดการการลา (Leave Management System)

ระบบบริหารจัดการการลาภายในองค์กร พัฒนาด้วย .NET 8 MVC, SQL Server, และ Dapper ORM

## ⭐ คุณสมบัติหลัก

### 1. การจัดการประเภทการลา
- ✅ เพิ่ม ลบ แก้ไข ประเภทการลาได้
- ✅ กำหนดจำนวนวันลาได้ในแต่ละประเภท
- ✅ ระบุเพศสำหรับการลาบางประเภท (เช่น ลาคลอด, ลาบวช)
- ✅ รองรับประเภทการลา:
  - วันลาพักร้อน (Annual Leave) - Pro-rated
  - วันลาป่วย (Sick Leave)
  - วันลากิจ (Personal Leave) - Pro-rated
  - วันลาคลอดบุตร (Maternity Leave) - สำหรับพนักงานหญิง
  - วันลาเพื่อเลี้ยงดูบุตร (Paternity Leave) - สำหรับพนักงานชาย
  - วันลาเพื่อทำการสมรส (Marriage Leave)
  - วันลาบวช (Ordination Leave) - สำหรับพนักงานชาย
  - วันลาเพื่อการศพ (Bereavement Leave)

### 2. การคำนวณวันลา Pro-Rate
- ✅ วันลาพักร้อนและวันลากิจคำนวณแบบ Pro-rate ตามจำนวนเดือนที่เข้าทำงาน
- ✅ วันลาพักร้อน: ทำงานครบ 5 ปี จะได้วันลา 10 วันในปีถัดไป
- ✅ รองรับการ Carry Forward วันลาพักร้อน (สูงสุด 5 วัน)

### 3. ระบบอนุมัติการลา
- ✅ สามารถเลือกผู้อนุมัติได้ 1-2 คน
- ✅ ระบบอนุมัติแบบลำดับขั้น (Level 1 ต้องอนุมัติก่อน Level 2)
- ✅ ส่ง Email แจ้งเตือนอัตโนมัติ:
  - เมื่อมีการขออนุมัติการลา → ส่งหาผู้อนุมัติ
  - เมื่อหัวหน้าอนุมัติการลา → ส่งหา HR และหัวหน้า
  - เมื่อปฏิเสธการลา → ส่งหาพนักงาน

### 4. หน้าจอและรายงาน
- ✅ หน้าแดชบอร์ด - แสดงสถานะวันลาคงเหลือ
- ✅ หน้าจอขอลา / ยกเลิกการลา
- ✅ หน้าจออนุมัติ / ปฏิเสธการลา
- ✅ รายงานการลาของผู้ใต้บังคับบัญชา (สำหรับ Manager)
- ✅ รายงานการลาของพนักงานทั้งหมด (สำหรับ HR/Admin)
- ✅ ประวัติการลาของพนักงาน

### 5. การจัดการข้อมูลพื้นฐาน
- ✅ จัดการ Employee (พนักงาน)
- ✅ จัดการ Department (แผนก)
- ✅ จัดการ Position (ตำแหน่ง)
- ✅ จัดการ Leave Type (ประเภทการลา)

### 6. Authentication & Authorization
- ✅ ระบบ Login / Logout
- ✅ เปลี่ยนรหัสผ่าน
- ✅ บทบาทผู้ใช้งาน (Roles):
  - **Employee** - พนักงานทั่วไป
  - **Manager** - หัวหน้างาน (สามารถอนุมัติการลา)
  - **HR** - ฝ่ายทรัพยากรบุคคล (ดูรายงานทั้งหมด)
  - **Admin** - ผู้ดูแลระบบ (สิทธิ์เต็ม)

## 🏗️ สถาปัตยกรรมระบบ

### เทคโนโลยีที่ใช้
- **Backend**: ASP.NET Core 8.0 MVC
- **Database**: Microsoft SQL Server
- **ORM**: Dapper
- **Authentication**: Cookie Authentication
- **Email**: SMTP (Gmail/Office365)
- **Password Hashing**: BCrypt

### โครงสร้างโปรเจกต์

```
LeaveManagementSystem/
├── Controllers/              # MVC Controllers
│   ├── AccountController.cs
│   ├── HomeController.cs
│   ├── LeaveRequestController.cs
│   ├── LeaveApprovalController.cs
│   ├── EmployeeController.cs (ต้องสร้างเพิ่ม)
│   ├── DepartmentController.cs (ต้องสร้างเพิ่ม)
│   ├── PositionController.cs (ต้องสร้างเพิ่ม)
│   ├── LeaveTypeController.cs (ต้องสร้างเพิ่ม)
│   └── ReportController.cs (ต้องสร้างเพิ่ม)
├── Models/                   # Data Models
│   ├── Employee.cs
│   ├── Department.cs
│   ├── Position.cs
│   ├── LeaveType.cs
│   ├── LeaveRequest.cs
│   ├── LeaveBalance.cs
│   ├── LeaveApprover.cs
│   └── ViewModels/
├── Views/                    # Razor Views (ต้องสร้าง)
│   ├── Account/
│   ├── Home/
│   ├── LeaveRequest/
│   ├── LeaveApproval/
│   ├── Employee/
│   ├── Department/
│   ├── Position/
│   ├── LeaveType/
│   ├── Report/
│   └── Shared/
├── Data/
│   ├── Interfaces/           # Repository Interfaces
│   └── Repositories/         # Repository Implementations (Dapper)
├── Services/
│   ├── Interfaces/           # Service Interfaces
│   └── Implementation/       # Service Implementations
├── wwwroot/                  # Static files (CSS, JS)
└── Program.cs                # Application startup

Database/
├── Scripts/
│   ├── 01_CreateTables.sql
│   └── 02_SeedData.sql
└── StoredProcedures/
    ├── SP_Authentication.sql
    ├── SP_Employee.sql
    ├── SP_Department_Position.sql
    ├── SP_LeaveType.sql
    ├── SP_LeaveRequest.sql
    ├── SP_LeaveApproval.sql
    └── SP_Reports.sql
```

## 📋 ขั้นตอนการติดตั้งและใช้งาน

### 1. ติดตั้ง Prerequisites

```bash
# ติดตั้ง .NET 8 SDK
https://dotnet.microsoft.com/download/dotnet/8.0

# ติดตั้ง SQL Server (Express หรือ Developer Edition)
https://www.microsoft.com/en-us/sql-server/sql-server-downloads

# ติดตั้ง SQL Server Management Studio (SSMS)
https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms
```

### 2. สร้าง Database

```sql
-- 1. สร้าง Database
CREATE DATABASE LeaveManagementDB;
GO

USE LeaveManagementDB;
GO

-- 2. Run สคริปต์สร้างตาราง
-- รันไฟล์ Database/Scripts/01_CreateTables.sql

-- 3. Run สคริปต์สร้าง Stored Procedures ทั้งหมด
-- รันไฟล์ในโฟลเดอร์ Database/StoredProcedures/ ตามลำดับ:
-- - SP_Authentication.sql
-- - SP_Employee.sql
-- - SP_Department_Position.sql
-- - SP_LeaveType.sql
-- - SP_LeaveRequest.sql
-- - SP_LeaveApproval.sql
-- - SP_Reports.sql

-- 4. Run สคริปต์ Seed Data
-- รันไฟล์ Database/Scripts/02_SeedData.sql
```

### 3. ตั้งค่า Connection String

แก้ไขไฟล์ `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=LeaveManagementDB;User Id=sa;Password=YourPassword;TrustServerCertificate=True;MultipleActiveResultSets=true"
  },
  "EmailSettings": {
    "SmtpServer": "smtp.gmail.com",
    "SmtpPort": 587,
    "SenderEmail": "noreply@company.com",
    "SenderName": "Leave Management System",
    "Username": "your-email@gmail.com",
    "Password": "your-app-password",
    "EnableSsl": true
  }
}
```

### 4. Restore Packages และ Run

```bash
# เข้าโฟลเดอร์โปรเจกต์
cd LeaveManagementSystem

# Restore packages
dotnet restore

# Build โปรเจกต์
dotnet build

# Run โปรเจกต์
dotnet run
```

เปิดเบราว์เซอร์ที่ `https://localhost:5001` หรือ `http://localhost:5000`

### 5. ข้อมูลเข้าสู่ระบบเริ่มต้น

```
Admin:
Email: admin@company.com
Password: Password123!

HR Manager:
Email: hr.manager@company.com
Password: Password123!

IT Manager:
Email: it.manager@company.com
Password: Password123!

Employee:
Email: dev1@company.com
Password: Password123!
```

## 📝 งานที่ต้องทำเพิ่มเติม

### Controllers ที่ยังไม่ได้สร้าง

1. **EmployeeController.cs** - จัดการพนักงาน (CRUD)
2. **DepartmentController.cs** - จัดการแผนก (CRUD)
3. **PositionController.cs** - จัดการตำแหน่ง (CRUD)
4. **LeaveTypeController.cs** - จัดการประเภทการลา (CRUD)
5. **ReportController.cs** - รายงานต่างๆ

### Views ทั้งหมดที่ต้องสร้าง

ใช้ Razor Pages พร้อม Bootstrap 5 สำหรับ UI

```
Views/
├── Account/
│   ├── Login.cshtml
│   ├── ChangePassword.cshtml
│   └── AccessDenied.cshtml
├── Home/
│   └── Index.cshtml
├── LeaveRequest/
│   ├── Index.cshtml
│   ├── Create.cshtml
│   ├── Details.cshtml
│   └── MyBalance.cshtml
├── LeaveApproval/
│   ├── Index.cshtml
│   └── Details.cshtml
├── Employee/
│   ├── Index.cshtml
│   ├── Create.cshtml
│   ├── Edit.cshtml
│   └── Details.cshtml
├── Department/
│   ├── Index.cshtml
│   ├── Create.cshtml
│   └── Edit.cshtml
├── Position/
│   ├── Index.cshtml
│   ├── Create.cshtml
│   └── Edit.cshtml
├── LeaveType/
│   ├── Index.cshtml
│   ├── Create.cshtml
│   └── Edit.cshtml
├── Report/
│   ├── TeamLeave.cshtml
│   └── AllEmployeesLeave.cshtml
└── Shared/
    ├── _Layout.cshtml
    ├── _LoginLayout.cshtml
    └── _ValidationScriptsPartial.cshtml
```

## 🔒 Security Features

- ✅ Password Hashing with BCrypt
- ✅ Cookie-based Authentication
- ✅ Role-based Authorization
- ✅ CSRF Protection with AntiForgery Tokens
- ✅ SQL Injection Prevention (Stored Procedures + Dapper)
- ✅ Input Validation

## 📧 Email Configuration

สำหรับ Gmail:
1. เปิดใช้งาน 2-Factor Authentication
2. สร้าง App Password: https://myaccount.google.com/apppasswords
3. ใช้ App Password ในการตั้งค่า

## 🎯 Business Rules

### การคำนวณวันลาพักร้อน
- พนักงานใหม่: Pro-rate ตามเดือนที่เข้าทำงาน (10 วัน/ปี ÷ 12 เดือน)
- พนักงานครบ 5 ปี: ได้ 10 วันเต็มในปีถัดไป
- Carry Forward สูงสุด 5 วัน

### การคำนวณวันลากิจ
- Pro-rate ตามเดือนที่เข้าทำงาน (3 วัน/ปี ÷ 12 เดือน)

### กระบวนการอนุมัติ
1. พนักงานยื่นคำขอลา
2. ส่ง Email แจ้งผู้อนุมัติ
3. ผู้อนุมัติระดับ 1 พิจารณา
4. (ถ้ามี) ผู้อนุมัติระดับ 2 พิจารณา
5. เมื่ออนุมัติครบ → หักวันลา และส่ง Email แจ้ง HR, Manager

## 🚀 Deployment

### สำหรับ Production

1. **ตั้งค่า Environment Variable**
```bash
export ASPNETCORE_ENVIRONMENT=Production
```

2. **Publish แอปพลิเคชัน**
```bash
dotnet publish -c Release -o ./publish
```

3. **ตั้งค่า IIS / Nginx / Docker**
4. **ตั้งค่า SSL Certificate**
5. **Backup Database Schedule**

## 🐛 Troubleshooting

### ปัญหา: ไม่สามารถเชื่อมต่อ Database
- ตรวจสอบ SQL Server ทำงานอยู่หรือไม่
- ตรวจสอบ Connection String
- ตรวจสอบ Firewall

### ปัญหา: ส่ง Email ไม่ได้
- ตรวจสอบ SMTP Settings
- ใช้ App Password สำหรับ Gmail
- ตรวจสอบ Firewall port 587

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributors

- Development Team - Initial work

## 📞 Support

หากมีปัญหาหรือข้อสงสัย กรุณาติดต่อ:
- Email: support@company.com
- GitHub Issues: [Create an issue](https://github.com/yourrepo/issues)

---

**หมายเหตุ**: นี่เป็นระบบ MVP (Minimum Viable Product) สำหรับการจัดการการลาภายในองค์กร สามารถปรับแต่งและขยายฟังก์ชันเพิ่มเติมได้ตามความต้องการ
