const express = require('express');
const pool = require('../db/pool');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Public: track by tracking number (no auth)
router.get('/track/:trackingNumber', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT id, tracking_number, status, origin_address, destination_address, created_at FROM shipments WHERE tracking_number = $1',
      [req.params.trackingNumber.toUpperCase()]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }
    const shipment = rows[0];
    const events = await pool.query(
      'SELECT status, location, message, created_at FROM tracking_events WHERE shipment_id = $1 ORDER BY created_at ASC',
      [shipment.id]
    );
    shipment.tracking_events = events.rows;
    res.json(shipment);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to track shipment' });
  }
});

// All routes below require auth
router.use(authMiddleware);

function generateTrackingNumber() {
  return 'LGS-' + Date.now().toString(36).toUpperCase() + '-' + Math.random().toString(36).slice(2, 8).toUpperCase();
}

// List my shipments
router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM shipments WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.sub]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch shipments' });
  }
});

// Get single shipment with tracking events
router.get('/:id', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM shipments WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.sub]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }
    const shipment = rows[0];
    const events = await pool.query(
      'SELECT * FROM tracking_events WHERE shipment_id = $1 ORDER BY created_at ASC',
      [shipment.id]
    );
    shipment.tracking_events = events.rows;
    res.json(shipment);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch shipment' });
  }
});

// Create shipment
router.post('/', async (req, res) => {
  const { origin_address, destination_address, weight_kg, notes } = req.body;
  if (!origin_address || !destination_address) {
    return res.status(400).json({
      error: 'Missing required fields',
      required: ['origin_address', 'destination_address'],
    });
  }

  const trackingNumber = generateTrackingNumber();
  try {
    const { rows } = await pool.query(
      `INSERT INTO shipments (user_id, tracking_number, origin_address, destination_address, weight_kg, notes, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'PENDING')
       RETURNING *`,
      [req.user.sub, trackingNumber, origin_address, destination_address, weight_kg || null, notes || null]
    );
    const shipment = rows[0];
    await pool.query(
      'INSERT INTO tracking_events (shipment_id, status, message) VALUES ($1, $2, $3)',
      [shipment.id, 'PENDING', 'Shipment created']
    );
    res.status(201).json(shipment);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create shipment' });
  }
});

// Update shipment status
router.patch('/:id/status', async (req, res) => {
  const { status, location, message } = req.body;
  if (!status) {
    return res.status(400).json({ error: 'status is required' });
  }

  const validStatuses = ['PENDING', 'PICKED_UP', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: 'Invalid status', valid: validStatuses });
  }

  try {
    const { rows } = await pool.query(
      'SELECT id FROM shipments WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.sub]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }

    await pool.query(
      'UPDATE shipments SET status = $1, updated_at = NOW() WHERE id = $2',
      [status, req.params.id]
    );
    await pool.query(
      'INSERT INTO tracking_events (shipment_id, status, location, message) VALUES ($1, $2, $3, $4)',
      [req.params.id, status, location || null, message || null]
    );

    const { rows: updated } = await pool.query(
      'SELECT * FROM shipments WHERE id = $1',
      [req.params.id]
    );
    res.json(updated[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update status' });
  }
});

// Delete shipment
router.delete('/:id', async (req, res) => {
  try {
    const { rowCount } = await pool.query(
      'DELETE FROM shipments WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.sub]
    );
    if (rowCount === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete shipment' });
  }
});

module.exports = router;
