const express = require('express');
const Clinic = require('../models/Clinic');
const Doctor = require('../models/Doctor');
const Appointment = require('../models/Appointment');
const upload = require('../middleware/upload');
const { sendRegistrationPending } = require('../utils/mailer');
const { haversineDistance } = require('../utils/helpers');
const { authClinic } = require('../middleware/auth');

const router = express.Router();

router.get('/nearby', async (req, res) => {
  try {
    const { lat, lng, city } = req.query;
    const filter = { status: 'approved' };
    if (city) filter.city = new RegExp(city, 'i');

    let clinics = await Clinic.find(filter).select('-loginPassword').lean();
    const doctorCounts = await Doctor.aggregate([
      { $match: { isActive: true } },
      { $group: { _id: '$clinic', count: { $sum: 1 } } },
    ]);
    const countMap = Object.fromEntries(doctorCounts.map((d) => [String(d._id), d.count]));

    clinics = clinics.map((c) => {
      const item = { ...c, doctorCount: countMap[c._id] || 0 };
      if (lat && lng && c.latitude && c.longitude) {
        item.distanceKm = Math.round(haversineDistance(+lat, +lng, c.latitude, c.longitude) * 10) / 10;
      }
      return item;
    });

    if (lat && lng) {
      clinics = clinics.filter(c => c.distanceKm != null && c.distanceKm <= 3);
      clinics.sort((a, b) => a.distanceKm - b.distanceKm);
    }

    res.json({ clinics, total: clinics.length });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/stats', async (_req, res) => {
  try {
    const [clinicCount, doctorCount, appointmentCount] = await Promise.all([
      Clinic.countDocuments({ status: 'approved' }),
      Doctor.countDocuments({ isActive: true }),
      Appointment.countDocuments(),
    ]);
    res.json({
      clinics: clinicCount || 50,
      doctors: doctorCount || 200,
      patients: appointmentCount || 10000,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const clinic = await Clinic.findOne({ _id: req.params.id, status: 'approved' }).select('-loginPassword');
    if (!clinic) return res.status(404).json({ message: 'Clinic not found' });

    const doctors = await Doctor.find({ clinic: clinic._id, isActive: true });
    res.json({ clinic, doctors });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

function handleUpload(req, res, next) {
  upload.fields([
    { name: 'certificateImage', maxCount: 1 },
    { name: 'licenseImage', maxCount: 1 },
    { name: 'agreementImages', maxCount: 5 },
  ])(req, res, (err) => {
    if (err) {
      const message =
        err.code === 'LIMIT_FILE_SIZE'
          ? 'File 10MB se choti honi chahiye'
          : err.message || 'File upload error';
      return res.status(400).json({ message });
    }
    next();
  });
}

router.post('/register', handleUpload, async (req, res) => {
    try {
      const { name, address, phone, email, latitude, longitude, city, password } = req.body;

      if (!name || !address || !phone || !email || !password) {
        return res.status(400).json({ message: 'Name, address, phone, email aur password zaroori hain' });
      }
      if (!req.files?.certificateImage?.[0] || !req.files?.licenseImage?.[0]) {
        return res.status(400).json({ message: 'Doctor certificate aur license ki image zaroori hai' });
      }

      const existing = await Clinic.findOne({ email: email.toLowerCase() });
      if (existing) {
        return res.status(400).json({ message: 'Is email se pehle se registration hai' });
      }

      const bcrypt = require('bcryptjs');
      const hashedPassword = await bcrypt.hash(password, 10);

      const agreementImages = (req.files.agreementImages || []).map((f) => `/uploads/${f.filename}`);

      const clinic = await Clinic.create({
        name,
        address,
        phone,
        email: email.toLowerCase(),
        password: hashedPassword,
        latitude: latitude ? +latitude : null,
        longitude: longitude ? +longitude : null,
        city: city || 'Karachi',
        certificateImage: `/uploads/${req.files.certificateImage[0].filename}`,
        licenseImage: `/uploads/${req.files.licenseImage[0].filename}`,
        agreementImages,
        status: 'pending',
      });

      res.status(201).json({
        message: 'Registration successful! Admin approval ke baad aap login kar sakenge.',
        clinicId: clinic._id,
      });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
});

router.patch('/settings', authClinic, async (req, res) => {
  try {
    const { isOpenToday, timings } = req.body;
    const clinic = await Clinic.findById(req.clinicId);
    if (!clinic) return res.status(404).json({ message: 'Clinic not found' });

    if (isOpenToday !== undefined) clinic.isOpenToday = isOpenToday;
    if (timings !== undefined) clinic.timings = timings;

    await clinic.save();
    res.json({ message: 'Settings update ho gayin', clinic });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
