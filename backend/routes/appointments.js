const express = require('express');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const Clinic = require('../models/Clinic');
const { authUser } = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

router.post('/', authUser, async (req, res) => {
  try {
    const { clinicId, doctorId, patientName, patientPhone, complaint, timeSlot } = req.body;

    if (!clinicId || !doctorId || !patientName || !patientPhone || !timeSlot) {
      return res.status(400).json({ message: 'Sab required fields bharein' });
    }

    const user = await User.findById(req.userId);
    if (!user || user.status === 'banned') {
      return res.status(403).json({ message: 'Aapka account ban hai ya exist nahi karta' });
    }

    const clinic = await Clinic.findOne({ _id: clinicId, status: 'approved' });
    if (!clinic) return res.status(404).json({ message: 'Clinic not found' });

    const doctor = await Doctor.findOne({ _id: doctorId, clinic: clinicId, isActive: true });
    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });

    if (!doctor.availableSlots.includes(timeSlot)) {
      return res.status(400).json({ message: 'Ye time slot available nahi hai' });
    }

    const appointment = await Appointment.create({
      clinic: clinicId,
      doctor: doctorId,
      user: req.userId,
      patientName,
      patientPhone,
      complaint: complaint || '',
      timeSlot,
    });

    res.status(201).json({
      message: 'Appointment book ho gayi!',
      appointment: {
        id: appointment._id,
        patientName,
        doctorName: doctor.name,
        clinicName: clinic.name,
        timeSlot,
        patientPhone,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/clinic/:clinicId', async (req, res) => {
  try {
    const appointments = await Appointment.find({ clinic: req.params.clinicId })
      .populate('doctor', 'name specialty')
      .sort({ createdAt: -1 });
    res.json({ appointments });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/user', authUser, async (req, res) => {
  try {
    const appointments = await Appointment.find({ user: req.userId })
      .populate('clinic', 'name address phone city')
      .populate('doctor', 'name specialty fee')
      .sort({ createdAt: -1 });
    res.json({ appointments });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
