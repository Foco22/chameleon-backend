# Piazza Database Design

## Overview

The Piazza system uses **3 main collections** in MongoDB that work together to provide complete functionality.

## Collections

### 1. Users Collection ✅
Stores user authentication and profile information.

```javascript
{
  _id: ObjectId,
  username: String,      // Unique, 3-30 chars
  email: String,         // Unique, validated format
  password: String,      // Hashed with bcrypt
  createdAt: Date,
  updatedAt: Date
}
```

**Purpose**: User authentication and authorization
**Relationships**: Referenced by Posts and Interactions

---

### 2. Posts Collection ✅
Stores all posts with their content and metadata.

```javascript
{
  _id: ObjectId,
  title: String,                    // 3-200 chars
  topics: [String],                 // ['Politics', 'Health', 'Sport', 'Tech']
  message: String,                  // 10-5000 chars
  owner: ObjectId (ref: User),      // Who created the post
  expirationTime: Date,             // When post expires
  status: String,                   // 'Live' or 'Expired'

  // Quick reference arrays for counts
  likes: [ObjectId (ref: User)],    // User IDs who liked
  dislikes: [ObjectId (ref: User)], // User IDs who disliked

  // Embedded comments
  comments: [{
    user: ObjectId (ref: User),
    text: String,
    createdAt: Date,
    _id: ObjectId
  }],

  createdAt: Date,
  updatedAt: Date,

  // Virtual fields (calculated, not stored)
  likesCount: Number,
  dislikesCount: Number,
  commentsCount: Number,
  totalInteractions: Number,
  timeLeft: Number (milliseconds)
}
```

**Purpose**: Store post content and provide quick access to interaction counts
**Relationships**:
- Owned by one User
- Referenced by many Interactions

---

### 3. Interactions Collection ✅ **NEW!**
**Junction table** between Users and Posts that stores detailed interaction metadata.

```javascript
{
  _id: ObjectId,

  // Who and What
  user: ObjectId (ref: User),       // Who made the interaction
  post: ObjectId (ref: Post),       // Which post was interacted with
  type: String,                     // 'like', 'dislike', or 'comment'

  // Comment data (only if type='comment')
  commentText: String,              // The actual comment text

  // Snapshot data at time of interaction (coursework requirement!)
  timeLeftAtInteraction: Number,    // Milliseconds left until expiration
  postStatusAtInteraction: String,  // 'Live' or 'Expired'
  postTopicsAtInteraction: [String],// Topics of post at interaction time

  // Additional metadata
  metadata: {
    userAgent: String,
    ipAddress: String
  },

  createdAt: Date,                  // When interaction happened
  updatedAt: Date
}
```

**Purpose**:
- Track complete history of all user interactions
- Store metadata required by coursework (time left, post status, topics)
- Enable analytics and interaction queries

**Relationships**:
- Belongs to one User
- Belongs to one Post

---

## Database Relationships

```
┌──────────┐
│  Users   │
└────┬─────┘
     │
     │ owns (1:N)
     ↓
┌──────────┐
│  Posts   │◄──────┐
└────┬─────┘       │
     │             │
     │             │ references (N:1)
     │ references  │
     │ (N:1)       │
     ↓             │
┌──────────────────┴──┐
│   Interactions      │
└─────────────────────┘
```

**Relationships:**
- One User can create many Posts (1:N)
- One User can have many Interactions (1:N)
- One Post can have many Interactions (1:N)
- One Interaction belongs to one User and one Post (N:1, N:1)

---

## Why This Design?

### Dual Storage Strategy

We use **both** embedded arrays in Posts AND a separate Interactions collection:

**Posts.likes/dislikes arrays**:
- ✅ Fast count queries
- ✅ Quick check if user already liked/disliked
- ✅ Efficient for displaying post cards

**Interactions collection**:
- ✅ Complete interaction history
- ✅ Stores required metadata (time left, status, topics)
- ✅ Enables analytics queries
- ✅ Meets coursework requirements fully

This is **NOT redundant** - it's a performance optimization with complete metadata tracking!

---

## Coursework Requirements Met ✅

### Each Interaction Includes:
✅ **User information** - user field references User document
✅ **Interaction value** - type field (like/dislike/comment) + commentText
✅ **Time left for post to expire** - timeLeftAtInteraction field
✅ **Additional metadata** - postStatusAtInteraction, postTopicsAtInteraction, timestamps

---

## Example Queries

### Create a Post
```javascript
const post = await Post.create({
  title: "Cloud Computing Basics",
  topics: ["Tech"],
  message: "Learn about cloud...",
  owner: userId,
  expirationTime: new Date(Date.now() + 3600000) // 1 hour
});
```

