import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { trackShipment } from '../lib/api';
import './Track.css';

const STATUS_COLORS = {
  PENDING: 'status-pending',
  PICKED_UP: 'status-picked',
  IN_TRANSIT: 'status-transit',
  DELIVERED: 'status-delivered',
  CANCELLED: 'status-cancelled',
};

export default function TrackShipment() {
  const [searchParams] = useSearchParams();
  const q = searchParams.get('q') || '';
  const [trackingNumber, setTrackingNumber] = useState(q);
  const [shipment, setShipment] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (q) {
      setTrackingNumber(q);
      setError('');
      setLoading(true);
      trackShipment(q)
        .then((data) => { setShipment(data); setError(''); })
        .catch((err) => { setShipment(null); setError(err.message); })
        .finally(() => setLoading(false));
    }
  }, [q]);

  const handleSearch = async (e) => {
    e?.preventDefault();
    if (!trackingNumber.trim()) return;
    setError('');
    setLoading(true);
    try {
      const data = await trackShipment(trackingNumber.trim());
      setShipment(data);
    } catch (err) {
      setShipment(null);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };


  return (
    <div className="track-page">
      <h1>Track shipment</h1>
      <form onSubmit={handleSearch} className="track-form">
        <input
          type="text"
          placeholder="Enter tracking number (e.g. LGS-xxx)"
          value={trackingNumber}
          onChange={(e) => setTrackingNumber(e.target.value)}
          className="track-input"
        />
        <button type="submit" disabled={loading}>
          {loading ? 'Searching...' : 'Track'}
        </button>
      </form>
      {error && <div className="track-error">{error}</div>}
      {shipment && (
        <div className="track-result">
          <div className="track-header">
            <code>{shipment.tracking_number}</code>
            <span className={`status-badge ${STATUS_COLORS[shipment.status] || ''}`}>
              {shipment.status.replace('_', ' ')}
            </span>
          </div>
          <div className="track-route">
            <div>
              <strong>From</strong>
              <p>{shipment.origin_address}</p>
            </div>
            <div>
              <strong>To</strong>
              <p>{shipment.destination_address}</p>
            </div>
          </div>
          {shipment.tracking_events?.length > 0 && (
            <div className="track-timeline">
              <h3>Tracking history</h3>
              {shipment.tracking_events.map((ev, i) => (
                <div key={i} className="track-event">
                  <span className="track-event-status">{ev.status.replace('_', ' ')}</span>
                  {ev.location && <span className="track-event-loc">{ev.location}</span>}
                  {ev.message && <p>{ev.message}</p>}
                  <span className="track-event-time">
                    {new Date(ev.created_at).toLocaleString()}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
