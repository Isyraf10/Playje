package com.lab.model;

import java.sql.Timestamp;

public class Booking {
    
    // Variables ikut sebiji column dalam SQL image_d116d9.png
    private String bookingId;
    private String studentId;
    private String stationId;
    private String slotId;
    private Timestamp bookingDate; // DATETIME dalam SQL mapped ke Timestamp
    private String status;         // ENUM dlm SQL mapped ke String
    private double totalPrice;     // DECIMAL(6,2)
    
    // Extra fields untuk tujuan display (Hasil JOIN nanti)
    private String stationName;
    private String slotTime; 
    private String paymentProof; // Variable ni penting untuk upload resit tadi

    public Booking() {}

    // Constructor
    public Booking(String bookingId, String studentId, String stationId, String slotId, 
                   Timestamp bookingDate, String status, double totalPrice) {
        this.bookingId = bookingId;
        this.studentId = studentId;
        this.stationId = stationId;
        this.slotId = slotId;
        this.bookingDate = bookingDate;
        this.status = status;
        this.totalPrice = totalPrice;
    }

    // Getters and Setters
    public String getBookingId() { return bookingId; }
    public void setBookingId(String bookingId) { this.bookingId = bookingId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }

    public String getSlotId() { return slotId; }
    public void setSlotId(String slotId) { this.slotId = slotId; }

    public Timestamp getBookingDate() { return bookingDate; }
    public void setBookingDate(Timestamp bookingDate) { this.bookingDate = bookingDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    // Getter/Setter untuk Extra Fields
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }

    public String getSlotTime() { return slotTime; }
    public void setSlotTime(String slotTime) { this.slotTime = slotTime; }

    public String getPaymentProofPath() { return paymentProof; }
    public void setPaymentProofPath(String paymentProof) { this.paymentProof = paymentProof; }
}
