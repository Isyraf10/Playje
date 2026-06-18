package com.lab.controller;

import com.lab.dao.BookingDAO;
import com.lab.model.Booking;
import com.lab.model.User;
import java.io.File;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/BookingServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 15      // 15MB
)
public class BookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 1. Ambil session user & validate
            User user = (User) request.getSession().getAttribute("currentUser");
            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            // 2. Ambil data asas dari paymentProof.jsp
            String stationId = request.getParameter("stationId");
            String bookingDate = request.getParameter("bookingDate");
            String[] selectedSlots = request.getParameterValues("slotId");
            
            // Safety check kalau slotId tak sampai
            if (selectedSlots == null || selectedSlots.length == 0) {
                response.sendRedirect("rolesStudent/booking.jsp?error=no_slots");
                return;
            }

            // 3. Handle File Upload (Payment Proof)
            Part filePart = request.getPart("paymentProof");
            String originalFileName = getFileName(filePart);
            String fileName = UUID.randomUUID().toString() + "_" + originalFileName;
            
            // Path: Simpan dalam folder 'uploads' di root directory Web Pages
            String uploadPath = getServletContext().getRealPath("/") + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs(); // Bina folder kalau belum ada
            }
            
            String fullPath = uploadPath + File.separator + fileName;
            filePart.write(fullPath);
            String dbFilePath = "uploads/" + fileName;

            // 4. Bina List of Booking Objects untuk Batch Insert
            List<Booking> bookingList = new ArrayList<>();
            Timestamp currentNow = new Timestamp(System.currentTimeMillis());
            double pricePerSlot = 7.00; // Harga default per slot

            for (String sId : selectedSlots) {
                Booking b = new Booking();
                // Pastikan column booking_id di DB adalah VARCHAR(50)
                b.setBookingId("BK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
                b.setStudentId(user.getUserId());
                b.setStationId(stationId);
                b.setSlotId(sId);
                b.setBookingDate(currentNow);
                b.setTotalPrice(pricePerSlot); 
                b.setPaymentProofPath(dbFilePath);
                
                bookingList.add(b);
            }

            // 5. Panggil DAO untuk simpan ke database
            BookingDAO bDao = new BookingDAO();
            boolean success = bDao.createMultipleBookings(bookingList);

            // 6. Redirect berdasarkan result
            if (success) {
                // Berjaya - Balik ke Dashboard dengan status pending
                response.sendRedirect("rolesStudent/dashboardStudent.jsp?status=pending");
            } else {
                // Gagal di level Database/DAO
                response.sendRedirect("rolesStudent/paymentProof.jsp?error=db_fail");
            }

        } catch (Exception e) {
            // Print error kat console supaya kau boleh nampak kat mana sangkut
            System.err.println("CRITICAL ERROR IN BOOKINGSERVLET:");
            e.printStackTrace();
            
            if (!response.isCommitted()) {
                response.sendRedirect("rolesStudent/paymentProof.jsp?error=system_error");
            }
        }
    }

    /**
     * Helper method untuk dapatkan nama file dari Part
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String content : contentDisp.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 2, content.length() - 1);
            }
        }
        return "receipt.png";
    }
}
