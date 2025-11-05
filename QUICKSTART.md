# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Docker Desktop installed
- Git installed
- 4GB RAM available

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd Leave_Code
```

### Step 2: Deploy with One Command
```bash
./deploy.sh
```

That's it! The script will:
- ✅ Build and start all containers
- ✅ Create and initialize the database
- ✅ Run all database scripts
- ✅ Start the web application
- ✅ Configure Nginx reverse proxy

### Step 3: Access the Application

Open your browser and go to:
- **HTTP**: http://localhost:5000
- **HTTPS**: https://localhost

### Step 4: Login

Use these credentials to login:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@company.com | Password123! |
| HR Manager | hr.manager@company.com | Password123! |
| IT Manager | it.manager@company.com | Password123! |
| Developer | dev1@company.com | Password123! |

---

## 📱 Features Tour

### For Employees
1. **Dashboard** - View your leave balance and recent requests
2. **Request Leave** - Submit new leave requests
3. **My Requests** - Track status of your leave requests
4. **Leave Balance** - Check remaining days for each leave type

### For Managers
1. **Approve Leave** - Review and approve/reject leave requests
2. **Team Report** - View leave statistics for your team

### For HR/Admin
1. **Employee Management** - Manage employees, departments, positions
2. **Leave Type Management** - Configure leave types and policies
3. **Reports** - View company-wide leave statistics
4. **All Leave Requests** - Monitor all leave requests across the company

---

## 🛠️ Common Tasks

### View Application Logs
```bash
docker-compose logs -f webapp
```

### View Database Logs
```bash
docker-compose logs -f sqlserver
```

### Restart Application
```bash
docker-compose restart webapp
```

### Stop All Services
```bash
docker-compose down
```

### Start Services Again
```bash
docker-compose up -d
```

### Access Database Directly
```bash
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P 'YourStrong!Passw0rd' \
    -d LeaveManagementDB
```

---

## 🔧 Configuration

### Email Settings
Edit `docker-compose.yml` to configure email:

```yaml
- EmailSettings__SmtpServer=smtp.gmail.com
- EmailSettings__SmtpPort=587
- EmailSettings__Username=your-email@gmail.com
- EmailSettings__Password=your-app-password
```

### Database Connection
Edit `docker-compose.yml` to change database password:

```yaml
- SA_PASSWORD=YourStrong!Passw0rd
- ConnectionStrings__DefaultConnection=Server=sqlserver;...
```

---

## 📚 Next Steps

1. **Read the full README** - [README.md](README.md)
2. **Learn about deployment** - [DEPLOYMENT.md](DEPLOYMENT.md)
3. **Customize the system** - Modify leave types, add new features
4. **Set up production** - Follow production deployment guide

---

## 🐛 Troubleshooting

### Port Already in Use
If port 5000 or 1433 is already in use:

```bash
# Change ports in docker-compose.yml
ports:
  - "5001:80"  # Change 5000 to 5001
```

### Database Connection Failed
```bash
# Wait for SQL Server to initialize (30 seconds)
# Or check SQL Server logs
docker-compose logs sqlserver
```

### Application Not Starting
```bash
# Check application logs
docker-compose logs webapp

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

---

## ❓ Need Help?

- Check [README.md](README.md) for detailed documentation
- Check [DEPLOYMENT.md](DEPLOYMENT.md) for deployment options
- Create an issue on GitHub
- Contact support@company.com

---

**Happy Managing! 🎉**
