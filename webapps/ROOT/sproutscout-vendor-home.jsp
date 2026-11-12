<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - Vendor Home</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <%@ include file="sproutscout-navbar.jsp" %>

    <div class="main-content">
        <%
            String selectedVendor = request.getParameter("vendor");
            String returnEventId = request.getParameter("returnEventId");
            String dbUrl = "jdbc:mysql://localhost:3306/sproutscout?autoReconnect=true&useSSL=false";
            String dbUser = "root";
            String dbPass = "database1234";
            String customerEmail = (String) session.getAttribute("userEmail");
            String reviewMessage = null;
            boolean reviewSaved = false;

            Connection con = null;
            String vendorEmail = null;
            String vendorType = null;
            String inventoryId = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                String vendorSql = "SELECT UserEmail, Type, InventoryId " +
                                   "FROM sproutscout.vendor WHERE Name = ?";
                try (PreparedStatement vendorStmt = con.prepareStatement(vendorSql)) {
                    vendorStmt.setString(1, selectedVendor);
                    try (ResultSet vendorRs = vendorStmt.executeQuery()) {
                        if (vendorRs.next()) {
                            vendorEmail = vendorRs.getString("UserEmail");
                            vendorType = vendorRs.getString("Type");
                            inventoryId = vendorRs.getString("InventoryId");
                        }
                    }
                }

                if (vendorEmail == null) {
                    out.println("<div class='error-msg'>Vendor not found.</div>");
                } else {
                    if ("submitReview".equals(request.getParameter("action")) &&
                        "POST".equalsIgnoreCase(request.getMethod())) {
                        if (customerEmail == null || customerEmail.trim().isEmpty()) {
                            reviewMessage = "Please log in as a customer before submitting a review.";
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

                                        String insertReviewSql = "INSERT INTO sproutscout.review " +
                                            "(ReviewID, `Date/Time`, Content, Rating) VALUES (?, NOW(), ?, ?)";
                                        try (PreparedStatement insertReview = con.prepareStatement(insertReviewSql)) {
                                            insertReview.setInt(1, nextReviewId);
                                            insertReview.setString(2, content.trim());
                                            insertReview.setInt(3, rating);
                                            insertReview.executeUpdate();
                                        }

                                        String writesSql = "INSERT INTO sproutscout.writes " +
                                            "(CustomerEmail, ReviewId, VendorEmail) VALUES (?, ?, ?)";
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
                            } catch (NumberFormatException invalidRating) {
                                reviewMessage = "Please select a valid rating from 0 to 5 stars.";
                            }
                        }
                    }

                    double averageRating = 0.0;
                    int reviewCount = 0;
                    String ratingSql = "SELECT Rating FROM sproutscout.review r " +
                                       "JOIN sproutscout.writes w ON r.ReviewID = w.ReviewId " +
                                       "WHERE w.VendorEmail = ?";
                    try (PreparedStatement ratingStmt = con.prepareStatement(ratingSql)) {
                        ratingStmt.setString(1, vendorEmail);
                        try (ResultSet ratingRs = ratingStmt.executeQuery()) {
                            int totalRating = 0;
                            while (ratingRs.next()) {
                                totalRating += ratingRs.getInt("Rating");
                                reviewCount++;
                            }
                            if (reviewCount > 0) averageRating = (double) totalRating / reviewCount;
                        }
                    }
        %>
                    <% if (returnEventId != null && !returnEventId.trim().isEmpty()) { %>
                        <a href="sproutscout-vendors.jsp?id=<%= escapeHtml(returnEventId) %>" class="back-btn">&larr; Back to Market</a>
                    <% } else { %>
                        <a href="sproutscout-all-vendors.jsp" class="back-btn">&larr; Back to All Vendors</a>
                    <% } %>

                    <div class="market-banner vendor-home-banner">
                        <h1 class="market-title"><%= escapeHtml(selectedVendor) %></h1>
                        <p class="market-info-row"><strong>Type:</strong> <%= escapeHtml(vendorType != null ? vendorType : "Vendor") %></p>
                        <p class="market-info-row"><strong>Contact:</strong> <%= escapeHtml(vendorEmail) %></p>
                        <p class="market-info-row"><strong>Rating:</strong> &#9733; <%= String.format("%.1f", averageRating) %> / 5 (<%= reviewCount %> reviews)</p>
                    </div>

                    <section class="vendor-home-section">
                        <h2 class="section-heading">Products</h2>
                        <ul class="product-grid">
                            <%
                                boolean hasProducts = false;
                                String productSql = "SELECT p.Name, p.Description, s.Price " +
                                                    "FROM sproutscout.stock s " +
                                                    "JOIN sproutscout.product p ON s.ProductId = p.ProductId " +
                                                    "WHERE s.InventoryId = ?";
                                try (PreparedStatement productStmt = con.prepareStatement(productSql)) {
                                    productStmt.setString(1, inventoryId);
                                    try (ResultSet productRs = productStmt.executeQuery()) {
                                        while (productRs.next()) {
                                            hasProducts = true;
                            %>
                                            <li class="product-card">
                                                <h4 class="product-name"><%= escapeHtml(productRs.getString("Name")) %></h4>
                                                <p class="product-desc"><%= escapeHtml(productRs.getString("Description")) %></p>
                                                <div class="product-footer">
                                                    <span class="product-price">$<%= String.format("%.2f", productRs.getDouble("Price")) %></span>
                                                </div>
                                            </li>
                            <%
                                        }
                                    }
                                }
                                if (!hasProducts) {
                            %>
                                <li class="no-products">No products currently listed for this vendor.</li>
                            <% } %>
                        </ul>
                    </section>

                    <section class="vendor-home-section">
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
                            <form class="review-form" method="post" action="sproutscout-vendor-home.jsp">
                                <input type="hidden" name="action" value="submitReview">
                                <input type="hidden" name="vendor" value="<%= escapeHtml(selectedVendor) %>">
                                <input type="hidden" name="returnEventId" value="<%= escapeHtml(returnEventId) %>">
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
                                <textarea name="content" id="reviewContent" maxlength="1000" required placeholder="Tell other customers about this vendor..."></textarea>
                                <button type="submit" class="btn-submit">Submit Review</button>
                            </form>
                        <% } else { %>
                            <p class="review-login-note">Please log in to write a review.</p>
                        <% } %>

                        <div class="review-list">
                            <%
                                boolean hasReviews = false;
                                String reviewsSql = "SELECT r.Rating, r.Content, r.`Date/Time`, u.FirstName, u.LastName " +
                                                    "FROM sproutscout.review r " +
                                                    "JOIN sproutscout.writes w ON r.ReviewID = w.ReviewId " +
                                                    "JOIN sproutscout.`user` u ON w.CustomerEmail = u.Email " +
                                                    "WHERE w.VendorEmail = ? ORDER BY r.`Date/Time` DESC";
                                try (PreparedStatement reviewsStmt = con.prepareStatement(reviewsSql)) {
                                    reviewsStmt.setString(1, vendorEmail);
                                    try (ResultSet reviewsRs = reviewsStmt.executeQuery()) {
                                        while (reviewsRs.next()) {
                                            hasReviews = true;
                            %>
                                            <article class="review-card">
                                                <div class="review-card-header">
                                                    <strong><%= escapeHtml(reviewsRs.getString("FirstName")) %> <%= escapeHtml(reviewsRs.getString("LastName")) %></strong>
                                                    <span class="review-card-date"><%= escapeHtml(reviewsRs.getString("Date/Time")) %></span>
                                                </div>
                                                <div class="review-stars">
                                                    <% for (int star = 1; star <= 5; star++) { %><%= star <= reviewsRs.getInt("Rating") ? "★" : "☆" %><% } %>
                                                </div>
                                                <p><%= escapeHtml(reviewsRs.getString("Content")) %></p>
                                            </article>
                            <%
                                        }
                                    }
                                }
                                if (!hasReviews) {
                            %>
                                <p class="no-reviews">No reviews yet. Be the first to review this vendor.</p>
                            <% } %>
                        </div>
                    </section>
        <%
                }
            } catch (Exception e) {
                out.println("<div class='error-msg'>Database Error: " + escapeHtml(e.getMessage()) + "</div>");
            } finally {
                if (con != null) try { con.close(); } catch (SQLException ignored) {}
            }
        %>
    </div>

    <footer class="footer">
        <p>&copy; 2026 SproutScout. Connecting communities with local farmers markets.</p>
    </footer>
</body>
</html>
