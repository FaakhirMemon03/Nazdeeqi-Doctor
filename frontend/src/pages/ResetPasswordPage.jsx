import { useState } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { resetPassword } from '../api';

export default function ResetPasswordPage() {
  const { token } = useParams();
  const navigate = useNavigate();
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);
    setError('');
    setMessage('');
    try {
      const res = await resetPassword(token, password);
      setMessage(res.data.message);
      setTimeout(() => navigate('/login'), 2000);
    } catch (err) {
      setError(err.response?.data?.message || 'Token invalid ya expire ho gaya hai');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero" style={{ marginBottom: '1.5rem' }}>
        <h1 className="cl-title">Reset Password</h1>
        <p className="cl-sub">Apna naya password set karein</p>
      </div>

      {error && <div className="alert alert-error">{error}</div>}
      {message && <div className="alert alert-success">{message}</div>}

      <form className="reg-form" onSubmit={handleSubmit} style={{ maxWidth: '400px', margin: '0 auto' }}>
        <div className="field">
          <label htmlFor="password">Naya Password</label>
          <input
            id="password"
            type="password"
            required
            placeholder="Naya password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button className="cl-cta" type="submit" disabled={loading} style={{ marginTop: '1rem', width: '100%' }}>
          {loading ? 'Updating...' : 'Update Password'}
        </button>
      </form>
    </div>
  );
}
