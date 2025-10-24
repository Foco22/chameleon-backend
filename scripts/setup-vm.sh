#!/bin/bash

# Piazza API - VM Setup Script
# This script sets up a fresh VM for Docker deployment
# Run this ONCE on your VM before first deployment

set -e  # Exit on error

echo "🚀 Setting up VM for Piazza API deployment..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
echo "📦 Installing required packages..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add current user to docker group
    sudo usermod -aG docker $USER

    echo "✅ Docker installed successfully"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose (standalone)
echo "🐳 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed successfully"
else
    echo "✅ Docker Compose already installed"
fi

# Create project directory
echo "📁 Creating project directory..."
mkdir -p ~/piazza-api
cd ~/piazza-api

# Configure firewall (if ufw is installed)
if command -v ufw &> /dev/null; then
    echo "🔥 Configuring firewall..."
    sudo ufw allow 22/tcp      # SSH
    sudo ufw allow 5000/tcp    # Piazza API
    echo "✅ Firewall configured"
fi

# Print versions
echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Installed versions:"
docker --version
docker-compose --version
echo ""
echo "📌 Next steps:"
echo "1. Log out and log back in for Docker group changes to take effect"
echo "2. Configure GitHub Secrets in your repository"
echo "3. Push code to GitHub to trigger automatic deployment"
echo ""
echo "🔑 GitHub Secrets needed:"
echo "   - DOCKER_USERNAME: Your Docker Hub username"
echo "   - DOCKER_PASSWORD: Your Docker Hub password/token"
echo "   - VM_HOST: This VM's IP address ($(hostname -I | awk '{print $1}'))"
echo "   - VM_USERNAME: Your username ($USER)"
echo "   - VM_SSH_KEY: Your private SSH key"
echo "   - MONGODB_URI: Your MongoDB connection string"
echo "   - JWT_SECRET: Your JWT secret key"
echo "   - JWT_EXPIRE: JWT expiration time (e.g., 7d)"
