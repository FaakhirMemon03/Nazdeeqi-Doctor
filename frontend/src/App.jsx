import { Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import LandingPage from './pages/LandingPage';
import ClinicPage from './pages/ClinicPage';
import RegisterClinicPage from './pages/RegisterClinicPage';
import AdminLoginPage from './pages/AdminLoginPage';
import AdminDashboard from './pages/AdminDashboard';
import ClinicDashboard from './pages/ClinicDashboard';

export default function App() {
  return (
    <div className="app-shell">
      <Navbar />
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/clinic/:id" element={<ClinicPage />} />
        <Route path="/register-clinic" element={<RegisterClinicPage />} />
        <Route path="/login" element={<AdminLoginPage />} />
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/clinic-dashboard" element={<ClinicDashboard />} />
      </Routes>
    </div>
  );
}
