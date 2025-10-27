# Piazza API - Phase B: Authentication & Verification

RESTful API for the Piazza social platform with JWT authentication.

## Features Implemented (Phase B)

✅ User registration with validation
✅ User login with JWT token generation
✅ Password hashing using bcrypt
✅ JWT-based authentication middleware
✅ Input validation and sanitization
✅ MongoDB integration
✅ Protected routes for authorized users only

## Project Structure

```
cam-backend/
├── src/
│   ├── config/
│   │   └── database.js          # MongoDB connection
│   ├── controllers/
│   │   ├── authController.js    # Authentication logic
│   │   └── postController.js    # Post CRUD and interactions
│   ├── middleware/
│   │   ├── auth.js              # JWT verification middleware
│   │   └── validation.js        # Input validation rules
│   ├── models/
│   │   ├── User.js              # User schema and model
│   │   ├── Post.js              # Post schema with expiration
│   │   └── Interaction.js       # Like/dislike/comment interactions
│   ├── routes/
│   │   ├── authRoutes.js        # Authentication endpoints
│   │   └── postRoutes.js        # Post and interaction endpoints
│   ├── utils/
│   │   └── generateToken.js     # JWT token generator
│   └── server.js                # Express app configuration
├── kubernetes/
│   ├── configmap.yaml           # Kubernetes ConfigMap
│   ├── deployment.yaml          # Kubernetes Deployment (3 replicas)
│   └── service.yaml             # LoadBalancer Service
├── .github/
│   └── workflows/
│       └── deploy.yml           # CI/CD pipeline for VM deployment
├── Dockerfile                   # Docker image configuration
├── .dockerignore
├── .env                         # Environment variables (local dev)
├── .gitignore
├── package.json
└── README.md
```

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (running locally or connection string)

## Installation & Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment variables:**
   Edit the `.env` file with your settings:
   ```env
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/piazza
   JWT_SECRET=your_secret_key
   JWT_EXPIRE=7d
   ```

3. **Start MongoDB:**
   ```bash
   # If using local MongoDB
   sudo systemctl start mongod
   # Or
   mongod
   ```

4. **Run the server:**
   ```bash
   # Development mode (with auto-reload)
   npm run dev

   # Production mode
   npm start
   ```

## API Endpoints

### Authentication Routes

All routes are prefixed with `/api/auth`

#### 1. Register User
- **POST** `/api/auth/register`
- **Access:** Public
- **Body:**
  ```json
  {
    "username": "johndoe",
    "email": "john@example.com",
    "password": "Password123"
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "data": {
      "user": {
        "id": "...",
        "username": "johndoe",
        "email": "john@example.com",
        "createdAt": "..."
      },
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
  ```

#### 2. Login User
- **POST** `/api/auth/login`
- **Access:** Public
- **Body:**
  ```json
  {
    "email": "john@example.com",
    "password": "Password123"
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "user": {
        "id": "...",
        "username": "johndoe",
        "email": "john@example.com"
      },
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
  ```

#### 3. Get Current User
- **GET** `/api/auth/me`
- **Access:** Private (requires token)
- **Headers:**
  ```
  Authorization: Bearer <your_token>
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "...",
        "username": "johndoe",
        "email": "john@example.com",
        "createdAt": "..."
      }
    }
  }
  ```

## Validation Rules

### Registration
- **Username:** 3-30 characters, alphanumeric with underscores only
- **Email:** Valid email format
- **Password:** Minimum 6 characters, must contain uppercase, lowercase, and number

### Login
- **Email:** Valid email format
- **Password:** Required

## Security Features

1. **Password Hashing:** Passwords are hashed using bcrypt with salt rounds
2. **JWT Tokens:** Secure token-based authentication
3. **Input Validation:** All inputs are validated and sanitized
4. **Protected Routes:** Middleware ensures only authenticated users access protected resources
5. **Error Handling:** Consistent error responses without exposing sensitive information

## Testing with Postman or cURL

### Register a new user:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123"
  }'
```

### Login:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123"
  }'
```

