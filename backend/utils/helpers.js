const crypto = require('crypto');

function generatePassword(length = 10) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789@#';
  let password = '';
  const bytes = crypto.randomBytes(length);
  for (let i = 0; i < length; i++) {
    password += chars[bytes[i] % chars.length];
  }
  return password;
}

function generateClinicLoginEmail(clinicName) {
  const slug = clinicName
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '')
    .slice(0, 12);
  const suffix = crypto.randomBytes(3).toString('hex');
  return `${slug || 'clinic'}_${suffix}@nazdeeqi.pk`;
}

function getInitials(name) {
  return name
    .replace(/^Dr\.?\s*/i, '')
    .split(/\s+/)
    .map((w) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
}

function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

module.exports = { generatePassword, generateClinicLoginEmail, getInitials, haversineDistance };
