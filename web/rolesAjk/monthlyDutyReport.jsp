<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User, com.lab.model.StaffSchedule, com.lab.dao.StaffScheduleDAO, java.util.*" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("ajk")) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Monthly Frequency Duty Report</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; padding: 40px; background: #fff; color: #1a1a2e; }
        .header-title { text-align: center; padding-bottom: 20px; border-bottom: 3px double #1a1a2e; margin-bottom: 30px; }
        .report-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .report-table th, .report-table td { border: 1px solid #1a1a2e; padding: 12px; text-align: left; }
        .report-table th { background: #f4f4f6; color: #000; font-weight: bold; }
        .btn-action { background: #7b2cbf; color: white; padding: 12px 25px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; }
        @media print { .no-print { display: none; } body { padding: 10px; } }
    </style>
</head>
<body>

    <div class="no-print" style="display: flex; justify-content: space-between; margin-bottom: 30px;">
        <button onclick="location.href='dashboardAjk.jsp'" class="btn-action" style="background: #444;">← Back to Dashboard</button>
        <button onclick="window.print();" class="btn-action" style="background: #10b981;"> Save / Export as PDF</button>
    </div>

    <div class="header-title">
        <h1>UMT Gaming Lounge (Playje Platform)</h1>
        <h2>Monthly AJK Duty Frequency & Reward Eligibility Report</h2>
        <p>Report Generated On: <%= new java.util.Date() %> | Requested By: Staff AJK</p>
    </div>

    <p style="font-size: 1.1rem; line-height: 1.6;">
        This document tracks how frequently each AJK member performed duties during the month. Management uses these records to calculate bonus distributions.
    </p>

    <table class="report-table">
        <thead>
            <tr>
                <th>AJK Member Staff ID</th>
                <th>Total Completed Shifts Tracked</th>
                <th>Performance Status Level</th>
                <th>Bonus Qualification Tier</th>
            </tr>
        </thead>
        <tbody>
        <%
            StaffScheduleDAO scheduleDao = new StaffScheduleDAO();
            List<StaffSchedule> globalSchedules = scheduleDao.getAllSchedules();
            
            Map<String, Integer> dutyCounter = new HashMap<>();
            if (globalSchedules != null) {
                for (StaffSchedule s : globalSchedules) {
                    // Corrected to track using getAjkId() from your model code
                    if (s.getAjkId() != null) {
                        dutyCounter.put(s.getAjkId(), dutyCounter.getOrDefault(s.getAjkId(), 0) + 1);
                    }
                }
            }

            if (dutyCounter.isEmpty()) {
        %>
            <tr><td colspan="4" style="text-align: center; color: #888;">No duty schedule history records found in system database.</td></tr>
        <%
            } else {
                for (Map.Entry<String, Integer> entry : dutyCounter.entrySet()) {
                    int totalShifts = entry.getValue();
                    String bonusTier = (totalShifts >= 12) ? "Platinum Bonus Level (RM 200)" : 
                                       (totalShifts >= 6) ? "Gold Bonus Level (RM 100)" : "Base Reward Level";
        %>
            <tr>
                <td><strong><%= entry.getKey() %></strong></td>
                <td><%= totalShifts %> Duty Session Shifts</td>
                <td><%= (totalShifts >= 6) ? "Highly Active" : "Active" %></td>
                <td style="font-weight: bold; color: #059669;"><%= bonusTier %></td>
            </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <div style="margin-top: 60px; display: flex; justify-content: space-between;">
        <div>________________________<br>Prepared By AJK Operations</div>
        <div>________________________<br>Approved By Manager / Boss</div>
    </div>

</body>
</html>