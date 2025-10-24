# Postman Testing Guide - Piazza API

Complete guide to test all Piazza API endpoints using Postman.

## 📋 Table of Contents
1. [Setup](#setup)
2. [Authentication Tests](#authentication-tests)
3. [Post Tests](#post-tests)
4. [Interaction Tests](#interaction-tests)
5. [Advanced Queries](#advanced-queries)

---

## 🔧 Setup

### Step 1: Create Environment in Postman

1. Click **"Environments"** in Postman (left sidebar)
2. Click **"+"** to create new environment
3. Name it: **"Piazza Local"**
4. Add these variables:

| Variable | Initial Value | Current Value |
|----------|--------------|---------------|
| `baseURL` | `http://localhost:5000` | `http://localhost:5000` |
| `token` | (leave empty) | (will be set automatically) |
| `postId` | (leave empty) | (will be set automatically) |
| `userId` | (leave empty) | (will be set automatically) |

5. Click **"Save"**
6. Select **"Piazza Local"** environment from dropdown (top-right)

---

## 🔐 Authentication Tests

### Test 1: Register User

**Request:**
```
POST {{baseURL}}/api/auth/register
```

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "johndoe",
  "email": "john@test.com",
  "password": "Test123"
}
```

**Expected Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "...",
      "username": "johndoe",
      "email": "john@test.com"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Save Token Automatically (Tests tab):**
```javascript
// Click "Tests" tab and add this script
if (pm.response.code === 201) {
    const response = pm.response.json();
    pm.environment.set("token", response.data.token);
    pm.environment.set("userId", response.data.user.id);
}
```

---

### Test 2: Login User

**Request:**
```
POST {{baseURL}}/api/auth/login
```

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "email": "john@test.com",
  "password": "Test123"
}
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {...},
    "token": "..."
  }
}
```

**Save Token (Tests tab):**
```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set("token", response.data.token);
}
```

---

### Test 3: Get Current User (Protected)

**Request:**
```
GET {{baseURL}}/api/auth/me
```

**Headers:**
```
Authorization: Bearer {{token}}
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "username": "johndoe",
      "email": "john@test.com"
    }
  }
}
```

**Test Without Token (should fail):**
- Remove Authorization header
- Expected: 401 Unauthorized

---

## 📝 Post Tests

### Test 4: Create Post

**Request:**
```
POST {{baseURL}}/api/posts
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

**Body (JSON):**
```json
{
  "title": "Introduction to Cloud Computing",
  "topics": ["Tech"],
  "message": "Cloud computing revolutionizes how we build and deploy applications. It provides on-demand access to computing resources.",
  "expirationMinutes": 60
}
```

**Expected Response (201):**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": {
    "post": {
      "_id": "...",
      "title": "Introduction to Cloud Computing",
      "topics": ["Tech"],
      "owner": {
        "username": "johndoe",
        "email": "john@test.com"
      },
      "status": "Live",
      "likesCount": 0,
      "dislikesCount": 0
    }
  }
}
```

**Save Post ID (Tests tab):**
```javascript
if (pm.response.code === 201) {
    const response = pm.response.json();
    pm.environment.set("postId", response.data.post._id);
}
```

**Try Different Topics:**
```json
{
  "title": "Health Benefits of Exercise",
  "topics": ["Health", "Sport"],
  "message": "Regular exercise...",
  "expirationMinutes": 30
}
```

---

### Test 5: Get All Posts

**Request:**
```
GET {{baseURL}}/api/posts
```

**No headers needed (public)**

**Expected Response (200):**
```json
{
  "success": true,
  "count": 5,
  "data": {
    "posts": [...]
  }
}
```

---

### Test 6: Get Posts by Topic

**Request:**
```
GET {{baseURL}}/api/posts?topic=Tech
```

**Try Different Filters:**
- `?topic=Health`
- `?status=Live`
- `?topic=Tech&status=Live`

---

### Test 7: Get Single Post

**Request:**
```
GET {{baseURL}}/api/posts/{{postId}}
```

**Expected Response (200):**
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
      "comments": [],
      "likesCount": 0,
      "timeLeft": 3540000
    }
  }
}
```

---

## 👍 Interaction Tests

### Setup: Create Second User

Before testing likes/dislikes, register another user (you can't like your own posts):

**Request:**
```
POST {{baseURL}}/api/auth/register
```

**Body:**
```json
{
  "username": "maria",
  "email": "maria@test.com",
  "password": "Maria123"
}
```

**Save Maria's token as `token2` (Tests tab):**
```javascript
if (pm.response.code === 201) {
    const response = pm.response.json();
    pm.environment.set("token2", response.data.token);
}
```

---

### Test 8: Like Post (Maria)

**Request:**
```
POST {{baseURL}}/api/posts/{{postId}}/like
```

**Headers:**
```
Authorization: Bearer {{token2}}
```

**Expected Response (200):**
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

**Test: Unlike (click again):**
- Same request
- Expected: "Like removed", likesCount: 0

---

### Test 9: Try to Like Own Post (Should Fail)

**Request:**
```
POST {{baseURL}}/api/posts/{{postId}}/like
```

**Headers:**
```
Authorization: Bearer {{token}}
```
(Using original user's token)

**Expected Response (400):**
```json
{
  "success": false,
  "message": "You cannot like your own post"
}
```

---

### Test 10: Dislike Post (Maria)

**Request:**
```
POST {{baseURL}}/api/posts/{{postId}}/dislike
```

**Headers:**
```
Authorization: Bearer {{token2}}
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Post disliked",
  "data": {
    "likesCount": 0,
    "dislikesCount": 1
  }
}
```

**Note:** If Maria had liked before, the like is removed automatically.

---

### Test 11: Add Comment (Maria)

**Request:**
```
POST {{baseURL}}/api/posts/{{postId}}/comment
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token2}}
```

**Body (JSON):**
```json
{
  "text": "Great introduction to cloud computing! Very helpful for beginners."
}
```

**Expected Response (201):**
```json
{
  "success": true,
  "message": "Comment added successfully",
  "data": {
    "post": {
      "comments": [
        {
          "user": {
            "username": "maria"
          },
          "text": "Great introduction...",
          "createdAt": "..."
        }
      ]
    },
    "commentsCount": 1
  }
}
```

---

### Test 12: Add Another Comment (John)

**Request:**
```
POST {{baseURL}}/api/posts/{{postId}}/comment
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

