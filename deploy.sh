#!/bin/bash

# Leave Management System - Production Deployment Script
# This script deploys the application using Docker Compose

set -e

echo "=================================="
echo "Leave Management System Deployment"
echo "=================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Stop existing containers
print_message "Stopping existing containers..."
docker-compose down || true

# Pull latest images
print_message "Pulling latest images..."
docker-compose pull

# Build application
print_message "Building application..."
docker-compose build --no-cache

# Generate SSL certificates (self-signed for development)
if [ ! -f "nginx/ssl/cert.pem" ]; then
    print_message "Generating self-signed SSL certificates..."
    mkdir -p nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/key.pem \
        -out nginx/ssl/cert.pem \
        -subj "/C=TH/ST=Bangkok/L=Bangkok/O=Company/OU=IT/CN=leave-management.local"
fi

# Start containers
print_message "Starting containers..."
docker-compose up -d

# Wait for SQL Server to be ready
print_message "Waiting for SQL Server to be ready..."
sleep 30

# Initialize database
print_message "Initializing database..."
docker-compose exec -T sqlserver /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P 'YourStrong!Passw0rd' \
    -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'LeaveManagementDB') CREATE DATABASE LeaveManagementDB;" || true

# Run database migrations
print_message "Running database scripts..."
for script in Database/Scripts/*.sql; do
    print_message "Executing $script..."
    docker-compose exec -T sqlserver /opt/mssql-tools/bin/sqlcmd \
        -S localhost -U sa -P 'YourStrong!Passw0rd' \
        -d LeaveManagementDB -i "/docker-entrypoint-initdb.d/$(basename $script)" || true
done

# Run stored procedures
for script in Database/StoredProcedures/*.sql; do
    print_message "Executing $script..."
    docker-compose exec -T sqlserver /opt/mssql-tools/bin/sqlcmd \
        -S localhost -U sa -P 'YourStrong!Passw0rd' \
        -d LeaveManagementDB -i "/docker-entrypoint-initdb.d/../StoredProcedures/$(basename $script)" || true
done

# Check container status
print_message "Checking container status..."
docker-compose ps

# Display logs
print_message "Displaying recent logs..."
docker-compose logs --tail=50

echo ""
print_message "=================================="
print_message "Deployment completed successfully!"
print_message "=================================="
echo ""
print_message "Application is running at:"
print_message "  HTTP:  http://localhost:5000"
print_message "  HTTPS: https://localhost (via Nginx)"
echo ""
print_message "Database connection:"
print_message "  Server: localhost,1433"
print_message "  Database: LeaveManagementDB"
print_message "  User: sa"
print_message "  Password: YourStrong!Passw0rd"
echo ""
print_message "Default login credentials:"
print_message "  Admin: admin@company.com / Password123!"
print_message "  HR: hr.manager@company.com / Password123!"
echo ""
print_message "To view logs: docker-compose logs -f"
print_message "To stop: docker-compose down"
print_message "To restart: docker-compose restart"
echo ""
