import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getClinicAppointments } from '../api';

export default function ClinicDashboard() {
  const navigate = useNavigate();
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('clinicToken');
    const clinicId = localStorage.getItem('clinicId');
    if (!token || !clinicId) {
      navigate('/login');
      return;
    }
    loadAppointments(clinicId);
  }, []);

  async function loadAppointments(clinicId) {
    setLoading(true);
    try {
      const res = await getClinicAppointments(clinicId);
      setAppointments(res.data.appointments);
    } catch {
      navigate('/login');
    } finally {
      setLoading(false);
    }
  }

  function logout() {
    localStorage.removeItem('clinicToken');
    localStorage.removeItem('clinicId');
    navigate('/login');
  }

  const filtered = appointments.filter((a) => {
    const q = search.toLowerCase();
    return (
      a.bookingCode?.toLowerCase().includes(q) ||
      a.patientName?.toLowerCase().includes(q) ||
      a.patientPhone?.includes(q)
    );
  });

  return (
    <div className="admin-layout">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '8px' }}>
        <h1 style={{ fontFamily: "'Playfair Display', serif", color: '#04342C', margin: 0 }}>
          Clinic Dashboard
        </h1>
        <button className="btn-sm btn-outline" onClick={logout} type="button">
          Logout
        </button>
      </div>

      {/* Search by booking ID */}
      <div style={{ marginBottom: '1.2rem' }}>
        <input
          type="text"
          placeholder="🔍 Booking ID ya patient naam se verify karein..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{ width: '100%', padding: '10px 14px', borderRadius: '8px', border: '1.5px solid #e2e8f0', fontSize: '14px', outline: 'none', boxSizing: 'border-box' }}
        />
      </div>

      {loading ? (
        <div className="loading">Loading...</div>
      ) : filtered.length === 0 ? (
        <div className="alert alert-info">{search ? 'Koi result nahi mila' : 'Koi appointment nahi mili'}</div>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="admin-table">
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Time Slot</th>
                <th>Takleef</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((a) => (
                <tr key={a._id}>
                  <td>
                    <span style={{
                      fontFamily: 'monospace',
                      fontWeight: 700,
                      fontSize: '15px',
                      color: '#0F6E56',
                      background: '#E1F5EE',
                      padding: '3px 10px',
                      borderRadius: '6px',
                      letterSpacing: '1px'
                    }}>
                      {a.bookingCode || 'N/A'}
                    </span>
                  </td>
                  <td>
                    <strong>{a.patientName}</strong>
                    <br />
                    <small>{a.patientPhone}</small>
                    {a.user?.email && <><br /><small style={{ color: '#888' }}>{a.user.email}</small></>}
                  </td>
                  <td>
                    {a.doctor?.name || 'Unknown'}
                    <br />
                    <small>{a.doctor?.specialty || ''}</small>
                  </td>
                  <td>
                    <span style={{ fontWeight: 500, color: '#0F6E56' }}>{a.timeSlot}</span>
                    <br />
                    <small>{new Date(a.appointmentDate).toLocaleDateString()}</small>
                  </td>
                  <td>
                    <small>{a.complaint || '-'}</small>
                  </td>
                  <td>
                    <span className={`status-badge status-${a.status === 'confirmed' ? 'approved' : a.status === 'cancelled' ? 'rejected' : 'pending'}`}>
                      {a.status}
                    </span>
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
