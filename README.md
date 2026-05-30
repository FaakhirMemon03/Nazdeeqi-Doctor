# Nazdeeqi Doctor — Clinic Appointment System (MERN)

Apna Doctor, Apni Marzi — patients apne qareeb ki clinic se doctor choose karke appointment book karte hain. Clinics register karti hain aur admin approve karne ke baad login credentials email/SMS par bheje jate hain.

## Features

- **Landing page** — qareeb ki approved clinics (GPS location se sort)
- **Clinic page** — doctor select, time slot, appointment book (aapke HTML template jaisa UI)
- **Clinic registration** — naam, address, phone, email, certificate, license, agreement images
- **Admin approval** — approve hone par random login email/password generate + email/SMS (mock without SMTP)
- **Credentials tab tak nahi bhejte** jab tak admin approve na kare

## Tech Stack

- **Frontend:** React 18, Vite, React Router, Axios
- **Backend:** Node.js, Express, MongoDB, Mongoose, Multer, JWT, Nodemailer

## Setup

### Prerequisites

- Node.js 18+
- MongoDB running locally (`mongodb://127.0.0.1:27017`)

### Backend

```bash
cd backend
npm install
cp .env.example .env
# Edit .env — SMTP optional (without it emails log to console)
npm run seed    # Admin + sample clinics
npm run dev     # http://localhost:5000
```

**Default admin:** `admin@nazdeeqi.com` / `admin123`

### Frontend

```bash
cd frontend
npm install
npm run dev     # http://localhost:5173
```

## Routes

| URL | Description |
|-----|-------------|
| `/` | Landing — nearby clinics |
| `/clinic/:id` | Doctor + appointment booking |
| `/register-clinic` | Clinic registration form |
| `/admin/login` | Admin login |
| `/admin` | Approve/reject clinics |

## API Endpoints

- `GET /api/clinics/nearby?lat=&lng=` — approved clinics (distance sorted)
- `GET /api/clinics/:id` — clinic + doctors
- `POST /api/clinics/register` — multipart registration
- `POST /api/appointments` — book appointment
- `POST /api/admin/login` — admin JWT
- `PATCH /api/admin/clinics/:id/approve` — approve + send credentials
- `PATCH /api/admin/clinics/:id/reject` — reject clinic

## Email / SMS

Without SMTP config, credentials console par log hote hain (`[Email Mock]`, `[SMS Mock]`). Production ke liye `.env` mein Gmail App Password ya SendGrid set karein. SMS ke liye Twilio/Jazz API integrate karein `backend/utils/mailer.js` mein.

## Project Structure

```
Nazdeeqi-Doctor/
├── backend/
│   ├── models/       Clinic, Doctor, Appointment, Admin
│   ├── routes/       clinics, appointments, admin
│   ├── middleware/   auth, upload
│   ├── utils/        mailer, helpers
│   └── server.js
└── frontend/
    └── src/
        ├── pages/    Landing, Clinic, Register, Admin
        └── api.js
```
