#!/bin/bash

# Piazza API - Manual Deployment Script
# Use this script to deploy manually without GitHub Actions

set -e  # Exit on error

# Configuration
DOCKER_USERNAME="${DOCKER_USERNAME:-your-docker-username}"
IMAGE_NAME="piazza-api"
CONTAINER_NAME="piazza-api"
PORT="5000"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting manual deployment of Piazza API...${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "Please create .env file with required environment variables"
    exit 1
fi

# Load environment variables
echo -e "${YELLOW}📋 Loading environment variables...${NC}"
export $(cat .env | grep -v '^#' | xargs)

# Build Docker image
echo -e "${YELLOW}🏗️  Building Docker image...${NC}"
docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest .

# Stop and remove existing container
echo -e "${YELLOW}🛑 Stopping existing container...${NC}"
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

# Run new container
echo -e "${YELLOW}🐳 Starting new container...${NC}"
docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p ${PORT}:${PORT} \
  -e NODE_ENV=production \
  -e PORT=${PORT} \
  -e MONGODB_URI="${MONGODB_URI}" \
  -e JWT_SECRET="${JWT_SECRET}" \
  -e JWT_EXPIRE="${JWT_EXPIRE}" \
  ${DOCKER_USERNAME}/${IMAGE_NAME}:latest

# Wait for container to start
echo -e "${YELLOW}⏳ Waiting for container to start...${NC}"
sleep 5

# Check container status
echo -e "${YELLOW}📊 Checking container status...${NC}"
if docker ps | grep -q ${CONTAINER_NAME}; then
    echo -e "${GREEN}✅ Container is running${NC}"
    docker ps | grep ${CONTAINER_NAME}
else
    echo -e "${RED}❌ Container failed to start${NC}"
    echo "Logs:"
    docker logs ${CONTAINER_NAME}
    exit 1
fi

# Test API endpoint
echo -e "${YELLOW}🧪 Testing API endpoint...${NC}"
sleep 3
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT}/api/health)

if [ "$response" = "200" ]; then
    echo -e "${GREEN}✅ API is responding (HTTP $response)${NC}"
else
    echo -e "${RED}❌ API health check failed (HTTP $response)${NC}"
    echo "Logs:"
    docker logs ${CONTAINER_NAME}
    exit 1
fi

# Show recent logs
echo -e "${YELLOW}📝 Recent logs:${NC}"
docker logs --tail 20 ${CONTAINER_NAME}

# Clean up old images
echo -e "${YELLOW}🧹 Cleaning up old images...${NC}"
docker image prune -f

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "📌 Container info:"
echo "   Name: ${CONTAINER_NAME}"
echo "   Port: ${PORT}"
echo "   Image: ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
echo ""
echo "🔗 Useful commands:"
echo "   View logs:    docker logs ${CONTAINER_NAME}"
echo "   Follow logs:  docker logs -f ${CONTAINER_NAME}"
echo "   Stop:         docker stop ${CONTAINER_NAME}"
echo "   Restart:      docker restart ${CONTAINER_NAME}"
echo "   Shell:        docker exec -it ${CONTAINER_NAME} sh"
