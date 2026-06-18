package com.lab.controller;

import com.lab.dao.StationDAO;
import com.lab.model.Station;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/StationServlet")
public class StationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        StationDAO dao = new StationDAO();

        try {
            // YOUR AJK MODULE ACTION: ADD NEW STATION
            if ("add".equals(action)) {
                Station s = new Station();
                s.setStationId(request.getParameter("stationId"));
                s.setStationName(request.getParameter("stationName"));
                s.setPricingId(request.getParameter("pricingId"));
                s.setSpecifications(request.getParameter("specifications")); // Pastikan line ni ada
                s.setStatus(request.getParameter("status"));

                if (dao.addStation(s)) {
                    // Updated with context pathing to ensure it drops into your correct AJK dashboard folder
                    response.sendRedirect(request.getContextPath() + "/rolesAjk/dashboardAjk.jsp?msg=added");
                } else {
                    response.sendRedirect(request.getContextPath() + "/rolesAjk/addStation.jsp?error=failed");
                }
            }
           
            // YOUR AJK MODULE ACTION: UPDATE STATION
            
            else if ("update".equals(action)) {
                Station s = new Station();
                s.setStationId(request.getParameter("stationId"));
                s.setPricingId(request.getParameter("pricingId"));
                s.setStationName(request.getParameter("stationName"));
                s.setSpecifications(request.getParameter("specifications"));
                s.setStatus(request.getParameter("status"));

                if (dao.updateStation(s)) {
                    response.sendRedirect(request.getContextPath() + "/rolesAjk/dashboardAjk.jsp?msg=updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/rolesAjk/editStation.jsp?id=" + s.getStationId() + "&error=failed");
                }
            } 
            
           
            // YOUR AJK MODULE ACTION: DELETE STATION
            
            else if ("delete".equals(action)) {
                String id = request.getParameter("stationId");
                if (dao.deleteStation(id)) {
                    response.sendRedirect(request.getContextPath() + "/rolesAjk/dashboardAjk.jsp?msg=deleted");
                } else {
                    response.sendRedirect(request.getContextPath() + "/rolesAjk/dashboardAjk.jsp?error=delete_failed");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/error.jsp");
        }
    }
}