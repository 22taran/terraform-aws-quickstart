import { Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { getCurrentUser } from './lib/auth';
import Layout from './components/Layout';
import Login from './pages/Login';
import Signup from './pages/Signup';
import ConfirmSignup from './pages/ConfirmSignup';
import Dashboard from './pages/Dashboard';
import Shipments from './pages/Shipments';
import CreateShipment from './pages/CreateShipment';
import TrackShipment from './pages/TrackShipment';

function ProtectedRoute({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setUser(getCurrentUser());
    setLoading(false);
  }, []);

  if (loading) return <div className="loading">Loading...</div>;
  if (!user) return <Navigate to="/login" replace />;
  return children;
}

function PublicOnlyRoute({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setUser(getCurrentUser());
    setLoading(false);
  }, []);

  if (loading) return <div className="loading">Loading...</div>;
  if (user) return <Navigate to="/" replace />;
  return children;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={
        <PublicOnlyRoute>
          <Login />
        </PublicOnlyRoute>
      } />
      <Route path="/signup" element={
        <PublicOnlyRoute>
          <Signup />
        </PublicOnlyRoute>
      } />
      <Route path="/confirm" element={
        <PublicOnlyRoute>
          <ConfirmSignup />
        </PublicOnlyRoute>
      } />
      <Route element={<Layout />}>
        <Route path="/" element={
          <ProtectedRoute>
            <Dashboard />
          </ProtectedRoute>
        } />
        <Route path="/shipments" element={
          <ProtectedRoute>
            <Shipments />
          </ProtectedRoute>
        } />
        <Route path="/shipments/new" element={
          <ProtectedRoute>
            <CreateShipment />
          </ProtectedRoute>
        } />
        <Route path="/track" element={<TrackShipment />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
