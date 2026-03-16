const request = require('supertest');
const app = require('../app');

describe('Health routes', () => {
  it('GET / returns healthy status', async () => {
    const res = await request(app).get('/');
    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({ status: 'healthy', service: 'logistics-api' });
    expect(res.body.timestamp).toBeDefined();
  });

  it('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });
});
