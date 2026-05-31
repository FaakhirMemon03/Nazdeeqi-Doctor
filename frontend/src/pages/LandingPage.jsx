import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getNearbyClinics, getStats } from '../api';

export default function LandingPage() {
  const navigate = useNavigate();
  const [clinics, setClinics] = useState([]);
  const [stats, setStats] = useState({ clinics: 50, doctors: 200, patients: 10000 });
  const [loading, setLoading] = useState(true);
  const [locationStatus, setLocationStatus] = useState('');

  useEffect(() => {
    loadData();
  }, []);

  async function loadData(lat, lng) {
    setLoading(true);
    try {
      const params = {};
      if (lat && lng) {
        params.lat = lat;
        params.lng = lng;
      }
      const [clinicsRes, statsRes] = await Promise.all([
        getNearbyClinics(params),
        getStats(),
      ]);
      setClinics(clinicsRes.data.clinics);
      setStats(statsRes.data);
    } catch {
      setLocationStatus('Clinics load nahi ho sake. Server check karein.');
    } finally {
      setLoading(false);
    }
  }

  function findNearby() {
    if (!navigator.geolocation) {
      setLocationStatus('Aapka browser location support nahi karta.');
      return;
    }
    setLocationStatus('Location dhoondh rahe hain...');
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setLocationStatus('Aapke qareeb ki clinics:');
        loadData(pos.coords.latitude, pos.coords.longitude);
      },
      () => {
        setLocationStatus('Location access nahi mili. Sab clinics dikha rahe hain.');
        loadData();
      }
    );
  }

  return (
    <div className="page-container cl-wrap">
      <div className="cl-hero">
        <span className="cl-badge">
          <i className="ti ti-shield-check" aria-hidden="true" /> Verified Doctors
        </span>
        <h1 className="cl-title">Apna Doctor,<br />Apni Marzi</h1>
        <p className="cl-sub">
          Ghar baithe appointment book karein — koi line nahi, koi intezaar nahi
        </p>
        <div className="cl-stats">
          <div className="cl-stat">
            <div className="cl-stat-num">{stats.clinics}+</div>
            <div className="cl-stat-label">Registered Clinics</div>
          </div>
          <div className="cl-stat">
            <div className="cl-stat-num">{stats.doctors}+</div>
            <div className="cl-stat-label">Doctors</div>
          </div>
          <div className="cl-stat">
            <div className="cl-stat-num">{stats.patients >= 1000 ? `${Math.floor(stats.patients / 1000)}K+` : stats.patients}</div>
            <div className="cl-stat-label">Patients Served</div>
          </div>
        </div>
      </div>

      <div className="cl-section">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem' }}>
          <p className="cl-section-title" style={{ margin: 0 }}>Qareeb ki Clinics</p>
          <button className="btn-sm btn-outline" onClick={findNearby} type="button">
            <i className="ti ti-map-pin" /> Meri Location
          </button>
        </div>
        {locationStatus && <p className="alert alert-info">{locationStatus}</p>}

        {loading ? (
          <div className="loading">Clinics load ho rahi hain...</div>
        ) : clinics.length === 0 ? (
          <div className="alert alert-info">
            {locationStatus.includes('qareeb') 
              ? 'Aapke qareeb (3km ke andar) koi clinic nahi mili. Location badal kar try karein.'
              : 'Abhi koi approved clinic nahi. Pehli clinic register karein!'}
          </div>
        ) : (
          <div className="clinic-grid">
            {clinics.map((clinic) => (
              <div
                key={clinic._id}
                className="clinic-card"
                onClick={() => navigate(`/clinic/${clinic._id}`)}
                role="button"
                tabIndex={0}
                onKeyDown={(e) => e.key === 'Enter' && navigate(`/clinic/${clinic._id}`)}
              >
                <div>
                  <p className="clinic-card-name" style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '8px' }}>
                    {clinic.name}
                    <span style={{
                      fontSize: '10px',
                      padding: '2px 8px',
                      borderRadius: '12px',
                      fontWeight: 600,
                      background: clinic.isOpenToday !== false ? '#E1F5EE' : '#FBEAF0',
                      color: clinic.isOpenToday !== false ? '#085041' : '#993556'
                    }}>
                      {clinic.isOpenToday !== false ? '● Open Today' : '● Closed Today'}
                    </span>
                  </p>
                  <p className="clinic-card-meta">
                    <i className="ti ti-map-pin" style={{ fontSize: 12 }} /> {clinic.address}
                  </p>
                  {clinic.timings && (
                    <p className="clinic-card-meta" style={{ color: '#0F6E56', display: 'flex', alignItems: 'center', gap: '4px', margin: '4px 0' }}>
                      <i className="ti ti-clock" style={{ fontSize: 12 }} /> <span style={{ fontWeight: 500 }}>{clinic.timings}</span>
                    </p>
                  )}
                  <p className="clinic-card-meta">
                    {clinic.doctorCount || 0} doctors available
                  </p>
                </div>
                {clinic.distanceKm != null && (
                  <span className="clinic-card-distance">{clinic.distanceKm} km</span>
                )}
              </div>
            ))}
          </div>
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
    </div>
  );
}
