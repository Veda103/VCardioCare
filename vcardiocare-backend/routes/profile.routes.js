const express  = require('express');
const router   = express.Router();
const { protect }  = require('../middleware/auth.middleware');
const User         = require('../models/User');
const HealthInput  = require('../models/HealthInput');
const Prediction   = require('../models/Prediction');

router.use(protect);

// ────────────────────────────────────────────
// GET /api/profile
// ────────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    res.json({
      success: true,
      data: {
        id:          user._id,
        name:        user.name,
        email:       user.email,
        memberSince: user.memberSince,
        totalChecks: user.totalChecks,
        settings:    user.settings,
      },
    });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to fetch profile' });
  }
});

// ────────────────────────────────────────────
// PATCH /api/profile
// Body: { name?, email? }
// ────────────────────────────────────────────
router.patch('/', async (req, res) => {
  const updates = {};
  ['name', 'email'].forEach((k) => {
    if (req.body[k] !== undefined) updates[k] = req.body[k];
  });

  try {
    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      new: true,
      runValidators: true,
    });
    res.json({ success: true, data: user });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to update profile' });
  }
});

// ────────────────────────────────────────────
// PATCH /api/profile/settings
// Body: { dataEncryption?, cloudBackup?, notifications? }
// ────────────────────────────────────────────
router.patch('/settings', async (req, res) => {
  const { dataEncryption, cloudBackup, notifications } = req.body;
  const set = {};

  if (dataEncryption !== undefined) set['settings.dataEncryption'] = dataEncryption;
  if (cloudBackup    !== undefined) set['settings.cloudBackup']    = cloudBackup;
  if (notifications  !== undefined) set['settings.notifications']  = notifications;

  try {
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: set },
      { new: true }
    );
    res.json({ success: true, settings: user.settings });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to update settings' });
  }
});

// ────────────────────────────────────────────
// DELETE /api/profile/clear-data
// Deletes all health data but keeps the account
// ────────────────────────────────────────────
router.delete('/clear-data', async (req, res) => {
  try {
    await Promise.all([
      HealthInput.deleteMany({ userId: req.user._id }),
      Prediction.deleteMany({ userId: req.user._id }),
      User.findByIdAndUpdate(req.user._id, { totalChecks: 0 }),
    ]);

    res.json({
      success: true,
      message: 'All health data cleared successfully.',
    });
  } catch (err) {
    res
      .status(500)
      .json({ success: false, message: 'Failed to clear data' });
  }
});

module.exports = router;