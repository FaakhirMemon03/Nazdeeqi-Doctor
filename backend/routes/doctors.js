const express = require('express');
const Doctor = require('../models/Doctor');
const { authClinic } = require('../middleware/auth');
const { getInitials } = require('../utils/helpers');

const router = express.Router();

// Get all doctors for the logged-in clinic
router.get('/', authClinic, async (req, res) => {
  try {
    const doctors = await Doctor.find({ clinic: req.clinicId, isActive: true }).sort({ createdAt: -1 });
    res.json({ doctors });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add a new doctor
router.post('/', authClinic, async (req, res) => {
  try {
    const { name, specialty, fee, availableSlots } = req.body;
    
    if (!name || !specialty || !fee) {
      return res.status(400).json({ message: 'Name, specialty, aur fee zaroori hain' });
    }

    const doctor = await Doctor.create({
      clinic: req.clinicId,
      name,
      specialty,
      fee: Number(fee),
      availableSlots: availableSlots && availableSlots.length > 0 
        ? availableSlots 
        : ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '5:00 PM'],
      initials: getInitials(name),
      // Assign random color for avatar
      avatarColor: ['#E1F5EE', '#E6F1FB', '#FBEAF0', '#FFF3E0'][Math.floor(Math.random() * 4)],
      textColor: ['#0F6E56', '#185FA5', '#993556', '#E65100'][Math.floor(Math.random() * 4)]
    });

    res.status(201).json({ message: 'Doctor add ho gaya', doctor });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update a doctor
router.patch('/:id', authClinic, async (req, res) => {
  try {
    const { name, specialty, fee, availableSlots } = req.body;
    const doctor = await Doctor.findOne({ _id: req.params.id, clinic: req.clinicId });
    
    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });

    if (name) {
      doctor.name = name;
      doctor.initials = getInitials(name);
    }
    if (specialty) doctor.specialty = specialty;
    if (fee) doctor.fee = Number(fee);
    if (availableSlots) doctor.availableSlots = availableSlots;

    await doctor.save();
    res.json({ message: 'Doctor update ho gaya', doctor });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Delete (soft delete) a doctor
router.delete('/:id', authClinic, async (req, res) => {
  try {
    const doctor = await Doctor.findOne({ _id: req.params.id, clinic: req.clinicId });
    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });

    doctor.isActive = false;
    await doctor.save();

    res.json({ message: 'Doctor remove kar diya gaya' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
