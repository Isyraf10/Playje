<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Academic Advisor System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <div class="glass-card auth-card">

        <img src="images/logo.jpg" alt="Logo" class="brand-logo">
        
        <h2></h2>
        <p class="subtitle">Login</p>

        <% if ("1".equals(request.getParameter("error"))) { %>
            <div class="error-alert">Invalid email or password. Please try again.</div>
        <% } else if ("registered".equals(request.getParameter("msg"))) { %>
            <div class="success-alert">Registration successful! You may now login.</div>
        <% } %>

        <form action="<%= request.getContextPath() %>/LoginServlet" method="POST">
            
            <div class="input-group">
                <label>EMAIL ADDRESS</label>
                <input type="email" name="email" required placeholder="s12345@ocean.umt.edu.my">
            </div>
            
            <div class="input-group">
                <label>PASSWORD</label>
                <input type="password" name="password" required placeholder="••••••••">
            </div>
            
            <button type="submit" class="btn-primary">Login</button>
            
            <p class="auth-footer">
                Don't have an account? <a href="register.jsp" class="text-link">Register here</a>
            </p>
        </form>
    </div>
</body>
</html>