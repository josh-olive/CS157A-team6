<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SproutScout</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            margin: 0;
            padding: 20px 40px;
            background-color: #f9fbf8;
            color: #333;
            position: relative;
        }

        /* Top Right Login Box Fixed/Absolute Position */
        .login-box {
            position: absolute;
            top: 20px;
            right: 40px;
            border: 2px solid #333;
            padding: 15px;
            border-radius: 8px;
            background-color: #ffffff;
            width: 260px;
            box-shadow: 2px 2px 8px rgba(0, 0, 0, 0.1);
            z-index: 10;
        }

        .login-box input[type="text"],
        .login-box input[type="password"] {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
            border: 2px solid #4CAF50;
            border-radius: 4px;
            outline: none;
        }

        .btn-group {
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }

        .btn {
            flex: 1;
            padding: 8px 5px;
            border: 1px solid #1c4b2b;
            background-color: #2e6f40;
            color: white;
            border-radius: 4px;
            font-size: 0.85rem;
            cursor: pointer;
            text-align: center;
        }

        .btn:hover {
            background-color: #235430;
        }

        /* Centered Header & Search Container */
        .hero-section {
            text-align: center;
            margin-top: 80px; 
            margin-bottom: 30px;
        }

        .title {
            font-size: 4.5rem; 
            font-weight: bold;
            color: #2e6f40;
            margin: 0 0 20px 0;
        }

        .search-bar {
            width: 65%;
            max-width: 650px;
            padding: 14px 22px;
            font-size: 1.1rem;
            border: 2px solid #4CAF50;
            border-radius: 25px;
            outline: none;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        .search-bar::placeholder {
            color: #4CAF50;
            font-weight: 500;
        }

        /* Farmers Market List Box */
        .market-list-container {
            width: 70%;
            max-width: 800px;
            margin: 0 auto;
            border: 3px solid #4CAF50;
            border-radius: 8px;
            padding: 20px;
            background-color: #ffffff;
            min-height: 250px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);
        }

        .market-list-title {
            color: #4CAF50;
            font-size: 1.4rem;
            margin-top: 0;
            margin-bottom: 15px;
        }

        .market-list {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }

        .market-item {
            margin-bottom: 10px;
        }

        .market-link {
            display: block;
            padding: 12px 15px;
            background-color: #e7ffe8;
            color: #4CAF50;
            text-decoration: none;
            border-radius: 6px;
            border: 1px solid #61af64;
            font-weight: bold;
            transition: all 0.2s ease-in-out;
        }

        .market-link:hover {
            background-color: #2d662f;
            color: white;
            transform: translateX(5px);
        }

        .status-badge {
            display: inline-block;
            margin-bottom: 15px;
            padding: 6px 12px;
            background-color: #e8f8f5;
            color: #117a65;
            border: 1px solid #a3e4d7;
            border-radius: 4px;
            font-size: 0.85rem;
            font-weight: bold;
        }

        .error-msg {
            color: #c0392b;
            background-color: #fadbd8;
            padding: 10px;
            border-radius: 4px;
        }
    </style>
</head>
<body>

    <!-- Top Right Login Box -->
    <div class="login-box">
        <form action="login" method="post">
            <input type="text" name="username" placeholder="Username" required />
            <input type="password" name="password" placeholder="Password" required />
            <div class="btn-group">
                <button type="submit" class="btn">Login</button>
                <button type="submit" class="btn" name="action" value="create">Create Account</button>
            </div>
        </form>
    </div>

    <!-- Title + Search Bar -->
    <div class="hero-section">
        <h1 class="title">SproutScout</h1>
        <input 
            type="text" 
            id="searchInput" 
            class="search-bar" 
            placeholder="Search for available farmers markets" 
            onkeyup="filterMarkets()"
        />
    </div>

    <!-- Farmers Market List -->
    <div class="market-list-container">
        <h2 class="market-list-title">List of Farmers Markets</h2>

        <ul class="market-list" id="marketList">
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

                    // Querying matching columns from MySQL Workbench schema
                    rs = stmt.executeQuery("SELECT `Number`, `Name`, `Address` FROM sproutscout.markets");

                    boolean hasResults = false;
                    while(rs.next()) {
                        hasResults = true;
                        int id = rs.getInt("Number");
                        String marketName = rs.getString("Name");
                        String address = rs.getString("Address");
            %>
                        <li class="market-item">
                            <a href="marketDetails.jsp?id=<%= id %>" class="market-link">
                                #<%= id %> - <%= marketName %> <%= (address != null && !address.trim().isEmpty() ? " (" + address + ")" : "") %>
                            </a>
                        </li>
            <%
                    }

                    if (!hasResults) {
                        out.println("<p>No farmers markets found in table 'markets'.</p>");
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

    <script>
        function filterMarkets() {
            var input = document.getElementById("searchInput");
            var filter = input.value.toLowerCase();
            var ul = document.getElementById("marketList");
            var li = ul.getElementsByTagName("li");

            for (var i = 0; i < li.length; i++) {
                var a = li[i].getElementsByTagName("a")[0];
                var txtValue = a.textContent || a.innerText;
                if (txtValue.toLowerCase().indexOf(filter) > -1) {
                    li[i].style.display = "";
                } else {
                    li[i].style.display = "none";
                }
            }
        }
    </script>

</body>
</html>