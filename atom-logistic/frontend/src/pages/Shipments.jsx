import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../lib/api';
import './Shipments.css';

const STATUS_COLORS = {
  PENDING: 'status-pending',
  PICKED_UP: 'status-picked',
  IN_TRANSIT: 'status-transit',
  DELIVERED: 'status-delivered',
  CANCELLED: 'status-cancelled',
};

export default function Shipments() {
  const [shipments, setShipments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    api.get('/api/shipments')
      .then((data) => setShipments(Array.isArray(data) ? data : []))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  const updateStatus = async (id, status) => {
    try {
      const updated = await api.patch(`/api/shipments/${id}/status`, { status });
      setShipments((prev) => prev.map((s) => (s.id === id ? updated : s)));
    } catch (err) {
      alert(err.message);
    }
  };

  if (loading) return <div className="loading">Loading...</div>;
  if (error) return <div className="page-error">{error}</div>;

  return (
    <div className="shipments-page">
      <div className="section-header">
        <h1>My shipments</h1>
        <Link to="/shipments/new" className="btn-primary">New shipment</Link>
      </div>
      {shipments.length === 0 ? (
        <p className="empty-state">No shipments yet. <Link to="/shipments/new">Create one</Link>.</p>
      ) : (
        <div className="shipments-table-wrap">
          <table className="shipments-table">
            <thead>
              <tr>
                <th>Tracking #</th>
                <th>Origin</th>
                <th>Destination</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {shipments.map((s) => (
                <tr key={s.id}>
                  <td>
                    <Link to={`/track?q=${s.tracking_number}`} className="tracking-link">{s.tracking_number}</Link>
                  </td>
                  <td>{s.origin_address?.slice(0, 40)}{s.origin_address?.length > 40 ? '…' : ''}</td>
                  <td>{s.destination_address?.slice(0, 40)}{s.destination_address?.length > 40 ? '…' : ''}</td>
                  <td><span className={`status-badge ${STATUS_COLORS[s.status] || ''}`}>{s.status.replace('_', ' ')}</span></td>
                  <td>
                    {s.status === 'PENDING' && (
                      <button className="btn-sm" onClick={() => updateStatus(s.id, 'PICKED_UP')}>Pick up</button>
                    )}
                    {s.status === 'PICKED_UP' && (
                      <button className="btn-sm" onClick={() => updateStatus(s.id, 'IN_TRANSIT')}>In transit</button>
                    )}
                    {s.status === 'IN_TRANSIT' && (
                      <button className="btn-sm" onClick={() => updateStatus(s.id, 'DELIVERED')}>Deliver</button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
