<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Market Vendors & Storefront</title>
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
            max-width: 1400px;
            width: 95%;
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

        /* Product Search Bar inside Storefront */
        .store-search-bar {
            width: 100%;
            padding: 10px 16px;
            font-size: 0.95rem;
            border: 2px solid #c8e6c9;
            border-radius: 20px;
            outline: none;
            background-color: #fafdfa;
            color: #2e6f40;
            margin-bottom: 20px;
        }

        .store-search-bar:focus {
            border-color: #4CAF50;
            background-color: #ffffff;
            box-shadow: 0 2px 6px rgba(76, 175, 80, 0.15);
        }

        /* Original 1-Column Grid Layout */
        .vendor-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .vendor-card-link {
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
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
            height: 100%;
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

        /* Dynamic 2-Column Split Layout */
        .storefront-container {
            display: grid;
            grid-template-columns: 350px 1fr;
            gap: 30px;
            align-items: start;
        }

        .vendor-sidebar {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #c8e6c9;
            box-shadow: 0 3px 10px rgba(46, 111, 64, 0.05);
            padding: 20px;
            max-height: 80vh;
            overflow-y: auto;
        }

        .sidebar-heading {
            font-size: 1.2rem;
            color: #2e6f40;
            margin-top: 0;
            margin-bottom: 15px;
            border-bottom: 2px solid #e8f5e9;
            padding-bottom: 8px;
            font-weight: bold;
        }

        .vendor-nav-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .vendor-nav-item {
            padding: 12px 15px;
            border-radius: 8px;
            border: 1px solid #e8f5e9;
            background-color: #fafdfa;
            text-decoration: none;
            color: #2c3e50;
            display: flex;
            flex-direction: column;
            gap: 4px;
            transition: all 0.2s ease;
        }

        .vendor-nav-item:hover {
            border-color: #4CAF50;
            background-color: #f1f8f1;
        }

        .vendor-nav-item.active {
            border-color: #2e6f40;
            background-color: #e8f5e9;
            box-shadow: 0 2px 6px rgba(46, 111, 64, 0.1);
        }

        .nav-vendor-name {
            font-weight: bold;
            color: #2e6f40;
            font-size: 1rem;
        }

        .nav-vendor-type {
            font-size: 0.8rem;
            color: #5c7561;
        }

        .storefront-main {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #c8e6c9;
            box-shadow: 0 3px 10px rgba(46, 111, 64, 0.05);
            padding: 30px;
            min-height: 400px;
        }

        .storefront-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #d4ede1;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }

        .storefront-title {
            font-size: 2rem;
            color: #2e6f40;
            margin: 0 0 5px 0;
            font-weight: bold;
        }

        .storefront-subtitle {
            font-size: 1rem;
            color: #5c7561;
            margin: 0;
        }

        .return-vendors-btn {
            background-color: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #a5d6a7;
            padding: 8px 14px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            font-size: 0.9rem;
            transition: background-color 0.2s;
            white-space: nowrap;
        }

        .return-vendors-btn:hover {
            background-color: #c8e6c9;
            color: #1b5e20;
        }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 20px;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        /* Centered Product Card Styles */
        .product-card {
            background: #fafdfa;
            border-radius: 10px;
            border: 1px solid #c8e6c9;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            justify-content: space-between;
            box-shadow: 0 2px 6px rgba(46, 111, 64, 0.03);
            transition: transform 0.2s ease;
        }

        .product-card:hover {
            transform: translateY(-3px);
            border-color: #4CAF50;
        }

        .product-name {
            font-size: 1.15rem;
            font-weight: bold;
            color: #2e6f40;
            margin: 0 0 8px 0;
        }

        .product-desc {
            font-size: 0.85rem;
            color: #5c7561;
            margin: 0 0 15px 0;
            line-height: 1.4;
        }

        .product-footer {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            border-top: 1px solid #e8f5e9;
            padding-top: 12px;
            width: 100%;
        }

        .product-price {
            font-size: 1.2rem;
            font-weight: bold;
            color: #27ae60;
        }

        .no-vendors, .no-products {
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
            <li><a href="sproutscout-home.jsp">Markets</a></li>
            <li><a href="sproutscout-all-vendors.jsp">Vendors</a></li>
            <li><a href="sproutscout-about.jsp">About Us</a></li>
            <li><a class="login-nav-btn" href="sproutscout-home.jsp">Login</a></li>
        </ul>
    </nav>

    <div class="main-content">
        <%
            String eventIdParam = request.getParameter("id"); 
            String selectedVendor = request.getParameter("vendor"); 
            
            String dbUrl = "jdbc:mysql://localhost:3306/sproutscout?autoReconnect=true&useSSL=false";
            String dbUser = "root";
            String dbPass = "database1234";

            Connection con = null;
            PreparedStatement eventStmt = null;
            PreparedStatement vendorStmt = null;
            PreparedStatement prodStmt = null;
            ResultSet eventRs = null;
            ResultSet vendorRs = null;
            ResultSet prodRs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                // 1. Fetch Event Header Details
                String eventSql = "SELECT Name, Address, `Date/Time` FROM sproutscout.event WHERE EventId = ?";
                eventStmt = con.prepareStatement(eventSql);
                eventStmt.setString(1, eventIdParam);
                eventRs = eventStmt.executeQuery();

                if (eventRs.next()) {
                    String marketName = eventRs.getString("Name");
                    String address = eventRs.getString("Address");
                    String dateTime = eventRs.getString("Date/Time");
        %>

                <!-- Back button to home if no vendor selected, otherwise back to vendor list view -->
                <% if (selectedVendor == null || selectedVendor.trim().isEmpty()) { %>
                    <a href="sproutscout-home.jsp" class="back-btn">&larr; Back to All Markets</a>
                <% } else { %>
                    <a href="sproutscout-vendors.jsp?id=<%= eventIdParam %>" class="back-btn">&larr; Back to All Vendors</a>
                <% } %>

                <div class="market-banner">
                    <h1 class="market-title"><%= marketName %></h1>
                    <p class="market-info-row"><strong>Location:</strong> <%= (address != null ? address : "Address unavailable") %></p>
                    <% if (dateTime != null && !dateTime.trim().isEmpty()) { %>
                        <p class="market-info-row"><strong>Date & Time:</strong> <%= dateTime %></p>
                    <% } %>
                    <p class="market-info-row"><strong>Rating:</strong> &#9733; 4.8</p>
                </div>

                <% if (selectedVendor == null || selectedVendor.trim().isEmpty()) { %>
                    <h2 class="section-heading">Vendors Attending This Market</h2>

                    <ul class="vendor-grid">
                        <%
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
                                <li>
                                    <a href="sproutscout-vendors.jsp?id=<%= eventIdParam %>&vendor=<%= java.net.URLEncoder.encode(vName, "UTF-8") %>" class="vendor-card-link">
                                        <div class="vendor-card">
                                            <span class="vendor-type-badge">🔖 <%= (vType != null ? vType : "Vendor") %></span>
                                            <h3 class="vendor-name"><%= vName %></h3>
                                            <div class="vendor-rating">&#9733; 4.9</div>
                                        </div>
                                    </a>
                                </li>
                        <%
                            }

                            if (!hasVendors) {
                                out.println("<li class='no-vendors'>No vendors currently attending this market.</li>");
                            }
                        %>
                    </ul>

                <% } else { %>
                    <!-- Dynamic 2-Column Storefront Layout Upon Click -->
                    <div class="storefront-container">
                        
                        <!-- Left Column: Attending Vendors List -->
                        <div class="vendor-sidebar">
                            <h3 class="sidebar-heading">Attending Vendors</h3>
                            <ul class="vendor-nav-list">
                                <%
                                    String sidebarSql = "SELECT v.Name, v.Type " +
                                                        "FROM sproutscout.attends a " +
                                                        "JOIN sproutscout.vendor v ON a.VendorName = v.Name " +
                                                        "WHERE a.EventID = ?";
                                    PreparedStatement sideStmt = con.prepareStatement(sidebarSql);
                                    sideStmt.setString(1, eventIdParam);
                                    ResultSet sideRs = sideStmt.executeQuery();

                                    while(sideRs.next()) {
                                        String sName = sideRs.getString("Name");
                                        String sType = sideRs.getString("Type");
                                        boolean isActive = selectedVendor.equals(sName);
                                %>
                                        <li>
                                            <a href="sproutscout-vendors.jsp?id=<%= eventIdParam %>&vendor=<%= java.net.URLEncoder.encode(sName, "UTF-8") %>" 
                                               class="vendor-nav-item <%= isActive ? "active" : "" %>">
                                                <span class="nav-vendor-name"><%= sName %></span>
                                                <span class="nav-vendor-type">🔖 <%= (sType != null ? sType : "Vendor") %></span>
                                            </a>
                                        </li>
                                <%
                                    }
                                    if (sideRs != null) sideRs.close();
                                    if (sideStmt != null) sideStmt.close();
                                %>
                            </ul>
                        </div>

                        <!-- Right Column: Storefront Products Panel with Live Search -->
                        <div class="storefront-main">
                            <div class="storefront-header-row">
                                <div>
                                    <h2 class="storefront-title"><%= selectedVendor %></h2>
                                    <p class="storefront-subtitle">Products currently available from this vendor's storefront.</p>
                                </div>
                                <a href="sproutscout-vendors.jsp?id=<%= eventIdParam %>" class="return-vendors-btn">&larr; Back to Vendors</a>
                            </div>

                            <!-- Live Product Search Input Field -->
                            <input 
                                type="text" 
                                id="productSearchInput" 
                                class="store-search-bar" 
                                placeholder="Search products in this storefront..." 
                                onkeyup="filterProducts()"
                            />

                            <ul class="product-grid" id="productList">
                                <%
                                    // Query products using Name column (matching product table schema)
                                    String productSql = "SELECT p.Name, p.Description, s.Price " +
                                                        "FROM sproutscout.vendor v " +
                                                        "JOIN sproutscout.stock s ON v.InventoryId = s.InventoryId " +
                                                        "JOIN sproutscout.product p ON s.ProductId = p.ProductId " +
                                                        "WHERE v.Name = ?";
                                    
                                    prodStmt = con.prepareStatement(productSql);
                                    prodStmt.setString(1, selectedVendor);
                                    prodRs = prodStmt.executeQuery();

                                    boolean hasProducts = false;
                                    while(prodRs.next()) {
                                        hasProducts = true;
                                        String pName = prodRs.getString("Name");
                                        String pDesc = prodRs.getString("Description");
                                        double pPrice = prodRs.getDouble("Price");
                                %>
                                        <li class="product-card">
                                            <div>
                                                <h4 class="product-name"><%= pName %></h4>
                                                <p class="product-desc"><%= (pDesc != null ? pDesc : "Fresh quality item available at our booth.") %></p>
                                            </div>
                                            <div class="product-footer">
                                                <span class="product-price">$<%= String.format("%.2f", pPrice) %></span>
                                            </div>
                                        </li>
                                <%
                                    }

                                    if (!hasProducts) {
                                        out.println("<li class='no-products'>No products currently listed for this vendor.</li>");
                                    }
                                %>
                            </ul>
                        </div>

                    </div>
                <% } %>

        <%
                } else {
                    out.println("<div class='error-msg'>Market event not found for ID: " + eventIdParam + "</div>");
                }

            } catch(Exception e) {
                out.println("<div class='error-msg'>Database Error: " + e.getMessage() + "</div>");
            } finally {
                if (eventRs != null) try { eventRs.close(); } catch(SQLException ignored) {}
                if (vendorRs != null) try { vendorRs.close(); } catch(SQLException ignored) {}
                if (prodRs != null) try { prodRs.close(); } catch(SQLException ignored) {}
                if (eventStmt != null) try { eventStmt.close(); } catch(SQLException ignored) {}
                if (vendorStmt != null) try { vendorStmt.close(); } catch(SQLException ignored) {}
                if (prodStmt != null) try { prodStmt.close(); } catch(SQLException ignored) {}
                if (con != null) try { con.close(); } catch(SQLException ignored) {}
            }
        %>
    </div>

    <footer class="footer">
        <p>&copy; 2026 SproutScout. Connecting communities with local farmers markets.</p>
    </footer>

    <!-- JavaScript for Live Product Filtering -->
    <script>
        function filterProducts() {
            var input = document.getElementById("productSearchInput");
            var filter = input.value.toLowerCase();
            var ul = document.getElementById("productList");
            var li = ul.getElementsByClassName("product-card");

            for (var i = 0; i < li.length; i++) {
                var nameEl = li[i].getElementsByClassName("product-name")[0];
                var descEl = li[i].getElementsByClassName("product-desc")[0];
                var textValue = (nameEl.textContent || nameEl.innerText) + " " + (descEl.textContent || descEl.innerText);
                
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