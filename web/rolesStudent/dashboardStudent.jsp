<%@page import="java.text.SimpleDateFormat"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User, com.lab.model.Booking, com.lab.dao.BookingDAO, com.lab.dao.NotificationDAO, java.util.List" %>
<%
    // 1. Session Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    NotificationDAO autoNotifDao = new NotificationDAO();
    BookingDAO bDao = new BookingDAO();

    // --- 1. AUTO-GENERATE NOTIFICATION ON SUCCESSFUL BOOKING ---
    String statusParam = request.getParameter("status");
    if ("pending".equals(statusParam)) {
        autoNotifDao.createNotification(
            currentUser.getUserId(), 
            "New booking request submitted successfully! Awaiting AJK approval."
        );
    }

    // --- 2. AUTOMATIC AJK APPROVAL/REJECT STATUS CHECKER ---
    List<Booking> currentBookings = null;
    try {
        currentBookings = bDao.getBookingsByStudent(currentUser.getUserId());
    } catch(Exception e) {
        System.out.println("DAO Method not compiled yet: " + e.getMessage());
    }

    List<String> existingNotifications = autoNotifDao.getLatestNotifications(currentUser.getUserId());
    
    if (currentBookings != null) {
        for (Booking b : currentBookings) {
            String bId = b.getBookingId();
            String status = b.getStatus() != null ? b.getStatus().toUpperCase() : "";
            
            if ("APPROVED".equals(status) || "REJECTED".equals(status)) {
                boolean alreadyNotified = false;
                for (String pastMsg : existingNotifications) {
                    if (pastMsg.contains(bId)) {
                        alreadyNotified = true;
                        break;
                    }
                }
                
                if (!alreadyNotified) {
                    String icon = "APPROVED".equals(status) ? "✓" : "X";
                    String stationLabel = bId;
                    try { stationLabel = b.getStationName(); } catch(Exception e) {
                        try { stationLabel = b.getStationId(); } catch(Exception ex) {}
                    }
                    
                    autoNotifDao.createNotification(
                        currentUser.getUserId(),
                        icon + " Your booking (" + bId + ") for " + stationLabel + " has been " + status + " by the AJK!"
                    );
                }
            }
        }
    }

    // 3. Fetch final booking history to render below
    List<Booking> myBookings = null;
    try {
        myBookings = bDao.getBookingsByStudent(currentUser.getUserId());
    } catch(Exception e) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - Playje</title>
    <link class="image_7fa386-png-ref" rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
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

        <% if ("db_fail".equals(request.getParameter("error"))) { %>
            <div class="alert" style="background: rgba(239, 68, 68, 0.2); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.4);">
                <strong>Database Error!</strong> Booking failed to save.
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
                    <% 
                        boolean hasRows = false;
                        SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");

                        // FIRST: Render active bookings from database (Pending / Approved)
                        if (myBookings != null && !myBookings.isEmpty()) { 
                            hasRows = true;
                            for(Booking b : myBookings) { 
                                String formattedDate = b.getBookingDate() != null ? sdf.format(b.getBookingDate()) : "N/A";
                                String currentStatus = b.getStatus() != null ? b.getStatus().toLowerCase() : "";
                                
                                String displayStation = "Gaming Station";
                                try { displayStation = b.getStationName(); } catch(Exception e) {
                                    try { displayStation = b.getStationId(); } catch(Exception ex) {}
                                }
                                
                                String displaySlot = "Standard Slot";
                                try { displaySlot = b.getSlotTime(); } catch(Exception e) {
                                    try { displaySlot = b.getSlotId(); } catch(Exception ex) {}
                                }
                        %>
                            <tr>
                                <td><strong><%= displayStation %></strong></td>
                                <td><%= displaySlot %></td>
                                <td><%= formattedDate %></td>
                                <td style="font-weight: bold; color: #fbbf24;">RM <%= String.format("%.2f", b.getTotalPrice()) %></td>
                                <td style="text-align: center; vertical-align: middle;">
                                    <span class="badge status-<%= currentStatus %>" style="padding: 5px 12px; border-radius: 4px; font-weight: bold; text-transform: uppercase;">
                                        <%= currentStatus %>
                                    </span>
                                </td>
                            </tr>
                        <% 
                            } 
                        } 

                        // SECOND: Reconstruct deleted rejected data from notification records 
                        if (existingNotifications != null && !existingNotifications.isEmpty()) {
                            for (String note : existingNotifications) {
                                if (note.contains("REJECTED") || note.contains("cancelled")) {
                                    hasRows = true;
                                    
                                    String rejectedStation = "Gaming Station";
                                    String rejectedSlot = "Cancelled Slot";
                                    String rejectedDate = "N/A";
                                    
                                    if (note.contains("for ")) {
                                        try {
                                            int startPos = note.indexOf("for ") + 4;
                                            int endPos = note.indexOf(" has");
                                            if (endPos > startPos) {
                                                rejectedStation = note.substring(startPos, endPos);
                                            }
                                        } catch(Exception e) {}
                                    }
                                    
                                    if (note.contains("[") && note.contains("]")) {
                                        try {
                                            int startTime = note.lastIndexOf("[") + 1;
                                            int endTime = note.lastIndexOf("]");
                                            if (endTime > startTime) {
                                                rejectedSlot = "Slot " + note.substring(startTime, endTime);
                                            }
                                        } catch(Exception e) {}
                                    }
                        %>
                            <tr>
                                <td><strong><%= rejectedStation %></strong></td>
                                <td style="color: #94a3b8; font-style: italic;"><%= rejectedSlot %></td>
                                <td style="color: #94a3b8;"><%= rejectedDate %></td>
                                <td style="font-weight: bold; color: #94a3b8; text-decoration: line-through;">RM 0.00</td>
                                <td style="text-align: center; vertical-align: middle;">
                                    <span class="badge status-rejected" style="background-color: #ef4444; color: white; padding: 5px 12px; border-radius: 4px; font-weight: bold; text-transform: uppercase;">
                                        rejected
                                    </span>
                                </td>
                            </tr>
                        <%
                                }
                            }
                        }

                        if (!hasRows) { 
                    %>
                        <tr>
                            <td colspan="5" style="text-align:center; padding: 40px; color: #999;">
                                Belum ada history booking. Jom main!
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>