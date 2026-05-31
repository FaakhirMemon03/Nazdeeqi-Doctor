const express = require('express');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const Clinic = require('../models/Clinic');
const { authUser } = require('../middleware/auth');
const User = require('../models/User');
const { sendEmail } = require('../utils/mailer');

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

    // 1. Send simulated SMS
    console.log(`\n========================================================================`);
    console.log(`[SMS Sent to ${patientPhone}]: "Nazdeeqi Doctors Slip: Aapki appointment confirm ho gayi hai. ID: ${appointment.bookingCode}, Doctor: ${doctor.name}, Waqt: ${timeSlot}, Clinic: ${clinic.name}"`);
    console.log(`========================================================================\n`);

    // 2. Send email to user
    if (user.email) {
      const emailHtml = `
        <div style="font-family: sans-serif; max-width: 520px; margin: 0 auto; border: 1px solid #0F6E56; border-radius: 12px; padding: 20px;">
          <h2 style="color: #0F6E56; text-align: center; margin-top: 0;">Nazdeeqi Doctors</h2>
          <h3 style="text-align: center; color: #333; margin-bottom: 20px;">Appointment Booking Confirmation</h3>
          <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 20px 0;"/>
          <p>Assalam-o-Alaikum <strong>${patientName}</strong>,</p>
          <p>Aapki appointment successfully book ho chuki hai. Details neeche darj hain:</p>
          <table style="width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 14px;">
            <tr>
              <td style="padding: 8px 0; color: #64748b; width: 40%;">Booking Code:</td>
              <td style="padding: 8px 0; font-weight: 700; font-family: monospace; font-size: 16px; color: #0F6E56; letter-spacing: 1px;">${appointment.bookingCode}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; color: #64748b;">Doctor Name:</td>
              <td style="padding: 8px 0; font-weight: 600; color: #1e293b;">${doctor.name}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; color: #64748b;">Specialty:</td>
              <td style="padding: 8px 0; color: #64748b;">${doctor.specialty}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; color: #64748b;">Clinic:</td>
              <td style="padding: 8px 0; font-weight: 600; color: #1e293b;">${clinic.name}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; color: #64748b;">Address:</td>
              <td style="padding: 8px 0; color: #1e293b;">${clinic.address}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; color: #64748b;">Time Slot:</td>
              <td style="padding: 8px 0; font-weight: 600; color: #0F6E56;">${timeSlot}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; color: #64748b;">Doctor Fee:</td>
              <td style="padding: 8px 0; font-weight: 600; color: #0F6E56;">Rs. ${doctor.fee}</td>
            </tr>
          </table>
          <div style="background: #E1F5EE; color: #085041; padding: 14px; border-radius: 8px; font-size: 13px; text-align: center; font-weight: 500;">
            Aap se guzarish hai ke clinic counter par Booking Code: <strong>${appointment.bookingCode}</strong> pesh karein.
          </div>
          <p style="font-size: 11px; color: #94a3b8; text-align: center; margin-top: 25px;">
            Thank you for choosing Nazdeeqi Doctors.
          </p>
        </div>
      `;
      
      // Send mail asynchronously
      sendEmail({
        to: user.email,
        subject: `Appointment Slip: ${appointment.bookingCode} - Nazdeeqi Doctors`,
        html: emailHtml,
      }).catch(err => console.error('[Appointment email error]:', err));
    }

    res.status(201).json({
      message: 'Appointment book ho gayi!',
      appointment: {
        id: appointment._id,
        bookingCode: appointment.bookingCode,
        patientName,
        doctorName: doctor.name,
        clinicName: clinic.name,
        clinicPhone: clinic.phone,
        timeSlot,
        patientPhone,
        complaint: complaint || '',
        appointmentDate: appointment.appointmentDate,
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
      .populate('user', 'name email phone')
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

// Admin: all appointments
const { authAdmin } = require('../middleware/auth');
router.get('/all', authAdmin, async (req, res) => {
  try {
    const appointments = await Appointment.find()
      .populate('clinic', 'name city')
      .populate('doctor', 'name specialty')
      .populate('user', 'name email phone')
      .sort({ createdAt: -1 });
    res.json({ appointments });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.patch('/:id/cancel', authUser, async (req, res) => {
  try {
    const appointment = await Appointment.findOne({ _id: req.params.id, user: req.userId });
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment nahi mili ya aapki nahi hai' });
    }
    if (appointment.status === 'cancelled') {
      return res.status(400).json({ message: 'Ye appointment pehle se cancel hai' });
    }
    appointment.status = 'cancelled';
    await appointment.save();
    res.json({ message: 'Appointment cancel kar di gayi' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
