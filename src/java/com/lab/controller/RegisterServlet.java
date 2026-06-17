package com.lab.controller;

import com.lab.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // TASK 1 FIX: Force uppercase for Matric No and lowercase for Email
        String matricNo = request.getParameter("matricNo").toUpperCase();
        String username = request.getParameter("username");
        String email = request.getParameter("email").toLowerCase();
        String faculty = request.getParameter("faculty");
        String password = request.getParameter("password");
        
        // Auto-generate surrogate key for users table
        String generatedUserId = "STU-" + UUID.randomUUID().toString().substring(0, 5).toUpperCase();
        
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psProfile = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction
            
            // Insert into users
            String sqlUser = "INSERT INTO users (user_id, username, email, password, role) VALUES (?, ?, ?, ?, 'student')";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, generatedUserId);
            psUser.setString(2, username);
            psUser.setString(3, email); // Will now always save as lowercase
            psUser.setString(4, password);
            psUser.executeUpdate();
            
            // Insert into student_profile
            String sqlProfile = "INSERT INTO student_profile (student_id, matric_no, faculty, is_member) VALUES (?, ?, ?, 1)";
            psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setString(1, generatedUserId); 
            psProfile.setString(2, matricNo); // Will now always save as UPPERCASE       
            psProfile.setString(3, faculty);
            psProfile.executeUpdate();
            
            conn.commit();
            response.sendRedirect("login.jsp?msg=registered");
            
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            if (e.getErrorCode() == 1062) {
                response.sendRedirect("register.jsp?error=duplicate");
            } else {
                response.sendRedirect("register.jsp?error=1");
            }
        } finally {
            try {
                if (psUser != null) psUser.close();
                if (psProfile != null) psProfile.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}