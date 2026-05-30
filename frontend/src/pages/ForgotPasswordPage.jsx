import { useState } from 'react';
import { Link } from 'react-router-dom';
import { forgotPassword } from '../api';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);
    setError('');
    setMessage('');
    try {
      const res = await forgotPassword(email);
      setMessage(res.data.message);
    } catch (err) {
      setError(err.response?.data?.message || 'Kuch masla ho gaya');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero" style={{ marginBottom: '1.5rem' }}>
        <h1 className="cl-title">Forgot Password</h1>
        <p className="cl-sub">Apna email likhein, hum reset link bhejenge</p>
      </div>

      {error && <div className="alert alert-error">{error}</div>}
      {message && <div className="alert alert-success">{message}</div>}

      <form className="reg-form" onSubmit={handleSubmit} style={{ maxWidth: '400px', margin: '0 auto' }}>
        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            id="email"
            type="email"
            required
            placeholder="ali@example.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <button className="cl-cta" type="submit" disabled={loading} style={{ marginTop: '1rem', width: '100%' }}>
          {loading ? 'Sending...' : 'Send Reset Link'}
        </button>
        <p style={{ textAlign: 'center', marginTop: '1rem' }}>
          <Link to="/login" style={{ color: '#0F6E56' }}>← Back to Login</Link>
        </p>
      </form>
    </div>
  );
}
