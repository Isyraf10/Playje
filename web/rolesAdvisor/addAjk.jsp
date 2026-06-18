<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lab.model.User" %>
<%
    // Session Validation untuk Advisor
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("advisor")) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New AJK - Playje</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* Pro Layout Fixes */
        body { 
            padding-top: 90px; 
            background-color: #0f0f1e; /* Ngam dengan tema dark dashboard */
        }
        
        .header-container { 
            position: fixed; 
            top: 0; 
            width: 100%; 
            z-index: 1000; 
            background: #1a1a2e; 
        }

        /* Card Customization untuk Form centering */
        .form-card {
            max-width: 520px;
            margin: 30px auto;
            padding: 35px;
            background: rgba(26, 26, 46, 0.65);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
        }

        .form-group {
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group label {
            color: #ddd;
            font-size: 0.9rem;
            font-weight: 500;
        }

        /* Clean styling untuk input & dropdown option */
        .input-field {
            box-sizing: border-box;
            width: 100%;
            padding: 12px;
            border-radius: 6px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: #fff;
            font-size: 0.95rem;
        }

        .input-field:focus {
            border-color: #c77dff;
            outline: none;
            background: rgba(255, 255, 255, 0.08);
        }

        .input-field option {
            background-color: #1a1a2e;
            color: #fff;
            padding: 10px;
        }

        /* Simetri Action Buttons */
        .form-actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-top: 30px;
        }

        .form-actions button, .form-actions a {
            padding: 12px;
            border-radius: 6px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            box-sizing: border-box;
            width: 100%;
        }

        .btn-cancel {
            background: rgba(255, 255, 255, 0.08);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .btn-cancel:hover {
            background: rgba(255, 255, 255, 0.15);
        }
    </style>
</head>
<body>
    <div class="header-container">
        <%@ include file="../header.jsp" %>
    </div>
    
    <div class="container">
        <div class="form-card">
            <h2 style="color: #c77dff; margin-top: 0; margin-bottom: 8px; font-weight: 600;">Register New AJK</h2>
            <p style="color: #aaa; font-size: 0.85rem; margin-bottom: 25px; margin-top: 0;">Sila daftar maklumat akaun AJK baharu untuk sistem Playje UMT Gaming Lounge.</p>
            
            <form action="../UserServlet" method="POST">
                <input type="hidden" name="action" value="registerAjk">
                
                <div class="form-group">
                    <label>No. Matric (User ID)</label>
                    <input type="text" name="userId" placeholder="e.g. S12345" required class="input-field">
                </div>

                <div class="form-group">
                    <label>Username (Full Name)</label>
                    <input type="text" name="username" placeholder="e.g. Isyraf Aiman" required class="input-field">
                </div>

                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" placeholder="e.g. student@ocean.umt.edu.my" required class="input-field">
                </div>

                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="Min 6 characters" required class="input-field">
                </div>

                <div class="form-group">
                    <label>Position in Esports Club</label>
                    <select name="position" required class="input-field">
                        <option value="Presiden">Presiden</option>
                        <option value="Timbalan President">Timbalan President</option>
                        <option value="Setiusaha">Setiausaha</option>
                        <option value="Timbalan Setiusaha">Timbalan Setiusaha</option>
                        <option value="Bendahari">Bendahari</option>
                        <option value="Timbalan Bendahari">Timbalan Bendahari</option>
                        <option value="Exco Multimedia">Exco Multimedia</option>
                        <option value="Exco Publisiti">Exco Publisiti</option>
                        <option value="Exco Pemerkasaan Sukan & Pembangunan Atlet">Exco Pemerkasaan Sukan & Pembangunan Atlet</option>
                        <option value="Exco Pengurusan Komuniti Pubg Mobile">Exco Pengurusan Komuniti Pubg Mobile</option>
                        <option value="Exco Pengurusan Komuniti Mobile Legends">Exco Pengurusan Komuniti Mobile Legends</option>
                        <option value="Exco Pengurusan Komuniti Console">Exco Pengurusan Komuniti Console</option>
                    </select>
                </div>

                <div class="form-actions">
                    <a href="dashboardAdvisor.jsp" class="btn-cancel">Cancel</a>
                    <button type="submit" class="btn-primary" style="border: none;">Register AJK</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>