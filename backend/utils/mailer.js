const nodemailer = require('nodemailer');

let transporter = null;

async function getTransporter() {
  if (transporter) return transporter;

  const user = process.env.SMTP_USER?.trim();
  const pass = process.env.SMTP_PASS?.trim();
  const placeholders = ['info.skillswapp@gmail.com', 'jhst cayc stmb bogu', '587'];

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

async function sendPasswordResetEmail(to, resetUrl) {
  const subject = 'Nazdeeqi — Password Reset Link';
  const html = `
    <div style="font-family: sans-serif; max-width: 520px; margin: 0 auto;">
      <h2 style="color: #0F6E56;">Password Reset</h2>
      <p>Aapne password reset ki request ki hai. Naye password set karne ke liye neeche diye gaye link par click karein:</p>
      <div style="margin: 20px 0;">
        <a href="${resetUrl}" style="background: #0F6E56; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a>
      </div>
      <p style="font-size: 12px; color: #666;">Ye link 10 minute mein expire ho jayega. Agar aapne request nahi ki thi, toh is email ko ignore karein.</p>
    </div>
  `;
  const text = `Password reset link: ${resetUrl}`;
  await sendEmail({ to, subject, html, text });
}

module.exports = { sendEmail, sendPasswordResetEmail };

