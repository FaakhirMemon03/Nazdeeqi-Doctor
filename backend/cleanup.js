const mongoose = require('mongoose');
require('dotenv').config();
const Clinic = require('./models/Clinic');
const User = require('./models/User');
const Appointment = require('./models/Appointment');
const Doctor = require('./models/Doctor');

mongoose.connect(process.env.MONGODB_URI).then(async () => {
  console.log('Connected to MongoDB');
  
  const memonClinic = await Clinic.findOne({ name: { $regex: /memon/i } });
  const aliUser = await User.findOne({ name: { $regex: /ali/i } });

  console.log('Memon Clinic:', memonClinic ? memonClinic.name : 'Not Found');
  console.log('Ali User:', aliUser ? aliUser.name : 'Not Found');

  // Keep ids
  const keepClinicId = memonClinic ? memonClinic._id : null;
  const keepUserId = aliUser ? aliUser._id : null;

  // Delete Clinics
  const clinicQuery = keepClinicId ? { _id: { $ne: keepClinicId } } : {};
  const delClinics = await Clinic.deleteMany(clinicQuery);
  console.log('Deleted Clinics:', delClinics.deletedCount);

  // Delete Users
  const userQuery = keepUserId ? { _id: { $ne: keepUserId } } : {};
  const delUsers = await User.deleteMany(userQuery);
  console.log('Deleted Users:', delUsers.deletedCount);

  // Clear all appointments and doctors that do not belong to the kept clinic/user
  const docQuery = keepClinicId ? { clinic: { $ne: keepClinicId } } : {};
  const delDocs = await Doctor.deleteMany(docQuery);
  console.log('Deleted Doctors:', delDocs.deletedCount);

  const apptQuery = { $or: [] };
  if (keepClinicId) apptQuery.$or.push({ clinic: { $ne: keepClinicId } });
  if (keepUserId) apptQuery.$or.push({ user: { $ne: keepUserId } });
  
  if (apptQuery.$or.length > 0) {
    const delAppts = await Appointment.deleteMany(apptQuery);
    console.log('Deleted Appointments:', delAppts.deletedCount);
  } else {
    const delAppts = await Appointment.deleteMany({});
    console.log('Deleted Appointments:', delAppts.deletedCount);
  }

  process.exit();
}).catch(console.error);