**Body (JSON):**
```json
{
  "text": "Thanks for reading! I'll post more about cloud architecture soon."
}
```

**Note:** Post owners CAN comment on their own posts.

---

## 📊 Advanced Queries

### Test 13: Get Most Active Post

**Request:**
```
GET {{baseURL}}/api/posts/most-active/Tech
```

**No headers needed (public)**

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "post": {...},
    "totalInteractions": 5
  }
}
```

**Try Other Topics:**
- `/most-active/Health`
- `/most-active/Sport`
- `/most-active/Politics`

---

### Test 14: Get Expired Posts

**Request:**
```
GET {{baseURL}}/api/posts/expired/Tech
```

**Expected Response (200):**
```json
{
  "success": true,
  "count": 2,
  "data": {
    "posts": [...]
  }
}
```

**Note:** Posts expire based on `expirationMinutes` set during creation.

---

### Test 15: Try to Interact with Expired Post

1. **Wait for a post to expire** (or create one with `expirationMinutes: 1`)
2. **Try to like it:**

**Request:**
```
POST {{baseURL}}/api/posts/{{expiredPostId}}/like
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Cannot like an expired post"
}
```

---

### Test 16: Get My Interaction History

**Request:**
```
GET {{baseURL}}/api/posts/interactions/my-history
```

**Headers:**
```
Authorization: Bearer {{token2}}
```

**Expected Response (200):**
```json
{
  "success": true,
  "count": 3,
  "data": {
    "interactions": [
      {
        "type": "comment",
        "commentText": "Great introduction...",
        "post": {
          "title": "Introduction to Cloud Computing"
        },
        "timeLeftAtInteraction": 3540000,
        "postStatusAtInteraction": "Live",
        "createdAt": "..."
      },
      {
        "type": "like",
        "post": {...},
        "timeLeftAtInteraction": 3600000,
        "createdAt": "..."
      }
    ]
  }
}
```

---

### Test 17: Get Post Interactions

**Request:**
```
GET {{baseURL}}/api/posts/{{postId}}/interactions
```

**No headers needed (public)**

**Expected Response (200):**
```json
{
  "success": true,
  "count": 5,
  "data": {
    "interactions": [
      {
        "user": {
          "username": "maria"
        },
        "type": "comment",
        "commentText": "...",
        "timeLeftAtInteraction": 3540000
      }
    ]
  }
}
```

---

## 🧪 Validation Tests

### Test 18: Invalid Post Creation

**Request:**
```
POST {{baseURL}}/api/posts
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

