import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getClinicAppointments } from '../api';

export default function ClinicDashboard() {
  const navigate = useNavigate();
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);

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

  return (
    <div className="admin-layout">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <h1 style={{ fontFamily: "'Playfair Display', serif", color: '#04342C', margin: 0 }}>
          Clinic Dashboard
        </h1>
        <button className="btn-sm btn-outline" onClick={logout} type="button">
          Logout
        </button>
      </div>

      <div className="alert alert-info" style={{ marginBottom: '1.5rem' }}>
        <i className="ti ti-bell-ringing" /> Yahan aapki clinic par aane wale appointments ki notification/details show hongi.
      </div>

      {loading ? (
        <div className="loading">Loading...</div>
      ) : appointments.length === 0 ? (
        <div className="alert alert-info">Koi appointment nahi mili</div>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="admin-table">
            <thead>
              <tr>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Time Slot</th>
                <th>Status</th>
                <th>Complaint</th>
              </tr>
            </thead>
            <tbody>
              {appointments.map((a) => (
                <tr key={a._id}>
                  <td>
                    <strong>{a.patientName}</strong>
                    <br />
                    <small>{a.patientPhone}</small>
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
                    <span className={`status-badge status-${a.status === 'confirmed' ? 'approved' : 'pending'}`}>
                      {a.status}
                    </span>
                  </td>
                  <td>
                    <small>{a.complaint || '-'}</small>
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
