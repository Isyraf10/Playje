<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User" %>
<%@ page import="com.lab.model.Station" %>
<%@ page import="com.lab.dao.StationDAO" %>
<%
    // 1. Core Module Security Verification
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equalsIgnoreCase("ajk")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // 2. Fetch target station data via ID
    String stationId = request.getParameter("id");
    StationDAO dao = new StationDAO();
    Station station = null;
    
    if (stationId != null && !stationId.trim().isEmpty()) {
        station = dao.getStationById(stationId);
    }
    
    // Fallback redirect if station cannot be fetched or found
    if (station == null) {
        response.sendRedirect("dashboardAjk.jsp?error=not_found");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Station - Playje</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">
</head>
<body style="display: block; padding-top: 80px; background-color: #1a1625; color: #fff; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
    
    <%-- Global navigation dynamic import header --%>
    <%@ include file="../header.jsp" %>
    
    <div class="container" style="max-width: 600px; margin: 40px auto; padding: 0 20px;">
        <div class="card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); padding: 30px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1);">
            
            <h2 style="color: #c77dff; margin-bottom: 25px; font-weight: 700;">Edit Station: <%= station.getStationId() %></h2>
            
            <form action="../StationServlet" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="stationId" value="<%= station.getStationId() %>">
                
                <div style="margin-bottom: 20px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Station Name:</label>
                    <input type="text" name="stationName" value="<%= station.getStationName() %>" required 
                           class="input-field" style="width: 100%; padding: 10px; background: rgba(0,0,0,0.2); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff;">
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Pricing Category (Pricing ID):</label>
                    <select name="pricingId" required class="input-field" style="width: 100%; padding: 10px; background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff;">
                        <option value="P001" <%= "P001".equals(station.getPricingId()) ? "selected" : "" %>>P001 - PS5 Standard</option>
                        <option value="P002" <%= "P002".equals(station.getPricingId()) ? "selected" : "" %>>P002 - Simulator Pro</option>
                        <option value="P003" <%= "P003".equals(station.getPricingId()) ? "selected" : "" %>>P003 - PC Gaming</option>
                    </select>
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Specifications:</label>
                    <textarea name="specifications" required class="input-field" style="width: 100%; height: 90px; padding: 10px; background: rgba(0,0,0,0.2); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff; resize: vertical;"><%= station.getSpecifications() %></textarea>
                </div>

                <div style="margin-bottom: 30px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Current Status:</label>
                    <select name="status" class="input-field" style="width: 100%; padding: 10px; background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff;">
                        <option value="available" <%= "available".equalsIgnoreCase(station.getStatus()) ? "selected" : "" %>>Available</option>
                        <option value="occupied" <%= "occupied".equalsIgnoreCase(station.getStatus()) ? "selected" : "" %>>Occupied</option>
                        <option value="maintenance" <%= "maintenance".equalsIgnoreCase(station.getStatus()) ? "selected" : "" %>>Maintenance</option>
                    </select>
                </div>

                <div style="display: flex; gap: 12px;">
                    <button type="submit" class="btn-primary" style="flex: 2; background: #c77dff; color: #1a1625; border: none; padding: 12px; border-radius: 6px; font-weight: bold; cursor: pointer; transition: background 0.2s;">Update Station</button>
                    <button type="button" onclick="location.href='dashboardAjk.jsp'" class="btn-secondary" style="flex: 1; background: #343a40; color: #fff; border: 1px solid rgba(255,255,255,0.1); padding: 12px; border-radius: 6px; font-weight: bold; cursor: pointer;">Cancel</button>
                </div>
            </form>
            
        </div>
    </div>
</body>
</html>