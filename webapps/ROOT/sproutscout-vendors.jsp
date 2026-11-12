<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private double getMarketAverageRating(Connection con, String eventId) throws SQLException {
        String sql = "SELECT v.UserEmail, r.Rating " +
                     "FROM sproutscout.attends a " +
                     "JOIN sproutscout.vendor v ON a.VendorName = v.Name " +
                     "JOIN sproutscout.writes w ON w.VendorEmail = v.UserEmail " +
                     "JOIN sproutscout.review r ON r.ReviewID = w.ReviewId " +
                     "WHERE a.EventID = ?";

        Map<String, Integer> vendorTotals = new HashMap<>();
        Map<String, Integer> vendorCounts = new HashMap<>();

        try (PreparedStatement stmt = con.prepareStatement(sql)) {
            stmt.setString(1, eventId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String vendorEmail = rs.getString("UserEmail");
                    vendorTotals.put(vendorEmail, vendorTotals.getOrDefault(vendorEmail, 0) + rs.getInt("Rating"));
                    vendorCounts.put(vendorEmail, vendorCounts.getOrDefault(vendorEmail, 0) + 1);
                }
            }
        }

        if (vendorTotals.isEmpty()) return 0.0;

        double totalVendorAverages = 0.0;
        for (String vendorEmail : vendorTotals.keySet()) {
            totalVendorAverages += (double) vendorTotals.get(vendorEmail) / vendorCounts.get(vendorEmail);
        }
        return totalVendorAverages / vendorTotals.size();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Market Vendors & Storefront</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

    <!-- Universal Navigation Bar -->
    <%@ include file="sproutscout-navbar.jsp" %>

    <!-- Pop-up Login Box -->
    <div id="loginModal" class="modal-overlay">
        <div class="login-modal-box">
            <span class="close-btn" onclick="closeLoginModal()">&times;</span>
            <h3>Account Login</h3>
            <form action="sproutscout-auth.jsp?action=login" method="post">
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
            String reviewMessage = null;
            boolean reviewSaved = false;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                String customerEmail = (String) session.getAttribute("userEmail");

                // Handle vendor review submissions on this same JSP page.
                if ("submitReview".equals(request.getParameter("action")) &&
                    "POST".equalsIgnoreCase(request.getMethod())) {

                    if (customerEmail == null || customerEmail.trim().isEmpty()) {
                        reviewMessage = "Please log in as a customer before submitting a review.";
                    } else if (selectedVendor == null || selectedVendor.trim().isEmpty()) {
                        reviewMessage = "A vendor must be selected before submitting a review.";
                    } else {
                        String ratingText = request.getParameter("rating");
                        String content = request.getParameter("content");

                        try {
                            int rating = Integer.parseInt(ratingText);

                            if (rating < 0 || rating > 5) {
                                reviewMessage = "Rating must be between 0 and 5 stars.";
                            } else if (content == null || content.trim().isEmpty()) {
                                reviewMessage = "Review text cannot be empty.";
                            } else {
                                String vendorEmail = null;
                                String vendorEmailSql = "SELECT UserEmail FROM sproutscout.vendor WHERE Name = ?";
                                try (PreparedStatement lookupStmt = con.prepareStatement(vendorEmailSql)) {
                                    lookupStmt.setString(1, selectedVendor);
                                    try (ResultSet lookupRs = lookupStmt.executeQuery()) {
                                        if (lookupRs.next()) {
                                            vendorEmail = lookupRs.getString("UserEmail");
                                        }
                                    }
                                }

                                if (vendorEmail == null || vendorEmail.trim().isEmpty()) {
                                    reviewMessage = "The selected vendor could not be found.";
                                } else {
                                    con.setAutoCommit(false);
                                    try {
                                        int nextReviewId = 1;
                                        String nextIdSql = "SELECT MAX(ReviewID) FROM sproutscout.review";
                                        try (PreparedStatement nextIdStmt = con.prepareStatement(nextIdSql);
                                             ResultSet nextIdRs = nextIdStmt.executeQuery()) {
                                            if (nextIdRs.next()) {
                                                int maxReviewId = nextIdRs.getInt(1);
                                                if (!nextIdRs.wasNull()) {
                                                    nextReviewId = maxReviewId + 1;
                                                }
                                            }
                                        }

                                        String reviewSql = "INSERT INTO sproutscout.review (ReviewID, `Date/Time`, Content, Rating) VALUES (?, NOW(), ?, ?)";
                                        try (PreparedStatement reviewStmt = con.prepareStatement(reviewSql)) {
                                            reviewStmt.setInt(1, nextReviewId);
                                            reviewStmt.setString(2, content.trim());
                                            reviewStmt.setInt(3, rating);
                                            reviewStmt.executeUpdate();
                                        }

                                        String writesSql = "INSERT INTO sproutscout.writes (CustomerEmail, ReviewId, VendorEmail) VALUES (?, ?, ?)";
                                        try (PreparedStatement writesStmt = con.prepareStatement(writesSql)) {
                                            writesStmt.setString(1, customerEmail);
                                            writesStmt.setInt(2, nextReviewId);
                                            writesStmt.setString(3, vendorEmail);
                                            writesStmt.executeUpdate();
                                        }

                                        con.commit();
                                        reviewSaved = true;
                                        reviewMessage = "Your review was submitted successfully.";
                                    } catch (Exception reviewError) {
                                        try { con.rollback(); } catch (SQLException ignored) {}
                                        throw reviewError;
                                    } finally {
                                        try { con.setAutoCommit(true); } catch (SQLException ignored) {}
                                    }
                                }
                            }
                        } catch (NumberFormatException invalidRating) {
                            reviewMessage = "Please select a valid rating from 0 to 5 stars.";
                        }
                    }
                }

                // Query Event Header details from event table (Name, Address, Date/Time)
                String eventSql = "SELECT Name, Address, `Date/Time` FROM sproutscout.event WHERE EventId = ?";
                eventStmt = con.prepareStatement(eventSql);
                eventStmt.setString(1, eventIdParam);
                eventRs = eventStmt.executeQuery();

                if (eventRs.next()) {
                    String marketName = eventRs.getString("Name");
                    String address = eventRs.getString("Address");
                    String dateTime = eventRs.getString("Date/Time");
                    double marketAverageRating = getMarketAverageRating(con, eventIdParam);
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
                    <p class="market-info-row"><strong>Rating:</strong> &#9733; <%= String.format("%.1f", marketAverageRating) %> / 5</p> 
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
                                double vendorAverageRating = 0.0;
                                int vendorReviewCount = 0;
                                String vendorRatingSql = "SELECT r.Rating FROM sproutscout.review r " +
                                                         "JOIN sproutscout.writes w ON r.ReviewID = w.ReviewId " +
                                                         "JOIN sproutscout.vendor v2 ON w.VendorEmail = v2.UserEmail " +
                                                         "WHERE v2.Name = ?";
                                try (PreparedStatement vendorRatingStmt = con.prepareStatement(vendorRatingSql)) {
                                    vendorRatingStmt.setString(1, vName);
                                    try (ResultSet vendorRatingRs = vendorRatingStmt.executeQuery()) {
                                        int vendorTotalRating = 0;
                                        while (vendorRatingRs.next()) {
                                            vendorTotalRating += vendorRatingRs.getInt("Rating");
                                            vendorReviewCount++;
                                        }
                                        if (vendorReviewCount > 0) {
                                            vendorAverageRating = (double) vendorTotalRating / vendorReviewCount;
                                        }
                                    }
                                }
                        %>
                                <li>
                                    <a href="sproutscout-vendor-home.jsp?vendor=<%= java.net.URLEncoder.encode(vName, "UTF-8") %>&returnEventId=<%= java.net.URLEncoder.encode(eventIdParam, "UTF-8") %>" class="vendor-card-link">
                                        <div class="vendor-card">
                                            <span class="vendor-type-badge">🔖 <%= (vType != null ? vType : "Vendor") %></span>
                                            <h3 class="vendor-name"><%= vName %></h3>
                                            <div class="vendor-rating">&#9733; <%= String.format("%.1f", vendorAverageRating) %> (<%= vendorReviewCount %>)</div>
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
                                            <a href="sproutscout-vendor-home.jsp?vendor=<%= java.net.URLEncoder.encode(sName, "UTF-8") %>&returnEventId=<%= java.net.URLEncoder.encode(eventIdParam, "UTF-8") %>" 
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

                            <%
                                String displayVendorEmail = null;
                                String displayVendorEmailSql = "SELECT UserEmail FROM sproutscout.vendor WHERE Name = ?";
                                try (PreparedStatement displayVendorStmt = con.prepareStatement(displayVendorEmailSql)) {
                                    displayVendorStmt.setString(1, selectedVendor);
                                    try (ResultSet displayVendorRs = displayVendorStmt.executeQuery()) {
                                        if (displayVendorRs.next()) {
                                            displayVendorEmail = displayVendorRs.getString("UserEmail");
                                        }
                                    }
                                }

                                double averageRating = 0.0;
                                int reviewCount = 0;
                                if (displayVendorEmail != null) {
                                    String ratingSql = "SELECT r.Rating " +
                                                       "FROM sproutscout.review r " +
                                                       "JOIN sproutscout.writes w ON r.ReviewID = w.ReviewId " +
                                                       "WHERE w.VendorEmail = ?";
                                    try (PreparedStatement ratingStmt = con.prepareStatement(ratingSql)) {
                                        ratingStmt.setString(1, displayVendorEmail);
                                        try (ResultSet ratingRs = ratingStmt.executeQuery()) {
                                            int totalRating = 0;
                                            while (ratingRs.next()) {
                                                totalRating += ratingRs.getInt("Rating");
                                                reviewCount++;
                                            }
                                            if (reviewCount > 0) {
                                                averageRating = (double) totalRating / reviewCount;
                                            }
                                        }
                                    }
                                }
                            %>

                            <div class="vendor-review-summary">
                                <h2>Customer Reviews</h2>
                                <div class="vendor-average-rating">
                                    <span class="review-stars"><%= reviewCount > 0 ? "★" : "☆" %></span>
                                    <strong><%= String.format("%.1f", averageRating) %> / 5</strong>
                                    <span>(<%= reviewCount %> review<%= reviewCount == 1 ? "" : "s" %>)</span>
                                </div>
                            </div>

                            <% if (reviewMessage != null) { %>
                                <div class="review-message <%= reviewSaved ? "review-success" : "review-error" %>">
                                    <%= escapeHtml(reviewMessage) %>
                                </div>
                            <% } %>

                            <% if (customerEmail != null && !customerEmail.trim().isEmpty()) { %>
                                <form class="review-form" method="post" action="sproutscout-vendors.jsp">
                                    <input type="hidden" name="action" value="submitReview">
                                    <input type="hidden" name="id" value="<%= escapeHtml(eventIdParam) %>">
                                    <input type="hidden" name="vendor" value="<%= escapeHtml(selectedVendor) %>">

                                    <label for="rating">Your rating</label>
                                    <select name="rating" id="rating" required>
                                        <option value="">Choose a rating</option>
                                        <option value="5">★★★★★ - 5</option>
                                        <option value="4">★★★★☆ - 4</option>
                                        <option value="3">★★★☆☆ - 3</option>
                                        <option value="2">★★☆☆☆ - 2</option>
                                        <option value="1">★☆☆☆☆ - 1</option>
                                        <option value="0">☆☆☆☆☆ - 0</option>
                                    </select>

                                    <label for="reviewContent">Your review</label>
                                    <textarea name="content" id="reviewContent" maxlength="1000" required
                                              placeholder="Tell other customers about this vendor..."></textarea>
                                    <button type="submit" class="btn-submit">Submit Review</button>
                                </form>
                            <% } else { %>
                                <p class="review-login-note">Please log in to write a review.</p>
                            <% } %>

                            <div class="review-list">
                                <%
                                    boolean hasReviews = false;
                                    if (displayVendorEmail != null) {
                                        String reviewsSql = "SELECT r.Rating, r.Content, r.`Date/Time`, " +
                                                            "u.FirstName, u.LastName " +
                                                            "FROM sproutscout.review r " +
                                                            "JOIN sproutscout.writes w ON r.ReviewID = w.ReviewId " +
                                                            "JOIN sproutscout.`user` u ON w.CustomerEmail = u.Email " +
                                                            "WHERE w.VendorEmail = ? " +
                                                            "ORDER BY r.`Date/Time` DESC";
                                        try (PreparedStatement reviewsStmt = con.prepareStatement(reviewsSql)) {
                                            reviewsStmt.setString(1, displayVendorEmail);
                                            try (ResultSet reviewsRs = reviewsStmt.executeQuery()) {
                                                while (reviewsRs.next()) {
                                                    hasReviews = true;
                                                    int reviewRating = reviewsRs.getInt("Rating");
                                                    String reviewContent = reviewsRs.getString("Content");
                                                    String firstName = reviewsRs.getString("FirstName");
                                                    String lastName = reviewsRs.getString("LastName");
                                                    String reviewDate = reviewsRs.getString("Date/Time");
                                %>
                                                    <article class="review-card">
                                                        <div class="review-card-header">
                                                            <strong><%= escapeHtml(firstName) %> <%= escapeHtml(lastName) %></strong>
                                                            <span class="review-card-date"><%= escapeHtml(reviewDate) %></span>
                                                        </div>
                                                        <div class="review-stars">
                                                            <% for (int star = 1; star <= 5; star++) { %>
                                                                <%= star <= reviewRating ? "★" : "☆" %>
                                                            <% } %>
                                                        </div>
                                                        <p><%= escapeHtml(reviewContent) %></p>
                                                    </article>
                                <%
                                                }
                                            }
                                        }
                                    }
                                    if (!hasReviews) {
                                %>
                                        <p class="no-reviews">No reviews yet. Be the first to review this vendor.</p>
                                <%
                                    }
                                %>
                            </div>
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
