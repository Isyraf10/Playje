<%-- 
    Document   : register
    Created on : May 14, 2026, 9:40:39 AM
    Author     : batrisyia aliza
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - UMT Gaming Lounge</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <div class="ambient-glow"></div>
    <div class="glass-card" style="max-width: 450px; margin: 40px auto;">
        
        <img src="<%= request.getContextPath() %>/images/logo.png" alt="Logo" class="brand-logo" onerror="this.src='<%= request.getContextPath() %>/images/logo.jpg'">
        
        <h2>Student Registration</h2>
        <p class="subtitle">Join the UMT Gaming Lounge</p>

        <% if ("duplicate".equals(request.getParameter("error"))) { %>
            <div class="error-alert">⚠️ Matric number or Email already exists!</div>
        <% } else if ("1".equals(request.getParameter("error"))) { %>
            <div class="error-alert">⚠️ Registration failed. Please try again later.</div>
        <% } %>

        <form action="<%= request.getContextPath() %>/RegisterServlet" method="POST">
            <div class="input-group">
                <label>MATRIC NUMBER</label>
                <input type="text" name="matricNo" required placeholder="e.g., S75516">
            </div>
            
            <div class="input-group">
                <label>FULL NAME</label>
                <input type="text" name="username" required placeholder="e.g., Ali Bin Abu">
            </div>
            
            <div class="input-group">
                <label>UMT EMAIL</label>
                <input type="email" name="email" required placeholder="s75516@ocean.umt.edu.my">
            </div>

            <div class="input-group">
                <label>FACULTY</label>
                <select name="faculty" required style="width: 100%; padding: 14px; background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 10px; color: #fff;">
                    <option value="" style="color: #000;">-- Select Faculty --</option>
                    <option value="Faculty of Computer Science and Mathematics" style="color: #000;">Faculty of Computer Science and Mathematics</option>
                    <option value="Faculty of Maritime Studies" style="color: #000;">Faculty of Maritime Studies</option>
                    <option value="Faculty of Science and Marine Environment" style="color: #000;">Faculty of Science and Marine Environment</option>
                    <option value="Other" style="color: #000;">Other</option>
                </select>
            </div>
            
            <div class="input-group">
                <label>PASSWORD</label>
                <input type="password" name="password" required placeholder="••••••••">
            </div>
            
            <button type="submit" class="btn-primary" style="margin-top: 20px;">CREATE ACCOUNT</button>
            
            <p class="auth-footer">
                Already have an account? <a href="login.jsp" class="text-link">Login here</a>
            </p>
        </form>
    </div>
</body>
</html>