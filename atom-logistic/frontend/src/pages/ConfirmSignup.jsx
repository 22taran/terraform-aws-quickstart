import { useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { confirmSignUp } from '../lib/auth';
import './Auth.css';

export default function ConfirmSignup() {
  const [searchParams] = useSearchParams();
  const email = searchParams.get('email') || '';
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await confirmSignUp(email, code);
      setSuccess(true);
    } catch (err) {
      setError(err.message || 'Verification failed');
    } finally {
      setLoading(false);
    }
  };

  if (!email) {
    return (
      <div className="auth-page">
        <div className="auth-card">
          <h1>Confirm sign up</h1>
          <p className="auth-subtitle">Missing email. Please use the link from your signup email.</p>
          <Link to="/signup">Back to sign up</Link>
        </div>
      </div>
    );
  }

  if (success) {
    return (
      <div className="auth-page">
        <div className="auth-card">
          <h1>Confirmed</h1>
          <p className="auth-success">Your email is verified. You can now sign in.</p>
          <Link to="/login" className="auth-link">Sign in</Link>
        </div>
      </div>
    );
  }

  return (
    <div className="auth-page">
      <div className="auth-card">
        <h1>Confirm sign up</h1>
        <p className="auth-subtitle">Enter the verification code sent to {email}</p>
        <form onSubmit={handleSubmit}>
          {error && <div className="auth-error">{error}</div>}
          <input
            type="text"
            placeholder="Verification code"
            value={code}
            onChange={(e) => setCode(e.target.value)}
            required
            autoComplete="one-time-code"
          />
          <button type="submit" disabled={loading}>
            {loading ? 'Verifying...' : 'Verify'}
          </button>
        </form>
        <p className="auth-footer">
          <Link to="/login">Back to sign in</Link>
        </p>
      </div>
    </div>
  );
}
