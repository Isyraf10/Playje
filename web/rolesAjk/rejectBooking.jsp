<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("ajk")) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String bookingId = request.getParameter("bookingId");
    String stationId = request.getParameter("stationId");
    if (bookingId == null) { response.sendRedirect("dashboardAjk.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Reject Booking - Playje</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">
</head>
<body style="display: block; padding-top: 80px;">
    <%@ include file="../header.jsp" %>
    
    <div class="container" style="max-width: 500px;">
        <div class="card">
            <h2 style="color: #ef4444; margin-bottom: 20px;">Reject Booking #<%= bookingId %></h2>
            
            <form action="../AjkServlet" method="POST">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                <input type="hidden" name="stationId" value="<%= stationId %>">
                
                <div class="input-group" style="margin-bottom: 25px;">
                    <label>Reason for Rejection:</label>
                    <input type="text" name="rejectReason" placeholder="e.g., Payment receipt is unclear or invalid" required style="width: 100%;">
                </div>
                
                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn-primary" style="background: #ef4444; flex: 2;">Confirm Reject</button>
                    <button type="button" onclick="location.href='dashboardAjk.jsp'" style="flex: 1; background: #444; color: white; border: none; padding: 15px; border-radius: 30px; cursor: pointer; font-weight: bold; font-size: 1.1rem;">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
