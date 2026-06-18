package com.lab.controller;

import com.lab.dao.UserDAO;
import com.lab.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        UserDAO uDao = new UserDAO();

        try {
            if ("registerAjk".equals(action)) {
                String userId = request.getParameter("userId");
                String username = request.getParameter("username");
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String position = request.getParameter("position");

                // STEP 1: Check validation duplicate No Matrik atau Email dulu
                if (uDao.isUserExist(userId, email)) {
                    response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp?msg=duplicate");
                    return; 
                }

                // STEP 2: Check validation kuota tunggal untuk Majlis Tertinggi (MT)
                if (uDao.isMajlisTertinggiFull(position)) {
                    response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp?msg=quota_full");
                    return; 
                }

                // STEP 3: Proceed register kalau lepas tapisan
                User newUser = new User(userId, username, email, password, "ajk");
                newUser.setPosition(position);

                boolean success = uDao.registerAjkWithProfile(newUser);

                if (success) {
                    response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp?msg=success");
                } else {
                    response.sendRedirect("rolesAdvisor/addAjk.jsp?error=failed");
                }

            } else if ("updateAjk".equals(action)) {
                String userId = request.getParameter("userId");
                String username = request.getParameter("username");
                String email = request.getParameter("email");
                String position = request.getParameter("position");

                // ?GATEKEEPER UPDATE: Menghalang pertukaran jawatan jika kuota jawatan MT baru tersebut dah penuh
                if (uDao.isMajlisTertinggiFullOnUpdate(position, userId)) {
                    response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp?msg=quota_full");
                    return; // Disekat serta-merta
                }

                User updatedUser = new User();
                updatedUser.setUserId(userId);
                updatedUser.setUsername(username);
                updatedUser.setEmail(email);
                updatedUser.setPosition(position);

                boolean success = uDao.updateAjkWithProfile(updatedUser);

                if (success) {
                    response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp?msg=updated");
                } else {
                    response.sendRedirect("rolesAdvisor/editAjk.jsp?id=" + userId + "&error=failed");
                }

            } else if ("deleteAjk".equals(action)) {
                String userId = request.getParameter("userId");
                boolean success = uDao.deleteUser(userId);

                response.sendRedirect("rolesAdvisor/dashboardAdvisor.jsp?msg=deleted");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}