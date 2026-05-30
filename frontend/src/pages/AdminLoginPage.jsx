import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { adminLogin } from '../api';

export default function AdminLoginPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await adminLogin(form);
      if (res.data.role === 'clinic') {
        localStorage.setItem('clinicToken', res.data.token);
        localStorage.setItem('clinicId', res.data.clinic.id);
        navigate('/clinic-dashboard');
      } else if (res.data.role === 'user') {
        localStorage.setItem('userToken', res.data.token);
        navigate('/user-dashboard'); // Or home page
      } else {
        localStorage.setItem('adminToken', res.data.token);
        navigate('/admin');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Galat email ya password');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero">
        <h1 className="cl-title">Login</h1>
        <p className="cl-sub">Admin ya Clinic account me login karein</p>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      <form className="reg-form" onSubmit={handleSubmit}>
        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            id="email"
            type="email"
            required
            value={form.email}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
          />
        </div>
        <div className="field">
          <label htmlFor="password">Password</label>
          <input
            id="password"
            type="password"
            required
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
          />
        </div>
        <button className="cl-cta" type="submit" disabled={loading}>
          {loading ? 'Login...' : 'Login'}
        </button>
      </form>
    </div>
  );
}
