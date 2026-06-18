package com.lab.controller;

import com.lab.dao.BookingDAO;
import com.lab.dao.StationDAO;
import com.lab.model.Station;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AjkServlet")
public class AjkServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        BookingDAO bDao = new BookingDAO();
        StationDAO sDao = new StationDAO();

        try {
            // approve booking
            if ("approve".equals(action)) {
                String bookingId = request.getParameter("bookingId");
                if (bDao.updateBookingStatus(bookingId, "approved")) {
                    response.sendRedirect("rolesAjk/dashboardAjk.jsp?msg=approved");
                    return;
                }
            
            // reject booking
            } else if ("reject".equals(action)) {
                String bookingId = request.getParameter("bookingId");
                String stationId = request.getParameter("stationId"); // Hantar stationId dlm form reject
                String rejectReason = request.getParameter("rejectReason"); // Added field to capture reason text

                // Panggil method dlm BookingDAO
                if (bDao.rejectAndReleaseSlot(bookingId, stationId)) {
                    // Note: If your DAO method is updated to save the reason text, you can pass 'rejectReason' into it.
                    response.sendRedirect(request.getContextPath() + "/rolesAjk/dashboardAjk.jsp?msg=rejected");
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("rolesAjk/dashboardAjk.jsp?error=1");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
