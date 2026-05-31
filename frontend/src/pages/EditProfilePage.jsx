import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { getProfile, updateProfile } from '../api';

export default function EditProfilePage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ name: '', email: '', phone: '' });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('userToken');
    if (!token) {
      navigate('/login');
      return;
    }
    getProfile()
      .then((res) => setForm({ name: res.data.user.name, email: res.data.user.email, phone: res.data.user.phone }))
      .catch(() => navigate('/login'))
      .finally(() => setLoading(false));
  }, []);

  function handleChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setSaving(true);
    setError('');
    setMessage('');
    try {
      const res = await updateProfile(form);
      setMessage(res.data.message);
    } catch (err) {
      setError(err.response?.data?.message || 'Update fail ho gayi');
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <div className="page-container loading">Loading...</div>;

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero" style={{ marginBottom: '1.5rem' }}>
        <h1 className="cl-title">Edit Profile</h1>
        <p className="cl-sub">Apni details update karein</p>
      </div>

      {error && <div className="alert alert-error">{error}</div>}
      {message && <div className="alert alert-success">{message}</div>}

      <form className="reg-form" onSubmit={handleSubmit} style={{ maxWidth: '480px', margin: '0 auto' }}>
        <div className="field">
          <label htmlFor="name">Naam</label>
          <input
            id="name"
            name="name"
            required
            placeholder="Apna naam"
            value={form.name}
            onChange={handleChange}
          />
        </div>
        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            id="email"
            name="email"
            type="email"
            required
            placeholder="Email"
            value={form.email}
            onChange={handleChange}
          />
        </div>
        <div className="field">
          <label htmlFor="phone">Phone</label>
          <input
            id="phone"
            name="phone"
            required
            placeholder="03XX XXXXXXX"
            value={form.phone}
            onChange={handleChange}
          />
        </div>

        <div style={{ display: 'flex', gap: '8px', marginTop: '1rem' }}>
          <button className="cl-cta" type="submit" disabled={saving} style={{ flex: 1 }}>
            {saving ? 'Saving...' : 'Save Changes'}
          </button>
          <Link
            to="/user-dashboard"
            style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', textDecoration: 'none', border: '1.5px solid #ccc', borderRadius: '8px', color: '#666', fontWeight: 500, fontSize: '14px' }}
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
