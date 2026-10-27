<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Discover Local Farmers Markets</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

    <!-- Top Navigation Bar -->
    <nav class="navbar">
        <a href="sproutscout-home.jsp" class="nav-brand">🌱 SproutScout</a>
        <ul class="nav-links">
            <li><a href="sproutscout-home.jsp">Markets</a></li>
            <li><a href="sproutscout-all-vendors.jsp">Vendors</a></li>
            <li><a href="sproutscout-about.jsp">About Us</a></li>
            <li><a class="login-nav-btn" onclick="openLoginModal()">Login</a></li>
        </ul>
    </nav>

    <!-- Pop-up Login Box -->
    <div id="loginModal" class="modal-overlay">
        <div class="login-modal-box">
            <span class="close-btn" onclick="closeLoginModal()">&times;</span>
            <h3>Account Login</h3>
            <form action="login" method="post">
                <select name="userType" required>
                    <option value="" disabled selected>Select user type...</option>
                    <option value="Customer">Customer</option>
                    <option value="Vendor">Vendor</option>
                    <option value="Supplier">Supplier</option>
                </select>
                <input type="email" name="email" placeholder="Email Address" required />
                <input type="password" name="password" placeholder="Password" required />
                <div class="btn-group">
                    <button type="submit" class="btn">Login</button>
                    <a href="sproutscout-register.jsp" class="btn btn-secondary">Create Account</a>
                </div>
            </form>
        </div>
    </div>

    <div class="main-content">

        <!-- Title + Subtitle + Search Bar Section -->
        <div class="search-section">
            <h1 class="title">SproutScout</h1>
            <p class="subtitle">Discover fresh local produce, community farmers markets, and vendors near you.</p>
            <input 
                type="text" 
                id="searchInput" 
                class="search-bar" 
                placeholder="Search for available farmers markets..." 
                onkeyup="filterMarkets()"
            />
        </div>

        <!-- Markets Grid Container -->
        <div class="market-grid-container" id="marketsSection">
            <h2 class="section-heading">Available Farmers Markets</h2>

            <ul class="market-grid" id="marketList">
                <%
                    String dbUrl = "jdbc:mysql://localhost:3306/sproutscout?autoReconnect=true&useSSL=false";
                    String dbUser = "root";
                    String dbPass = "database1234";

                    Connection con = null;
                    Statement stmt = null;
                    ResultSet rs = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                        stmt = con.createStatement();

                        // Query EventId, Name, Address, Date/Time columns from event table
                        rs = stmt.executeQuery("SELECT EventId, Name, Address, `Date/Time` FROM sproutscout.event");

                        boolean hasResults = false;
                        
                        while(rs.next()) {
                            hasResults = true;
                            int eventId = rs.getInt("EventId");
                            String name = rs.getString("Name");
                            String address = rs.getString("Address");
                            String dateTime = rs.getString("Date/Time");
                %>
                            <li class="market-card">
                                <!-- eventid from the event table passed into the URL query string -->
                                <a href="sproutscout-vendors.jsp?id=<%= eventId %>" class="market-link">
                                    <div class="card-header">
                                        <h3 class="market-name"><%= name %></h3>
                                        <span class="market-rating">&#9733; 4.8</span>
                                    </div>
                                    <p class="market-address">
                                        <strong>Location:</strong> <%= (address != null && !address.trim().isEmpty() ? address : "Address unavailable") %>
                                    </p>
                                    <% if (dateTime != null && !dateTime.trim().isEmpty()) { %>
                                        <div class="market-meta">
                                            <strong>Date/Time:</strong> <%= dateTime %>
                                        </div>
                                    <% } %>
                                </a>
                            </li>
                <%
                        }

                        if (!hasResults) {
                            out.println("<li class='no-results'>No events found in table 'event'.</li>");
                        }

                    } catch(Exception e) {
                        out.println("<div class='error-msg'>Database Connection Error: " + e.getMessage() + "</div>");
                    } finally {
                        if (rs != null) try { rs.close(); } catch(SQLException ignored) {}
                        if (stmt != null) try { stmt.close(); } catch(SQLException ignored) {}
                        if (con != null) try { con.close(); } catch(SQLException ignored) {}
                    }
                %>
            </ul>
        </div>

    </div>

    <footer class="footer">
        <p>&copy; 2026 SproutScout. Connecting communities with local farmers markets.</p>
    </footer>

    <!-- Login Box popup & Live Market Search Script -->
    <script>
        function openLoginModal() {
            document.getElementById('loginModal').style.display = 'flex';
        }

        function closeLoginModal() {
            document.getElementById('loginModal').style.display = 'none';
        }

        window.onclick = function(event) {
            var modal = document.getElementById('loginModal');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }

        function filterMarkets() {
            var input = document.getElementById("searchInput");
            var filter = input.value.toLowerCase();
            var ul = document.getElementById("marketList");
            var li = ul.getElementsByClassName("market-card");

            for (var i = 0; i < li.length; i++) {
                var nameEl = li[i].getElementsByClassName("market-name")[0];
                var addrEl = li[i].getElementsByClassName("market-address")[0];
                var textValue = (nameEl.textContent || nameEl.innerText) + " " + (addrEl.textContent || addrEl.innerText);
                
                if (textValue.toLowerCase().indexOf(filter) > -1) {
                    li[i].style.display = "";
                } else {
                    li[i].style.display = "none";
                }
            }
        }
    </script>

</body>
</html>