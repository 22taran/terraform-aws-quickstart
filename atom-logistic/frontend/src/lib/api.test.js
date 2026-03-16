import { describe, it, expect, vi, beforeEach } from 'vitest';
import { trackShipment } from './api';

describe('trackShipment', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn());
  });

  it('calls API with tracking number', async () => {
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ tracking_number: 'LGS-ABC', status: 'PENDING' }),
    });

    const result = await trackShipment('LGS-ABC');
    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining('/api/shipments/track/LGS-ABC'),
      expect.any(Object)
    );
    expect(result.tracking_number).toBe('LGS-ABC');
  });

  it('throws on API error', async () => {
    fetch.mockResolvedValueOnce({
      ok: false,
      json: async () => ({ error: 'Shipment not found' }),
    });

    await expect(trackShipment('INVALID')).rejects.toThrow();
  });
});
