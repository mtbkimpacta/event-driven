const nodemailer = require('nodemailer');

exports.handler = async (event, context, callback) => {
  try {
    // Create a Nodemailer transporter using SMTP
    const transporter = nodemailer.createTransport({
      host: 'smtp.mailtrap.io',
      port: 2525,
      auth: {
        user: '161200c3a8d279',
        pass: '1588b7f74ba007',
      },
    });

    // Define the email options
    const mailOptions = {
      from: 'Sender <remetente@teste.com>',
      to: 'Receiver <destinatario@teste.com>',
      subject: 'Event Driven Test e-mail',
      text: 'This is a test email from AWS Lambda that was trigged by AWS EventBridge',
    };

    // Send the email
    await transporter.sendMail(mailOptions);

    callback(null, 'Email sent successfully');
  } catch (error) {
    callback(error);
  }
};
