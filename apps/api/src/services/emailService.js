import nodemailer from "nodemailer";

export function createEmailService(env) {
  const transporter = nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_SECURE,
    auth: {
      user: env.SMTP_USER,
      pass: env.SMTP_PASS
    }
  });

  async function sendPasswordResetEmail({ to, name, token, resetLink, expiresMinutes }) {
    const subject = "Восстановление пароля";
    const greeting = name ? `Здравствуйте, ${name}!` : "Здравствуйте!";
    const lines = [
      greeting,
      "",
      "Мы получили запрос на сброс пароля в DAMU APP.",
      `Код для сброса: ${token}`,
      `Срок действия кода: ${expiresMinutes} минут.`,
      resetLink ? `Ссылка для сброса: ${resetLink}` : null,
      "",
      "Если вы не запрашивали сброс, просто игнорируйте это письмо."
    ].filter((line) => line != null);
    const text = lines.join("\n");

    await transporter.sendMail({
      from: env.SMTP_FROM,
      to,
      subject,
      text
    });
  }

  return { sendPasswordResetEmail };
}
