import { Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import LandingPage from './pages/LandingPage';
import ClinicPage from './pages/ClinicPage';
import RegisterClinicPage from './pages/RegisterClinicPage';
import AdminLoginPage from './pages/AdminLoginPage';
import AdminDashboard from './pages/AdminDashboard';
import ClinicDashboard from './pages/ClinicDashboard';

import RegisterUserPage from './pages/RegisterUserPage';
import ForgotPasswordPage from './pages/ForgotPasswordPage';
import ResetPasswordPage from './pages/ResetPasswordPage';
import UserDashboard from './pages/UserDashboard';

export default function App() {
  return (
    <div className="app-shell">
      <Navbar />
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/clinic/:id" element={<ClinicPage />} />
        <Route path="/register-clinic" element={<RegisterClinicPage />} />
        <Route path="/login" element={<AdminLoginPage />} />
        <Route path="/register-user" element={<RegisterUserPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
        <Route path="/reset-password/:token" element={<ResetPasswordPage />} />
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/clinic-dashboard" element={<ClinicDashboard />} />
        <Route path="/user-dashboard" element={<UserDashboard />} />
      </Routes>
    </div>
  );
}
