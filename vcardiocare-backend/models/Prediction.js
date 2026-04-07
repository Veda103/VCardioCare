const mongoose = require('mongoose');

const shapFactorSchema = new mongoose.Schema(
  {
    feature:       String,
    displayName:   String,
    icon:          String,
    shapValue:     Number,
    impactPercent: Number,
    isModifiable:  Boolean,
  },
  { _id: false }
);

const predictionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    healthInputId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'HealthInput',
      required: true,
    },

    // ── ML Output ──
    riskPercent: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    riskLabel: {
      type: String,
      enum: ['low', 'moderate', 'elevated'],
      required: true,
    },
    confidenceScore: { type: Number, min: 0, max: 100 },

    // ── SHAP Explanations ──
    shapFactors: [shapFactorSchema],

    // ── Gentle wellness message ──
    wellnessMessage: { type: String, default: '' },

    // ── Snapshot of key vitals at prediction time ──
    vitalSnapshot: {
      systolicBP:  Number,
      diastolicBP: Number,
      bmi:         Number,
      cholesterol: Number,
    },

    predictedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Prediction', predictionSchema);