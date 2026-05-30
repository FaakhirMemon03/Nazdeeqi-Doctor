const mongoose = require('mongoose');

const clinicSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    address: { type: String, required: true },
    phone: { type: String, required: true },
    email: { type: String, required: true, lowercase: true, trim: true },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    city: { type: String, default: 'Karachi' },
    certificateImage: { type: String, required: true },
    licenseImage: { type: String, required: true },
    agreementImages: [{ type: String }],
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending',
    },
    loginEmail: { type: String, default: null },
    loginPassword: { type: String, default: null },
    credentialsSent: { type: Boolean, default: false },
    rejectionReason: { type: String, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Clinic', clinicSchema);
