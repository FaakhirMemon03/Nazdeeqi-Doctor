const mongoose = require('mongoose');

function generateBookingCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = 'NDQ-';
  for (let i = 0; i < 6; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
}

const appointmentSchema = new mongoose.Schema(
  {
    bookingCode: { type: String, unique: true, default: generateBookingCode },
    clinic: { type: mongoose.Schema.Types.ObjectId, ref: 'Clinic', required: true },
    doctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor', required: true },
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    patientName: { type: String, required: true },
    patientPhone: { type: String, required: true },
    complaint: { type: String, default: '' },
    timeSlot: { type: String, required: true },
    appointmentDate: { type: Date, default: () => new Date() },
    status: {
      type: String,
      enum: ['confirmed', 'cancelled', 'completed'],
      default: 'confirmed',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Appointment', appointmentSchema);

