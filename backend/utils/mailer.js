const nodemailer = require('nodemailer');

let transporter = null;

async function getTransporter() {
  if (transporter) return transporter;

  const user = process.env.SMTP_USER?.trim();
  const pass = process.env.SMTP_PASS?.trim();
  const placeholders = ['your-email@gmail.com', 'your-app-password', ''];

  if (!user || !pass || placeholders.includes(user) || placeholders.includes(pass)) {
    console.log('[Email] No SMTP credentials, creating Ethereal test account...');
    const testAccount = await nodemailer.createTestAccount();
    transporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: testAccount.user,
        pass: testAccount.pass,
      },
    });
    return transporter;
  }

  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: Number(process.env.SMTP_PORT) || 587,
    secure: false,
    auth: { user, pass },
  });
  return transporter;
}

async function sendEmail({ to, subject, html, text }) {
  const payload = { to, subject, text: text || html?.replace(/<[^>]+>/g, '') };

  const transport = await getTransporter();

  try {
    const info = await transport.sendMail({
      from: process.env.SMTP_FROM || process.env.SMTP_USER || '"Nazdeeqi Doctor" <noreply@nazdeeqi.pk>',
      to,
      subject,
      html,
      text,
    });
    if (info.messageId && transport.options.host === 'smtp.ethereal.email') {
      console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));
    }
    return info;
  } catch (err) {
    console.error('[Email failed]', err.message);
    return { mocked: true, error: err.message };
  }
}

async function sendClinicCredentials({ clinicName, contactEmail, contactPhone, loginEmail, loginPassword }) {
  const subject = 'Nazdeeqi — Aapki Clinic Approved! Login Details';
  const html = `
    <div style="font-family: sans-serif; max-width: 520px; margin: 0 auto;">
      <h2 style="color: #0F6E56;">Clinic Approved — ${clinicName}</h2>
      <p>Assalam o Alaikum,</p>
      <p>Aapki clinic admin ne approve kar di hai. Neeche login details hain:</p>
      <div style="background: #E1F5EE; padding: 16px; border-radius: 8px; margin: 16px 0;">
        <p><strong>Email:</strong> ${loginEmail}</p>
        <p><strong>Password:</strong> ${loginPassword}</p>
      </div>
      <p>In credentials se aap apni clinic manage kar sakte hain.</p>
      <p style="color: #666; font-size: 12px;">Nazdeeqi Doctor Team</p>
    </div>
  `;
  const text = `Clinic Approved - ${clinicName}\nEmail: ${loginEmail}\nPassword: ${loginPassword}`;

  await sendEmail({ to: contactEmail, subject, html, text });

  // SMS mock — integrate Twilio/Jazz API in production
  console.log(`[SMS Mock] To: ${contactPhone} | ${clinicName} approved. Login: ${loginEmail} / ${loginPassword}`);
}

async function sendRegistrationPending({ clinicName, contactEmail }) {
  const subject = 'Nazdeeqi — Clinic Registration Received';
  const html = `
    <div style="font-family: sans-serif;">
      <h2 style="color: #0F6E56;">Registration Received</h2>
      <p><strong>${clinicName}</strong> ki registration mil gayi hai.</p>
      <p>Admin review ke baad aapko email aur SMS par login details bheji jayengi.</p>
    </div>
  `;
  await sendEmail({
    to: contactEmail,
    subject,
    html,
    text: `${clinicName} registration received. Login details will be sent after admin approval.`,
  });
}

module.exports = { sendEmail, sendClinicCredentials, sendRegistrationPending };
