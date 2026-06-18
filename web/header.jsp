<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.lab.model.User, com.lab.dao.NotificationDAO, java.util.List" %>
<%
    // Check session kat sini terus supaya tak payah tulis kat setiap page
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Fetch Notifications for the Bell Icon
    NotificationDAO headerNotifDao = new NotificationDAO();
    List<String> headerNotifications = headerNotifDao.getLatestNotifications(user.getUserId());
    int notifCount = headerNotifications.size();
%>
<style>
    .navbar-global {
        background: rgba(255, 255, 255, 0.05);
        backdrop-filter: blur(10px);
        padding: 15px 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        position: sticky;
        top: 0;
        z-index: 1000;
    }
    .nav-brand { color: #e0aaff; font-size: 1.5rem; font-weight: 800; }
    .logout-link { color: #f87171; text-decoration: none; font-weight: bold; transition: 0.3s; }
    .logout-link:hover { text-shadow: 0 0 10px rgba(248, 113, 113, 0.5); }

    /* --- NOTIFICATION BELL CSS --- */
    .notif-container {
        position: relative;
        display: inline-block;
        cursor: pointer;
        padding-top: 5px;
    }
    .notif-bell {
        font-size: 1.4rem;
        position: relative;
        transition: transform 0.2s;
    }
    .notif-container:hover .notif-bell {
        transform: scale(1.1); /* Slight pop effect on hover */
    }
    .notif-badge {
        position: absolute;
        top: -5px;
        right: -8px;
        background: #ef4444;
        color: white;
        border-radius: 50%;
        padding: 2px 6px;
        font-size: 0.75rem;
        font-weight: bold;
        box-shadow: 0 0 8px rgba(239, 68, 68, 0.6);
    }
    .notif-dropdown {
        display: none;
        position: absolute;
        right: -10px; /* Aligns to the right edge */
        top: 40px;
        background: rgba(30, 30, 46, 0.95);
        backdrop-filter: blur(15px);
        min-width: 320px;
        border: 1px solid rgba(199, 125, 255, 0.3);
        border-radius: 12px;
        box-shadow: 0px 10px 30px rgba(0,0,0,0.8);
        z-index: 1001;
        padding: 15px;
        text-align: left;
    }
    .notif-container:hover .notif-dropdown {
        display: block; /* Shows dropdown when hovering over the bell */
    }
    .notif-header {
        color: #c77dff;
        font-weight: bold;
        padding-bottom: 10px;
        border-bottom: 1px solid rgba(199, 125, 255, 0.3);
        margin-bottom: 10px;
        font-size: 1rem;
    }
    .notif-item {
        color: #fff;
        padding: 12px;
        background: rgba(0,0,0,0.2);
        border-radius: 8px;
        margin-bottom: 8px;
        font-size: 0.85rem;
        line-height: 1.4;
    }
    .notif-item:last-child {
        margin-bottom: 0;
    }
</style>

<nav class="navbar-global">
    <div class="nav-brand">UMT Gaming Lounge</div>
    <div style="display: flex; gap: 25px; align-items: center;">

        <div class="notif-container">
            <div class="notif-bell">
                &#128276; <% if (notifCount > 0) { %>
                    <span class="notif-badge"><%= notifCount %></span>
                <% } %>
            </div>
            
            <div class="notif-dropdown">
                <div class="notif-header">Recent Notifications</div>
                <% if (notifCount == 0) { %>
                    <div style="color: #adb5bd; text-align: center; padding: 20px 0;">
                        No new notifications
                    </div>
                <% } else {
                    for(String msg : headerNotifications) { %>
                        <div class="notif-item"><%= msg %></div>
                    <% } 
                } %>
            </div>
        </div>

        <span style="font-size: 0.9rem; color: #adb5bd; border-left: 1px solid rgba(255,255,255,0.2); padding-left: 20px;">
            Role: <strong><%= user.getRole().toUpperCase() %></strong>
        </span>
        <a href="<%= request.getContextPath() %>/LoginServlet?action=logout" class="logout-link">Logout</a>
    </div>
</nav>