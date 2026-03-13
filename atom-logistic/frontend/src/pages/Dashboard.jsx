import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../lib/api';
import './Dashboard.css';

const STATUS_COLORS = {
  PENDING: 'status-pending',
  PICKED_UP: 'status-picked',
  IN_TRANSIT: 'status-transit',
  DELIVERED: 'status-delivered',
  CANCELLED: 'status-cancelled',
};

export default function Dashboard() {
  const [shipments, setShipments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    api.get('/api/shipments')
      .then((data) => setShipments(Array.isArray(data) ? data : []))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="loading">Loading...</div>;
  if (error) return <div className="page-error">{error}</div>;

  const recent = shipments.slice(0, 5);
  const pending = shipments.filter((s) => s.status === 'PENDING').length;
  const inTransit = shipments.filter((s) => s.status === 'IN_TRANSIT').length;

  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      <div className="stats">
        <div className="stat-card">
          <span className="stat-value">{shipments.length}</span>
          <span className="stat-label">Total shipments</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">{pending}</span>
          <span className="stat-label">Pending</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">{inTransit}</span>
          <span className="stat-label">In transit</span>
        </div>
      </div>
      <section>
        <div className="section-header">
          <h2>Recent shipments</h2>
          <Link to="/shipments/new" className="btn-primary">New shipment</Link>
        </div>
        {recent.length === 0 ? (
          <p className="empty-state">No shipments yet. <Link to="/shipments/new">Create your first</Link>.</p>
        ) : (
          <div className="shipment-list">
            {recent.map((s) => (
              <Link key={s.id} to={`/shipments`} className="shipment-card">
                <div className="shipment-header">
                  <code>{s.tracking_number}</code>
                  <span className={`status-badge ${STATUS_COLORS[s.status] || ''}`}>{s.status.replace('_', ' ')}</span>
                </div>
                <p className="shipment-route">{s.origin_address} → {s.destination_address}</p>
              </Link>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
