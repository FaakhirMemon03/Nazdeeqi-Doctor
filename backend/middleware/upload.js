const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    cb(null, `${unique}${path.extname(file.originalname)}`);
  },
});

const IMAGE_EXT =
  /\.(jpe?g|png|gif|webp|bmp|svg|ico|tiff?|heic|heif|avif|jfif|raw|cr2|nef|dng)$/i;

function isAllowedFile(file) {
  const ext = path.extname(file.originalname).toLowerCase();
  const mime = (file.mimetype || '').toLowerCase();

  if (mime.startsWith('image/')) return true;
  if (mime === 'application/pdf' || ext === '.pdf') return true;
  if (IMAGE_EXT.test(ext)) return true;
  // Phone/camera kabhi generic mime bhejte hain
  if (mime === 'application/octet-stream' && ext) return true;

  return false;
}

const fileFilter = (_req, file, cb) => {
  if (isAllowedFile(file)) return cb(null, true);
  cb(new Error('Sirf image files (jpg, png, gif, heic, webp, ...) ya PDF upload karein'));
};

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter,
});

module.exports = upload;
