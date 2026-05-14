/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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

/**
 *
 * @author batrisyia aliza
 */

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String matricNo = request.getParameter("matricNo");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
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
            psUser.setString(3, email);
            psUser.setString(4, password);
            psUser.executeUpdate();
            
            // Insert into student_profile
            String sqlProfile = "INSERT INTO student_profile (student_id, matric_no, faculty, is_member) VALUES (?, ?, ?, 1)";
            psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setString(1, generatedUserId); 
            psProfile.setString(2, matricNo);        
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
