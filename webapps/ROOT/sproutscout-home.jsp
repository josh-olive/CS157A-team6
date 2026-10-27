<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Discover Local Farmers Markets</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        html {
            scroll-behavior: smooth;
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

        /* Top Navigation Bar */
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
            transition: background-color 0.2s ease;
        }

        .login-nav-btn:hover {
            background-color: #21522f !important;
            color: white !important;
        }

        /* Main Container Content */
        .main-content {
            flex: 1;
            padding: 40px;
        }

        /* Pop-up Modal Overlay */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.35);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        /* Modal Box Content */
        .login-modal-box {
            background-color: #ffffff;
            border-radius: 12px;
            padding: 28px;
            width: 360px;
            position: relative;
            border: 2px solid #4CAF50;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
            animation: modalPop 0.2s ease-in-out;
        }

        @keyframes modalPop {
            from { transform: scale(0.92); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        .close-btn {
            position: absolute;
            top: 15px;
            right: 18px;
            font-size: 1.5rem;
            font-weight: bold;
            color: #2e6f40;
            cursor: pointer;
            line-height: 1;
        }

        .close-btn:hover {
            color: #1b4326;
        }

        .login-modal-box h3 {
            margin-top: 0;
            color: #2e6f40;
            font-size: 1.4rem;
            margin-bottom: 18px;
            border-bottom: 2px solid #e8f5e9;
            padding-bottom: 8px;
        }

        .login-modal-box select,
        .login-modal-box input[type="email"],
        .login-modal-box input[type="password"] {
            width: 100%;
            padding: 10px 12px;
            margin-bottom: 14px;
            border: 2px solid #c8e6c9;
            border-radius: 6px;
            outline: none;
            font-size: 0.95rem;
            color: #2e6f40;
            background-color: #fafdfa;
        }

        .login-modal-box select:focus,
        .login-modal-box input:focus {
            border-color: #4CAF50;
            background-color: #ffffff;
        }

        .btn-group {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-top: 5px;
        }

        .btn {
            flex: 1;
            padding: 10px 5px;
            border: none;
            background-color: #2e6f40;
            color: white;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: bold;
            cursor: pointer;
            text-align: center;
        }

        .btn:hover {
            background-color: #21522f;
        }

        .btn-secondary {
            background-color: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #a5d6a7;
            text-decoration: none;
            display: inline-block;
            line-height: 1.4;
            padding-top: 9px;
        }

        .btn-secondary:hover {
            background-color: #c8e6c9;
            color: #1b5e20;
        }

        /* Hero Section */
        .hero-section {
            text-align: center;
            margin-top: 20px;
            margin-bottom: 40px;
        }

        .title {
            font-size: 4rem;
            font-weight: bold;
            color: #2e6f40;
            margin: 0 0 10px 0;
            letter-spacing: -1px;
        }

        .subtitle {
            font-size: 1.1rem;
            color: #4a7c59;
            margin-bottom: 25px;
            font-weight: 500;
        }

        .search-bar {
            width: 60%;
            max-width: 600px;
            padding: 14px 22px;
            font-size: 1.05rem;
            border: 2px solid #4CAF50;
            border-radius: 30px;
            outline: none;
            background-color: #ffffff;
            box-shadow: 0 3px 8px rgba(76, 175, 80, 0.15);
            color: #2e6f40;
        }

        .search-bar::placeholder {
            color: #61af64;
        }

        .search-bar:focus {
            box-shadow: 0 3px 12px rgba(76, 175, 80, 0.3);
            border-color: #2e6f40;
        }

        /* Market Cards Grid Container */
        .market-grid-container {
            width: 90%;
            max-width: 1200px;
            margin: 0 auto 50px auto;
        }

        .section-heading {
            font-size: 1.5rem;
            color: #2e6f40;
            margin-bottom: 20px;
            font-weight: bold;
            border-bottom: 2px solid #d4ede1;
            padding-bottom: 8px;
        }

        .market-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 20px;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        /* Individual Market Card Style */
        .market-card {
            background: #ffffff;
            border-radius: 10px;
            border: 1px solid #c8e6c9;
            box-shadow: 0 3px 10px rgba(46, 111, 64, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .market-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 6px 18px rgba(76, 175, 80, 0.2);
            border-color: #4CAF50;
        }

        .market-link {
            text-decoration: none;
            color: inherit;
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        /* Card Header - Aligns Name on Left & Rating on Right */
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 10px;
        }

        .market-name {
            font-size: 1.25rem;
            font-weight: bold;
            color: #2e6f40;
            margin: 0;
            flex-grow: 1;
        }

        .market-rating {
            color: #f39c12;
            font-size: 0.9rem;
            font-weight: bold;
            white-space: nowrap;
            padding-top: 2px;
        }

        .market-address {
            font-size: 0.9rem;
            color: #4a5d4e;
            margin-top: 5px;
            line-height: 1.4;
        }

        .market-meta {
            font-size: 0.85rem;
            color: #5c7561;
            margin-top: 10px;
            border-top: 1px solid #e8f5e9;
            padding-top: 8px;
        }

        .error-msg {
            grid-column: 1 / -1;
            color: #c0392b;
            background-color: #fadbd8;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
        }

        .no-results {
            grid-column: 1 / -1;
            text-align: center;
            color: #4a7c59;
            padding: 30px;
            font-style: italic;
        }

        /* Dark Green Footer */
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

    <!-- Pop-up Login Modal -->
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

        <!-- Title + Subtitle + Search Bar Hero Section -->
        <div class="hero-section">
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

        <!-- Markets Professional Grid Container -->
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

                        // Querying columns from your event table
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

    <!-- Dark Green Footer -->
    <footer class="footer">
        <p>&copy; 2026 SproutScout. Connecting communities with local farmers markets.</p>
    </footer>

    <!-- JavaScript for Modal and Live Search -->
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