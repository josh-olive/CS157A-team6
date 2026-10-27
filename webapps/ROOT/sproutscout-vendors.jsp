<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Market Vendors & Storefront</title>
    <link rel="stylesheet" href="styles.css">
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

                // Query Event Header details from event table (Name, Address, Date/Time)
                String eventSql = "SELECT Name, Address, `Date/Time` FROM sproutscout.event WHERE EventId = ?";
                eventStmt = con.prepareStatement(eventSql);
                eventStmt.setString(1, eventIdParam);
                eventRs = eventStmt.executeQuery();

                if (eventRs.next()) {
                    String marketName = eventRs.getString("Name");
                    String address = eventRs.getString("Address");
                    String dateTime = eventRs.getString("Date/Time");
        %>

                <!-- Back button to home if no vendor selected, otherwise back to vendor list view from product view -->
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
                            // Query vendors attending the selected event (Join Vendor and Attends using matching EventID)
                                // event: EventId, Name
                                // attends: VendorName, EventId
                                // vendor: VendorName, Type
                            // Use URL eventID placeholder from event table to check attends table for matching EventID
                            // Use corresponding VendorName from attends to:
                                // Join attends and vendor tables with matching VendorName and Select Name and Type

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
                                    // Query the Name and Type columns of vendors attending the selected event by joining vendor and attends tables
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

                        <!-- Right Column: Storefront Products Panel with Product Search -->
                        <div class="storefront-main">
                            <div class="storefront-header-row">
                                <div>
                                    <h2 class="storefront-title"><%= selectedVendor %></h2>
                                    <p class="storefront-subtitle">Products currently available from this vendor's storefront.</p>
                                </div>
                                <a href="sproutscout-vendors.jsp?id=<%= eventIdParam %>" class="return-vendors-btn">&larr; Back to Vendors</a>
                            </div>

                            <!-- Product Search Input Field -->
                            <input 
                                type="text" 
                                id="productSearchInput" 
                                class="store-search-bar" 
                                placeholder="Search products in this storefront..." 
                                onkeyup="filterProducts()"
                            />

                            <ul class="product-grid" id="productList">
                                <%
                                    // Query Name, Description, and Price columns of products within the selected vendor's stock 
                                    // 3-way Join of Vendor, Stock, and Product tables 
                                    // Use selected VenderName placeholder to get vendor's InventoryId
                                    // Join Stock and Inventory tables with matching InventoryId to get the ProductIDs corresponding to that InventoryID
                                    // Join Stock and Product tables with matching ProductID to Select product Name, Description, Price
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

    <!-- Login Box popup & Live Product Search Filtering Script -->
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