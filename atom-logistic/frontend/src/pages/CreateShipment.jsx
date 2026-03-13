import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../lib/api';
import './Form.css';

export default function CreateShipment() {
  const [origin, setOrigin] = useState('');
  const [destination, setDestination] = useState('');
  const [weight, setWeight] = useState('');
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await api.post('/api/shipments', {
        origin_address: origin,
        destination_address: destination,
        weight_kg: weight ? parseFloat(weight) : null,
        notes: notes || null,
      });
      navigate('/shipments');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="form-page">
      <h1>Create shipment</h1>
      <form onSubmit={handleSubmit} className="form">
        {error && <div className="form-error">{error}</div>}
        <label>
          Origin address *
          <input
            type="text"
            value={origin}
            onChange={(e) => setOrigin(e.target.value)}
            placeholder="123 Main St, City, Country"
            required
          />
        </label>
        <label>
          Destination address *
          <input
            type="text"
            value={destination}
            onChange={(e) => setDestination(e.target.value)}
            placeholder="456 Oak Ave, City, Country"
            required
          />
        </label>
        <label>
          Weight (kg)
          <input
            type="number"
            step="0.01"
            min="0"
            value={weight}
            onChange={(e) => setWeight(e.target.value)}
            placeholder="Optional"
          />
        </label>
        <label>
          Notes
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Optional notes"
            rows={3}
          />
        </label>
        <button type="submit" disabled={loading}>
          {loading ? 'Creating...' : 'Create shipment'}
        </button>
      </form>
    </div>
  );
}
