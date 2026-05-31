import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('userToken') || localStorage.getItem('clinicToken') || localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const getNearbyClinics = (params) => api.get('/clinics/nearby', { params });
export const getClinicById = (id) => api.get(`/clinics/${id}`);
export const getStats = () => api.get('/clinics/stats');
export const registerClinic = (formData) =>
  api.post('/clinics/register', formData);
export const bookAppointment = (data) => api.post('/appointments', data);

// Auth & Users
export const registerUser = (data) => api.post('/auth/register', data);
export const login = (data) => api.post('/auth/login', data);
export const adminLogin = login; // Alias for old code
export const forgotPassword = (email) => api.post('/auth/forgot-password', { email });
export const resetPassword = (token, password) => api.post(`/auth/reset-password/${token}`, { password });

// Admin Actions
export const getAllClinics = () => api.get('/admin/clinics/all');
export const getPendingClinics = () => api.get('/admin/clinics/pending');
export const getClinicDetails = (id) => api.get(`/admin/clinics/${id}`);
export const approveClinic = (id) => api.patch(`/admin/clinics/${id}/approve`);
export const rejectClinic = (id, reason) => api.patch(`/admin/clinics/${id}/reject`, { reason });
export const suspendClinic = (id) => api.patch(`/admin/clinics/${id}/suspend`);

export const getUsers = () => api.get('/admin/users');
export const banUser = (id) => api.patch(`/admin/users/${id}/ban`);
export const unbanUser = (id) => api.patch(`/admin/users/${id}/unban`);

// Appointments
export const getClinicAppointments = (clinicId) => api.get(`/appointments/clinic/${clinicId}`);
export const getUserAppointments = () => api.get('/appointments/user');
export const cancelAppointment = (id) => api.patch(`/appointments/${id}/cancel`);

export const getProfile = () => api.get('/auth/profile');
export const updateProfile = (data) => api.put('/auth/profile', data);

export default api;
