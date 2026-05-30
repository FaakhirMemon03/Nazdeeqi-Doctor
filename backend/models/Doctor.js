const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema(
  {
    clinic: { type: mongoose.Schema.Types.ObjectId, ref: 'Clinic', required: true },
    name: { type: String, required: true },
    specialty: { type: String, required: true },
    fee: { type: Number, required: true },
    avatarColor: { type: String, default: '#E1F5EE' },
    textColor: { type: String, default: '#0F6E56' },
    initials: { type: String, required: true },
    availableSlots: {
      type: [String],
      default: ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '5:00 PM'],
    },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Doctor', doctorSchema);
