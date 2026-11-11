<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout - About Us</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

    <!-- Universal Navigation Bar -->
    <%@ include file="sproutscout-navbar.jsp" %>

    <div class="main-content">
        
        <div class="search-section">
            <h1 class="title">About SproutScout</h1>
            <p class="subtitle">Connecting communities with local growers, artisan crafters, and fresh markets.</p>
        </div>

        <div class="about-card">
            <h2>Our Mission</h2>
            <p>
                SproutScout was created to make fresh, local food accessible to everyone while empowering independent 
                farmers, artisan food makers, and small businesses. We believe that strong local food systems make 
                healthier communities.
            </p>

            <div class="feature-grid">
                <div class="feature-box">
                    <h3>📍 Discover Markets</h3>
                    <p>Find local farmers markets near you with live event times and location details.</p>
                </div>
                <div class="feature-box">
                    <h3>⛺ Connect with Vendors</h3>
                    <p>Explore vendor profiles and see who will be attending your favorite weekend markets.</p>
                </div>
                <div class="feature-box">
                    <h3>🥖 Browse Storefronts</h3>
                    <p>Check product availability and pricing directly from local vendor digital storefronts.</p>
                </div>
            </div>
        </div>

    </div>

    <footer class="footer">
        <p>&copy; 2026 SproutScout. Connecting communities with local farmers markets.</p>
    </footer>

</body>
</html>