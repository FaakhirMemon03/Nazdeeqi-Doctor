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

  const adminToken = localStorage.getItem('adminToken');
  const clinicToken = localStorage.getItem('clinicToken');
  const userToken = localStorage.getItem('userToken');

  let dashboardLink = '/login';
  let dashboardText = 'Login';

  if (adminToken) {
    dashboardLink = '/admin';
    dashboardText = 'Admin Dashboard';
  } else if (clinicToken) {
    dashboardLink = '/clinic-dashboard';
    dashboardText = 'Clinic Dashboard';
  } else if (userToken) {
    dashboardLink = '/user-dashboard';
    dashboardText = 'My Appointments';
  }

  return (
    <nav className="app-nav">
      <Link to="/" className="app-nav-brand">Nazdeeqi Doctor</Link>
      <div className="app-nav-links">
        <Link to={dashboardLink} style={{ fontSize: 14, fontWeight: 500 }}>{dashboardText}</Link>
        <Link to="/register-clinic" className="app-nav-cta">Clinic Register Karein</Link>
      </div>
    </nav>
  );
}
