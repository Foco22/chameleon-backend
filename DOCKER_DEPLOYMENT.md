# Docker Deployment Guide - Piazza API

Complete guide to deploy Piazza API to a VM using Docker with automatic GitHub Actions CI/CD.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [VM Setup](#vm-setup)
4. [GitHub Configuration](#github-configuration)
5. [Automatic Deployment](#automatic-deployment)
6. [Manual Deployment](#manual-deployment)
7. [Local Docker Testing](#local-docker-testing)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### Deployment Architecture

```
Your Computer → GitHub → GitHub Actions → Docker Hub → VM
                 (push)    (auto build)    (push img)  (auto deploy)
```

### What Gets Automated

✅ Docker image building
✅ Pushing to Docker Hub
✅ SSH deployment to VM
✅ Container management
✅ Health checks
✅ Rollback on failure

---

## 📦 Prerequisites

### On Your Computer

- Git installed
- GitHub account
- Docker Hub account (free tier works)
- SSH access to a VM

### On Your VM

- Ubuntu 20.04+ (or similar Linux)
- At least 1GB RAM
- 10GB disk space
- Public IP address
- SSH access (port 22 or custom)

---

## 🚀 VM Setup

### Step 1: Connect to Your VM

```bash
ssh username@your-vm-ip
```

### Step 2: Download Setup Script

```bash
# Download the setup script
curl -o setup-vm.sh https://raw.githubusercontent.com/YOUR-GITHUB/cam-backend/main/scripts/setup-vm.sh

# Make it executable
chmod +x setup-vm.sh

# Run it
./setup-vm.sh
```

**OR manually copy the script:**

```bash
# Create the script
nano setup-vm.sh

# Paste the contents from scripts/setup-vm.sh
# Save and exit (Ctrl+X, Y, Enter)

# Make executable and run
chmod +x setup-vm.sh
./setup-vm.sh
```

### Step 3: Log Out and Back In

```bash
exit
ssh username@your-vm-ip
```

This is needed for Docker group permissions to take effect.

### Step 4: Verify Installation

```bash
docker --version
# Docker version 24.0.x or higher

docker-compose --version
# Docker Compose version 2.x.x or higher

# Test Docker
docker run hello-world
```

### Step 5: Create Project Directory

```bash
mkdir -p ~/piazza-api
cd ~/piazza-api
```

---

## 🔐 GitHub Configuration

### Step 1: Create Docker Hub Token

1. Go to https://hub.docker.com
2. Click your profile → **Account Settings**
3. **Security** → **New Access Token**
4. Name: `github-actions`
5. Copy the token (save it somewhere safe!)

### Step 2: Generate SSH Key Pair (if you don't have one)

On your VM:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "github-actions"
# Press Enter to accept defaults
# Don't set a passphrase (just press Enter twice)

# View your public key
cat ~/.ssh/id_ed25519.pub

# View your private key (we'll use this for GitHub)
cat ~/.ssh/id_ed25519
```

Add your public key to authorized_keys:

```bash
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Step 3: Configure GitHub Secrets

1. Go to your GitHub repository
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

| Secret Name | Value | Example |
|------------|-------|---------|
| `DOCKER_USERNAME` | Your Docker Hub username | `johndoe` |
| `DOCKER_PASSWORD` | Docker Hub token from Step 1 | `dckr_pat_abc123...` |
| `VM_HOST` | Your VM's IP address | `203.0.113.42` |
| `VM_USERNAME` | Your VM username | `ubuntu` |
| `VM_SSH_KEY` | Private SSH key (entire file) | Copy from `cat ~/.ssh/id_ed25519` |
| `VM_SSH_PORT` | SSH port (optional, default 22) | `22` |
| `MONGODB_URI` | MongoDB connection string | `mongodb+srv://...` |
| `JWT_SECRET` | JWT secret key | `your_secret_key_min_32_chars` |
| `JWT_EXPIRE` | JWT expiration | `7d` |

**Important:** For `VM_SSH_KEY`, copy the **entire private key** including:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

---

## 🤖 Automatic Deployment

### How It Works

1. You push code to GitHub
2. GitHub Actions automatically:
   - Builds Docker image
   - Pushes to Docker Hub
   - SSHs to your VM
   - Pulls latest image
   - Stops old container
   - Starts new container
   - Verifies deployment

### Trigger Deployment

```bash
# Make a change
echo "# Update" >> README.md

# Commit and push
git add .
git commit -m "Update API"
git push origin main
```

### Monitor Deployment

1. Go to your GitHub repository
2. **Actions** tab
3. Click on the running workflow
4. Watch the live logs

### Deployment Steps

```
✅ Checkout code
✅ Set up Docker Buildx
✅ Log in to Docker Hub
✅ Build and push Docker image
✅ Deploy to VM
   - Pull latest image
   - Stop old container
   - Start new container
   - Clean up old images
✅ Verify deployment
   - Check container health
   - Test API endpoint
✅ Notify status
```

---

## 🔧 Manual Deployment

If you want to deploy without GitHub Actions:

### Option 1: Using Deploy Script

```bash
# On your local machine
cd cam-backend

# Copy .env file
cp .env.example .env
# Edit .env with your values

# Set Docker username
export DOCKER_USERNAME=your-docker-username

# Run deployment script
./scripts/deploy-manual.sh
```

### Option 2: Using Docker Commands

```bash
# Build image
docker build -t your-username/piazza-api:latest .

# Run container
docker run -d \
  --name piazza-api \
  --restart unless-stopped \
  -p 5000:5000 \
  -e NODE_ENV=production \
  -e PORT=5000 \
  -e MONGODB_URI="your-mongodb-uri" \
  -e JWT_SECRET="your-jwt-secret" \
  -e JWT_EXPIRE="7d" \
  your-username/piazza-api:latest

# Check logs
docker logs piazza-api
```

### Option 3: Using Docker Compose

```bash
# Create .env file
cp .env.example .env
# Edit with your values

# Start services
docker-compose up -d

# View logs
docker-compose logs -f piazza-api

# Stop services
docker-compose down
```

---

## 🧪 Local Docker Testing

Test your Docker setup locally before deploying:

```bash
# Build image
docker build -t piazza-api:test .

# Run container
docker run -d \
  --name piazza-test \
  -p 5000:5000 \
  --env-file .env \
  piazza-api:test

# Test API
curl http://localhost:5000/api/health

# Check logs
docker logs piazza-test

# Stop and remove
docker stop piazza-test
docker rm piazza-test
```

---

## 🔍 Troubleshooting

### Check Container Status

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# View container logs
docker logs piazza-api

# Follow logs in real-time
docker logs -f piazza-api

# Check last 100 lines
docker logs --tail 100 piazza-api
```

### Container Not Starting

```bash
# Check logs for errors
docker logs piazza-api

# Common issues:
# 1. MongoDB connection failed
#    - Verify MONGODB_URI is correct
#    - Check MongoDB Atlas IP whitelist (allow 0.0.0.0/0)

# 2. Port already in use
#    - Stop the conflicting container
#    - Or use different port: -p 5001:5000

# 3. Environment variables missing
#    - Verify all required env vars are set
#    - Check docker run command
```

### Restart Container

```bash
docker restart piazza-api
```

### View Container Details

```bash
docker inspect piazza-api
```

### Execute Shell in Container

```bash
docker exec -it piazza-api sh
```

### Clean Up

```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Remove unused data
docker system prune -a
```

### GitHub Actions Failing

**Build fails:**
- Check Dockerfile syntax
- Verify all files exist
- Check Docker Hub credentials

**Deployment fails:**
- Verify VM is accessible
- Check SSH key is correct
- Ensure VM has Docker installed
- Check VM firewall allows port 5000

**Health check fails:**
- Container may need more time to start
- Check MongoDB connection
- Verify environment variables

### View GitHub Actions Logs

1. Go to repository → **Actions**
2. Click on failed workflow
3. Click on failed job
4. Expand steps to see error details

---

## 📊 Monitoring

### Check API Health

```bash
# From VM
curl http://localhost:5000/api/health

# From outside (replace with your VM IP)
curl http://your-vm-ip:5000/api/health
```

### Expected Response

```json
{
  "success": true,
  "status": "healthy",
  "service": "piazza-api",
  "uptime": 12345.67,
  "timestamp": "2025-10-24T16:00:00.000Z"
}
```

### Monitor Container Resources

```bash
# Real-time stats
docker stats piazza-api

# One-time stats
docker stats --no-stream piazza-api
```

---

## 🔄 Updates and Rollbacks

### Deploy Update

Just push to GitHub:

```bash
git add .
git commit -m "Update feature"
git push origin main
```

### Rollback to Previous Version

```bash
# On VM
cd ~/piazza-api

# Pull specific version
docker pull your-username/piazza-api:COMMIT_SHA

# Stop current container
docker stop piazza-api
docker rm piazza-api

# Run previous version
docker run -d \
  --name piazza-api \
  --restart unless-stopped \
  -p 5000:5000 \
  --env-file .env \
  your-username/piazza-api:COMMIT_SHA
```

---

## 🎯 Success Checklist

After deployment, verify:

- [ ] Container is running: `docker ps | grep piazza-api`
- [ ] Health check passes: `curl http://localhost:5000/api/health`
- [ ] API accessible externally: `curl http://your-vm-ip:5000/api/health`
- [ ] Can register user
- [ ] Can login
- [ ] Can create post
- [ ] Can like/dislike/comment
- [ ] Logs show no errors: `docker logs piazza-api`

---

## 📝 Commands Cheat Sheet

```bash
# View logs
docker logs piazza-api
docker logs -f piazza-api          # Follow
docker logs --tail 50 piazza-api   # Last 50 lines

# Restart
docker restart piazza-api

# Stop
docker stop piazza-api

# Start
docker start piazza-api

# Remove
docker rm piazza-api

# Shell access
docker exec -it piazza-api sh

# Stats
docker stats piazza-api

# Inspect
docker inspect piazza-api

# Pull latest
docker pull your-username/piazza-api:latest

# Clean up
docker system prune -a
```

---

## 🆘 Getting Help

If you encounter issues:

1. Check logs: `docker logs piazza-api`
2. Verify environment variables
3. Test MongoDB connection
4. Check GitHub Actions logs
5. Verify VM firewall settings

---

**Deployment Status:** ✅ Ready for Production

**Next Steps:**
- Configure domain name (optional)
- Set up HTTPS with Let's Encrypt
- Configure monitoring (Prometheus/Grafana)
- Set up log aggregation