### Get current user (replace TOKEN with actual token):
```bash
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer TOKEN"
```

## Next Steps (Phase C)

- Create Post model for messages
- Implement post creation, browsing, and interactions
- Add like/dislike functionality
- Add comment functionality
- Implement post expiration logic
- Add topic-based filtering

## Deployment Options

### Option 1: Kubernetes (GKE) - Production

**Architecture:**
- 3 pod replicas for high availability
- LoadBalancer service with external IP
- ConfigMaps for configuration
- Secrets for sensitive data

**Deploy to Kubernetes:**

```bash
# 1. Create Kubernetes secrets (one-time setup)
kubectl create secret generic piazza-secrets \
  --from-literal=MONGODB_URI='your-mongodb-uri' \
  --from-literal=JWT_SECRET='your-jwt-secret'

# 2. Apply Kubernetes manifests
kubectl apply -f kubernetes/

# 3. Check deployment status
kubectl get pods
kubectl get service piazza-api-service

# 4. Get external IP (may take 1-2 minutes)
kubectl get service piazza-api-service

# 5. Test the API
curl http://<EXTERNAL-IP>/api/health
```

**Scale the deployment:**
```bash
# Scale to 5 replicas
kubectl scale deployment piazza-api-deployment --replicas=5

# Scale down to 3 replicas
kubectl scale deployment piazza-api-deployment --replicas=3
```

**Monitor logs:**
```bash
# All pods
kubectl logs -f deployment/piazza-api-deployment

# Specific pod
kubectl logs -f <pod-name>
```

### Option 2: VM with Docker - Development

**Architecture:**
- Single Docker container on Google Compute Engine VM
- GitHub Actions CI/CD pipeline
- Automatic deployment on push to main/master

**GitHub Actions Workflow:**
1. Build Docker image
2. Push to Docker Hub
3. SSH to VM
4. Pull latest image
5. Restart container

**Current Deployments:**
- **Kubernetes (GKE)**: `http://34.136.8.35` (3 replicas)
- **VM with Docker**: `http://34.31.213.170:5000` (single instance)

## Infrastructure Details

### Kubernetes Configuration

**ConfigMap** (`kubernetes/configmap.yaml`):
- NODE_ENV=production
- PORT=5000
- JWT_EXPIRE=7d

**Deployment** (`kubernetes/deployment.yaml`):
- 3 replicas for high availability
- Resource limits: 512Mi memory, 500m CPU per pod
- Health checks: liveness and readiness probes
- Rolling update strategy

**Service** (`kubernetes/service.yaml`):
- Type: LoadBalancer
- External port: 80
- Internal port: 5000

### Docker Configuration

**Dockerfile** features:
- Multi-stage build (optional optimization)
- Node.js 18 Alpine base image
- Non-root user for security
- Health check endpoint

**Build and run locally:**
```bash
# Build image
docker build -t piazza-api .

# Run container
docker run -d \
  -p 5000:5000 \
  -e MONGODB_URI='your-uri' \
  -e JWT_SECRET='your-secret' \
  --name piazza-api \
  piazza-api
```

## CI/CD Pipeline

**GitHub Actions** (`.github/workflows/deploy.yml`):

Triggers:
- Push to main/master branch
- Manual workflow dispatch

Steps:
1. Checkout code
2. Build Docker image with BuildX
3. Push to Docker Hub
4. SSH to VM
5. Deploy container
6. Verify deployment

**Required GitHub Secrets:**
- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub password
- `VM_HOST` - VM IP address
- `VM_USERNAME` - SSH username
- `VM_SSH_KEY` - SSH private key
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - JWT signing secret
- `JWT_EXPIRE` - Token expiration

## Technologies Used

- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM for MongoDB
- **JSON Web Tokens** - Authentication
- **bcryptjs** - Password hashing
- **express-validator** - Input validation
- **dotenv** - Environment configuration
- **cors** - Cross-origin resource sharing
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **GitHub Actions** - CI/CD automation
- **Google Cloud Platform** - Cloud infrastructure (GKE, Compute Engine)
