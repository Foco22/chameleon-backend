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
│   │   └── authController.js    # Authentication logic
│   ├── middleware/
│   │   ├── auth.js              # JWT verification middleware
│   │   └── validation.js        # Input validation rules
│   ├── models/
│   │   └── User.js              # User schema and model
│   ├── routes/
│   │   └── authRoutes.js        # Authentication endpoints
│   ├── utils/
│   │   └── generateToken.js     # JWT token generator
│   └── server.js                # Express app configuration
├── .env                         # Environment variables
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

## Technologies Used

- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM for MongoDB
- **JSON Web Tokens** - Authentication
- **bcryptjs** - Password hashing
- **express-validator** - Input validation
- **dotenv** - Environment configuration
- **cors** - Cross-origin resource sharing
# Docker installed on VM - Ready for deployment