**Body (Invalid - title too short):**
```json
{
  "title": "Hi",
  "topics": ["Tech"],
  "message": "Short",
  "expirationMinutes": 60
}
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "title",
      "message": "Title must be between 3 and 200 characters"
    },
    {
      "field": "message",
      "message": "Message must be between 10 and 5000 characters"
    }
  ]
}
```

---

### Test 19: Invalid Topic

**Body:**
```json
{
  "title": "Invalid Topic Post",
  "topics": ["InvalidTopic"],
  "message": "This should fail...",
  "expirationMinutes": 60
}
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "topics",
      "message": "Topics must be one of: Politics, Health, Sport, Tech"
    }
  ]
}
```

---

## 📋 Complete Testing Checklist

### Authentication
- [x] Test 1: Register new user
- [x] Test 2: Login user
- [x] Test 3: Get current user (protected)
- [x] Test 3b: Try without token (should fail)

### Posts
- [x] Test 4: Create post
- [x] Test 5: Get all posts
- [x] Test 6: Filter posts by topic
- [x] Test 7: Get single post

### Interactions
- [x] Test 8: Like post
- [x] Test 9: Try to like own post (should fail)
- [x] Test 10: Dislike post
- [x] Test 11: Add comment
- [x] Test 12: Add another comment

### Advanced
- [x] Test 13: Get most active post
- [x] Test 14: Get expired posts
- [x] Test 15: Try to interact with expired post (should fail)
- [x] Test 16: Get my interaction history
- [x] Test 17: Get post interactions

### Validation
- [x] Test 18: Invalid post data
- [x] Test 19: Invalid topic

---

## 💡 Tips

### 1. Use Environment Variables
Always use `{{baseURL}}`, `{{token}}`, `{{postId}}` instead of hard-coding values.

### 2. Save Values Automatically
Add test scripts to save tokens and IDs:
```javascript
// In Tests tab
if (pm.response.code === 201) {
    const response = pm.response.json();
    pm.environment.set("token", response.data.token);
}
```

### 3. Create Collections
Organize tests into folders:
```
Piazza API/
  ├── Authentication/
  │   ├── Register
  │   ├── Login
  │   └── Get Me
  ├── Posts/
  │   ├── Create Post
  │   ├── Get Posts
  │   └── Get Single Post
  └── Interactions/
      ├── Like
      ├── Dislike
      └── Comment
```

### 4. Use Pre-request Scripts
Set common headers:
```javascript
// In Collection settings > Pre-request Scripts
pm.request.headers.add({
    key: 'Content-Type',
    value: 'application/json'
});
```

### 5. Test in Order
Some tests depend on others:
1. Register/Login first (get token)
2. Create posts (get postIds)
3. Then test interactions

---

## 🚀 Quick Test Sequence

**5-Minute Full Test:**

1. **Register** → Save token
2. **Create Post** → Save postId
3. **Register 2nd User** → Save token2
4. **Like Post** (user 2)
5. **Comment on Post** (user 2)
6. **Get Post** → See likes & comments
7. **Get Most Active** → See your post
8. **Get My History** (user 2) → See interactions

---

## 📥 Import Postman Collection

See `Piazza_API.postman_collection.json` for a ready-to-import collection with all tests configured!

---

**Happy Testing!** 🎉
