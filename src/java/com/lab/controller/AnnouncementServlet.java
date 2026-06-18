package com.lab.controller;

import com.lab.dao.AnnouncementDAO;
import com.lab.dao.UserDAO;
import com.lab.util.EmailUtil;
import com.lab.model.User;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AnnouncementServlet")
public class AnnouncementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private AnnouncementDAO announcementDAO = new AnnouncementDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Dapatkan Session dan pastikan Advisor yang tengah access
        HttpSession session = request.getSession();
        User currentAdvisor = (User) session.getAttribute("currentUser"); // Adjust ikot nama attribute session kau
        
        if (currentAdvisor == null || !"advisor".equalsIgnoreCase(currentAdvisor.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Tangkap data input dari Form JSP
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String audience = request.getParameter("audience"); // Nilai: 'student', 'ajk', atau 'everybody'
        
        String advisorId = currentAdvisor.getUserId();

        // 3. Simpan ke dalam Database (Log Sejarah Announcement)
        boolean isSaved = announcementDAO.createAnnouncement(advisorId, title, content, audience);

        if (isSaved) {
            // 4. Tarik list email target berdasarkan audience yang dipilih
            List<String> recipients = userDAO.getEmailsByAudience(audience);
            
            // Format rupa email (Guna HTML sikit biar nampak pro)
            String emailSubject = "[Playje UMT] " + title;
            // Format rupa email Rasmi & Formal (HTML + CSS)
            // Format rupa email Rasmi & Formal (Versi Flat & Clean untuk Mobile-Friendly)
            String emailBody = "<div style=\"font-family: 'Segoe UI', Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; background-color: #ffffff;\">"
                 + "  "
                 + "  <div style=\"background-color: #1e1e38; padding: 25px 20px; text-align: center; color: #ffffff;\">"
                 + "    <h1 style=\"margin: 0; font-size: 22px; font-weight: 600; letter-spacing: 1px;\">PLAYJE GAMING ROOM</h1>"
                 + "    <p style=\"margin: 5px 0 0 0; opacity: 0.8; font-size: 13px;\">Universiti Malaysia Terengganu</p>"
                 + "  </div>"
                 + "  "
                 + "  "
                 + "  <div style=\"padding: 30px 25px; color: #333333; line-height: 1.6;\">"
                 + "    "
                 + "    <h2 style=\"color: #1e1e38; margin-top: 0; font-size: 18px; border-bottom: 2px solid #f0f0f8; padding-bottom: 10px;\">" 
                 + title + "</h2>"
                 + "    "
                 + "    <p style=\"font-size: 15px; margin-bottom: 15px;\">Assalamualaikum dan Salam Sejahtera,</p>"
                 + "    "
                 + "    "
                 + "    <div style=\"font-size: 14px; color: #333333; margin: 15px 0 25px 0;\">"
                 +        content.replaceAll("\n", "<br>")
                 + "    </div>"
                 + "    "
                 + "    <p style=\"font-size: 14px;\">Harap maklum, terima kasih.</p>"
                 + "    "
                 + "    "
                 + "    <div style=\"margin-top: 30px; padding-top: 15px; border-top: 1px solid #eeeeee; font-size: 13px; color: #666666;\">"
                 + "      <strong>Yang menjalankan amanah,</strong><br>"
                 +        currentAdvisor.getUsername() + "<br>"
                 + "      <span>System Advisor, Playje Management Committee</span>"
                 + "    </div>"
                 + "  </div>"
                 + "  "
                 + "  "
                 + "  <div style=\"background-color: #f9f9f9; padding: 15px; text-align: center; font-size: 12px; color: #999999; border-top: 1px solid #eeeeee;\">"
                 + "    <p style=\"margin: 0;\">This is an automated system-generated email. Please do not reply to this message.</p>"
                 + "    <p style=\"margin: 5px 0 0 0;\">&copy; 2026 Playje UMT. All Rights Reserved.</p>"
                 + "  </div>"
                 + "</div>";

            // 5. Blast Email menggunakan EmailUtil (Asynchronous/Looping)
            // Kita run dalam Thread baru supaya UI tak "freezing" lama masa hantar email yang banyak
            new Thread(() -> {
                for (String email : recipients) {
                    EmailUtil.sendEmail(email, emailSubject, emailBody);
                }
            }).start();

            // Set success message dan hantar balik ke dashboard
            session.setAttribute("successMessage", "Announcement successfully published and emailed!");
            response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp"); // Adjust ikot path jsp kau
            
        } else {
            session.setAttribute("errorMessage", "Failed to save announcement to database.");
            response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp");
        }
    }
}