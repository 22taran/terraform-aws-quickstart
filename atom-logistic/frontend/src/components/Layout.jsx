import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import './Layout.css';
import { signOut } from '../lib/auth';

export default function Layout() {
  const navigate = useNavigate();

  const handleSignOut = () => {
    signOut();
    navigate('/login');
  };

  return (
    <div className="layout">
      <header className="header">
        <NavLink to="/" className="logo">Logistics</NavLink>
        <nav className="nav">
          <NavLink to="/" end>Dashboard</NavLink>
          <NavLink to="/shipments">Shipments</NavLink>
          <NavLink to="/shipments/new">New Shipment</NavLink>
          <NavLink to="/track">Track</NavLink>
          <button type="button" className="btn-outline" onClick={handleSignOut}>
            Sign out
          </button>
        </nav>
      </header>
      <main className="main">
        <Outlet />
      </main>
    </div>
  );
}
