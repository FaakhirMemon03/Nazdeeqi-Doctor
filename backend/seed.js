require('dotenv').config();
const mongoose = require('mongoose');
const Admin = require('./models/Admin');
const Clinic = require('./models/Clinic');
const Doctor = require('./models/Doctor');
const { getInitials } = require('./utils/helpers');

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/nazdeeqi-doctor');

  const adminEmail = process.env.ADMIN_EMAIL || 'admin@nazdeeqi.com';
  const adminPass = process.env.ADMIN_PASSWORD || 'admin123';

  let admin = await Admin.findOne({ email: adminEmail });
  if (!admin) {
    admin = await Admin.create({ email: adminEmail, password: adminPass, name: 'Super Admin' });
    console.log('Admin created:', adminEmail, '/', adminPass);
  } else {
    console.log('Admin already exists');
  }

  const sampleClinics = [
    {
      name: 'City Care Hospital',
      address: 'Block 5, Clifton, Karachi',
      phone: '03001234567',
      email: 'citycare@example.com',
      latitude: 24.8138,
      longitude: 67.0299,
      city: 'Karachi',
      certificateImage: '/uploads/sample-cert.jpg',
      licenseImage: '/uploads/sample-license.jpg',
      agreementImages: [],
      status: 'approved',
      password: '$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // Dummy hash
    },
    {
      name: 'Green Valley Clinic',
      address: 'Main Boulevard, Gulberg, Lahore',
      phone: '03009876543',
      email: 'greenvalley@example.com',
      latitude: 31.5204,
      longitude: 74.3587,
      city: 'Lahore',
      certificateImage: '/uploads/sample-cert.jpg',
      licenseImage: '/uploads/sample-license.jpg',
      agreementImages: [],
      status: 'approved',
      password: '$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    },
    {
      name: 'Family Health Center',
      address: 'Satellite Town, Rawalpindi',
      phone: '03111222333',
      email: 'familyhealth@example.com',
      latitude: 33.5651,
      longitude: 73.0169,
      city: 'Rawalpindi',
      certificateImage: '/uploads/sample-cert.jpg',
      licenseImage: '/uploads/sample-license.jpg',
      agreementImages: [],
      status: 'approved',
      password: '$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    },
  ];

  for (const data of sampleClinics) {
    let clinic = await Clinic.findOne({ email: data.email });
    if (!clinic) {
      clinic = await Clinic.create(data);
      console.log('Clinic seeded:', clinic.name);

      const doctors = [
        { name: 'Dr. Sana Malik', specialty: 'General Physician', fee: 800, avatarColor: '#E1F5EE', textColor: '#0F6E56' },
        { name: 'Dr. Ahmed Raza', specialty: 'Cardiologist', fee: 1500, avatarColor: '#E6F1FB', textColor: '#185FA5' },
        { name: 'Dr. Nida Fatima', specialty: 'Dermatologist', fee: 1200, avatarColor: '#FBEAF0', textColor: '#993556' },
        { name: 'Dr. Bilal Khan', specialty: 'Pediatrician', fee: 1000, avatarColor: '#FAEEDA', textColor: '#854F0B' },
      ];

      await Doctor.insertMany(
        doctors.map((d) => ({
          ...d,
          clinic: clinic._id,
          initials: getInitials(d.name),
        }))
      );
    }
  }

  console.log('Seed complete');
  process.exit(0);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
