/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.lab.dao;

import com.lab.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 *
 * @author batrisyia aliza
 */
public class NotificationDAO {
    // The AJK module will call this method later
    public void createNotification(String userId, String message) {
        String query = "INSERT INTO notification (notification_id, user_id, message) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, "NOTIF-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            ps.setString(2, userId);
            ps.setString(3, message);
            ps.executeUpdate();
            
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // Your Student module will call this method to display the alerts
    public List<String> getLatestNotifications(String userId) {
        List<String> list = new ArrayList<>();
        String query = "SELECT message FROM notification WHERE user_id = ? ORDER BY created_at DESC LIMIT 5";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("message"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}