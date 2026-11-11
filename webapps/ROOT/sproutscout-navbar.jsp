<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if a user session is active globally and handle errors if necessary
    String navbarUserEmail = (String) session.getAttribute("userEmail");
    String errorParam = request.getParameter("error");
%>
<!-- Top Navigation Bar -->
<nav class="navbar">
    <a href="sproutscout-home.jsp" class="nav-brand">🌱 SproutScout</a>
    <ul class="nav-links">
        <li><a href="sproutscout-home.jsp">Markets</a></li>
        <li><a href="sproutscout-all-vendors.jsp">Vendors</a></li>
        <li><a href="sproutscout-about.jsp">About Us</a></li>
        
        <% if (navbarUserEmail != null && !navbarUserEmail.isEmpty()) { %>
            <!-- Logged-in View: Email + Logout Button on Top Right -->
            <li class="user-auth-info">
                <span class="nav-user-email"><%= navbarUserEmail %></span>
                <form action="sproutscout-auth.jsp?action=logout" method="post" style="margin: 0; display: inline;">
                    <button type="submit" class="logout-nav-btn">Logout</button>
                </form>
            </li>
        <% } else { %>
            <!-- Logged-out View: Login Trigger -->
            <li><a class="login-nav-btn" onclick="openLoginModal()">Login</a></li>
        <% } %>
    </ul>
</nav>

<!-- Pop-up Login Box (Automatically stays open if there is an error) -->
<div id="loginModal" class="modal-overlay" style="<%= ("invalid_login".equals(errorParam)) ? "display: flex;" : "" %>">
    <div class="login-modal-box">
        <span class="close-btn" onclick="closeLoginModal()">&times;</span>
        <h3>Account Login</h3>
        
        <!-- Visible Error Message -->
        <% if ("invalid_login".equals(errorParam)) { %>
            <div style="background-color: #fadbd8; color: #c0392b; padding: 10px; border-radius: 6px; font-size: 0.85rem; margin-bottom: 12px; text-align: center;">
                Invalid email or password. Please try again.
            </div>
        <% } %>

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

<!-- Global Login Modal Script -->
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
</script>