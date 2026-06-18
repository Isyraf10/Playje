package com.lab.dao;

import com.lab.util.DBConnection;
import java.sql.*;

public class AnnouncementDAO {

    public boolean createAnnouncement(String advisorId, String title, String content, String audience) {
        String query = "INSERT INTO announcement (announcement_id, advisor_id, title, target_audience, content, publish_date, is_published) "
                     + "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, 1)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            // Guna java.util.UUID untuk generate ID unik secara automatik
            String announceId = "ANN-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            
            ps.setString(1, announceId);
            ps.setString(2, advisorId);
            ps.setString(3, title);
            ps.setString(4, audience.toLowerCase()); // 'student', 'ajk', atau 'everybody'
            ps.setString(5, content);

            int rowsInserted = ps.executeUpdate();
            return rowsInserted > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}