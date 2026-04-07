const express    = require('express');
const router     = express.Router();
const axios      = require('axios');
const { protect }    = require('../middleware/auth.middleware');
const Prediction     = require('../models/Prediction');
const HealthInput    = require('../models/HealthInput');
const User           = require('../models/User');

router.use(protect);

// ── Wellness messages by risk level ──
const messages = {
  low: [
    "You're doing really well. Your numbers look healthy — keep up your current habits and stay consistent.",
    "Great news! Your indicators suggest a low risk profile. Small daily habits compound beautifully over time.",
  ],
  moderate: [
    "You're on the right path. A few focused changes — especially around stress and activity — could make a meaningful difference.",
    "Your results suggest some areas worth attention. Nothing to worry about — just a gentle nudge to keep moving forward.",
  ],
  elevated: [
    "Thank you for checking in. Your results suggest it may be worth speaking with your doctor. You're being proactive and that matters.",
    "Your score suggests some factors worth discussing with a healthcare professional. Reaching out is a sign of strength.",
  ],
};

const pickMessage = (label) => {
  const opts = messages[label] || messages.low;
  return opts[Math.floor(Math.random() * opts.length)];
};

const getRiskLabel = (pct) => {
  if (pct < 30) return 'low';
  if (pct < 60) return 'moderate';
  return 'elevated';
};

// ────────────────────────────────────────────
// POST /api/predictions/analyse
// Body: { healthInputId }
// ────────────────────────────────────────────
router.post('/analyse', async (req, res) => {
  const { healthInputId } = req.body;

  if (!healthInputId) {
    return res
      .status(400)
      .json({ success: false, message: 'healthInputId is required' });
  }

  try {
    // 1. Fetch the health record
    const health = await HealthInput.findOne({
      _id: healthInputId,
      userId: req.user._id,
    });

    if (!health) {
      return res
        .status(404)
        .json({ success: false, message: 'Health input record not found' });
    }

    // 2. Call Python ML API (falls back to mock if not ready)
    let mlResult;
    try {
      const { data } = await axios.post(
        process.env.ML_API_URL || 'http://localhost:8000/predict',
        {
          systolic_bp:      health.systolicBP,
          diastolic_bp:     health.diastolicBP,
          bmi:              health.bmi,
          age:              health.age,
          total_cholesterol: health.totalCholesterol,
          fasting_glucose:  health.fastingGlucose,
          smoking_status:   health.smokingStatus,
          sleep_hours:      health.sleepHours,
          stress_level:     health.stressLevel,
          has_diabetes:     health.hasDiabetes,
          has_family_history: health.hasFamilyHistory,
          has_hypertension: health.hasHypertension,
          physical_activity: health.physicalActivity,
        },
        { timeout: 10000 }
      );
      mlResult = data;
    } catch (mlErr) {
      console.warn('ML API unavailable — using mock result');
      mlResult = {
        risk_percent: 34,
        confidence: 87,
        shap_factors: [
          { feature: 'smoking_status', display_name: 'Smoking History', icon: '🚬', shap_value: 0.18, impact_percent: 18, is_modifiable: true  },
          { feature: 'stress_level',   display_name: 'Stress Level',    icon: '😰', shap_value: 0.09, impact_percent: 9,  is_modifiable: true  },
          { feature: 'family_history', display_name: 'Family History',  icon: '👨‍👩‍👧', shap_value: 0.06, impact_percent: 6,  is_modifiable: false },
        ],
      };
    }

    const riskPercent = mlResult.risk_percent;
    const riskLabel   = getRiskLabel(riskPercent);

    // 3. Persist prediction in Atlas
    const prediction = await Prediction.create({
      userId:          req.user._id,
      healthInputId:   health._id,
      riskPercent,
      riskLabel,
      confidenceScore: mlResult.confidence || 85,
      shapFactors:     (mlResult.shap_factors || []).map((f) => ({
        feature:       f.feature,
        displayName:   f.display_name,
        icon:          f.icon,
        shapValue:     f.shap_value,
        impactPercent: f.impact_percent,
        isModifiable:  f.is_modifiable,
      })),
      wellnessMessage: pickMessage(riskLabel),
      vitalSnapshot: {
        systolicBP:  health.systolicBP,
        diastolicBP: health.diastolicBP,
        bmi:         health.bmi,
        cholesterol: health.totalCholesterol,
      },
    });

    // 4. Increment user check count
    await User.findByIdAndUpdate(req.user._id, { $inc: { totalChecks: 1 } });

    res.status(201).json({
      success: true,
      data: {
        predictionId:    prediction._id,
        riskPercent:     prediction.riskPercent,
        riskLabel:       prediction.riskLabel,
        confidenceScore: prediction.confidenceScore,
        shapFactors:     prediction.shapFactors,
        wellnessMessage: prediction.wellnessMessage,
        vitalSnapshot:   prediction.vitalSnapshot,
        predictedAt:     prediction.predictedAt,
      },
    });
  } catch (err) {
    console.error('Prediction error:', err.message);
    res.status(500).json({ success: false, message: 'Prediction failed' });
  }
});

// ────────────────────────────────────────────
// GET /api/predictions/history?filter=30d&page=1&limit=20
// ────────────────────────────────────────────
router.get('/history', async (req, res) => {
  const { filter = '30d', page = 1, limit = 20 } = req.query;
  const skip = (parseInt(page) - 1) * parseInt(limit);

  const days     = { '30d': 30, '90d': 90, '1y': 365 }[filter] || 30;
  const fromDate = new Date(Date.now() - days * 86400 * 1000);

  try {
    const query = { userId: req.user._id, predictedAt: { $gte: fromDate } };

    const [predictions, total] = await Promise.all([
      Prediction.find(query)
        .sort({ predictedAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .select('riskPercent riskLabel confidenceScore vitalSnapshot predictedAt'),
      Prediction.countDocuments(query),
    ]);

    res.json({ success: true, total, filter, data: predictions });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to fetch history' });
  }
});

// ────────────────────────────────────────────
// GET /api/predictions/latest
// ────────────────────────────────────────────
router.get('/latest', async (req, res) => {
  try {
    const latest = await Prediction.findOne({ userId: req.user._id }).sort({
      predictedAt: -1,
    });

    if (!latest) {
      return res
        .status(404)
        .json({ success: false, message: 'No predictions yet.' });
    }

    res.json({ success: true, data: latest });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to fetch prediction' });
  }
});

module.exports = router;