const express = require('express');
const router = express.Router();
const {
  createPost,
  getPosts,
  getPost,
  likePost,
  dislikePost,
  addComment,
  getMostActivePost,
  getExpiredPosts,
  getMyInteractions,
  getPostInteractions
} = require('../controllers/postController');
const { createPostValidation, commentValidation, validate } = require('../middleware/validation');
const { protect } = require('../middleware/auth');

/**
 * Post Routes
 * All routes under /api/posts
 */

// @route   POST /api/posts
// @desc    Create a new post
// @access  Private
router.post('/', protect, createPostValidation, validate, createPost);

// @route   GET /api/posts
// @desc    Get all posts (with optional filters: ?topic=Tech&status=Live)
// @access  Public
router.get('/', getPosts);

// @route   GET /api/posts/interactions/my-history
// @desc    Get current user's interaction history
// @access  Private
router.get('/interactions/my-history', protect, getMyInteractions);

// @route   GET /api/posts/most-active/:topic
// @desc    Get most active post for a topic
// @access  Public
router.get('/most-active/:topic', getMostActivePost);

// @route   GET /api/posts/expired/:topic
// @desc    Get expired posts by topic
// @access  Public
router.get('/expired/:topic', getExpiredPosts);

// @route   GET /api/posts/:id
// @desc    Get single post by ID
// @access  Public
router.get('/:id', getPost);

// @route   POST /api/posts/:id/like
// @desc    Like a post
// @access  Private
router.post('/:id/like', protect, likePost);

// @route   POST /api/posts/:id/dislike
// @desc    Dislike a post
// @access  Private
router.post('/:id/dislike', protect, dislikePost);

// @route   POST /api/posts/:id/comment
// @desc    Add comment to a post
// @access  Private
router.post('/:id/comment', protect, commentValidation, validate, addComment);

// @route   GET /api/posts/:id/interactions
// @desc    Get all interactions for a specific post
// @access  Public
router.get('/:id/interactions', getPostInteractions);

module.exports = router;
