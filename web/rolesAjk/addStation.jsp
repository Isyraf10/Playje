<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equalsIgnoreCase("ajk")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Station - Playje</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">
</head>
<body style="display: block; padding-top: 80px; background-color: #1a1625; color: #fff; font-family: 'Segoe UI', sans-serif;">
    
    <%@ include file="../header.jsp" %>
    
    <div class="container" style="max-width: 600px; margin: 40px auto; padding: 0 20px;">
        <div class="card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); padding: 35px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);">
            
            <h2 style="color: #c77dff; margin-bottom: 25px; font-weight: 700; letter-spacing: 0.5px;">Register New Gaming Station</h2>
            
            <form action="../StationServlet" method="POST">
                <input type="hidden" name="action" value="add">
                
                <div style="margin-bottom: 20px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Station ID (e.g., PS004):</label>
                    <input type="text" name="stationId" placeholder="Enter unique ID" required 
                           style="width: 100%; padding: 12px; background: rgba(0,0,0,0.25); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff; box-sizing: border-box;">
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Station Name:</label>
                    <input type="text" name="stationName" placeholder="e.g., PS5 Station 4" required 
                           style="width: 100%; padding: 12px; background: rgba(0,0,0,0.25); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff; box-sizing: border-box;">
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Pricing Category:</label>
                    <select name="pricingId" required style="width: 100%; padding: 12px; background: #242038; border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff; box-sizing: border-box; cursor: pointer;">
                        <option value="" style="background: #242038;">-- Select Pricing Category --</option>
                        <option value="P001" style="background: #242038;">P001 - PS5 Standard (RM 5.00)</option>
                        <option value="P002" style="background: #242038;">P002 - Simulator Pro (RM 8.00)</option>
                        <option value="P003" style="background: #242038;">P003 - PC Gaming (RM 6.00)</option>
                    </select>
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Specifications:</label>
                    <textarea name="specifications" placeholder="e.g., Sony PS5 + 2 DualSense Controllers" required 
                              style="width: 100%; height: 90px; padding: 12px; background: rgba(0,0,0,0.25); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff; resize: none; box-sizing: border-box;"></textarea>
                </div>

                <div style="margin-bottom: 30px;">
                    <label style="display: block; color: #adb5bd; margin-bottom: 8px; font-size: 0.9rem;">Initial Status:</label>
                    <select name="status" style="width: 100%; padding: 12px; background: #242038; border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: #fff; box-sizing: border-box; cursor: pointer;">
                        <option value="available" style="background: #242038;">Available</option>
                        <option value="maintenance" style="background: #242038;">Maintenance</option>
                    </select>
                </div>

                <div style="display: flex; gap: 12px;">
                    <button type="submit" style="flex: 2; background: #c77dff; color: #1a1625; border: none; padding: 14px; border-radius: 6px; font-weight: bold; cursor: pointer; transition: background 0.2s; box-shadow: 0 0 10px rgba(199, 125, 255, 0.2);">Save Station</button>
                    <button type="button" onclick="location.href='dashboardAjk.jsp'" style="flex: 1; background: #343a40; color: #fff; border: 1px solid rgba(255,255,255,0.1); padding: 14px; border-radius: 6px; font-weight: bold; cursor: pointer;">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>