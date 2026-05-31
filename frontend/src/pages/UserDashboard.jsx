import { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { getUserAppointments, cancelAppointment } from '../api';

export default function UserDashboard() {
  const navigate = useNavigate();
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('userToken');
    if (!token) {
      navigate('/login');
      return;
    }
    loadAppointments();
  }, []);

  async function loadAppointments() {
    setLoading(true);
    try {
      const res = await getUserAppointments();
      setAppointments(res.data.appointments);
    } catch {
      navigate('/login');
    } finally {
      setLoading(false);
    }
  }

  async function handleCancel(id) {
    if (!confirm('Kya aap ye appointment cancel karna chahte hain?')) return;
    try {
      const res = await cancelAppointment(id);
      setMessage(res.data.message);
      loadAppointments();
    } catch (err) {
      alert(err.response?.data?.message || 'Cancel nahi ho saka');
    }
  }

  function logout() {
    localStorage.removeItem('userToken');
    navigate('/');
  }

  return (
    <div className="admin-layout">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '8px' }}>
        <h1 style={{ fontFamily: "'Playfair Display', serif", color: '#04342C', margin: 0 }}>
          My Appointments
        </h1>
        <div style={{ display: 'flex', gap: '8px' }}>
          <Link
            to="/edit-profile"
            style={{ textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: '4px', padding: '6px 14px', fontSize: '13px', fontWeight: 500, borderRadius: '6px', border: '1.5px solid #0F6E56', color: '#0F6E56', background: 'white' }}
          >
            ✏️ Edit Profile
          </Link>
          <button className="btn-sm btn-outline" onClick={logout} type="button">
            Logout
          </button>
        </div>
      </div>

      {message && <div className="alert alert-success" style={{ marginBottom: '1rem' }}>{message}</div>}

      {loading ? (
        <div className="loading">Loading...</div>
      ) : appointments.length === 0 ? (
        <div className="alert alert-info">
          Aapki koi appointment nahi hai. <Link to="/" style={{ color: '#0F6E56', fontWeight: 600 }}>Clinic dhundein →</Link>
        </div>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="admin-table">
            <thead>
              <tr>
                <th>Clinic</th>
                <th>Doctor</th>
                <th>Time Slot</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {appointments.map((a) => (
                <tr key={a._id}>
                  <td>
                    <strong>{a.clinic?.name || 'Unknown'}</strong>
                    <br />
                    <small>{a.clinic?.address}, {a.clinic?.city}</small>
                  </td>
                  <td>
                    {a.doctor?.name || 'Unknown'}
                    <br />
                    <small>{a.doctor?.specialty} (Rs. {a.doctor?.fee})</small>
                  </td>
                  <td>
                    <span style={{ fontWeight: 500, color: '#0F6E56' }}>{a.timeSlot}</span>
                    <br />
                    <small>{new Date(a.appointmentDate).toLocaleDateString()}</small>
                  </td>
                  <td>
                    <span className={`status-badge status-${a.status === 'confirmed' ? 'approved' : a.status === 'cancelled' ? 'rejected' : 'pending'}`}>
                      {a.status}
                    </span>
                  </td>
                  <td>
                    {a.status === 'confirmed' && (
                      <button
                        className="btn-sm btn-reject"
                        onClick={() => handleCancel(a._id)}
                        type="button"
                      >
                        Cancel
                      </button>
                    )}
                    {a.status !== 'confirmed' && <small style={{ color: '#bbb' }}>—</small>}
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
