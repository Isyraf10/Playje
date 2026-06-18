package com.lab.util;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtil {

    // Gantikan dengan email official/personal kau & 16-letter App Password tadi
    private static final String SMTP_USERNAME = "playje.service@gmail.com"; 
    private static final String SMTP_PASSWORD = "ulxlpcfvsaklgcna"; // App Password tanpa spacing pun tak apa

    public static boolean sendEmail(String toEmail, String subject, String bodyContent) {
        // 1. Set SMTP server properties untuk Google Gmail
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587"); // Port untuk TLS
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true"); // Wajib enable TLS untuk security Google

        // 2. Create session dengan authentication (Log masuk)
        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
            }
        });

        try {
            // 3. Create standard MimeMessage object
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_USERNAME, "Esport UMT Announcement"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            
            // Menggunakan setText(content, "UTF-8", "html") supaya kau boleh letak tag HTML (bold, br, dsb) dalam email
            message.setDataHandler(new javax.activation.DataHandler(
                new javax.mail.util.ByteArrayDataSource(bodyContent, "text/html; charset=utf-8")
            ));

            // 4. Fire! Kirim email
            Transport.send(message);
            System.out.println("Email successfully sent to: " + toEmail);
            return true;

        } catch (Exception e) {
            System.err.println("Error sending email to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}