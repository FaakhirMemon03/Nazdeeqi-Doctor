import { useState } from 'react';
import { Link } from 'react-router-dom';
import { registerClinic } from '../api';

export default function RegisterClinicPage() {
  const [form, setForm] = useState({
    name: '',
    address: '',
    phone: '',
    email: '',
    city: 'Karachi',
  });
  const [files, setFiles] = useState({
    certificateImage: null,
    licenseImage: null,
    agreementImages: [],
  });
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

  function handleChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  function handleFileChange(e) {
    const { name, files: selected } = e.target;
    if (name === 'agreementImages') {
      setFiles({ ...files, agreementImages: Array.from(selected) });
    } else {
      setFiles({ ...files, [name]: selected[0] });
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');

    if (!files.certificateImage || !files.licenseImage) {
      setError('Doctor certificate aur license ki image zaroor upload karein');
      return;
    }

    const data = new FormData();
    Object.entries(form).forEach(([k, v]) => data.append(k, v));
    data.append('certificateImage', files.certificateImage);
    data.append('licenseImage', files.licenseImage);
    files.agreementImages.forEach((f) => data.append('agreementImages', f));

    // Try to get location for nearby feature
    if (navigator.geolocation) {
      try {
        const pos = await new Promise((resolve, reject) =>
          navigator.geolocation.getCurrentPosition(resolve, reject, { timeout: 5000 })
        );
        data.append('latitude', pos.coords.latitude);
        data.append('longitude', pos.coords.longitude);
      } catch {
        /* optional */
      }
    }

    setLoading(true);
    try {
      await registerClinic(data);
      setSuccess(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Registration fail ho gayi');
    } finally {
      setLoading(false);
    }
  }

  if (success) {
    return (
      <div className="page-container cl-wrap">
        <div className="cl-success">
          <i className="ti ti-circle-check" aria-hidden="true" />
          <p className="cl-success-title">Registration Submit Ho Gayi!</p>
          <p className="cl-success-msg">
            Admin review ke baad aapke diye gaye email ({form.email}) aur phone ({form.phone}) par
            login credentials bheje jayenge. Tab tak credentials send nahi honge jab tak admin
            approve na kare.
          </p>
          <Link to="/" style={{ display: 'inline-block', marginTop: '1rem', color: '#0F6E56' }}>
            ← Home par wapas jayein
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero" style={{ marginBottom: '1.5rem' }}>
        <span className="cl-badge">
          <i className="ti ti-building-hospital" aria-hidden="true" /> Clinic Registration
        </span>
        <h1 className="cl-title">Apni Clinic Register Karein</h1>
        <p className="cl-sub">
          Documents submit karein — admin approve karne ke baad login details milengi
        </p>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      <form className="reg-form" onSubmit={handleSubmit}>
        <div className="field">
          <label htmlFor="name">Hospital / Clinic ka naam *</label>
          <input
            id="name"
            name="name"
            required
            placeholder="e.g. City Care Hospital"
            value={form.name}
            onChange={handleChange}
          />
        </div>

        <div className="field">
          <label htmlFor="address">Pura address (fixed) *</label>
          <input
            id="address"
            name="address"
            required
            placeholder="Block, Area, City"
            value={form.address}
            onChange={handleChange}
          />
        </div>

        <div className="cl-form-row">
          <div className="field">
            <label htmlFor="phone">Phone number *</label>
            <input
              id="phone"
              name="phone"
              type="tel"
              required
              placeholder="03XX XXXXXXX"
              value={form.phone}
              onChange={handleChange}
            />
          </div>
          <div className="field">
            <label htmlFor="email">Email *</label>
            <input
              id="email"
              name="email"
              type="email"
              required
              placeholder="clinic@email.com"
              value={form.email}
              onChange={handleChange}
            />
          </div>
        </div>

        <div className="field">
          <label htmlFor="city">Shehar</label>
          <select id="city" name="city" value={form.city} onChange={handleChange}>
            <option value="Karachi">Karachi</option>
            <option value="Lahore">Lahore</option>
            <option value="Islamabad">Islamabad</option>
            <option value="Rawalpindi">Rawalpindi</option>
            <option value="Faisalabad">Faisalabad</option>
            <option value="Multan">Multan</option>
            <option value="Peshawar">Peshawar</option>
            <option value="Quetta">Quetta</option>
          </select>
        </div>

        <div className="field">
          <label htmlFor="certificateImage">Doctor ka Certificate (image/PDF) *</label>
          <input
            id="certificateImage"
            name="certificateImage"
            type="file"
            accept="image/*,.pdf"
            required
            onChange={handleFileChange}
          />
          <p className="file-hint">MBBS ya specialist degree certificate</p>
        </div>

        <div className="field">
          <label htmlFor="licenseImage">Doctor ka License (image/PDF) *</label>
          <input
            id="licenseImage"
            name="licenseImage"
            type="file"
            accept="image/*,.pdf"
            required
            onChange={handleFileChange}
          />
          <p className="file-hint">PMDC / medical council license</p>
        </div>

        <div className="field">
          <label htmlFor="agreementImages">Agreement ki images (optional, max 5)</label>
          <input
            id="agreementImages"
            name="agreementImages"
            type="file"
            accept="image/*,.pdf"
            multiple
            onChange={handleFileChange}
          />
          <p className="file-hint">Clinic agreement, rent deed, etc.</p>
        </div>

        <div className="alert alert-info" style={{ marginTop: '1rem' }}>
          <i className="ti ti-info-circle" /> Registration ke baad random login email/password
          generate hoga. Ye tab tak email aur SMS par nahi bheja jayega jab tak admin approve na
          kare.
        </div>

        <button className="cl-cta" type="submit" disabled={loading} style={{ marginTop: '1rem' }}>
          {loading ? 'Submit ho raha hai...' : 'Register Karein'}
        </button>
      </form>
    </div>
  );
}