### Like a Post (creates Interaction)
```javascript
// Add to Post likes array
post.likes.push(userId);
await post.save();

// Create detailed Interaction record
await Interaction.create({
  user: userId,
  post: postId,
  type: 'like',
  timeLeftAtInteraction: post.timeLeft,      // Milliseconds until expiration
  postStatusAtInteraction: post.status,      // 'Live'
  postTopicsAtInteraction: post.topics       // ['Tech']
});
```

### Get User's Interaction History
```javascript
const interactions = await Interaction.find({ user: userId })
  .populate('post', 'title topics message')
  .populate('user', 'username')
  .sort({ createdAt: -1 });

// Returns:
[
  {
    user: { username: "john" },
    post: { title: "Cloud Basics", topics: ["Tech"] },
    type: "like",
    timeLeftAtInteraction: 3456000,  // Had 57 minutes left
    postStatusAtInteraction: "Live",
    postTopicsAtInteraction: ["Tech"],
    createdAt: "2025-10-23T12:00:00Z"
  },
  {
    user: { username: "john" },
    post: { title: "Health Tips", topics: ["Health"] },
    type: "comment",
    commentText: "Great advice!",
    timeLeftAtInteraction: 1800000,  // Had 30 minutes left
    postStatusAtInteraction: "Live",
    postTopicsAtInteraction: ["Health"],
    createdAt: "2025-10-23T11:45:00Z"
  }
]
```

### Get All Interactions for a Post
```javascript
const interactions = await Interaction.find({ post: postId })
  .populate('user', 'username email')
  .sort({ createdAt: -1 });

// Shows complete timeline of who interacted, when, and with what time remaining
```

### Analytics: Most Active Users
```javascript
// Users with most interactions
const activeUsers = await Interaction.aggregate([
  { $group: { _id: "$user", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 10 }
]);
```

### Analytics: Interaction Patterns
```javascript
// When do users interact (while posts are fresh vs about to expire)?
const patterns = await Interaction.aggregate([
  {
    $bucket: {
      groupBy: "$timeLeftAtInteraction",
      boundaries: [0, 900000, 1800000, 3600000, Infinity],  // 0-15min, 15-30min, 30-60min, 60min+
      default: "other",
      output: { count: { $sum: 1 } }
    }
  }
]);
```

---

## Database Indexes

### Posts Collection
```javascript
// Find posts by topic and status
{ topics: 1, status: 1, createdAt: -1 }

// Find posts by owner
{ owner: 1 }

// Find posts by expiration
{ expirationTime: 1 }
```

### Interactions Collection
```javascript
// Find all interactions by a user
{ user: 1, createdAt: -1 }

// Find all interactions on a post
{ post: 1, createdAt: -1 }

// Find specific interaction type by user
{ user: 1, type: 1 }

// Find specific interaction type on a post
{ post: 1, type: 1 }

// Ensure unique likes/dislikes (prevent duplicates)
{ user: 1, post: 1, type: 1 }
```

---

## Collection Statistics (Example Data)

```
Users Collection:
  Total Documents: 10 users
  Size: ~2KB
  Indexes: 2 (_id, email)

Posts Collection:
  Total Documents: 50 posts
  Size: ~50KB
  Indexes: 3 (topics+status+createdAt, owner, expirationTime)
  Avg Likes per Post: 5
  Avg Comments per Post: 3

Interactions Collection:
  Total Documents: 400 interactions
    - Likes: 250
    - Dislikes: 50
    - Comments: 100
  Size: ~150KB
  Indexes: 5 (see above)
```

---

## Benefits of This Design

### 1. Performance
- Fast count queries from Post arrays
- Detailed history from Interactions
- Indexed for common query patterns

### 2. Data Integrity
- Foreign key references ensure valid relationships
- Timestamps track when everything happened
- Status snapshots preserve historical context

### 3. Analytics Capability
- Track user engagement patterns
- Analyze interaction timing
- Generate reports on popular topics

### 4. Scalability
- Separate concerns (Posts vs Interactions)
- Can archive old interactions
- Indexes support large datasets

### 5. Coursework Compliance
- Meets ALL requirements for interaction metadata
- Provides rich data for reports
- Enables advanced queries

---

## Summary

This 3-collection design provides:
- ✅ Fast performance (embedded arrays)
- ✅ Complete history (Interactions collection)
- ✅ Rich metadata (time left, status, topics)
- ✅ Full coursework compliance
- ✅ Analytics capabilities
- ✅ Scalability

**Database**: `chamaleon` on MongoDB Atlas
**Collections**: `users`, `posts`, `interactions`
