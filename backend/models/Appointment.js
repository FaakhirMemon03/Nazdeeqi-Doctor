const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema(
  {
    clinic: { type: mongoose.Schema.Types.ObjectId, ref: 'Clinic', required: true },
    doctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor', required: true },
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
