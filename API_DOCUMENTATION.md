# Piazza API - Complete Documentation

RESTful API for the Piazza social platform with JWT authentication, posts, likes, dislikes, and comments.

## ✅ Completed Phases

- **Phase A**: Installation and deployment ✅
- **Phase B**: Authentication & verification ✅
- **Phase C**: Piazza RESTful APIs ✅

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start server
npm run dev

# Server runs on http://localhost:5000
```

## 📋 Complete API Reference

### Base URL
```
http://localhost:5000
```

---

## 🔐 Authentication Endpoints

### 1. Register User
```http
POST /api/auth/register
```

**Request Body:**
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "Password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
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

### 2. Login User
```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "Password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {...},
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 3. Get Current User
```http
GET /api/auth/me
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "username": "johndoe",
      "email": "john@example.com"
    }
  }
}
```

---

## 📝 Post Endpoints

### 1. Create Post
```http
POST /api/posts
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Introduction to Cloud Computing",
  "topics": ["Tech"],
  "message": "Cloud computing is transforming technology...",
  "expirationMinutes": 60
}
```

**Response:**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": {
    "post": {
      "_id": "...",
      "title": "Introduction to Cloud Computing",
      "topics": ["Tech"],
      "message": "...",
      "owner": {
        "username": "johndoe",
        "email": "john@example.com"
      },
      "expirationTime": "2025-10-23T12:00:00Z",
      "status": "Live",
      "likesCount": 0,
      "dislikesCount": 0,
      "commentsCount": 0
    }
  }
}
```

### 2. Browse All Posts
```http
GET /api/posts
```

**Optional Query Parameters:**
- `topic` - Filter by topic (Politics, Health, Sport, Tech)
- `status` - Filter by status (Live, Expired)

**Examples:**
```bash
GET /api/posts
GET /api/posts?topic=Tech
GET /api/posts?status=Live
GET /api/posts?topic=Health&status=Expired
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "data": {
    "posts": [...]
  }
}
```

### 3. Get Single Post
```http
GET /api/posts/:id
```

**Response:**
```json
{
  "success": true,
  "data": {
    "post": {
      "_id": "...",
      "title": "...",
      "topics": ["Tech"],
      "message": "...",
      "owner": {...},
      "comments": [
        {
          "user": {"username": "maria"},
          "text": "Great post!",
          "createdAt": "..."
        }
      ],
      "likesCount": 5,
      "dislikesCount": 2,
      "commentsCount": 3
    }
  }
}
```

### 4. Like Post
```http
POST /api/posts/:id/like
Authorization: Bearer {token}
```

**Features:**
- Toggle like (click again to unlike)
- Removes dislike if user previously disliked
- Cannot like own posts
- Cannot like expired posts

**Response:**
```json
{
  "success": true,
  "message": "Post liked",
  "data": {
    "post": {...},
    "likesCount": 1,
    "dislikesCount": 0
  }
}
```

### 5. Dislike Post
```http
POST /api/posts/:id/dislike
Authorization: Bearer {token}
```

**Features:**
- Toggle dislike (click again to remove)
- Removes like if user previously liked
- Cannot dislike own posts
- Cannot dislike expired posts

**Response:**
```json
{
  "success": true,
  "message": "Post disliked",
  "data": {
    "post": {...},
    "likesCount": 0,
    "dislikesCount": 1
  }
}
```

### 6. Add Comment
```http
POST /api/posts/:id/comment
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "text": "Great post! Very informative."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Comment added successfully",
  "data": {
    "post": {...},
    "commentsCount": 1
  }
}
```

### 7. Get Most Active Post
```http
GET /api/posts/most-active/:topic
```

**Example:**
```bash
GET /api/posts/most-active/Tech
```

Returns the post with the highest engagement (likes + dislikes) for the specified topic.

**Response:**
```json
{
  "success": true,
  "data": {
    "post": {...},
    "totalInteractions": 15
  }
}
```

### 8. Get Expired Posts
```http
GET /api/posts/expired/:topic
```

**Example:**
```bash
GET /api/posts/expired/Tech
```

Returns all expired posts for the specified topic.

**Response:**
```json
{
  "success": true,
  "count": 3,
  "data": {
    "posts": [...]
  }
}
```

---

## 📊 Data Models

### User Model
```javascript
{
  _id: ObjectId,
  username: String,      // 3-30 chars, alphanumeric + underscore
  email: String,         // Valid email, unique
  password: String,      // Hashed with bcrypt
  createdAt: Date,
  updatedAt: Date
}
```

### Post Model
```javascript
{
  _id: ObjectId,
  title: String,                    // 3-200 chars
  topics: [String],                 // ['Politics', 'Health', 'Sport', 'Tech']
  message: String,                  // 10-5000 chars
  owner: ObjectId (ref: User),
  expirationTime: Date,
  status: String,                   // 'Live' or 'Expired'
  likes: [ObjectId],                // User IDs who liked
  dislikes: [ObjectId],             // User IDs who disliked
  comments: [
    {
      user: ObjectId (ref: User),
      text: String,
      createdAt: Date
    }
  ],
  createdAt: Date,
  updatedAt: Date,

  // Virtual fields
  likesCount: Number,
  dislikesCount: Number,
  commentsCount: Number,
  totalInteractions: Number,
  timeLeft: Number (milliseconds)
}
```

---

## 🧪 Testing

### Automated Tests
```bash
# Test authentication endpoints
./test-api.sh

