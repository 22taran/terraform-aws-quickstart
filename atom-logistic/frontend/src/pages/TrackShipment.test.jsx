import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import TrackShipment from './TrackShipment';
import * as api from '../lib/api';

vi.mock('../lib/api');

describe('TrackShipment', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders track form', () => {
    render(
      <MemoryRouter>
        <TrackShipment />
      </MemoryRouter>
    );
    expect(screen.getByRole('heading', { name: /track shipment/i })).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/tracking number/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /track/i })).toBeInTheDocument();
  });

  it('displays shipment when track succeeds', async () => {
    api.trackShipment.mockResolvedValueOnce({
      tracking_number: 'LGS-ABC123',
      status: 'IN_TRANSIT',
      origin_address: 'NYC',
      destination_address: 'LA',
      tracking_events: [],
    });

    render(
      <MemoryRouter>
        <TrackShipment />
      </MemoryRouter>
    );

    fireEvent.change(screen.getByPlaceholderText(/tracking number/i), {
      target: { value: 'LGS-ABC123' },
    });
    fireEvent.click(screen.getByRole('button', { name: /track/i }));

    await waitFor(() => {
      expect(screen.getByText('LGS-ABC123')).toBeInTheDocument();
      expect(screen.getByText('NYC')).toBeInTheDocument();
      expect(screen.getByText('LA')).toBeInTheDocument();
    });
  });

  it('displays error when track fails', async () => {
    api.trackShipment.mockRejectedValueOnce(new Error('Shipment not found'));

    render(
      <MemoryRouter>
        <TrackShipment />
      </MemoryRouter>
    );

    fireEvent.change(screen.getByPlaceholderText(/tracking number/i), {
      target: { value: 'INVALID' },
    });
    fireEvent.click(screen.getByRole('button', { name: /track/i }));

    await waitFor(() => {
      expect(screen.getByText('Shipment not found')).toBeInTheDocument();
    });
  });
});
