<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User, com.lab.model.StaffSchedule, com.lab.dao.StaffScheduleDAO, com.lab.dao.UserDAO, com.lab.dao.StationDAO, java.util.List, java.util.Map" %>
<%
    // 1. Session Validation
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("advisor")) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // 2. Data Retrieval
    StaffScheduleDAO staffDAO = new StaffScheduleDAO();
    UserDAO userDAO = new UserDAO();
    StationDAO stationDAO = new StationDAO();
    
    List<StaffSchedule> schedules = staffDAO.getAllSchedules();
    Map<String, String> ajkStaffList = staffDAO.getAllAJKStaff();
    List<User> fullAjkList = userDAO.getUsersByRole("ajk"); // Ikut susunan strict SQL CASE WHEN terbaru kau
    
    // Stats
    int totalUsers = userDAO.getTotalUserCount(); 
    int availableStations = stationDAO.getAvailableStationCount();
    
    // Alert Messages for Announcement Status & Validations
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
    
    // Tangkap query msg daripada UserServlet filter gatekeeper
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Advisor Dashboard - Playje</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css?v=1.4">
    <style>
        /* Fix Header and Container Spacing */
        body { padding-top: 80px; } 
        .header-fixed { position: fixed; top: 0; width: 100%; z-index: 1000; background: #1a1a2e; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); padding: 25px; border-radius: 12px; }
        .stat-card h3 { font-size: 2rem; color: #c77dff; margin-top: 10px; }
        .crud-section { margin-top: 40px; }
        .badge-position { background: #6366f1; color: white; padding: 4px 10px; border-radius: 20px; font-size: 0.8rem; display: inline-block; }
        
        /* Form Styling for Announcement Section */
        .form-group { margin-bottom: 15px; display: flex; flex-direction: column; gap: 5px; }
        .form-group label { color: #bbb; font-size: 0.9rem; }
        .form-control { background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.1); padding: 12px; border-radius: 8px; color: #fff; font-family: inherit; }
        .form-control:focus { border-color: #c77dff; outline: none; }
        
        /* Alert Message Badges Style */
        .alert { padding: 14px; border-radius: 8px; margin-bottom: 20px; font-size: 0.95rem; font-weight: 500; }
        .alert-success { background: rgba(34, 197, 94, 0.15); border: 1px solid #22c55e; color: #4ade80; }
        .alert-error { background: rgba(239, 68, 68, 0.15); border: 1px solid #ef4444; color: #f87171; }

        /* Fix Dropdown Option Contrast */
        .form-control option { background-color: #1a1a2e; color: #ffffff; padding: 10px; }

        select.form-control {
            cursor: pointer;
            background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10' fill='%23ffffff'><polygon points='0,0 10,0 5,5'/></svg>");
            background-repeat: no-repeat;
            background-position: right 15px center;
            padding-right: 30px;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none; 
        }
    </style>
</head>
<body>
    <div class="header-fixed">
        <%@ include file="../header.jsp" %> 
    </div>

    <div class="container">
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>
        <% if ("duplicate".equals(msg)) { %>
            <div class="alert alert-error">Pendaftaran Gagal! No. Matrik atau Email tersebut sudah pun berdaftar dalam sistem.</div>
        <% } else if ("quota_full".equals(msg)) { %>
            <div class="alert alert-error">Had Kuota Penuh! Jawatan Majlis Tertinggi tersebut sudah diisi oleh ajk lain.</div>
        <% } else if ("success".equals(msg)) { %>
            <div class="alert alert-success">Pendaftaran Berjaya! Akaun AJK baru telah disimpan.</div>
        <% } else if ("updated".equals(msg)) { %>
            <div class="alert alert-success">Kemaskini Berjaya! Profil AJK telah disimpan semula.</div>
        <% } else if ("deleted".equals(msg)) { %>
            <div class="alert alert-success">Rekod Berjaya Dipadam! Akaun telah dikeluarkan daripada sistem.</div>
        <% } %>
        
        <div class="card">
            <h2 style="margin-top:0; margin-bottom: 20px; color: #fff;">System Analytics</h2>
            <div class="stats-grid">
                <div class="stat-card">
                    <p style="color: #bbb; margin:0;">Total Registered Users</p>
                    <h3><%= totalUsers %></h3>
                </div>
                <div class="stat-card">
                    <p style="color: #bbb; margin:0;">Available Stations</p>
                    <h3><%= availableStations %></h3>
                </div>
            </div>
        </div>

        <div class="card crud-section">
            <h2 style="margin-top:0; margin-bottom: 5px; color: #fff;">Create System Announcement</h2>
            <p style="color: #bbb; margin-top:0; margin-bottom: 20px; font-size: 0.9rem;">Pengumuman rasmi kepada pengguna sistem playje.</p>
            
            <form action="<%= request.getContextPath() %>/AnnouncementServlet" method="POST">
                <div class="form-grid" style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label>Announcement Title</label>
                        <input type="text" name="title" class="form-control" placeholder="e.g., Scheduled Maintenance for PS5 Stations" required>
                    </div>
                    <div class="form-group">
                        <label>Target Audience (Email Blast)</label>
                        <select name="audience" class="form-control" style="height: 46px;">
                            <option value="everybody">Everybody (All Users)</option>
                            <option value="student">Students Only</option>
                            <option value="ajk">AJK Members Only</option>
                        </select>
                    </div>
                </div>
                <div class="form-group" style="margin-top: 15px;">
                    <label>Message Content</label>
                    <textarea name="content" class="form-control" rows="5" placeholder="Type your official announcement here..." required></textarea>
                </div>
                <div style="text-align: right; margin-top: 15px;">
                    <button type="submit" class="btn-primary" style="width: auto; padding: 12px 25px;">Publish Email</button>
                </div>
            </form>
        </div>
        
        <div class="card" style="margin-top: 40px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2 style="color: #fff; margin:0;">Staff Duty Schedule</h2>
                <button class="btn-primary" onclick="location.href='addSchedule.jsp'" style="width: auto; padding: 10px 20px;">
                    + Add New Schedule
                </button>
            </div>

            <div style="overflow-x: auto;">
                <table class="staff-table" width="100%" style="border-collapse: collapse;">
                    <thead>
                        <tr style="background: rgba(199, 125, 255, 0.1); text-align: left;">
                            <th style="padding: 12px; width: 60px;">No.</th>
                            <th style="padding: 12px;">Staff Name</th>
                            <th style="padding: 12px;">Duty Role</th>
                            <th style="padding: 12px;">Date</th>
                            <th style="padding: 12px;">Status</th>
                            <th style="padding: 12px; text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if(schedules.isEmpty()) { %>
                            <tr><td colspan="6" style="text-align:center; padding: 30px; color: #999;">No schedules found.</td></tr>
                        <% } else { 
                            int scheduleIndex = 1; 
                            for(StaffSchedule s : schedules) { 
                        %>
                            <tr style="border-bottom: 1px solid rgba(255,255,255,0.05);">
                                <td style="padding: 12px; color: #aaa;"><%= scheduleIndex++ %></td>
                                <td style="padding: 12px;"><strong><%= s.getAjkName() %></strong></td>
                                <td style="padding: 12px;"><%= s.getDutyRole() %></td>
                                <td style="padding: 12px;"><%= s.getShiftDate() %></td>
                                <td style="padding: 12px;">
                                    <span class="status-badge <%= (s.getIsAssigned() == 1) ? "assigned" : "unassigned" %>">
                                        <%= (s.getIsAssigned() == 1) ? "Assigned" : "Missing" %>
                                    </span>
                                </td>
                                <td style="padding: 12px; text-align: center;">
                                    <div style="display: flex; gap: 10px; justify-content: center;">
                                        <a href="editSchedule.jsp?id=<%= s.getScheduleId() %>" class="btn-edit" style="color: #ffc107; text-decoration: none;">Edit</a>
                                        <form action="../ScheduleServlet" method="POST" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="scheduleId" value="<%= s.getScheduleId() %>">
                                            <button type="submit" style="background:none; border:none; color:#ef4444; cursor:pointer; text-decoration:underline;" onclick="return confirm('Delete schedule?')">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card crud-section" style="margin-bottom: 40px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2 style="color: #fff; margin:0;">AJK Member Management</h2>
                <button class="btn-primary" onclick="location.href='addAjk.jsp'" style="width: auto; padding: 10px 20px;">+ Add New AJK</button>
            </div>
            
            <div style="overflow-x: auto;">
                <table class="staff-table" style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: rgba(199, 125, 255, 0.1); text-align: left;">
                            <th style="padding: 12px; width: 60px;">No.</th>
                            <th style="padding: 12px;">No. Matric</th>
                            <th style="padding: 12px;">Name</th>
                            <th style="padding: 12px;">Position</th>
                            <th style="padding: 12px;">Email</th>
                            <th style="padding: 12px; text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int ajkIndex = 1; 
                            for(User ajk : fullAjkList) { 
                        %>
                        <tr style="border-bottom: 1px solid rgba(255,255,255,0.05);">
                            <td style="padding: 12px; color: #aaa;"><%= ajkIndex++ %></td>
                            <td style="padding: 12px;"><%= ajk.getUserId() %></td>
                            <td style="padding: 12px;"><strong><%= ajk.getUsername() %></strong></td>
                            <td style="padding: 12px;"><span class="badge-position"><%= ajk.getPosition() %></span></td>
                            <td style="padding: 12px;"><%= ajk.getEmail() %></td>
                            <td style="padding: 12px; text-align: center;">
                                <div style="display: flex; gap: 10px; justify-content: center;">
                                    <a href="editAjk.jsp?id=<%= ajk.getUserId() %>" class="btn-edit" style="color: #ffc107; text-decoration: none;">Edit</a>
                                    <form action="../UserServlet" method="POST" onsubmit="return confirm('Confirm remove AJK <%= ajk.getUsername() %>?')">
                                        <input type="hidden" name="action" value="deleteAjk">
                                        <input type="hidden" name="userId" value="<%= ajk.getUserId() %>">
                                        <button type="submit" style="background:none; border:none; color:#ef4444; cursor:pointer; text-decoration:underline;">Delete</button>
                                    </form>
                                </div>
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