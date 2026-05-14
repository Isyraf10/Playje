<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - UMT Gaming Lounge</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <div class="glass-card auth-card">
        
        <!-- Prioritize PNG for transparency, fallback to JPG if it doesn't exist -->
        <img src="<%= request.getContextPath() %>/images/logo.png" alt="Logo" class="brand-logo" onerror="this.src='<%= request.getContextPath() %>/images/logo.jpg'">
        
        <h2>UMT Gaming Lounge</h2>
        <p class="subtitle">Login to book your station</p>

        <!-- Alerts Handling -->
        <% if ("1".equals(request.getParameter("error"))) { %>
            <div class="error-alert">⚠️ Invalid email or password. Please try again.</div>
        <% } else if ("registered".equals(request.getParameter("msg"))) { %>
            <div class="success-alert">✅ Registration successful! You may now login.</div>
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
            
            <button type="submit" class="btn-primary">ACCESS LOUNGE</button>
            
            <p class="auth-footer">
                Don't have an account? <a href="register.jsp" class="text-link">Register here</a>
            </p>
        </form>
    </div>
</body>
</html>