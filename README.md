# Piazza API - Backend 

RESTful API for the Piazza social platform with JWT authentication.

## Description

Piazza API is a RESTful backend service for a Piazza-style social platform with JWT-based authentication. This API provides secure endpoints for user registration, authentication, post management, and social interactions (likes, dislikes, comments). Built with Express.js and MongoDB, it features containerized deployment with Docker and Kubernetes orchestration for scalable cloud infrastructure.


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

- Node.js (v14 or higher) OR Docker
- MongoDB (running locally or connection string)

## Installation & Setup

### Option 1: Run with Node.js (Local Development)

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

### Option 2: Run with Docker

1. **Build the Docker image:**
   ```bash
   docker build -t piazza-api .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     -p 5000:5000 \
     -e MONGODB_URI='your-mongodb-uri' \
     -e JWT_SECRET='your-jwt-secret' \
     -e JWT_EXPIRE='7d' \
     -e PORT=5000 \
     --name piazza-api \
     piazza-api
   ```

3. **Check container status:**
   ```bash
   docker ps
   docker logs piazza-api
   ```

4. **Stop and remove container:**
   ```bash
   docker stop piazza-api
   docker rm piazza-api
   ```

**Using Docker Compose (if available):**
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down
```

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
