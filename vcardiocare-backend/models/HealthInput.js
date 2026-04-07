const mongoose = require('mongoose');

const healthInputSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // ── Vitals ──
    systolicBP:  { type: Number, required: true, min: 70,  max: 200 },
    diastolicBP: { type: Number, required: true, min: 40,  max: 130 },
    bmi:         { type: Number, required: true, min: 10,  max: 60  },
    age:         { type: Number, required: true, min: 1,   max: 120 },
    heartRate:   { type: Number, default: null },

    // ── Blood Work ──
    totalCholesterol: { type: Number, required: true },
    fastingGlucose:   { type: Number, required: true },
    hdlCholesterol:   { type: Number, default: null },
    ldlCholesterol:   { type: Number, default: null },
    triglycerides:    { type: Number, default: null },

    // ── Lifestyle ──
    smokingStatus: {
      type: String,
      enum: ['non-smoker', 'former', 'smoker'],
      required: true,
    },
    sleepHours:       { type: Number, min: 0, max: 24,  default: null },
    stressLevel:      { type: Number, min: 0, max: 10,  default: null },
    physicalActivity: {
      type: String,
      enum: ['sedentary', 'light', 'moderate', 'active'],
      default: 'moderate',
    },

    // ── Medical History ──
    hasDiabetes:      { type: Boolean, default: false },
    hasFamilyHistory: { type: Boolean, default: false },
    hasHypertension:  { type: Boolean, default: false },

    recordedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

module.exports = mongoose.model('HealthInput', healthInputSchema);