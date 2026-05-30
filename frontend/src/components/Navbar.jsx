import { Link, useLocation } from 'react-router-dom';

export default function Navbar() {
  const location = useLocation();
  const isAdmin = location.pathname.startsWith('/admin');

  if (isAdmin) {
    return (
      <nav className="app-nav">
        <Link to="/" className="app-nav-brand">Nazdeeqi Admin</Link>
        <div className="app-nav-links">
          <Link to="/">← Home</Link>
        </div>
      </nav>
    );
  }

  return (
    <nav className="app-nav">
      <Link to="/" className="app-nav-brand">Nazdeeqi Doctor</Link>
      <div className="app-nav-links">
        <Link to="/login" style={{ fontSize: 14, fontWeight: 500 }}>Login</Link>
        <Link to="/register-clinic" className="app-nav-cta">Clinic Register Karein</Link>
      </div>
    </nav>
  );
}
