import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getClinicAppointments, getClinicDoctors, addDoctor, deleteDoctor } from '../api';

const SPECIALTIES = [
  'General Physician', 'Cardiologist', 'Gynecologist', 'Dermatologist', 
  'Pediatrician', 'Neurologist', 'Orthopedic Surgeon', 'Psychiatrist',
  'Dentist', 'ENT Specialist'
];

export default function ClinicDashboard() {
  const navigate = useNavigate();
  const [tab, setTab] = useState('appointments'); // appointments | doctors
  const [appointments, setAppointments] = useState([]);
  const [doctors, setDoctors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [message, setMessage] = useState('');

  // Doctor Form
  const [docForm, setDocForm] = useState({ name: '', specialty: SPECIALTIES[0], fee: '' });

  useEffect(() => {
    const token = localStorage.getItem('clinicToken');
    const clinicId = localStorage.getItem('clinicId');
    if (!token || !clinicId) {
      navigate('/login');
      return;
    }
    loadData(clinicId);
  }, [tab]);

  async function loadData(clinicId) {
    setLoading(true);
    try {
      if (tab === 'appointments') {
        const res = await getClinicAppointments(clinicId);
        setAppointments(res.data.appointments);
      } else {
        const res = await getClinicDoctors();
        setDoctors(res.data.doctors);
      }
    } catch {
      navigate('/login');
    } finally {
      setLoading(false);
    }
  }

  async function handleAddDoctor(e) {
    e.preventDefault();
    try {
      await addDoctor({ ...docForm, name: `Dr. ${docForm.name.replace(/^Dr\.\s*/i, '')}` });
      setMessage('Doctor add ho gaya!');
      setDocForm({ name: '', specialty: SPECIALTIES[0], fee: '' });
      loadData(localStorage.getItem('clinicId'));
    } catch (err) {
      alert(err.response?.data?.message || 'Error adding doctor');
    }
  }

  async function handleDeleteDoctor(id) {
    if (!confirm('Kya aap is doctor ko remove karna chahte hain?')) return;
    try {
      await deleteDoctor(id);
      setMessage('Doctor remove ho gaya.');
      loadData(localStorage.getItem('clinicId'));
    } catch (err) {
      alert(err.response?.data?.message || 'Error deleting doctor');
    }
  }

  function logout() {
    localStorage.removeItem('clinicToken');
    localStorage.removeItem('clinicId');
    navigate('/login');
  }

  const filteredAppointments = appointments.filter((a) => {
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

      <div style={{ display: 'flex', gap: '8px', marginBottom: '1.5rem' }}>
        <button
          className={`btn-sm ${tab === 'appointments' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('appointments')}
          type="button"
        >
          Appointments
        </button>
        <button
          className={`btn-sm ${tab === 'doctors' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('doctors')}
          type="button"
        >
          Manage Doctors
        </button>
      </div>

      {message && <div className="alert alert-success" style={{ marginBottom: '1rem' }}>{message}</div>}

      {tab === 'appointments' ? (
        <>
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
          ) : filteredAppointments.length === 0 ? (
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
                  {filteredAppointments.map((a) => (
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
        </>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '2rem' }}>
          {/* Add Doctor Form */}
          <div style={{ background: '#f8fafc', padding: '1.5rem', borderRadius: '12px', border: '1px solid #e2e8f0' }}>
            <h3 style={{ marginTop: 0, marginBottom: '1rem', color: '#04342C' }}>Naya Doctor Add Karein</h3>
            <form onSubmit={handleAddDoctor}>
              <div style={{ marginBottom: '1rem' }}>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, marginBottom: '4px' }}>Naam</label>
                <div style={{ display: 'flex', alignItems: 'center' }}>
                  <span style={{ padding: '8px 12px', background: '#e2e8f0', borderRadius: '6px 0 0 6px', border: '1px solid #cbd5e1', borderRight: 'none', color: '#64748b' }}>Dr.</span>
                  <input
                    required
                    value={docForm.name}
                    onChange={(e) => setDocForm({ ...docForm, name: e.target.value })}
                    style={{ flex: 1, padding: '8px 12px', border: '1px solid #cbd5e1', borderRadius: '0 6px 6px 0', outline: 'none' }}
                    placeholder="Ali Khan"
                  />
                </div>
              </div>
              <div style={{ marginBottom: '1rem' }}>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, marginBottom: '4px' }}>Specialty</label>
                <select
                  value={docForm.specialty}
                  onChange={(e) => setDocForm({ ...docForm, specialty: e.target.value })}
                  style={{ width: '100%', padding: '8px 12px', border: '1px solid #cbd5e1', borderRadius: '6px', outline: 'none', background: 'white' }}
                >
                  {SPECIALTIES.map((s) => <option key={s} value={s}>{s}</option>)}
                </select>
              </div>
              <div style={{ marginBottom: '1rem' }}>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, marginBottom: '4px' }}>Fees (Rs.)</label>
                <input
                  required
                  type="number"
                  min="0"
                  value={docForm.fee}
                  onChange={(e) => setDocForm({ ...docForm, fee: e.target.value })}
                  style={{ width: '100%', padding: '8px 12px', border: '1px solid #cbd5e1', borderRadius: '6px', outline: 'none', boxSizing: 'border-box' }}
                  placeholder="e.g. 1500"
                />
              </div>
              <button type="submit" className="btn-sm btn-approve" style={{ width: '100%' }}>Add Doctor</button>
            </form>
          </div>

          {/* Doctors List */}
          <div>
            <h3 style={{ marginTop: 0, marginBottom: '1rem', color: '#04342C' }}>Aapke Doctors</h3>
            {loading ? (
              <div className="loading">Loading...</div>
            ) : doctors.length === 0 ? (
              <div className="alert alert-info">Aapne abhi koi doctor add nahi kiya.</div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                {doctors.map((d) => (
                  <div key={d._id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'white', padding: '1rem', borderRadius: '8px', border: '1px solid #e2e8f0', boxShadow: '0 2px 4px rgba(0,0,0,0.02)' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ width: 40, height: 40, borderRadius: '50%', background: d.avatarColor, color: d.textColor, display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>
                        {d.initials}
                      </div>
                      <div>
                        <div style={{ fontWeight: 600, color: '#1e293b' }}>{d.name}</div>
                        <div style={{ fontSize: '12px', color: '#64748b' }}>{d.specialty} • Rs. {d.fee}</div>
                      </div>
                    </div>
                    <button 
                      onClick={() => handleDeleteDoctor(d._id)}
                      className="btn-sm btn-reject"
                      style={{ padding: '6px 10px' }}
                      title="Remove Doctor"
                    >
                      <i className="ti ti-trash"></i>
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
