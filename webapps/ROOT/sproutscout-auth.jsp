<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String action = request.getParameter("action");

    if ("login".equalsIgnoreCase(action)) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String userType = request.getParameter("userType");

        String dbUrl = "jdbc:mysql://localhost:3306/sproutscout?autoReconnect=true&useSSL=false";
        String dbUser = "root";
        String dbPass = "database1234";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            
            // Utilizes an SQL query statement to check if the entered email and password exist in the User table in our database.
            PreparedStatement stmt = con.prepareStatement("SELECT * FROM User WHERE Email = ? AND Password = ?")) {
                
            stmt.setString(1, email);
            stmt.setString(2, password);
                
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    session.setAttribute("userEmail", email);
                    session.setAttribute("userType", userType);
                    response.sendRedirect("sproutscout-home.jsp");
                    return;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("sproutscout-home.jsp?error=invalid_login");

    } else if ("logout".equalsIgnoreCase(action)) {
        HttpSession userSession = request.getSession(false);
        if (userSession != null) {
            userSession.invalidate(); // Destroy session
        }
        response.sendRedirect("sproutscout-home.jsp");
    } else {
        response.sendRedirect("sproutscout-home.jsp");
    }
%>