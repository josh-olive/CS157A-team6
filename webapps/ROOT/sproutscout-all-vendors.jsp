<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Our Vendors</title>
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

        /* Vendor Cards Grid Container */
        .vendor-grid-container {
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

        .vendor-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        /* Individual Vendor Card */
        .vendor-card {
            background: #ffffff;
            border-radius: 10px;
            border: 1px solid #c8e6c9;
            box-shadow: 0 3px 10px rgba(46, 111, 64, 0.05);
            padding: 22px;
            display: flex;
            flex-direction: column;
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
            margin-bottom: 12px;
        }

        .vendor-name {
            font-size: 1.3rem;
            font-weight: bold;
            color: #2e6f40;
            margin: 0 0 8px 0;
        }

        .vendor-email {
            font-size: 0.85rem;
            color: #5c7561;
            margin-top: auto;
            border-top: 1px solid #e8f5e9;
            padding-top: 10px;
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

        <!-- Hero Section -->
        <div class="hero-section">
            <h1 class="title">Our Vendors</h1>
            <p class="subtitle">Explore local creators, farmers, and culinary partners featured at SproutScout.</p>
            <input 
                type="text" 
                id="searchVendorInput" 
                class="search-bar" 
                placeholder="Search vendors by name..." 
                onkeyup="filterVendors()"
            />
        </div>

        <!-- Vendor Cards Grid Container -->
        <div class="vendor-grid-container">
            <h2 class="section-heading">All Registered Vendors</h2>

            <ul class="vendor-grid" id="vendorList">
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

                        // Querying Name and Type from your vendor table
                        rs = stmt.executeQuery("SELECT Name, Type, UserEmail FROM sproutscout.vendor");

                        boolean hasResults = false;
                        while(rs.next()) {
                            hasResults = true;
                            String name = rs.getString("Name");
                            String type = rs.getString("Type");
                            String email = rs.getString("UserEmail");
                %>
                            <li class="vendor-card">
                                <span class="vendor-type-badge"> 🔖 <%= (type != null ? type : "General Vendor") %></span>
                                <h3 class="vendor-name"><%= name %></h3>
                                <div class="vendor-email">
                                    <strong>Contact:</strong> <%= email %>
                                </div>
                            </li>
                <%
                        }

                        if (!hasResults) {
                            out.println("<li class='no-results'>No vendors found in table 'vendor'.</li>");
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

    <!-- Live Search Filtering Script -->
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

        function filterVendors() {
            var input = document.getElementById("searchVendorInput");
            var filter = input.value.toLowerCase();
            var ul = document.getElementById("vendorList");
            var li = ul.getElementsByClassName("vendor-card");

            for (var i = 0; i < li.length; i++) {
                var nameEl = li[i].getElementsByClassName("vendor-name")[0];
                var textValue = nameEl.textContent || nameEl.innerText;
                
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