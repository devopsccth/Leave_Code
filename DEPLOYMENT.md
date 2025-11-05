# Production Deployment Guide

## 🚀 Deployment Options

This guide covers multiple deployment scenarios for the Leave Management System.

---

## Option 1: Docker Deployment (Recommended)

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum
- 20GB disk space

### Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd Leave_Code

# Run deployment script
chmod +x deploy.sh
./deploy.sh
```

### Manual Docker Deployment

```bash
# Build and start containers
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Remove all data (WARNING: This will delete the database)
docker-compose down -v
```

### Access the Application

- **HTTP**: http://localhost:5000
- **HTTPS**: https://localhost (via Nginx)
- **Database**: localhost:1433

---

## Option 2: Traditional Server Deployment

### Prerequisites
- Windows Server 2019+ / Linux (Ubuntu 20.04+)
- .NET 8 SDK and Runtime
- SQL Server 2019+ or Azure SQL
- IIS (Windows) or Nginx (Linux)

### Windows Server with IIS

1. **Install .NET 8 Hosting Bundle**
```powershell
# Download and install
https://dotnet.microsoft.com/download/dotnet/8.0
```

2. **Publish Application**
```bash
cd LeaveManagementSystem
dotnet publish -c Release -o C:\inetpub\wwwroot\LeaveManagement
```

3. **Create Database**
```sql
-- Run in SQL Server Management Studio
-- 1. Run Database/Scripts/01_CreateTables.sql
-- 2. Run all Database/StoredProcedures/*.sql files
-- 3. Run Database/Scripts/02_SeedData.sql
```

4. **Configure IIS**
- Create new Application Pool (.NET CLR Version: No Managed Code)
- Create new Website pointing to published folder
- Set Application Pool identity
- Configure bindings (HTTP/HTTPS)

5. **Configure appsettings.Production.json**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SQL_SERVER;Database=LeaveManagementDB;..."
  },
  "EmailSettings": {
    "SmtpServer": "smtp.office365.com",
    "SmtpPort": 587,
    ...
  }
}
```

### Linux with Nginx

1. **Install .NET 8 Runtime**
```bash
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0
```

2. **Publish Application**
```bash
cd LeaveManagementSystem
dotnet publish -c Release -o /var/www/leave-management
```

3. **Create Systemd Service**
```bash
sudo nano /etc/systemd/system/leave-management.service
```

```ini
[Unit]
Description=Leave Management System
After=network.target

[Service]
WorkingDirectory=/var/www/leave-management
ExecStart=/usr/bin/dotnet /var/www/leave-management/LeaveManagementSystem.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=leave-management
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
```

4. **Configure Nginx**
```bash
sudo nano /etc/nginx/sites-available/leave-management
```

```nginx
server {
    listen 80;
    server_name leave-management.yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

5. **Start Services**
```bash
sudo systemctl enable leave-management
sudo systemctl start leave-management
sudo systemctl enable nginx
sudo systemctl restart nginx
```

---

## Option 3: Azure Deployment

### Azure App Service + Azure SQL

1. **Create Azure Resources**
```bash
# Login to Azure
az login

# Create Resource Group
az group create --name rg-leave-management --location southeastasia

# Create SQL Server
az sql server create \
    --name sql-leave-management \
    --resource-group rg-leave-management \
    --admin-user sqladmin \
    --admin-password YourStrong!Password

# Create SQL Database
az sql db create \
    --resource-group rg-leave-management \
    --server sql-leave-management \
    --name LeaveManagementDB \
    --service-objective S0

# Create App Service Plan
az appservice plan create \
    --name plan-leave-management \
    --resource-group rg-leave-management \
    --sku B1 \
    --is-linux

# Create Web App
az webapp create \
    --resource-group rg-leave-management \
    --plan plan-leave-management \
    --name app-leave-management \
    --runtime "DOTNETCORE:8.0"
```

2. **Configure Connection String**
```bash
az webapp config connection-string set \
    --resource-group rg-leave-management \
    --name app-leave-management \
    --settings DefaultConnection="Server=tcp:sql-leave-management.database.windows.net,1433;Initial Catalog=LeaveManagementDB;..."
    --connection-string-type SQLAzure
```

3. **Deploy Application**
```bash
cd LeaveManagementSystem
az webapp up \
    --resource-group rg-leave-management \
    --name app-leave-management
```

---

## Option 4: Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (AKS, EKS, GKE, or on-premises)
- kubectl configured
- Helm 3 (optional)

### Create Kubernetes Manifests

**deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: leave-management
spec:
  replicas: 3
  selector:
    matchLabels:
      app: leave-management
  template:
    metadata:
      labels:
        app: leave-management
    spec:
      containers:
      - name: webapp
        image: your-registry/leave-management:latest
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: connection-string
```

**service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: leave-management-service
spec:
  selector:
    app: leave-management
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

**Deploy**
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## 🔒 Security Checklist

Before deploying to production:

### Application Security
- [ ] Change default passwords
- [ ] Update appsettings.Production.json with production values
- [ ] Enable HTTPS with valid SSL certificate
- [ ] Configure CORS appropriately
- [ ] Enable request rate limiting
- [ ] Configure logging and monitoring
- [ ] Set secure cookie policies

### Database Security
- [ ] Use strong SA password
- [ ] Create dedicated application user (not SA)
- [ ] Enable SQL Server encryption
- [ ] Configure firewall rules
- [ ] Enable audit logging
- [ ] Set up automated backups

### Email Configuration
- [ ] Use app-specific passwords (Gmail)
- [ ] Configure SPF/DKIM records
- [ ] Test email delivery
- [ ] Set up email templates

### Infrastructure
- [ ] Configure firewall rules
- [ ] Set up monitoring and alerts
- [ ] Configure automated backups
- [ ] Set up disaster recovery
- [ ] Enable WAF if using cloud
- [ ] Configure CDN for static files

---

## 🔧 Troubleshooting

### Application won't start
```bash
# Check logs
docker-compose logs webapp

# Check if port is in use
netstat -an | grep 5000

# Verify .NET installation
dotnet --info
```

### Database connection issues
```bash
# Test SQL Server connection
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P 'YourStrong!Passw0rd' -Q "SELECT 1"

# Check connection string
# Verify server, database name, credentials
```

### Email not sending
- Verify SMTP settings
- Check firewall rules for port 587
- Verify credentials
- Check application logs

---

## 📊 Monitoring

### Health Checks
```bash
# Application health
curl http://localhost:5000/health

# Database health
sqlcmd -S localhost -U sa -P 'password' -Q "SELECT @@VERSION"
```

### Logs
```bash
# Docker logs
docker-compose logs -f

# Application logs (traditional deployment)
# Check: /var/log/leave-management/
# Or Windows Event Viewer
```

---

## 🔄 Backup and Restore

### Database Backup
```sql
-- Backup
BACKUP DATABASE LeaveManagementDB
TO DISK = 'C:\Backup\LeaveManagementDB.bak'
WITH FORMAT, MEDIANAME = 'LeaveManagement', NAME = 'Full Backup';

-- Restore
RESTORE DATABASE LeaveManagementDB
FROM DISK = 'C:\Backup\LeaveManagementDB.bak'
WITH REPLACE;
```

### Docker Volume Backup
```bash
# Backup database volume
docker run --rm \
    -v leave_code_sqlserver_data:/source \
    -v $(pwd)/backup:/backup \
    alpine tar czf /backup/db-backup-$(date +%Y%m%d).tar.gz -C /source .
```

---

## 📞 Support

For issues or questions:
- GitHub Issues: [Create an issue](https://github.com/yourrepo/issues)
- Email: support@company.com
- Documentation: See README.md

---

**Note**: Always test deployments in a staging environment before production!
