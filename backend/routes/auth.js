const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const Admin = require('../models/Admin');
const Clinic = require('../models/Clinic');
const User = require('../models/User');
const { sendPasswordResetEmail } = require('../utils/mailer');

const router = express.Router();

router.post('/register', async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    if (!name || !email || !phone || !password) {
      return res.status(400).json({ message: 'Sab fields bharna zaroori hain' });
    }

    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: 'Is email se pehle se account hai' });
    }

    const user = await User.create({ name, email: email.toLowerCase(), phone, password });
    const token = jwt.sign({ id: user._id, role: 'user' }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({
      token,
      role: 'user',
      user: { id: user._id, name: user.name, email: user.email },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const lowerEmail = email?.toLowerCase();

    // Check Admin
    const admin = await Admin.findOne({ email: lowerEmail });
    if (admin && (await admin.comparePassword(password))) {
      const token = jwt.sign({ id: admin._id, role: 'admin' }, process.env.JWT_SECRET, { expiresIn: '7d' });
      return res.json({ token, role: 'admin', admin: { id: admin._id, email: admin.email, name: admin.name } });
    }

    // Check Clinic
    const clinic = await Clinic.findOne({ email: lowerEmail });
    if (clinic && (await clinic.comparePassword(password))) {
      if (clinic.status === 'suspended') {
        return res.status(403).json({ message: 'Aapki clinic suspended hai. Admin se rabta karein.' });
      }
      if (clinic.status !== 'approved') {
        return res.status(403).json({ message: 'Aapki clinic abhi admin ne approve nahi ki hai.' });
      }
      const token = jwt.sign({ id: clinic._id, role: 'clinic' }, process.env.JWT_SECRET, { expiresIn: '7d' });
      return res.json({ token, role: 'clinic', clinic: { id: clinic._id, name: clinic.name, email: clinic.email } });
    }

    // Check User
    const user = await User.findOne({ email: lowerEmail });
    if (user && (await user.comparePassword(password))) {
      if (user.status === 'banned') {
        return res.status(403).json({ message: 'Aapka account ban ho chuka hai.' });
      }
      const token = jwt.sign({ id: user._id, role: 'user' }, process.env.JWT_SECRET, { expiresIn: '7d' });
      return res.json({ token, role: 'user', user: { id: user._id, name: user.name, email: user.email } });
    }

    return res.status(401).json({ message: 'Galat email ya password' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    const lowerEmail = email?.toLowerCase();

    const user = (await User.findOne({ email: lowerEmail })) ||
                 (await Clinic.findOne({ email: lowerEmail })) ||
                 (await Admin.findOne({ email: lowerEmail }));

    if (!user) {
      // Return 200 anyway for security (so we don't leak registered emails)
      return res.json({ message: 'Agar ye email registered hai toh humne password reset link bhej diya hai.' });
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    user.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
    user.resetPasswordExpires = Date.now() + 10 * 60 * 1000; // 10 minutes

    await user.save();

    const clientUrl = process.env.CLIENT_URL || 'http://localhost:5173';
    const resetUrl = `${clientUrl}/reset-password/${resetToken}`;

    await sendPasswordResetEmail(user.email, resetUrl);

    res.json({ message: 'Agar ye email registered hai toh humne password reset link bhej diya hai.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/reset-password/:token', async (req, res) => {
  try {
    const resetPasswordToken = crypto.createHash('sha256').update(req.params.token).digest('hex');

    const user = (await User.findOne({ resetPasswordToken, resetPasswordExpires: { $gt: Date.now() } })) ||
                 (await Clinic.findOne({ resetPasswordToken, resetPasswordExpires: { $gt: Date.now() } })) ||
                 (await Admin.findOne({ resetPasswordToken, resetPasswordExpires: { $gt: Date.now() } }));

    if (!user) {
      return res.status(400).json({ message: 'Token invalid ya expire ho chuka hai' });
    }

    user.password = req.body.password; // bcrypt pre-save hook handles hashing for User/Admin, wait! Clinic doesn't have a pre-save hook!
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;

    // Fix for Clinic password which was hashed manually in register route
    if (user.collection.collectionName === 'clinics') {
       const bcrypt = require('bcryptjs');
       user.password = await bcrypt.hash(req.body.password, 10);
    }
    
    await user.save();
    res.json({ message: 'Password reset successful! Ab login karein.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
