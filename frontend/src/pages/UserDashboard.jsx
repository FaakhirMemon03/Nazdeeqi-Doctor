import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getUserAppointments } from '../api';

export default function UserDashboard() {
  const navigate = useNavigate();
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('userToken');
    if (!token) {
      navigate('/login');
      return;
    }
    loadAppointments();
  }, []);

  async function loadAppointments() {
    try {
      const res = await getUserAppointments();
      setAppointments(res.data.appointments);
    } catch {
      navigate('/login');
    } finally {
      setLoading(false);
    }
  }

  function logout() {
    localStorage.removeItem('userToken');
    navigate('/login');
  }

  return (
    <div className="admin-layout">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <h1 style={{ fontFamily: "'Playfair Display', serif", color: '#04342C', margin: 0 }}>
          Patient Dashboard
        </h1>
        <button className="btn-sm btn-outline" onClick={logout} type="button">
          Logout
        </button>
      </div>

      <div className="alert alert-info" style={{ marginBottom: '1.5rem' }}>
        Yahan aapki saari book ki gayi appointments ki details hain.
      </div>

      {loading ? (
        <div className="loading">Loading...</div>
      ) : appointments.length === 0 ? (
        <div className="alert alert-info">Aapki koi appointment nahi hai.</div>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="admin-table">
            <thead>
              <tr>
                <th>Clinic</th>
                <th>Doctor</th>
                <th>Time Slot</th>
                <th>Status</th>
                <th>Patient Details</th>
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
                    <span className={`status-badge status-${a.status === 'confirmed' ? 'approved' : 'pending'}`}>
                      {a.status}
                    </span>
                  </td>
                  <td>
                    {a.patientName}
                    <br />
                    <small>{a.patientPhone}</small>
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
