const express = require('express');
const jwt = require('jsonwebtoken');
const Admin = require('../models/Admin');
const Clinic = require('../models/Clinic');
const Doctor = require('../models/Doctor');
const { authAdmin } = require('../middleware/auth');
const { generatePassword, generateClinicLoginEmail, getInitials } = require('../utils/helpers');
const { sendClinicCredentials } = require('../utils/mailer');

const router = express.Router();

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const admin = await Admin.findOne({ email: email?.toLowerCase() });
    
    if (admin && (await admin.comparePassword(password))) {
      const token = jwt.sign({ id: admin._id, role: 'admin' }, process.env.JWT_SECRET, { expiresIn: '7d' });
      return res.json({ token, role: 'admin', admin: { id: admin._id, email: admin.email, name: admin.name } });
    }

    const clinic = await Clinic.findOne({ email: email?.toLowerCase() });
    if (clinic && (await clinic.comparePassword(password))) {
      if (clinic.status !== 'approved') {
        return res.status(403).json({ message: 'Aapki clinic abhi admin ne approve nahi ki hai' });
      }
      const token = jwt.sign({ id: clinic._id, role: 'clinic' }, process.env.JWT_SECRET, { expiresIn: '7d' });
      return res.json({ token, role: 'clinic', clinic: { id: clinic._id, name: clinic.name, email: clinic.email } });
    }

    return res.status(401).json({ message: 'Galat email ya password' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/clinics/pending', authAdmin, async (_req, res) => {
  try {
    const clinics = await Clinic.find({ status: 'pending' }).sort({ createdAt: -1 });
    res.json({ clinics });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/clinics/all', authAdmin, async (_req, res) => {
  try {
    const clinics = await Clinic.find().sort({ createdAt: -1 }).select('-loginPassword');
    res.json({ clinics });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/clinics/:id', authAdmin, async (req, res) => {
  try {
    const clinic = await Clinic.findById(req.params.id).select('-loginPassword');
    if (!clinic) return res.status(404).json({ message: 'Clinic not found' });
    res.json({ clinic });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.patch('/clinics/:id/approve', authAdmin, async (req, res) => {
  try {
    const clinic = await Clinic.findById(req.params.id);
    if (!clinic) return res.status(404).json({ message: 'Clinic not found' });
    if (clinic.status === 'approved') {
      return res.status(400).json({ message: 'Pehle se approved hai' });
    }

    clinic.status = 'approved';
    await clinic.save();

    // Seed default doctors if none exist
    const existingDoctors = await Doctor.countDocuments({ clinic: clinic._id });
    if (existingDoctors === 0) {
      const defaults = [
        { name: 'Dr. Sana Malik', specialty: 'General Physician', fee: 800, avatarColor: '#E1F5EE', textColor: '#0F6E56' },
        { name: 'Dr. Ahmed Raza', specialty: 'Cardiologist', fee: 1500, avatarColor: '#E6F1FB', textColor: '#185FA5' },
        { name: 'Dr. Nida Fatima', specialty: 'Dermatologist', fee: 1200, avatarColor: '#FBEAF0', textColor: '#993556' },
      ];
      await Doctor.insertMany(
        defaults.map((d) => ({
          ...d,
          clinic: clinic._id,
          initials: getInitials(d.name),
        }))
      );
    }

    res.json({
      message: 'Clinic approved!',
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.patch('/clinics/:id/reject', authAdmin, async (req, res) => {
  try {
    const clinic = await Clinic.findById(req.params.id);
    if (!clinic) return res.status(404).json({ message: 'Clinic not found' });

    clinic.status = 'rejected';
    clinic.rejectionReason = req.body.reason || 'Documents verify nahi ho sake';
    await clinic.save();

    res.json({ message: 'Clinic reject kar di gayi' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
