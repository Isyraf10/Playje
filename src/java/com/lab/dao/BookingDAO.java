package com.lab.dao;

import com.lab.model.Booking;
import com.lab.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    /**
     * Method untuk simpan banyak slot sekaligus (Batch Processing)
     * Juga update status availability slot dalam table time_slot
     */
    public boolean createMultipleBookings(List<Booking> bookingList) {
        // Query 1: Masukkan data booking
        String queryInsert = "INSERT INTO booking (booking_id, student_id, station_id, slot_id, booking_date, status, total_price, payment_proof) "
                           + "VALUES (?, ?, ?, ?, ?, 'pending', ?, ?)";
        
        // Query 2: Update slot supaya tak boleh dibooking orang lain
        String queryUpdateSlot = "UPDATE time_slot SET is_available = 0 WHERE slot_id = ?";
        
        Connection conn = null;
        PreparedStatement psInsert = null;
        PreparedStatement psUpdate = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // START TRANSACTION

            psInsert = conn.prepareStatement(queryInsert);
            psUpdate = conn.prepareStatement(queryUpdateSlot);
            
            for (Booking b : bookingList) {
                // Setup untuk INSERT
                psInsert.setString(1, b.getBookingId());
                psInsert.setString(2, b.getStudentId());
                psInsert.setString(3, b.getStationId());
                psInsert.setString(4, b.getSlotId());
                psInsert.setTimestamp(5, b.getBookingDate());
                psInsert.setDouble(6, b.getTotalPrice());
                psInsert.setString(7, b.getPaymentProofPath());
                psInsert.addBatch(); // Masuk dalam queue batch
                
                // Setup untuk UPDATE time_slot
                psUpdate.setString(1, b.getSlotId());
                psUpdate.addBatch(); // Masuk dalam queue batch
            }
            
            // Execute semua queue serentak
            psInsert.executeBatch();
            psUpdate.executeBatch();
            
            conn.commit(); // SAVE SEMUA PERUBAHAN SECARA KEKAL
            return true;
            
        } catch (SQLException e) {
            System.err.println("DATABASE ERROR IN createMultipleBookings:");
            e.printStackTrace();
            if (conn != null) {
                try {
                    System.err.println("ROLLING BACK TRANSACTION...");
                    conn.rollback(); // CANCEL SEMUA KALAU ADA ERROR
                } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            // TUTUP SEMUA RESOURCE UNTUK ELAK MEMORY LEAK/DB HANG
            try {
                if (psInsert != null) psInsert.close();
                if (psUpdate != null) psUpdate.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    /**
     * Method untuk tarik history booking student
     * Join dengan table station & time_slot supaya user nampak text, bukan ID
     */
    public List<Booking> getBookingsByStudent(String studentId) {
        List<Booking> list = new ArrayList<>();
        String query = "SELECT b.*, s.station_name, ts.start_time, ts.end_time " +
                       "FROM booking b " +
                       "JOIN gaming_station s ON b.station_id = s.station_id " +
                       "JOIN time_slot ts ON b.slot_id = ts.slot_id " +
                       "WHERE b.student_id = ? " +
                       "ORDER BY b.booking_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, studentId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getString("booking_id"));
                b.setStudentId(rs.getString("student_id"));
                b.setStationId(rs.getString("station_id"));
                b.setSlotId(rs.getString("slot_id"));
                b.setBookingDate(rs.getTimestamp("booking_date"));
                b.setStatus(rs.getString("status"));
                b.setTotalPrice(rs.getDouble("total_price"));
                b.setPaymentProofPath(rs.getString("payment_proof"));
                
                // Data dari hasil JOIN untuk dipaparkan di Dashboard
                b.setStationName(rs.getString("station_name"));
                b.setSlotTime(rs.getString("start_time") + " - " + rs.getString("end_time"));
                
                list.add(b);
            }
        } catch (SQLException e) {
            System.err.println("ERROR IN getBookingsByStudent:");
            e.printStackTrace();
        }
        return list;
    }
    public List<Booking> getAllPendingBookings() {
    List<Booking> list = new ArrayList<>();
    // JOIN dengan time_slot untuk dapatkan masa mula dan tamat
    String query = "SELECT b.*, s.station_name, ts.start_time, ts.end_time " +
                   "FROM booking b " +
                   "JOIN gaming_station s ON b.station_id = s.station_id " +
                   "JOIN time_slot ts ON b.slot_id = ts.slot_id " +
                   "WHERE b.status = 'pending' " +
                   "ORDER BY b.booking_date ASC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Booking b = new Booking();
            b.setBookingId(rs.getString("booking_id"));
            b.setStudentId(rs.getString("student_id"));
            b.setStationId(rs.getString("station_id"));
            b.setBookingDate(rs.getTimestamp("booking_date"));
            b.setStatus(rs.getString("status"));
            b.setTotalPrice(rs.getDouble("total_price"));
            b.setPaymentProofPath(rs.getString("payment_proof"));
            b.setStationName(rs.getString("station_name"));
            
            // Format slot time jadi "14:00 - 15:00"
            b.setSlotTime(rs.getString("start_time") + " - " + rs.getString("end_time"));
            
            list.add(b);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}
    public boolean updateBookingStatus(String bookingId, String status) {
    String query = "UPDATE booking SET status = ? WHERE booking_id = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, status);
        ps.setString(2, bookingId);
        
        int rowAffected = ps.executeUpdate();
        return rowAffected > 0;
        
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
public boolean rejectAndReleaseSlot(String bookingId, String stationId) {
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); 

        // 1. Dapatkan slot_id dulu sebelum delete booking
        String getSlotQuery = "SELECT slot_id FROM booking WHERE booking_id = ?";
        PreparedStatement psSlot = conn.prepareStatement(getSlotQuery);
        psSlot.setString(1, bookingId);
        ResultSet rs = psSlot.executeQuery();
        String slotId = "";
        if (rs.next()) {
            slotId = rs.getString("slot_id");
        }

        // 2. Update status station jadi 'available'
        String updateStation = "UPDATE gaming_station SET status = 'available' WHERE station_id = ?";
        PreparedStatement ps1 = conn.prepareStatement(updateStation);
        ps1.setString(1, stationId);
        ps1.executeUpdate();

        // 3. Update status time_slot jadi '1' (Available balik)
        if (!slotId.equals("")) {
            String updateSlot = "UPDATE time_slot SET is_available = 1 WHERE slot_id = ?";
            PreparedStatement ps3 = conn.prepareStatement(updateSlot);
            ps3.setString(1, slotId);
            ps3.executeUpdate();
        }

        // 4. Delete booking
        String deleteBooking = "DELETE FROM booking WHERE booking_id = ?";
        PreparedStatement ps2 = conn.prepareStatement(deleteBooking);
        ps2.setString(1, bookingId);
        ps2.executeUpdate();

        conn.commit(); 
        return true;

    } catch (SQLException e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        e.printStackTrace();
        return false;
    } finally {
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
}  
    public boolean deleteBooking(String bookingId) {
    String query = "DELETE FROM booking WHERE booking_id = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, bookingId);
            return ps.executeUpdate() > 0;
        
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}