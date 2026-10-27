<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Our Vendors</title>
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

        <!-- Seach Section -->
        <div class="search-section">
            <h1 class="title">Our Vendors</h1>
            <p class="subtitle">Explore local creators, farmers, and culinary partners featured by SproutScout.</p>
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

                        // Query Name, Type, and UserEmail columns from vendor table
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

    <footer class="footer">
        <p>&copy; 2026 SproutScout. Connecting communities with local farmers markets.</p>
    </footer>

    <!-- Login Box popup & Live Search Filtering Script -->
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