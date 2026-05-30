import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getAllClinics, getPendingClinics, approveClinic, rejectClinic } from '../api';

export default function AdminDashboard() {
  const navigate = useNavigate();
  const [tab, setTab] = useState('pending');
  const [clinics, setClinics] = useState([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');
  const [credentials, setCredentials] = useState(null);

  useEffect(() => {
    const token = localStorage.getItem('adminToken');
    if (!token) {
      navigate('/admin/login');
      return;
    }
    loadClinics();
  }, [tab]);

  async function loadClinics() {
    setLoading(true);
    try {
      const res = tab === 'pending' ? await getPendingClinics() : await getAllClinics();
      setClinics(res.data.clinics);
    } catch {
      navigate('/admin/login');
    } finally {
      setLoading(false);
    }
  }

  async function handleApprove(id) {
    if (!confirm('Is clinic ko approve karna hai? Login credentials email/SMS par bheje jayenge.')) return;
    try {
      const res = await approveClinic(id);
      setMessage(res.data.message);
      setCredentials({ loginEmail: res.data.loginEmail, loginPassword: res.data.loginPassword });
      loadClinics();
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
      loadClinics();
    } catch (err) {
      alert(err.response?.data?.message || 'Reject fail');
    }
  }

  function logout() {
    localStorage.removeItem('adminToken');
    navigate('/admin/login');
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

      <div style={{ display: 'flex', gap: '8px', marginBottom: '1rem' }}>
        <button
          className={`btn-sm ${tab === 'pending' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('pending')}
          type="button"
        >
          Pending
        </button>
        <button
          className={`btn-sm ${tab === 'all' ? 'btn-approve' : 'btn-outline'}`}
          onClick={() => setTab('all')}
          type="button"
        >
          All Clinics
        </button>
      </div>

      {message && <div className="alert alert-success">{message}</div>}

      {credentials && (
        <div className="alert alert-info">
          <strong>Generated Credentials (email/SMS bhej diye gaye):</strong>
          <br />
          Email: {credentials.loginEmail}
          <br />
          Password: {credentials.loginPassword}
        </div>
      )}

      {loading ? (
        <div className="loading">Loading...</div>
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
                    {c.credentialsSent && (
                      <br />
                    )}
                    {c.credentialsSent && <small>Credentials sent</small>}
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
                    {c.status === 'approved' && c.loginEmail && (
                      <small>{c.loginEmail}</small>
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
