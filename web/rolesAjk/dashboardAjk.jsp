<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User, com.lab.model.Booking, com.lab.model.Station, com.lab.model.StaffSchedule, com.lab.dao.BookingDAO, com.lab.dao.StationDAO, com.lab.dao.StaffScheduleDAO, java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>AJK Dashboard - Playje</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">
</head>
<body style="display: block;">

    <%@ include file="../header.jsp" %>

    <div class="container">
    
        <%-- 3) Create notification pending booking --%>
        <%
            BookingDAO bDao = new BookingDAO();
            List<Booking> pendingList = bDao.getAllPendingBookings();
            if (pendingList != null && !pendingList.isEmpty()) {
        %>
            <div class="alert text-link" style="background: rgba(245, 158, 11, 0.15); border: 1px solid #f59e0b; color: #f59e0b; margin-bottom: 20px; text-align: left; padding: 15px; border-radius: 10px;">
                🔔 <strong>Notification:</strong> There are currently <%= pendingList.size() %> pending bookings that require your validation.
            </div>
        <% } %>

        <div class="card welcome-box">
            <h2>Welcome AJK <%= currentUser.getUsername() %>!</h2>
            <div class="user-info">
                <p><strong>User ID:</strong> <%= currentUser.getUserId() %></p>
                <p><strong>Email:</strong> <%= currentUser.getEmail() %></p>
                <p><strong>Role:</strong> <%= currentUser.getRole() %></p>
            </div>
        </div>

        <%-- 2) Create dashboard to view ajk task schedule --%>
        <div class="card" style="margin-top: 20px;">
            <h3>My Task & Duty Schedule</h3>
            <table class="staff-table">
                <thead>
                    <tr>
                        <th>Schedule ID</th>
                        <th>Date</th>
                        <th>Duty Role</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    StaffScheduleDAO scheduleDao = new StaffScheduleDAO();
                    List<StaffSchedule> userSchedules = scheduleDao.getAllSchedules();
                    boolean hasSchedule = false;

                    if (userSchedules != null && !userSchedules.isEmpty()) {
                        for (StaffSchedule sch : userSchedules) {
                            // Match using getAjkId() from your model file
                            if (currentUser.getUserId().equals(sch.getAjkId())) {
                                hasSchedule = true;
                %>
                    <tr>
                        <td><%= sch.getScheduleId() %></td>
                        <td style="color: #fbbf24;"><%= sch.getShiftDate() %></td>
                        <td><%= sch.getDutyRole() %></td>
                        <td>
                            <span class="badge status-approved"><%= sch.getStatusText() %></span>
                        </td>
                    </tr>
                <%
                            }
                        }
                    }

                    if (!hasSchedule) {
                %>
                    <tr><td colspan="4" style="text-align:center; padding: 20px;">No duty schedules assigned.</td></tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>

        <div class="card" style="margin-top: 20px;">
            <h3>Pending Approvals</h3>
            <table class="staff-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Student</th>
                        <th>Station</th>
                        <th>Slot Time</th>
                        <th>Date</th>
                        <th>Price</th>
                        <th>Receipt</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
            <%
                if(pendingList == null || pendingList.isEmpty()) {
            %>
                <tr><td colspan="8" style="text-align:center; padding: 20px;">No pending bookings.</td></tr>
            <% } else { 
                SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy hh:mm a");
                for(Booking b : pendingList) { 
                    String formattedDate = sdf.format(b.getBookingDate());
            %>
                <tr>
                    <td><%= b.getBookingId() %></td>
                    <td><%= b.getStudentId() %></td>
                    <td><%= b.getStationName() %></td>
                    <td style="white-space: nowrap;"><%= b.getSlotTime() %></td> 
                    <td style="white-space: nowrap; color: #fbbf24; font-weight: 500;"><%= formattedDate %></td>
                    <td style="font-weight: bold;">RM <%= String.format("%.2f", b.getTotalPrice()) %></td> 
                    <td>
                        <a href="<%= request.getContextPath() %>/<%= b.getPaymentProofPath() %>" 
                           target="_blank" style="color: #60a5fa; text-decoration: underline;">View Receipt</a>
                    </td>
                    <td style="display: flex; gap: 5px;">
                        <form action="<%= request.getContextPath() %>/AjkServlet" method="POST">
                            <input type="hidden" name="action" value="approve">
                            <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                            <button type="submit" class="btn btn-save" style="background:#22c55e; cursor: pointer; border: none; padding: 6px 12px; border-radius: 4px; color: white; font-weight: bold;">Approve</button>
                        </form>
                        
                        <a href="rejectBooking.jsp?bookingId=<%= b.getBookingId() %>&stationId=<%= b.getStationId() %>" 
                           class="btn btn-delete" 
                           style="background:#ef4444; cursor: pointer; text-decoration: none; padding: 6px 12px; border-radius: 4px; color: white; font-weight: bold; font-size: 0.85rem; display: inline-block;">
                           Reject
                        </a>
                    </td>
                </tr>
            <% } } %>
        </tbody>
            </table>
        </div>

        <div class="card" style="margin-top: 20px;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                <h3>Gaming Station Management</h3>
                <div style="display: flex; gap: 10px;">
                    <button class="btn-primary" style="background: linear-gradient(45deg, #10b981, #059669); padding: 10px 20px; font-size: 0.95rem; border-radius: 20px;" onclick="location.href='monthlyDutyReport.jsp'">Generate Duty Report</button>
                    <button class="btn btn-primary" style="padding: 10px 20px; font-size: 0.95rem; border-radius: 20px;" onclick="location.href='addStation.jsp'">+ Add Station</button>
                </div>
            </div>
            <table class="staff-table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Type</th>
                        <th>Price/Hr</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    StationDAO sDao = new StationDAO();
                    List<Station> stations = sDao.getAllStations();
                    for(Station s : stations) {
                %>
                    <tr>
                        <td><strong><%= s.getStationName() %></strong></td>
                        <td><%= s.getStationType() %></td>
                        <td>RM <%= String.format("%.2f", s.getBasePricePerHour()) %></td>
                        <td>
                            <span class="badge status-<%= s.getStatus().toLowerCase() %>">
                                <%= s.getStatus().toUpperCase() %>
                            </span>
                        </td>
                        <td style="display: flex; gap: 8px; justify-content: center;">
                            <a href="editStation.jsp?id=<%= s.getStationId() %>" class="btn" style="background:#ffc107; padding:5px 12px; border-radius:4px; text-decoration:none; color:black; font-weight:bold; font-size:0.8rem;">Edit</a>
                            <form action="../StationServlet" method="POST" onsubmit="return confirm('Confirm delete station <%= s.getStationName() %>?')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="stationId" value="<%= s.getStationId() %>">
                                <button type="submit" style="background:#dc3545; padding:5px 12px; border-radius:4px; color:white; border:none; cursor:pointer; font-weight:bold; font-size:0.8rem;">Delete</button>
                            </form>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>