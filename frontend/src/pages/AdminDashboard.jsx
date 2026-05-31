import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getAllClinics, getPendingClinics, approveClinic, rejectClinic, suspendClinic, getUsers, banUser, unbanUser, getAllAppointments } from '../api';

export default function AdminDashboard() {
  const navigate = useNavigate();
  const [tab, setTab] = useState('pending');
  const [clinics, setClinics] = useState([]);
  const [users, setUsers] = useState([]);
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('adminToken');
    if (!token) {
      navigate('/login');
      return;
    }
    loadData();
  }, [tab]);

  async function loadData() {
    setLoading(true);
    try {
      if (tab === 'users') {
        const res = await getUsers();
        setUsers(res.data.users);
      } else if (tab === 'appointments') {
        const res = await getAllAppointments();
        setAppointments(res.data.appointments);
      } else {
        const res = tab === 'pending' ? await getPendingClinics() : await getAllClinics();
        setClinics(res.data.clinics);
      }
    } catch {
      navigate('/login');
    } finally {
      setLoading(false);
    }
  }

  async function handleApprove(id) {
    if (!confirm('Is clinic ko approve karna hai? Approve hone ke baad clinic apne email aur password se login kar sakegi.')) return;
    try {
      const res = await approveClinic(id);
      setMessage(res.data.message);
      loadData();
    } catch (err) {
      alert(err.response?.data?.message || 'Approve fail');
    }
  }

  async function handleReject(id) {
    const reason = prompt('Rejection reason (optional):');
    if (reason === null) return;
    try {
      await rejectClinic(id, reason);
      setMessage('Clinic reject kar di gayi');
      loadData();
    } catch (err) {
      alert(err.response?.data?.message || 'Reject fail');
    }
  }

  async function handleSuspend(id) {
    if (!confirm('Kya aap is clinic ko suspend (stop) karna chahte hain?')) return;
    try {
      await suspendClinic(id);
      setMessage('Clinic suspend kar di gayi hai');
      loadData();
    } catch (err) {
      alert(err.response?.data?.message || 'Suspend fail');
    }
  }

  async function handleBanUser(id) {
    if (!confirm('User ko ban karna hai?')) return;
    try {
      await banUser(id);
      setMessage('User ban kar diya gaya');
      loadData();
    } catch (err) {
      alert(err.response?.data?.message || 'Ban fail');
    }
  }

  async function handleUnbanUser(id) {
    if (!confirm('User ko unban karna hai?')) return;
    try {
      await unbanUser(id);
      setMessage('User unban kar diya gaya');
      loadData();
    } catch (err) {
      alert(err.response?.data?.message || 'Unban fail');
    }
  }

  function logout() {
    localStorage.removeItem('adminToken');
    navigate('/login');
  }

  return (
    <div className="admin-layout">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <h1 style={{ fontFamily: "'Playfair Display', serif", color: '#04342C', margin: 0 }}>
          Admin Dashboard
        </h1>
        <button className="btn-sm btn-outline" onClick={logout} type="button">
          Logout
        </button>
      </div>

      <div style={{ display: 'flex', gap: '8px', marginBottom: '1rem', flexWrap: 'wrap' }}>
        <button
          className={`btn-sm ${tab === 'pending' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('pending')}
          type="button"
        >
          Pending Clinics
        </button>
        <button
          className={`btn-sm ${tab === 'all' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('all')}
          type="button"
        >
          All Clinics
        </button>
        <button
          className={`btn-sm ${tab === 'users' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('users')}
          type="button"
        >
          Users
        </button>
        <button
          className={`btn-sm ${tab === 'appointments' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('appointments')}
          type="button"
        >
          All Appointments
        </button>
      </div>

      {message && <div className="alert alert-success">{message}</div>}

      {loading ? (
        <div className="loading">Loading...</div>
      ) : tab === 'appointments' ? (
        appointments.length === 0 ? (
          <div className="alert alert-info">Koi appointment nahi mili</div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Booking ID</th>
                  <th>Patient</th>
                  <th>Clinic</th>
                  <th>Doctor & Time</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((a) => (
                  <tr key={a._id}>
                    <td>
                      <span style={{ fontFamily: 'monospace', fontWeight: 700, color: '#0F6E56', background: '#E1F5EE', padding: '3px 8px', borderRadius: '4px' }}>
                        {a.bookingCode || 'N/A'}
                      </span>
                    </td>
                    <td>
                      <strong>{a.patientName}</strong><br />
                      <small>{a.patientPhone}</small>
                      {a.user?.email && <><br /><small style={{ color: '#888' }}>{a.user.email}</small></>}
                    </td>
                    <td>
                      <strong>{a.clinic?.name || 'Unknown'}</strong><br />
                      <small>{a.clinic?.city}</small>
                    </td>
                    <td>
                      {a.doctor?.name || 'Unknown'}<br />
                      <span style={{ fontWeight: 500, color: '#0F6E56' }}>{a.timeSlot}</span>
                      <br /><small>{new Date(a.appointmentDate).toLocaleDateString()}</small>
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
        )
      ) : tab === 'users' ? (
        users.length === 0 ? (
          <div className="alert alert-info">Koi user nahi mila</div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Contact</th>
                  <th>Joined</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((u) => (
                  <tr key={u._id}>
                    <td><strong>{u.name}</strong></td>
                    <td>{u.email}<br /><small>{u.phone}</small></td>
                    <td>{new Date(u.createdAt).toLocaleDateString()}</td>
                    <td><span className={`status-badge status-${u.status === 'active' ? 'approved' : 'rejected'}`}>{u.status}</span></td>
                    <td>
                      {u.status === 'active' ? (
                        <button className="btn-sm btn-reject" onClick={() => handleBanUser(u._id)} type="button">Ban</button>
                      ) : (
                        <button className="btn-sm btn-approve" onClick={() => handleUnbanUser(u._id)} type="button">Unban</button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      ) : clinics.length === 0 ? (
        <div className="alert alert-info">Koi clinic nahi mili</div>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="admin-table">
            <thead>
              <tr>
                <th>Clinic</th>
                <th>Contact</th>
                <th>Documents</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {clinics.map((c) => (
                <tr key={c._id}>
                  <td>
                    <strong>{c.name}</strong>
                    <br />
                    <small>{c.address}</small>
                  </td>
                  <td>
                    {c.email}
                    <br />
                    <small>{c.phone}</small>
                  </td>
                  <td>
                    <a href={c.certificateImage} target="_blank" rel="noreferrer">Certificate</a>
                    {' · '}
                    <a href={c.licenseImage} target="_blank" rel="noreferrer">License</a>
                    {c.agreementImages?.length > 0 && (
                      <>
                        {' · '}
                        {c.agreementImages.map((img, i) => (
                          <a key={i} href={img} target="_blank" rel="noreferrer">
                            Agree{i + 1}
                          </a>
                        ))}
                      </>
                    )}
                  </td>
                  <td>
                    <span className={`status-badge status-${c.status}`}>{c.status}</span>
                  </td>
                  <td>
                    {c.status === 'pending' && (
                      <>
                        <button className="btn-sm btn-approve" onClick={() => handleApprove(c._id)} type="button">
                          Approve
                        </button>
                        <button className="btn-sm btn-reject" onClick={() => handleReject(c._id)} type="button">
                          Reject
                        </button>
                      </>
                    )}
                    {c.status === 'approved' && tab === 'all' && (
                      <button className="btn-sm btn-reject" onClick={() => handleSuspend(c._id)} type="button">
                        Suspend
                      </button>
                    )}
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
