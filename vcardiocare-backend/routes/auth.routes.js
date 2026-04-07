const express  = require('express');
const router   = express.Router();
const { body, validationResult } = require('express-validator');
const jwt      = require('jsonwebtoken');
const User     = require('../models/User');
const { protect } = require('../middleware/auth.middleware');

// ── Helper: sign JWT ──
const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });

// ── Helper: shape user response ──
const userPayload = (user) => ({
  id:          user._id,
  name:        user.name,
  email:       user.email,
  memberSince: user.memberSince,
  totalChecks: user.totalChecks,
  settings:    user.settings,
});

// ────────────────────────────────────────────
// POST /api/auth/register
// Body: { name, email, password, consentTimestamp }
// ────────────────────────────────────────────
router.post(
  '/register',
  body('name').notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  body('consentTimestamp')
    .notEmpty()
    .withMessage('Consent timestamp is required'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('❌ Validation errors:', errors.array());
      return res.status(400).json({ 
        success: false, 
        errors: errors.array().map((e) => e.msg) 
      });
    }
    next();
  },
  async (req, res) => {
    console.log('📥 Register request:', req.body);
    
    const { name, email, password, consentTimestamp } = req.body;

    try {
      console.log('🔍 Checking if email exists:', email);
      const existing = await User.findOne({ email });
      if (existing) {
        console.log('⚠️ Email already registered:', email);
        return res.status(400).json({
          success: false,
          message: 'An account with this email already exists.',
        });
      }

      console.log('💾 Creating new user:', { name, email });
      const user = await User.create({
        name,
        email,
        password,
        consentTimestamp: new Date(consentTimestamp),
      });

      console.log('✅ User created successfully:', user._id);
      res.status(201).json({
        success: true,
        token: signToken(user._id),
        user: userPayload(user),
      });
    } catch (err) {
      console.error('❌ Registration error:', err.message);
      console.error('Stack:', err.stack);
      res.status(500).json({ success: false, message: 'Registration failed: ' + err.message });
    }
  }
);

// ────────────────────────────────────────────
// POST /api/auth/login
// Body: { email, password }
// ────────────────────────────────────────────
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res
        .status(400)
        .json({ success: false, errors: errors.array().map((e) => e.msg) });
    }

    const { email, password } = req.body;

    try {
      const user = await User.findOne({ email }).select('+password');
      if (!user || !(await user.comparePassword(password))) {
        return res.status(401).json({
          success: false,
          message: 'Incorrect email or password.',
        });
      }

      res.json({
        success: true,
        token: signToken(user._id),
        user: userPayload(user),
      });
    } catch (err) {
      console.error('Login error:', err.message);
      res.status(500).json({ success: false, message: 'Login failed' });
    }
  }
);

// ────────────────────────────────────────────
// GET /api/auth/me  — protected
// ────────────────────────────────────────────
router.get('/me', protect, (req, res) => {
  res.json({ success: true, user: userPayload(req.user) });
});

module.exports = router;