# MongoDB Installation Guide for Ubuntu/Debian

## Install MongoDB

### Method 1: Using Docker (Recommended for development)

```bash
# Pull MongoDB image
docker pull mongo:latest

# Run MongoDB container
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -e MONGO_INITDB_DATABASE=piazza \
  mongo:latest

# Check if running
docker ps
```

### Method 2: Native Installation

```bash
# Import MongoDB public GPG Key
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

# Create list file for MongoDB
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Reload package database
sudo apt-get update

# Install MongoDB
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod

# Enable MongoDB to start on boot
sudo systemctl enable mongod

# Check status
sudo systemctl status mongod
```

## Verify MongoDB is Running

```bash
# Connect to MongoDB shell
mongosh

# Or check if port 27017 is listening
sudo netstat -nltp | grep 27017
```

## Quick Start After MongoDB Installation

1. **Start the Piazza API:**
   ```bash
   cd cam-backend
   npm run dev
   ```

2. **Test the API:**
   ```bash
   # Health check
   curl http://localhost:3000/

   # Register a user
   curl -X POST http://localhost:3000/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "email": "test@example.com",
       "password": "Test123"
     }'
   ```

## Common MongoDB Commands

```bash
# Start MongoDB
sudo systemctl start mongod

# Stop MongoDB
sudo systemctl stop mongod

# Restart MongoDB
sudo systemctl restart mongod

# View MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log
```

## MongoDB Shell Commands

```javascript
// Connect to MongoDB
mongosh

// Show databases
show dbs

// Use piazza database
use piazza

// Show collections
show collections

// View users
db.users.find().pretty()

// Count users
db.users.countDocuments()

// Delete all users (for testing)
db.users.deleteMany({})
```

## Troubleshooting

### Port Already in Use
```bash
# Find what's using port 3000
sudo lsof -i :3000

# Kill the process
sudo kill -9 <PID>
```

### MongoDB Connection Issues
```bash
# Check if MongoDB is running
sudo systemctl status mongod

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log

# Restart MongoDB
sudo systemctl restart mongod
```

### Permission Issues
```bash
# Fix MongoDB data directory permissions
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown mongodb:mongodb /tmp/mongodb-27017.sock
```
