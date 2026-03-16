const express = require('express');
const cors = require('cors');
const shipmentsRouter = require('./routes/shipments');

const app = express();

app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
}));
app.use(express.json());

// Health checks
app.get('/', (req, res) => {
  res.json({ status: 'healthy', service: 'logistics-api', timestamp: new Date().toISOString() });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// API routes
app.use('/api/shipments', shipmentsRouter);

module.exports = app;
