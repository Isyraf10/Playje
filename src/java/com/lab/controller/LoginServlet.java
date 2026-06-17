package com.lab.controller;

import com.lab.dao.UserDAO;
import com.lab.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // TASK 1 FIX: Force lowercase for Email to prevent case-sensitive login errors
        String email = request.getParameter("email").toLowerCase();
        String password = request.getParameter("password");

        User user = userDAO.authenticateUser(email, password);

        if (user != null) {

            HttpSession session = request.getSession();
            session.setAttribute("currentUser", user);

            String role = user.getRole();

            if ("student".equals(role)) {
                response.sendRedirect("rolesStudent/dashboardStudent.jsp");

            } else if ("ajk".equals(role)) {
                response.sendRedirect("rolesAjk/dashboardAjk.jsp");

            } else if ("advisor".equals(role)) {
                response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp");

            } else {
                response.sendRedirect("login.jsp?error=1");
            }

        } else {
            response.sendRedirect("login.jsp?error=1");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    
        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            // 1. Buang session data
            request.getSession().invalidate();
            
            // 2. Redirect balik ke login page
            // Pastikan path login.jsp betul (kalau Servlet kat root, guna "login.jsp")
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Kalau orang saja-saja masuk URL tanpa action=logout, hantar ke login juga
        response.sendRedirect("login.jsp");
    }
}