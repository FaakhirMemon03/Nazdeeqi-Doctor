import { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { getClinicById, bookAppointment } from '../api';

export default function ClinicPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [clinic, setClinic] = useState(null);
  const [doctors, setDoctors] = useState([]);
  const [selectedDoctor, setSelectedDoctor] = useState(null);
  const [selectedTime, setSelectedTime] = useState('');
  const [form, setForm] = useState({ name: '', phone: '', complaint: '' });
  const [success, setSuccess] = useState(null);
  const [loading, setLoading] = useState(true);
  const [booking, setBooking] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    loadClinic();
  }, [id]);

  async function loadClinic() {
    setLoading(true);
    try {
      const res = await getClinicById(id);
      setClinic(res.data.clinic);
      setDoctors(res.data.doctors);
      if (res.data.doctors.length > 0) {
        setSelectedDoctor(res.data.doctors[0]);
        setSelectedTime(res.data.doctors[0].availableSlots[0] || '');
      }
    } catch {
      setError('Clinic nahi mili ya abhi approved nahi hai.');
    } finally {
      setLoading(false);
    }
  }

  function selectDoctor(doc) {
    setSelectedDoctor(doc);
    setSelectedTime(doc.availableSlots[0] || '');
  }

  async function handleBook() {
    const token = localStorage.getItem('userToken');
    if (!token) {
      alert('Appointment book karne ke liye pehle login karein');
      navigate('/login');
      return;
    }

    if (!form.name.trim() || !form.phone.trim()) {
      alert('Naam aur phone number zaroor bharein');
      return;
    }
    if (!selectedDoctor || !selectedTime) {
      alert('Doctor aur time select karein');
      return;
    }

    setBooking(true);
    try {
      const res = await bookAppointment({
        clinicId: id,
        doctorId: selectedDoctor._id,
        patientName: form.name.trim(),
        patientPhone: form.phone.trim(),
        complaint: form.complaint.trim(),
        timeSlot: selectedTime,
      });
      setSuccess(res.data.appointment);
    } catch (err) {
      alert(err.response?.data?.message || 'Booking fail ho gayi');
    } finally {
      setBooking(false);
    }
  }

  if (loading) return <div className="page-container loading">Loading...</div>;
  if (error) {
    return (
      <div className="page-container">
        <div className="alert alert-error">{error}</div>
        <Link to="/">← Wapas jayein</Link>
      </div>
    );
  }

  const slots = selectedDoctor?.availableSlots || [];

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero">
        <span className="cl-badge">
          <i className="ti ti-building-hospital" aria-hidden="true" /> {clinic.city}
        </span>
        <h1 className="cl-title">{clinic.name}</h1>
        <p className="cl-sub">
          <i className="ti ti-map-pin" /> {clinic.address}
        </p>
        <div className="cl-stats">
          <div className="cl-stat">
            <div className="cl-stat-num">{doctors.length}</div>
            <div className="cl-stat-label">Doctors Available</div>
          </div>
          <div className="cl-stat">
            <div className="cl-stat-num">
              <i className="ti ti-phone" style={{ fontSize: 18 }} />
            </div>
            <div className="cl-stat-label">{clinic.phone}</div>
          </div>
        </div>
      </div>

      {!success ? (
        <>
          <div className="cl-section">
            <p className="cl-section-title">Doctor chunein</p>
            <div className="cl-doctors">
              {doctors.map((doc) => (
                <div
                  key={doc._id}
                  className={`cl-doc ${selectedDoctor?._id === doc._id ? 'active' : ''}`}
                  onClick={() => selectDoctor(doc)}
                  role="button"
                  tabIndex={0}
                >
                  <div
                    className="cl-doc-avatar"
                    style={{ background: doc.avatarColor, color: doc.textColor }}
                  >
                    {doc.initials}
                  </div>
                  <p className="cl-doc-name">{doc.name}</p>
                  <p className="cl-doc-spec">{doc.specialty}</p>
                  <p className="cl-doc-fee">Rs. {doc.fee.toLocaleString()}</p>
                </div>
              ))}
            </div>
          </div>

          <div className="cl-section">
            <p className="cl-section-title">Waqt chunein</p>
            <div className="cl-times">
              {slots.map((slot) => (
                <div
                  key={slot}
                  className={`cl-time ${selectedTime === slot ? 'active' : ''}`}
                  onClick={() => setSelectedTime(slot)}
                  role="button"
                  tabIndex={0}
                >
                  {slot}
                </div>
              ))}
            </div>
          </div>

          <div className="cl-section">
            <p className="cl-section-title">Aapki details</p>
            <div className="cl-form-row">
              <input
                type="text"
                placeholder="Aapka naam"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
              />
              <input
                type="tel"
                placeholder="Phone number"
                value={form.phone}
                onChange={(e) => setForm({ ...form, phone: e.target.value })}
              />
            </div>
            <div className="cl-form-full">
              <input
                type="text"
                placeholder="Takleef kya hai? (Optional)"
                value={form.complaint}
                onChange={(e) => setForm({ ...form, complaint: e.target.value })}
              />
            </div>
            <button className="cl-cta" onClick={handleBook} disabled={booking}>
              <i className="ti ti-calendar-check" aria-hidden="true" />{' '}
              {booking ? 'Booking ho rahi hai...' : 'Appointment Book Karein'}
            </button>
          </div>

          <div className="cl-section">
            <div className="cl-features">
              <div className="cl-feat">
                <i className="ti ti-clock" aria-hidden="true" />
                <div className="cl-feat-text">SMS reminder milega</div>
              </div>
              <div className="cl-feat">
                <i className="ti ti-lock" aria-hidden="true" />
                <div className="cl-feat-text">Data bilkul safe</div>
              </div>
              <div className="cl-feat">
                <i className="ti ti-phone-call" aria-hidden="true" />
                <div className="cl-feat-text">Free cancellation</div>
              </div>
            </div>
          </div>
        </>
      ) : (
        <div className="cl-success">
          <i className="ti ti-circle-check" aria-hidden="true" />
          <p className="cl-success-title">Appointment Book Ho Gayi!</p>
          <p className="cl-success-msg">
            {success.patientName}, {success.doctorName} ke saath {success.timeSlot} ki appointment
            confirm hai. SMS aa jayega {success.patientPhone} par.
          </p>
          <Link to="/" style={{ display: 'inline-block', marginTop: '1rem', color: '#0F6E56' }}>
            ← Home par wapas jayein
          </Link>
        </div>
      )}
    </div>
  );
}
