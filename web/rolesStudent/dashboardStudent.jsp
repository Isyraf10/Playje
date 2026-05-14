<%@page import="java.text.SimpleDateFormat"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User, com.lab.model.Booking, com.lab.dao.BookingDAO, java.util.List" %>
<%
    // 1. Session Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // 2. Fetch booking history
    BookingDAO bDao = new BookingDAO();
    List<Booking> myBookings = bDao.getBookingsByStudent(currentUser.getUserId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - Playje</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">
</head>
<body style="display: block; background-color: #1a1a2e; overflow-y: auto;"> 
    <%@ include file="../header.jsp" %>
    
    <div class="container" style="margin-top: 80px;">
        
        <div class="card" style="margin-bottom: 30px; text-align: left;">
            <h2 style="color: #fff;">Hello, <%= currentUser.getUsername() %>!</h2>
            <p class="subtitle" style="margin-bottom: 20px;">Ready for your next gaming session?</p>
            <button class="btn-primary" onclick="location.href='booking.jsp'" style="width: auto; padding: 12px 30px;">
                + BOOK NEW SESSION
            </button>
        </div>

        <% if ("pending".equals(request.getParameter("status"))) { %>
            <div class="alert" style="background: rgba(34, 197, 94, 0.2); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.4);">
                ✅ Booking submitted! Sila tunggu approval dari AJK Bertugas.
            </div>
        <% } else if ("db_fail".equals(request.getParameter("error"))) { %>
            <div class="alert" style="background: rgba(239, 68, 68, 0.2); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.4);">
                ⚠️ <strong>Database Error!</strong> Booking failed to save.
            </div>
        <% } else if ("system_crash".equals(request.getParameter("error"))) { %>
            <div class="alert" style="background: rgba(239, 68, 68, 0.2); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.4);">
                ⚠️ <strong>System Crash!</strong> Please upload a standard .JPG or .PNG file.
            </div>
        <% } %>

        <div class="card" style="text-align: left;">
            <h3 style="margin-bottom: 20px; color: #c77dff;">My Booking History</h3>
            
            <div style="overflow-x: auto;">
                <table class="staff-table">
                    <thead>
                        <tr>
                            <th>Station</th>
                            <th>Slot Time</th>
                            <th>Booking Date</th>
                            <th>Total Price</th>
                            <th style="text-align: center;">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if(myBookings == null || myBookings.isEmpty()) { %>
                        <tr>
                            <td colspan="5" style="text-align:center; padding: 40px; color: #999;">
                                Belum ada history booking. Jom main!
                            </td>
                        </tr>
                    <% } else { 
                        SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy hh:mm a");
                        for(Booking b : myBookings) { 
                            String formattedDate = sdf.format(b.getBookingDate());
                            String statusClass = b.getStatus().toLowerCase();
                    %>
                        <tr>
                            <td><strong><%= b.getStationName() %></strong></td>
                            <td><%= b.getSlotTime() %></td>
                            <td><%= formattedDate %></td>
                            <td style="font-weight: bold; color: #fbbf24;">RM <%= String.format("%.2f", b.getTotalPrice()) %></td>
                            <td style="text-align: center;">
                                <span class="badge status-<%= statusClass %>">
                                    <%= b.getStatus() %>
                                </span>
                            </td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>