# Test post endpoints
./test-posts.sh
```

### Manual Testing with curl

**1. Register and Login:**
```bash
# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123"
  }'

# Login (save the token)
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123"
  }'
```

**2. Create a Post:**
```bash
curl -X POST http://localhost:5000/api/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "My First Post",
    "topics": ["Tech"],
    "message": "This is my first post on Piazza!",
    "expirationMinutes": 60
  }'
```

**3. Browse Posts:**
```bash
curl http://localhost:5000/api/posts?topic=Tech
```

**4. Like a Post:**
```bash
curl -X POST http://localhost:5000/api/posts/POST_ID/like \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**5. Add a Comment:**
```bash
curl -X POST http://localhost:5000/api/posts/POST_ID/comment \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"text": "Great post!"}'
```

---

## 🔒 Security Features

1. **Password Hashing** - bcrypt with 10 salt rounds
2. **JWT Tokens** - Signed with secret key, expires in 7 days
3. **Input Validation** - All inputs validated and sanitized
4. **Protected Routes** - Middleware blocks unauthorized access
5. **Owner Restrictions** - Cannot like/dislike own posts
6. **Expired Post Protection** - No interactions on expired posts

---

## ⚙️ Configuration

### Environment Variables (.env)
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your_secret_key
JWT_EXPIRE=7d
CLIENT_URL=http://localhost:3000
```

---

## 📁 Project Structure

```
cam-backend/
├── src/
│   ├── config/
│   │   └── database.js           # MongoDB connection
│   ├── controllers/
│   │   ├── authController.js     # Auth logic
│   │   └── postController.js     # Post logic
│   ├── middleware/
│   │   ├── auth.js               # JWT verification
│   │   └── validation.js         # Input validation
│   ├── models/
│   │   ├── User.js               # User schema
│   │   └── Post.js               # Post schema
│   ├── routes/
│   │   ├── authRoutes.js         # Auth endpoints
│   │   └── postRoutes.js         # Post endpoints
│   ├── utils/
│   │   └── generateToken.js      # JWT generator
│   └── server.js                 # Express app
├── .env
├── package.json
├── test-api.sh
├── test-posts.sh
├── README.md
├── API_DOCUMENTATION.md
├── PHASE_B_SUMMARY.md
└── PHASE_C_SUMMARY.md
```

---

## 📝 Validation Rules

### User Registration
- Username: 3-30 chars, alphanumeric + underscore
- Email: Valid email format
- Password: Min 6 chars, must contain uppercase, lowercase, and number

### Post Creation
- Title: 3-200 chars
- Topics: At least 1 from [Politics, Health, Sport, Tech]
- Message: 10-5000 chars
- ExpirationMinutes: Minimum 1 minute

### Comments
- Text: 1-1000 chars

---

## 🎯 Coursework Requirements Status

### Phase B: Authentication ✅
- ✅ User management and JWT functionality
- ✅ Authenticate users on every action
- ✅ Unauthorized users blocked
- ✅ Input validation implemented

### Phase C: Piazza APIs ✅
- ✅ Action 1: OAuth v2 (JWT) authentication
- ✅ Action 2: Post messages for topics
- ✅ Action 3: Browse messages per topic
- ✅ Action 4: Like, dislike, comment
- ✅ Action 5: Most active post per topic
- ✅ Action 6: Browse expired posts

---

## 🛠️ Technologies

- **Node.js** - Runtime
- **Express.js** - Web framework
- **MongoDB Atlas** - Cloud database
- **Mongoose** - MongoDB ODM
- **JWT** - Authentication
- **bcryptjs** - Password hashing
- **express-validator** - Input validation
- **dotenv** - Environment config
- **cors** - CORS support
- **nodemon** - Development auto-reload

---

## 📄 License

ISC

---

**Piazza API** - Cloud Computing Coursework 2023-2024
