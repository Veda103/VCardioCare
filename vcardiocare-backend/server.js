const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const authRoutes       = require('./routes/auth.routes');
const healthRoutes     = require('./routes/health.routes');
const predictionRoutes = require('./routes/prediction.routes');
const profileRoutes    = require('./routes/profile.routes');

const app = express();

// ── Middleware ──
app.use(cors());
app.use(express.json());

// ── Routes ──
app.use('/api/auth',        authRoutes);
app.use('/api/health',      healthRoutes);
app.use('/api/predictions', predictionRoutes);
app.use('/api/profile',     profileRoutes);

// ── Root health check ──
app.get('/', (req, res) => {
  res.json({ status: 'VCardioCare API is running ✅', version: '1.0.0' });
});

// ── 404 handler ──
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// ── Global error handler ──
app.use((err, req, res, next) => {
  console.error('Server Error:', err.message);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

// ── Connect to MongoDB Atlas then start server ──
const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB Atlas connected');
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('❌ MongoDB connection failed:', err.message);
    process.exit(1);
  });