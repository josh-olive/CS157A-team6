<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Market Vendors</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            margin: 0;
            padding: 0;
            background-color: #f4f9f4;
            color: #2c3e50;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #ffffff;
            padding: 15px 40px;
            border-bottom: 2px solid #e2f0e3;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }

        .nav-brand {
            font-size: 1.5rem;
            font-weight: bold;
            color: #2e6f40;
            text-decoration: none;
        }

        .nav-links {
            display: flex;
            gap: 25px;
            list-style: none;
            margin: 0;
            padding: 0;
            align-items: center;
        }

        .nav-links a {
            text-decoration: none;
            color: #2e6f40;
            font-weight: 600;
            font-size: 0.95rem;
            transition: color 0.2s;
            cursor: pointer;
        }

        .nav-links a:hover {
            color: #1b4326;
        }

        .login-nav-btn {
            background-color: #2e6f40;
            color: white !important;
            padding: 8px 18px;
            border-radius: 6px;
        }

        .main-content {
            flex: 1;
            padding: 40px;
            max-width: 1200px;
            width: 90%;
            margin: 0 auto;
        }

        .back-btn {
            display: inline-block;
            color: #2e6f40;
            text-decoration: none;
            font-weight: bold;
            margin-bottom: 20px;
            font-size: 0.95rem;
        }

        .back-btn:hover {
            text-decoration: underline;
        }

        .market-banner {
            background: #ffffff;
            border-radius: 12px;
            padding: 30px;
            border: 2px solid #c8e6c9;
            box-shadow: 0 4px 15px rgba(46, 111, 64, 0.06);
            margin-bottom: 40px;
        }

        .market-title {
            font-size: 2.2rem;
            color: #2e6f40;
            margin: 0 0 10px 0;
            font-weight: bold;
        }

        .market-info-row {
            font-size: 1.05rem;
            color: #4a5d4e;
            margin: 6px 0;
        }

        .section-heading {
            font-size: 1.5rem;
            color: #2e6f40;
            margin-bottom: 20px;
            font-weight: bold;
            border-bottom: 2px solid #d4ede1;
            padding-bottom: 8px;
        }

        .vendor-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .vendor-card {
            background: #ffffff;
            border-radius: 10px;
            border: 1px solid #c8e6c9;
            box-shadow: 0 3px 10px rgba(46, 111, 64, 0.05);
            padding: 22px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .vendor-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 6px 18px rgba(76, 175, 80, 0.2);
            border-color: #4CAF50;
        }

        .vendor-type-badge {
            align-self: flex-start;
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
            border: 1px solid #c8e6c9;
            margin-bottom: 10px;
        }

        .vendor-name {
            font-size: 1.3rem;
            font-weight: bold;
            color: #2e6f40;
            margin: 0;
        }

        .vendor-rating {
            color: #f39c12;
            font-size: 0.9rem;
            font-weight: bold;
            margin-top: 8px;
        }

        .no-vendors {
            grid-column: 1 / -1;
            text-align: center;
            color: #4a7c59;
            padding: 30px;
            font-style: italic;
            background: #ffffff;
            border-radius: 8px;
            border: 1px dashed #c8e6c9;
        }

        .error-msg {
            color: #c0392b;
            background-color: #fadbd8;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
        }

        .footer {
            background-color: #1b4326;
            color: #e8f5e9;
            text-align: center;
            padding: 25px 40px;
            margin-top: auto;
            font-size: 0.9rem;
            border-top: 3px solid #2e6f40;
        }

        .footer p {
            margin: 0;
        }
    </style>
