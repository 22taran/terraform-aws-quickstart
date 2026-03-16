const request = require('supertest');
const app = require('../app');

jest.mock('../db/pool', () => ({
  query: jest.fn(),
}));

const pool = require('../db/pool');

describe('GET /api/shipments/track/:trackingNumber', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns 404 when shipment not found', async () => {
    pool.query
      .mockResolvedValueOnce({ rows: [] });

    const res = await request(app).get('/api/shipments/track/LGS-XXX123');
    expect(res.status).toBe(404);
    expect(res.body).toEqual({ error: 'Shipment not found' });
  });

  it('returns shipment with tracking events when found', async () => {
    const mockShipment = {
      id: 1,
      tracking_number: 'LGS-ABC123',
      status: 'IN_TRANSIT',
      origin_address: 'NYC',
      destination_address: 'LA',
      created_at: new Date(),
    };
    pool.query
      .mockResolvedValueOnce({ rows: [mockShipment] })
      .mockResolvedValueOnce({ rows: [{ status: 'PENDING', message: 'Created', location: null, created_at: new Date() }] });

    const res = await request(app).get('/api/shipments/track/LGS-ABC123');
    expect(res.status).toBe(200);
    expect(res.body.tracking_number).toBe('LGS-ABC123');
    expect(res.body.tracking_events).toBeDefined();
    expect(Array.isArray(res.body.tracking_events)).toBe(true);
  });

  it('normalizes tracking number to uppercase', async () => {
    pool.query.mockResolvedValueOnce({ rows: [] });
    await request(app).get('/api/shipments/track/lgs-xyz789');
    expect(pool.query).toHaveBeenCalledWith(
      expect.stringContaining('WHERE tracking_number = $1'),
      ['LGS-XYZ789']
    );
  });
});
