import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { registerUser } from '../api';

export default function RegisterUserPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    name: '',
    email: '',
    phone: '',
    password: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  function handleChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await registerUser(form);
      localStorage.setItem('userToken', res.data.token);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || 'Registration failed');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero" style={{ marginBottom: '1.5rem' }}>
        <h1 className="cl-title">Patient Registration</h1>
        <p className="cl-sub">Nazdeeqi par apna account banayein aur appointments book karein</p>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      <form className="reg-form" onSubmit={handleSubmit} style={{ maxWidth: '500px', margin: '0 auto' }}>
        <div className="field">
          <label htmlFor="name">Pura Naam *</label>
          <input id="name" name="name" required placeholder="Ali Raza" value={form.name} onChange={handleChange} />
        </div>

        <div className="field">
          <label htmlFor="email">Email *</label>
          <input id="email" name="email" type="email" required placeholder="ali@example.com" value={form.email} onChange={handleChange} />
        </div>

        <div className="field">
          <label htmlFor="phone">Phone *</label>
          <input id="phone" name="phone" required placeholder="03XX XXXXXXX" value={form.phone} onChange={handleChange} />
        </div>

        <div className="field">
          <label htmlFor="password">Password *</label>
          <input id="password" name="password" type="password" required placeholder="Password set karein" value={form.password} onChange={handleChange} />
        </div>

        <button className="cl-cta" type="submit" disabled={loading} style={{ marginTop: '1rem', width: '100%' }}>
          {loading ? 'Submitting...' : 'Register'}
        </button>
        
        <p style={{ textAlign: 'center', marginTop: '1rem' }}>
          Pehle se account hai? <Link to="/login" style={{ color: '#0F6E56', fontWeight: 'bold' }}>Login karein</Link>
        </p>
      </form>
    </div>
  );
}
