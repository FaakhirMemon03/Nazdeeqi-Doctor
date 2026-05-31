const express = require('express');
const jwt = require('jsonwebtoken');
const Admin = require('../models/Admin');
const Clinic = require('../models/Clinic');
const Doctor = require('../models/Doctor');
const { authAdmin } = require('../middleware/auth');
const { generatePassword, generateClinicLoginEmail, getInitials } = require('../utils/helpers');
const { sendClinicCredentials } = require('../utils/mailer');

const User = require('../models/User');

const router = express.Router();

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

router.patch('/clinics/:id/suspend', authAdmin, async (req, res) => {
  try {
    const clinic = await Clinic.findById(req.params.id);
    if (!clinic) return res.status(404).json({ message: 'Clinic not found' });

    clinic.status = 'suspended';
    await clinic.save();

    res.json({ message: 'Clinic suspend kar di gayi hai' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/users', authAdmin, async (req, res) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 });
    res.json({ users });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.patch('/users/:id/ban', authAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    user.status = 'banned';
    await user.save();
    res.json({ message: 'User ko ban kar diya gaya hai' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.patch('/users/:id/unban', authAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    user.status = 'active';
    await user.save();
    res.json({ message: 'User unban ho gaya hai' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
