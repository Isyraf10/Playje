<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.Station, com.lab.dao.StationDAO, java.util.List" %>
<%
    StationDAO dao = new StationDAO();
    List<Station> stations = dao.getAllStations();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Step 1: Select Station - Playje</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">
</head>
<body style="display: block; background-color: #1a1a2e; min-height: 100vh;">
    <%@ include file="../header.jsp" %>
    
    <div class="container" style="margin-top: 80px; display: flex; justify-content: center;">
        
        <div class="glass-card" style="width: 100%; max-width: 600px; text-align: left; padding: 40px; z-index: 1;">
            
            <div style="display: flex; justify-content: space-between; margin-bottom: 30px; font-size: 0.95rem;">
                <span style="color: #c77dff; font-weight: bold;">1. Station</span>
                <span style="color: #666;">2. Time Slot</span>
                <span style="color: #666;">3. Payment</span>
            </div>

            <h2 style="color: #fff; margin-bottom: 25px;">Select Gaming Station</h2>
            
            <form action="timeSlot.jsp" method="GET">
                
                <div class="input-group">
                    <label>Station Category</label>
                    <select name="stationId" required class="form-select">
                        <option value="" style="color: #000;">-- Choose Station --</option>
                        <% for(Station s : stations) { %>
                            <option value="<%= s.getStationId() %>" style="color: #000;">
                                <%= s.getStationName() %> (<%= s.getStationType() %>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="input-group">
                    <label>Booking Date</label>
                    <input type="date" name="bookingDate" id="datePicker" required class="form-select">
                </div>

                <div style="display: flex; gap: 15px; margin-top: 35px;">
                    <button type="button" onclick="location.href='dashboardStudent.jsp'" class="btn-primary" style="flex: 1; background: #444; box-shadow: none;">Cancel</button>
                    <button type="submit" class="btn-primary" style="flex: 2;">Next: Select Time Slot</button>
                </div>
                
            </form>
        </div>
    </div>

    <script>
        // Pro-tip: This script accounts for the Malaysia (+8) Timezone. 
        // Standard Date() sometimes gets the UTC date, which might accidentally lock students out of today's slots!
        const tzOffset = (new Date()).getTimezoneOffset() * 60000; 
        const localISOTime = (new Date(Date.now() - tzOffset)).toISOString().split('T')[0];
        document.getElementById('datePicker').min = localISOTime;
    </script>
</body>
</html>