const app = require('./app');
const pool = require('./db/pool');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;

async function initDb() {
  try {
    const schema = fs.readFileSync(path.join(__dirname, 'db', 'schema.sql'), 'utf8');
    await pool.query(schema);
    console.log('Database schema initialized');
  } catch (err) {
    console.error('DB init warning:', err.message);
  }
}

app.listen(PORT, '0.0.0.0', async () => {
  await initDb();
  console.log(`Logistics API running on port ${PORT}`);
});
