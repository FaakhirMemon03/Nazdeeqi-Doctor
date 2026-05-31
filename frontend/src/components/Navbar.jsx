import { Link, useLocation, useNavigate } from 'react-router-dom';

export default function Navbar() {
  const location = useLocation();
  const navigate = useNavigate();

  const isAdminPage = location.pathname.startsWith('/admin');
  const isClinicPage = location.pathname.startsWith('/clinic-dashboard');

  const adminToken = localStorage.getItem('adminToken');
  const clinicToken = localStorage.getItem('clinicToken');
  const userToken = localStorage.getItem('userToken');

  function logout() {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('clinicToken');
    localStorage.removeItem('clinicId');
    localStorage.removeItem('userToken');
    navigate('/');
  }

  // Admin dashboard navbar
  if (isAdminPage) {
    return (
      <nav className="app-nav">
        <Link to="/" className="app-nav-brand">Nazdeeqi Admin</Link>
        <div className="app-nav-links">
          <Link to="/">← Home</Link>
          <button
            onClick={logout}
            type="button"
            style={{ background: 'none', border: '1.5px solid #dc2626', color: '#dc2626', borderRadius: '6px', padding: '5px 14px', fontSize: '13px', fontWeight: 500, cursor: 'pointer' }}
          >
            Logout
          </button>
        </div>
      </nav>
    );
  }

  // Clinic dashboard navbar
  if (isClinicPage) {
    return (
      <nav className="app-nav">
        <Link to="/" className="app-nav-brand">Nazdeeqi Doctor</Link>
        <div className="app-nav-links">
          <Link to="/">← Home</Link>
          <button
            onClick={logout}
            type="button"
            style={{ background: 'none', border: '1.5px solid #dc2626', color: '#dc2626', borderRadius: '6px', padding: '5px 14px', fontSize: '13px', fontWeight: 500, cursor: 'pointer' }}
          >
            Logout
          </button>
        </div>
      </nav>
    );
  }

  // Logged in as regular user
  if (userToken) {
    return (
      <nav className="app-nav">
        <Link to="/" className="app-nav-brand">Nazdeeqi Doctor</Link>
        <div className="app-nav-links">
          <Link to="/user-dashboard" style={{ fontSize: 14, fontWeight: 500 }}>My Appointments</Link>
          <Link to="/edit-profile" style={{ fontSize: 14, fontWeight: 500 }}>Edit Profile</Link>
          <button
            onClick={logout}
            type="button"
            className="app-nav-cta"
            style={{ border: 'none', cursor: 'pointer', background: '#dc2626' }}
          >
            Logout
          </button>
        </div>
      </nav>
    );
  }

  // Not logged in
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
