const express = require('express');
const cors = require('cors');
const pool = require('./db/pool');
const shipmentsRouter = require('./routes/shipments');

const app = express();
const PORT = process.env.PORT || 3000;

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

// Init DB (creates tables if not exist)
async function initDb() {
  const fs = require('fs');
  const path = require('path');
  try {
    const schema = fs.readFileSync(path.join(__dirname, 'db', 'schema.sql'), 'utf8');
    await pool.query(schema);
    console.log('Database schema initialized');
  } catch (err) {
    console.error('DB init warning:', err.message);
  }
}

// API routes
app.use('/api/shipments', shipmentsRouter);

app.listen(PORT, '0.0.0.0', async () => {
  await initDb();
  console.log(`Logistics API running on port ${PORT}`);
});
