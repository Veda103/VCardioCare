const express = require('express');
const router  = express.Router();
const { body, validationResult } = require('express-validator');
const { protect }    = require('../middleware/auth.middleware');
const HealthInput    = require('../models/HealthInput');

// All routes protected
router.use(protect);

// ────────────────────────────────────────────
// POST /api/health/submit
// ────────────────────────────────────────────
router.post(
  '/submit',
  body('systolicBP')
    .isFloat({ min: 70, max: 200 })
    .withMessage('Systolic BP must be 70–200'),
  body('diastolicBP')
    .isFloat({ min: 40, max: 130 })
    .withMessage('Diastolic BP must be 40–130'),
  body('bmi')
    .isFloat({ min: 10, max: 60 })
    .withMessage('BMI must be 10–60'),
  body('age')
    .isInt({ min: 1, max: 120 })
    .withMessage('Age must be 1–120'),
  body('totalCholesterol').isFloat().withMessage('Cholesterol is required'),
  body('fastingGlucose').isFloat().withMessage('Glucose is required'),
  body('smokingStatus')
    .isIn(['non-smoker', 'former', 'smoker'])
    .withMessage('Invalid smoking status'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('❌ Health validation errors:', errors.array());
      return res
        .status(400)
        .json({ success: false, errors: errors.array().map((e) => e.msg) });
    }
    next();
  },
  async (req, res) => {
    try {
      const record = await HealthInput.create({
        userId: req.user._id,
        ...req.body,
      });

      res.status(201).json({
        success: true,
        message: 'Health data saved successfully',
        healthInputId: record._id,
        data: record,
      });
    } catch (err) {
      console.error('Health submit error:', err.message);
      res
        .status(500)
        .json({ success: false, message: 'Failed to save health data' });
    }
  }
);

// ────────────────────────────────────────────
// GET /api/health/latest
// ────────────────────────────────────────────
router.get('/latest', async (req, res) => {
  try {
    const latest = await HealthInput.findOne({ userId: req.user._id }).sort({
      createdAt: -1,
    });

    if (!latest) {
      return res.status(404).json({
        success: false,
        message: 'No health data found. Please complete a health check first.',
      });
    }

    res.json({ success: true, data: latest });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to fetch data' });
  }
});

// ────────────────────────────────────────────
// GET /api/health/all?page=1&limit=10
// ────────────────────────────────────────────
router.get('/all', async (req, res) => {
  const page  = parseInt(req.query.page)  || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip  = (page - 1) * limit;

  try {
    const [records, total] = await Promise.all([
      HealthInput.find({ userId: req.user._id })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      HealthInput.countDocuments({ userId: req.user._id }),
    ]);

    res.json({
      success: true,
      total,
      page,
      pages: Math.ceil(total / limit),
      data: records,
    });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to fetch records' });
  }
});

module.exports = router;