import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
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

export const adminLogin = (data) => api.post('/admin/login', data);
export const getPendingClinics = () => api.get('/admin/clinics/pending');
export const getAllClinics = () => api.get('/admin/clinics/all');
export const approveClinic = (id) => api.patch(`/admin/clinics/${id}/approve`);
export const rejectClinic = (id, reason) => api.patch(`/admin/clinics/${id}/reject`, { reason });

export const getClinicAppointments = (clinicId) => api.get(`/appointments/clinic/${clinicId}`);

export default api;
