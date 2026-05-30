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
      enum: ['pending', 'approved', 'rejected', 'suspended'],
      default: 'pending',
    },
    password: { type: String, required: true },
    rejectionReason: { type: String, default: null },
    resetPasswordToken: { type: String, default: null },
    resetPasswordExpires: { type: Date, default: null },
  },
  { timestamps: true }
);

clinicSchema.methods.comparePassword = async function (candidatePassword) {
  const bcrypt = require('bcryptjs');
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('Clinic', clinicSchema);
