# Postman Quick Start Guide

## 🚀 Get Testing in 5 Minutes!

### Step 1: Import Collection (30 seconds)

1. Open Postman
2. Click **"Import"** (top left)
3. Click **"Upload Files"**
4. Select `Piazza_API.postman_collection.json`
5. Click **"Import"**

✅ You now have **25 pre-configured tests** ready to run!

---

### Step 2: Create Environment (1 minute)

1. Click **"Environments"** (left sidebar)
2. Click **"+"** to create new
3. Name it: **"Piazza Local"**
4. Add variables:

```
Variable:  baseURL
Value:     http://localhost:5000

Variable:  token
Value:     (leave empty)

Variable:  token2
Value:     (leave empty)

Variable:  postId
Value:     (leave empty)
```

5. Click **"Save"**
6. Select **"Piazza Local"** from dropdown (top right)

---

### Step 3: Run Tests (3 minutes)

**🎯 Quick Test Sequence:**

1. **Authentication → Register User 1 (John)**
   - Click **"Send"**
   - ✅ Token automatically saved!

2. **Authentication → Register User 2 (Maria)**
   - Click **"Send"**
   - ✅ Token2 automatically saved!

3. **Posts → Create Post (Tech)**
   - Click **"Send"**
   - ✅ PostId automatically saved!

4. **Interactions → Like Post (Maria)**
   - Click **"Send"**
   - ✅ Maria likes John's post!

5. **Interactions → Add Comment (Maria)**
   - Click **"Send"**
   - ✅ Comment added!

6. **Posts → Get Single Post**
   - Click **"Send"**
   - ✅ See the post with 1 like and 1 comment!

---

## 📊 What Each Folder Tests

### 📁 Authentication (4 tests)
- Register users
- Login
- Get current user
- Protected route access

### 📁 Posts (6 tests)
- Create posts
- Get all posts
- Filter by topic
- Filter by status
- Get single post

### 📁 Interactions (7 tests)
- Like posts
- Dislike posts
- Add comments
- Try to like own post (fails)
- Get interaction history
- Get post interactions

### 📁 Advanced Queries (3 tests)
- Most active post per topic
- Expired posts per topic

### 📁 Validation Tests (3 tests)
- Invalid data handling
- Invalid topics
- Unauthorized access

---

## 💡 Pro Tips

### Tip 1: Use Environment Variables
All requests use `{{baseURL}}`, `{{token}}`, `{{postId}}` automatically!

### Tip 2: Watch the Console
Open **Postman Console** (bottom left) to see:
- "Token saved: eyJhbG..."
- "Post ID saved: 68fa..."

### Tip 3: Run All Tests
1. Click on collection name
2. Click **"Run"** button
3. Select all tests
4. Click **"Run Piazza API"**
5. ✅ All tests run automatically!

### Tip 4: Check Environment
Click the "eye" icon (👁️) next to environment dropdown to see saved values.

---

## 🎯 Test Order Matters!

Some tests depend on previous ones:

```
1. Register → Saves token
   ↓
2. Create Post → Saves postId
   ↓
3. Like/Comment → Uses token and postId
   ↓
4. Get Post → Shows likes and comments
```

**Run in this order:**
1. ✅ Authentication folder first
2. ✅ Posts folder second
3. ✅ Interactions folder third
4. ✅ Advanced Queries last

---

## 🔍 Common Issues

### Issue: "Not authorized, no token provided"
**Solution**: Run **"Register User 1"** or **"Login User"** first to get a token.

### Issue: "Post not found"
**Solution**: Run **"Create Post"** first to get a valid postId.

### Issue: "You cannot like your own post"
**Solution**: Use **"Like Post (Maria)"** which uses `{{token2}}`, not `{{token}}`.

### Issue: Environment variables not working
**Solution**:
1. Check environment is selected (top right)
2. Check variables are saved (click eye icon 👁️)

---

## 📸 Screenshots to Take for Report

### 1. Successful Registration
Show response with user and token.

### 2. Create Post
Show response with post details, status="Live", likesCount=0.

### 3. Like Post
Show response with likesCount=1.

### 4. Get Post with Interactions
Show post with likes, comments, and all metadata.

### 5. Interaction History
Show timeLeftAtInteraction and other metadata.

### 6. Validation Error
Show validation error messages for invalid data.

### 7. Authorization Error
Show 401 error when trying without token.

### 8. Owner Restriction Error
Show 400 error when trying to like own post.

---

## 🎉 Success Checklist

After running all tests, you should have:

- [x] 2 registered users (John & Maria)
- [x] 2+ posts created
- [x] Posts with likes and comments
- [x] Interaction history records
- [x] Validated all endpoints work
- [x] Tested error cases
- [x] Screenshots for report

---

## 📝 For Your Report

**What to Include:**

1. **Screenshot of Postman collection**
   - Shows all folders and tests

2. **Environment variables setup**
   - Shows baseURL, token, postId

3. **Successful requests**
   - Register, Login, Create Post, Like, Comment

4. **Error handling**
   - Validation errors
   - Authorization errors
   - Business logic errors (can't like own post)

5. **Interaction metadata**
   - Show timeLeftAtInteraction
   - Show postStatusAtInteraction
   - Show postTopicsAtInteraction

---

## 🆘 Need Help?

### Test a Single Endpoint Manually

**Example: Like a Post**

1. URL: `http://localhost:5000/api/posts/YOUR_POST_ID/like`
2. Method: `POST`
3. Headers:
   ```
   Authorization: Bearer YOUR_TOKEN
   ```
4. Send!

**Replace:**
- `YOUR_POST_ID` with actual post ID
- `YOUR_TOKEN` with actual token from login

---

**Ready to test? Import the collection and start! 🚀**
