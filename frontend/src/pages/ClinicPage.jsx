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
            {!localStorage.getItem('userToken') ? (
              <div className="alert alert-info" style={{ textAlign: 'center', padding: '2rem' }}>
                <p style={{ margin: '0 0 1rem 0', fontWeight: 500 }}>Appointment book karne ke liye login zaroori hai</p>
                <Link to="/login" className="btn-sm btn-approve" style={{ padding: '10px 20px', display: 'inline-block', textDecoration: 'none' }}>
                  Login / Signup
                </Link>
              </div>
            ) : (
              <>
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
              </>
            )}
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
        <div className="cl-success" style={{ textAlign: 'left', padding: '2rem', maxWidth: '520px', margin: '0 auto' }}>
          <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
            <i className="ti ti-circle-check" aria-hidden="true" style={{ fontSize: '3rem', color: '#0F6E56' }} />
            <p className="cl-success-title" style={{ marginTop: '0.5rem' }}>Appointment Confirm Ho Gayi!</p>
          </div>

          {/* Receipt Card */}
          <div className="receipt-card" style={{
            background: 'linear-gradient(135deg, #04342C 0%, #0F6E56 100%)',
            borderRadius: '16px',
            padding: '1.5rem',
            color: 'white',
            marginBottom: '1.5rem',
            boxShadow: '0 8px 32px rgba(4,52,44,0.25)',
            position: 'relative',
            overflow: 'hidden'
          }}>
            <div style={{ textAlign: 'center', marginBottom: '1.2rem', paddingBottom: '0.8rem', borderBottom: '1px dashed rgba(255,255,255,0.3)' }}>
              <div style={{ fontSize: '12px', letterSpacing: '2px', opacity: 0.8, textTransform: 'uppercase' }}>Official Appointment Slip</div>
              <div style={{ fontSize: '1.4rem', fontWeight: 700, fontFamily: "'Playfair Display', serif", marginTop: '4px' }}>Nazdeeqi Doctors</div>
            </div>
            
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '1rem' }}>
              <div>
                <div style={{ fontSize: '11px', opacity: 0.7, letterSpacing: '1px', textTransform: 'uppercase' }}>Booking ID</div>
                <div style={{ fontSize: '1.6rem', fontWeight: 700, letterSpacing: '3px', fontFamily: 'monospace' }}>{success.bookingCode}</div>
              </div>
              <div style={{ fontSize: '11px', opacity: 0.7, background: 'rgba(255,255,255,0.15)', padding: '4px 10px', borderRadius: '20px' }}>CONFIRMED</div>
            </div>

            <div style={{ height: '1px', background: 'rgba(255,255,255,0.2)', margin: '1rem 0' }} />

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.8rem', fontSize: '13px' }}>
              <div>
                <div style={{ opacity: 0.65, fontSize: '11px', marginBottom: '2px' }}>Patient</div>
                <div style={{ fontWeight: 600 }}>{success.patientName}</div>
              </div>
              <div>
                <div style={{ opacity: 0.65, fontSize: '11px', marginBottom: '2px' }}>Phone</div>
                <div style={{ fontWeight: 600 }}>{success.patientPhone}</div>
              </div>
              <div>
                <div style={{ opacity: 0.65, fontSize: '11px', marginBottom: '2px' }}>Doctor</div>
                <div style={{ fontWeight: 600 }}>{success.doctorName}</div>
              </div>
              <div>
                <div style={{ opacity: 0.65, fontSize: '11px', marginBottom: '2px' }}>Time Slot</div>
                <div style={{ fontWeight: 600 }}>{success.timeSlot}</div>
              </div>
              <div>
                <div style={{ opacity: 0.65, fontSize: '11px', marginBottom: '2px' }}>Clinic</div>
                <div style={{ fontWeight: 600 }}>{success.clinicName}</div>
              </div>
              {success.complaint && (
                <div>
                  <div style={{ opacity: 0.65, fontSize: '11px', marginBottom: '2px' }}>Takleef</div>
                  <div style={{ fontWeight: 600 }}>{success.complaint}</div>
                </div>
              )}
            </div>
          </div>

          <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
            <button 
              className="btn-sm btn-outline" 
              onClick={() => window.print()}
              style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', fontSize: '14px', padding: '8px 16px' }}
            >
              <i className="ti ti-download" /> Download / Print Slip
            </button>
          </div>

          <div className="alert alert-info" style={{ fontSize: '13px', marginBottom: '1rem' }}>
            <strong>Clinic ko yeh Booking ID dikhayein:</strong> <span style={{ fontFamily: 'monospace', fontWeight: 700, fontSize: '15px' }}>{success.bookingCode}</span>
            <br />Clinic staff is ID se aapki booking verify karengi.
          </div>

          <div style={{ display: 'flex', gap: '8px', marginTop: '1rem' }}>
            <Link to="/user-dashboard" style={{ flex: 1, display: 'block', textAlign: 'center', padding: '10px', background: '#0F6E56', color: 'white', borderRadius: '8px', textDecoration: 'none', fontWeight: 600 }}>
              My Appointments
            </Link>
            <Link to="/" style={{ flex: 1, display: 'block', textAlign: 'center', padding: '10px', border: '1.5px solid #ccc', color: '#666', borderRadius: '8px', textDecoration: 'none', fontWeight: 500 }}>
              ← Home
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}
