package com.lab.dao;

import com.lab.util.DBConnection;
import com.lab.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.sql.SQLException;

public class UserDAO {

    public User authenticateUser(String email, String password) {
        User user = null;
        String query = "SELECT * FROM users WHERE email = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            System.out.println("DEBUG: Attempting login with email: " + email);
            System.out.println("DEBUG: Password: " + password);
            
            stmt.setString(1, email);
            stmt.setString(2, password);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getString("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                System.out.println("DEBUG: User found - " + user.getUsername());
            } else {
                System.out.println("DEBUG: No user found with email: " + email);
                String checkQuery = "SELECT * FROM users WHERE email = ?";
                try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                    checkStmt.setString(1, email);
                    ResultSet checkRs = checkStmt.executeQuery();
                    if (checkRs.next()) {
                        System.out.println("DEBUG: Email exists but password doesn't match");
                        System.out.println("DEBUG: Stored password: " + checkRs.getString("password"));
                    } else {
                        System.out.println("DEBUG: Email doesn't exist in database");
                    }
                }
            }

        } catch (Exception e) {
            System.out.println("Error in UserDAO: " + e.getMessage());
            e.printStackTrace();
        }

        return user;
    }

    public User getUserById(String id) {
        User user = null;
        String query = "SELECT u.*, a.position FROM users u " +
                       "LEFT JOIN ajk_profile a ON u.user_id = a.ajk_id " +
                       "WHERE u.user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getString("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setPosition(rs.getString("position")); 
            }
        } catch (Exception e) { e.printStackTrace(); }
        return user;
    }

    public int getTotalUserCount() {
        String query = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // MEMENUHI REQ 1: Susun ikut pangkat hierarki kelab (Penasihat dibuang)
    public List<User> getUsersByRole(String role) {
    List<User> list = new ArrayList<>();
    // SQL Query disusun strict menyeluruh untuk MT dan semua kategori EXCO
    String query = "SELECT u.*, a.position FROM users u " +
                   "LEFT JOIN ajk_profile a ON u.user_id = a.ajk_id " +
                   "WHERE u.role = ? " +
                   "ORDER BY CASE a.position " +
                   "  WHEN 'Presiden' THEN 1 " +
                   "  WHEN 'Timbalan President' THEN 2 " +
                   "  WHEN 'Setiausaha' THEN 3 " +
                   "  WHEN 'Timbalan Setiausaha' THEN 4 " +
                   "  WHEN 'Bendahari' THEN 5 " +
                   "  WHEN 'Timbalan Bendahari' THEN 6 " +
                   "  WHEN 'Exco Multimedia' THEN 7 " +
                   "  WHEN 'Exco Publisiti' THEN 8 " +
                   "  WHEN 'Exco Pemerkasaan Sukan & Pembangunan Atlet' THEN 9 " +
                   "  WHEN 'Exco Pengurusan Komuniti Pubg Mobile' THEN 10 " +
                   "  WHEN 'Exco Pengurusan Komuniti Mobile Legends' THEN 11 " +
                   "  WHEN 'Exco Pengurusan Komuniti Console' THEN 12 " +
                   "  ELSE 13 END ASC, u.user_id ASC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, role);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getString("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                
                String pos = rs.getString("position");
                user.setPosition(pos != null ? pos : "N/A"); 
                
                list.add(user);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}

    // MEMENUHI REQ 3: Prevent double entry check no matric ATAU email
    public boolean isUserExist(String userId, String email) {
        String query = "SELECT COUNT(*) FROM users WHERE user_id = ? OR email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, userId);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return true;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // MEMENUHI REQ 2: Limit satu orang sahaja untuk jawatan Majlis Tertinggi (MT)
    public boolean isMajlisTertinggiFull(String position) {
        if (position == null || position.startsWith("Exco")) {
            return false; // Kalau exco, lepas tanpa had kuota
        }
        String query = "SELECT COUNT(*) FROM ajk_profile WHERE position = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, position);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) >= 1) {
                    return true; // Dah penuh
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean registerAjkWithProfile(User user) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); 

            String sqlUser = "INSERT INTO users (user_id, username, email, password, role) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps1 = conn.prepareStatement(sqlUser);
            ps1.setString(1, user.getUserId());
            ps1.setString(2, user.getUsername());
            ps1.setString(3, user.getEmail());
            ps1.setString(4, user.getPassword());
            ps1.setString(5, user.getRole());
            ps1.executeUpdate();

            String sqlProfile = "INSERT INTO ajk_profile (ajk_id, position) VALUES (?, ?)";
            PreparedStatement ps2 = conn.prepareStatement(sqlProfile);
            ps2.setString(1, user.getUserId());
            ps2.setString(2, user.getPosition());
            ps2.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateAjkWithProfile(User user) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String sqlUser = "UPDATE users SET username=?, email=? WHERE user_id=?";
            PreparedStatement ps1 = conn.prepareStatement(sqlUser);
            ps1.setString(1, user.getUsername());
            ps1.setString(2, user.getEmail());
            ps1.setString(3, user.getUserId());
            ps1.executeUpdate();

            String sqlProfile = "UPDATE ajk_profile SET position=? WHERE ajk_id=?";
            PreparedStatement ps2 = conn.prepareStatement(sqlProfile);
            ps2.setString(1, user.getPosition());
            ps2.setString(2, user.getUserId());
            ps2.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteUser(String userId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); 

            String sqlProfile = "DELETE FROM ajk_profile WHERE ajk_id = ?";
            PreparedStatement ps1 = conn.prepareStatement(sqlProfile);
            ps1.setString(1, userId);
            ps1.executeUpdate();

            String sqlUser = "DELETE FROM users WHERE user_id = ?";
            PreparedStatement ps2 = conn.prepareStatement(sqlUser);
            ps2.setString(1, userId);
            ps2.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        }
    }

    public List<String> getEmailsByAudience(String audience) {
        List<String> emailList = new ArrayList<>();
        String query = "";

        if ("everybody".equalsIgnoreCase(audience)) {
            query = "SELECT email FROM users";
        } else if ("student".equalsIgnoreCase(audience)) {
            query = "SELECT email FROM users WHERE role = 'student'";
        } else if ("ajk".equalsIgnoreCase(audience)) {
            query = "SELECT email FROM users WHERE role = 'ajk'";
        }

        if (!query.isEmpty()) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    emailList.add(rs.getString("email"));
                }
                System.out.println("DEBUG: Target [" + audience + "] found " + emailList.size() + " emails.");

            } catch (SQLException e) {
                System.out.println("Error fetching emails in UserDAO: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return emailList;
    }
    // Check quota Majlis Tertinggi khusus untuk fasa UPDATE (Kecualikan tuan badan sendiri)
public boolean isMajlisTertinggiFullOnUpdate(String position, String currentUserId) {
    if (position == null || position.startsWith("Exco")) {
        return false; // Kalau jawatan exco, bypass terus tanpa had kuota
    }
    
    // Kira berapa ramai orang pegang jawatan MT ni, KECUALI user yang tengah diedit sekarang
    String query = "SELECT COUNT(*) FROM ajk_profile WHERE position = ? AND ajk_id != ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, position);
        ps.setString(2, currentUserId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt(1) >= 1) {
                return true; // Dah ada orang lain pegang jawatan MT ni!
            }
        }
    } catch (Exception e) { 
        e.printStackTrace(); 
    }
    return false;
}
}