</head>
<body>

    <nav class="navbar">
        <a href="sproutscout-home.jsp" class="nav-brand">🌱 SproutScout</a>
        <ul class="nav-links">
            <li><a href="sproutscout-home.jsp">Home</a></li>
            <li><a href="sproutscout-vendors.jsp">Vendors</a></li>
            <li><a href="sproutscout-about.jsp">About Us</a></li>
            <li><a class="login-nav-btn" href="sproutscout-home.jsp">Login</a></li>
        </ul>
    </nav>

    <div class="main-content">
        <a href="sproutscout-home.jsp" class="back-btn">&larr; Back to All Markets</a>

        <%
            String eventIdParam = request.getParameter("id"); //get eventid from the url query parameter
            String dbUrl = "jdbc:mysql://localhost:3306/sproutscout?autoReconnect=true&useSSL=false";
            String dbUser = "root";
            String dbPass = "database1234";

            Connection con = null;
            PreparedStatement eventStmt = null;
            PreparedStatement vendorStmt = null;
            ResultSet eventRs = null;
            ResultSet vendorRs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                // 1. Fetch Event Header Details
                String eventSql = "SELECT Name, Address, `Date/Time` FROM sproutscout.event WHERE EventId = ?";
                eventStmt = con.prepareStatement(eventSql);
                eventStmt.setString(1, eventIdParam); //set the eventid as a placeholder value to reference below in attends/vendors tables
                eventRs = eventStmt.executeQuery();

                if (eventRs.next()) {
                    String marketName = eventRs.getString("Name");
                    String address = eventRs.getString("Address");
                    String dateTime = eventRs.getString("Date/Time");
        %>

                <div class="market-banner">
                    <h1 class="market-title"><%= marketName %></h1>
                    <p class="market-info-row"><strong>Location:</strong> <%= (address != null ? address : "Address unavailable") %></p>
                    <% if (dateTime != null && !dateTime.trim().isEmpty()) { %>
                        <p class="market-info-row"><strong>Date & Time:</strong> <%= dateTime %></p>
                    <% } %>
                    <p class="market-info-row"><strong>Rating:</strong> &#9733; 4.8</p>
                </div>

                <h2 class="section-heading">Vendors Attending This Market</h2>

                <ul class="vendor-grid">
                    <%
                        // 2. Fetch Vendors Attending This Event via Join
                        String vendorSql = "SELECT v.Name, v.Type " +
                                           "FROM sproutscout.attends a " +
                                           "JOIN sproutscout.vendor v ON a.VendorName = v.Name " +
                                           "WHERE a.EventID = ?";
                        vendorStmt = con.prepareStatement(vendorSql);
                        vendorStmt.setString(1, eventIdParam);
                        vendorRs = vendorStmt.executeQuery();

                        boolean hasVendors = false;
                        while(vendorRs.next()) {
                            hasVendors = true;
                            String vName = vendorRs.getString("Name");
                            String vType = vendorRs.getString("Type");
                    %>
                            <li class="vendor-card">
                                <span class="vendor-type-badge">🏷️ <%= (vType != null ? vType : "Vendor") %></span>
                                <h3 class="vendor-name"><%= vName %></h3>
                                <div class="vendor-rating">&#9733; 4.9</div>
                            </li>
                    <%
                        }

                        if (!hasVendors) {
                            out.println("<li class='no-vendors'>No vendors currently attending this market.</li>");
                        }
                    %>
                </ul>

        <%
                } else {
                    out.println("<div class='error-msg'>Market event not found for ID: " + eventIdParam + "</div>");
                }

            } catch(Exception e) {
                out.println("<div class='error-msg'>Database Error: " + e.getMessage() + "</div>");
            } finally {
                if (eventRs != null) try { eventRs.close(); } catch(SQLException ignored) {}
                if (vendorRs != null) try { vendorRs.close(); } catch(SQLException ignored) {}
                if (eventStmt != null) try { eventStmt.close(); } catch(SQLException ignored) {}
                if (vendorStmt != null) try { vendorStmt.close(); } catch(SQLException ignored) {}
                if (con != null) try { con.close(); } catch(SQLException ignored) {}
            }
        ?>
    </div>

    <footer class="footer">
        <p>&copy; 2026 SproutScout. Connecting communities with local farmers markets.</p>
    </footer>

</body>
</html>