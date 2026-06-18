<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User, com.lab.dao.UserDAO" %>
<%
    // Session Validation untuk keselamatan sistem
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("advisor")) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String userId = request.getParameter("id");
    UserDAO uDao = new UserDAO();
    User ajk = uDao.getUserById(userId); 

    if (ajk == null) {
        response.sendRedirect("dashboardAdvisor.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit AJK Profile - Playje</title>
    
    <style>
        /* Global Base Override (Kalis Flex Layout Clash) */
        body {
            margin: 0;
            padding: 90px 0 0 0;
            box-sizing: border-box;
            background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #0f0c29 100%);
            color: #f8fafc;
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            min-height: 100vh;
            display: block;
        }

        .header-fixed-container {
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            background: #1a1a2e;
        }

        /* Container & Kad Tengah Form */
        .custom-form-container {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .custom-form-card {
            max-width: 520px;
            margin: 30px auto;
            background: rgba(26, 26, 46, 0.65);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 12px;
            padding: 35px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
        }

        /* Input Elements Group Styling */
        .custom-group {
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            text-align: left;
        }

        .custom-group label {
            color: #c77dff;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .custom-input {
            box-sizing: border-box;
            width: 100%;
            padding: 14px;
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 8px;
            color: #fff;
            outline: none;
            font-size: 0.95rem;
            transition: border-color 0.2s;
        }

        .custom-input:focus {
            border-color: #9d4edd;
            box-shadow: 0 0 12px rgba(157, 78, 221, 0.35);
        }

        /* Read-only / Disabled field style */
        .custom-input:disabled {
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(255, 255, 255, 0.08);
            color: #888888;
            cursor: not-allowed;
        }

        /* Dropdown Options Fix (Dark Dropdown Menu) */
        .custom-input option {
            background-color: #1a1a2e;
            color: #ffffff;
            padding: 12px;
        }

        /* Custom Native Select Arrow Indicator */
        select.custom-input {
            cursor: pointer;
            background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10' fill='%23c77dff'><polygon points='0,0 10,0 5,5'/></svg>");
            background-repeat: no-repeat;
            background-position: right 15px center;
            padding-right: 35px;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
        }

        /* Action Buttons Layout Grid (50-50 Simetri) */
        .custom-actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-top: 30px;
        }

        .custom-btn-primary {
            background: linear-gradient(45deg, #7b2cbf, #9d4edd);
            color: white;
            padding: 14px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            box-shadow: 0 4px 15px rgba(123, 44, 191, 0.3);
            transition: all 0.2s;
        }

        .custom-btn-primary:hover {
            box-shadow: 0 4px 20px rgba(157, 78, 221, 0.5);
        }

        .custom-btn-cancel {
            background: rgba(255, 255, 255, 0.08);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 14px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            text-align: center;
            text-decoration: none;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .custom-btn-cancel:hover {
            background: rgba(255, 255, 255, 0.15);
        }
    </style>
</head>
<body>

    <div class="header-fixed-container">
        <%@ include file="../header.jsp" %>
    </div>
    
    <div class="custom-form-container">
        <div class="custom-form-card">
            <h2 style="color: #e0aaff; margin-top: 0; margin-bottom: 8px; font-weight: 600; font-size: 1.8rem; letter-spacing: 1px;">Edit AJK Profile</h2>
            <p style="color: #adb5bd; font-size: 0.85rem; margin-bottom: 25px; margin-top: 0; font-weight: 300;">Kemaskini maklumat krew bagi <%= ajk.getUsername() %>.</p>
            
            <form action="../UserServlet" method="POST">
                <input type="hidden" name="action" value="updateAjk">
                <input type="hidden" name="userId" value="<%= ajk.getUserId() %>">
                
                <div class="custom-group">
                    <label>No. Matric (Read-only)</label>
                    <input type="text" value="<%= ajk.getUserId() %>" disabled class="custom-input">
                </div>

                <div class="custom-group">
                    <label>Full Name</label>
                    <input type="text" name="username" value="<%= ajk.getUsername() %>" required class="custom-input">
                </div>

                <div class="custom-group">
                    <label>Email Address</label>
                    <input type="email" name="email" value="<%= ajk.getEmail() %>" required class="custom-input">
                </div>

                <div class="custom-group">
                    <label>Current Position</label>
                    <select name="position" required class="custom-input">
                        <option value="Presiden" <%= ajk.getPosition().equals("Presiden") ? "selected" : "" %>>Presiden</option>
                        <option value="Timbalan President" <%= ajk.getPosition().equals("Timbalan President") ? "selected" : "" %>>Timbalan President</option>
                        <option value="Setiausaha" <%= ajk.getPosition().equals("Setiausaha") ? "selected" : "" %>>Setiausaha</option>
                        <option value="Timbalan Setiausaha" <%= ajk.getPosition().equals("Timbalan Setiausaha") ? "selected" : "" %>>Timbalan Setiausaha</option>
                        <option value="Bendahari" <%= ajk.getPosition().equals("Bendahari") ? "selected" : "" %>>Bendahari</option>
                        <option value="Timbalan Bendahari" <%= ajk.getPosition().equals("Timbalan Bendahari") ? "selected" : "" %>>Timbalan Bendahari</option>
                        <option value="Exco Multimedia" <%= ajk.getPosition().equals("Exco Multimedia") ? "selected" : "" %>>Exco Multimedia</option>
                        <option value="Exco Publisiti" <%= ajk.getPosition().equals("Exco Publisiti") ? "selected" : "" %>>Exco Publisiti</option>
                        <option value="Exco Pemerkasaan Sukan & Pembangunan Atlet" <%= ajk.getPosition().equals("Exco Pemerkasaan Sukan & Pembangunan Atlet") ? "selected" : "" %>>Exco Pemerkasaan Sukan & Pembangunan Atlet</option>
                        <option value="Exco Pengurusan Komuniti Pubg Mobile" <%= ajk.getPosition().equals("Exco Pengurusan Komuniti Pubg Mobile") ? "selected" : "" %>>Exco Pengurusan Komuniti Pubg Mobile</option>
                        <option value="Exco Pengurusan Komuniti Mobile Legends" <%= ajk.getPosition().equals("Exco Pengurusan Komuniti Mobile Legends") ? "selected" : "" %>>Exco Pengurusan Komuniti Mobile Legends</option>
                        <option value="Exco Pengurusan Komuniti Console" <%= ajk.getPosition().equals("Exco Pengurusan Komuniti Console") ? "selected" : "" %>>Exco Pengurusan Komuniti Console</option>
                    </select>
                </div>

                <div class="custom-actions">
                    <a href="dashboardAdvisor.jsp" class="custom-btn-cancel">Back</a>
                    <button type="submit" class="custom-btn-primary">Update Profile</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>