<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String errorMsg = null;
if ("POST".equalsIgnoreCase(request.getMethod())) {
	String userType = request.getParameter("userType");
	String subclassName = request.getParameter("subclassName"); 
	String firstName = request.getParameter("firstName");
	String lastName = request.getParameter("lastName");
	String email = request.getParameter("email");
	String password = request.getParameter("password");
	String address = request.getParameter("address");
	
	String dbUrl = "jdbc:mysql://localhost:3306/sproutscout?autoReconnect=true&useSSL=false";
	String dbUser = "root";
	String dbPass = "database1234";
	
	Connection con = null;
	PreparedStatement stmtUser = null;
	PreparedStatement stmtSubclass = null;
	
	try {
		Class.forName("com.mysql.cj.jdbc.Driver");
		con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
		con.setAutoCommit(false);
		
		String userSql = "INSERT INTO User (Email, Password, FirstName, LastName, Address) VALUES (?, ?, ?, ?, ?)";
		stmtUser = con.prepareStatement(userSql);
		stmtUser.setString(1, email);
		stmtUser.setString(2, password);
		stmtUser.setString(3, firstName);
		stmtUser.setString(4, lastName);
		stmtUser.setString(5, address);
		stmtUser.executeUpdate();
		
		String subclassSql = "";
		if ("Customer".equals(userType)) {
			subclassSql = "INSERT INTO Customer (UserEmail, Username) VALUES (?, ?)";
		} else if ("Vendor".equals(userType)) {
			subclassSql = "INSERT INTO Vendor (UserEmail, Name) VALUES (?, ?)";
		} else if ("Supplier".equals(userType)) {
			subclassSql = "INSERT INTO Supplier (UserEmail, Name) VALUES (?, ?)";
		}
		
		stmtSubclass = con.prepareStatement(subclassSql);
		stmtSubclass.setString(1, email);
		stmtSubclass.setString(2, subclassName);
		stmtSubclass.executeUpdate();
		
		con.commit();
		response.sendRedirect("sproutscout-home.jsp");
		return;
	} catch (Exception e) {
		if (con != null) {
			try { con.rollback(); } catch (SQLException ignored) {}
		}
		errorMsg = e.getMessage();
	} finally {
		if (stmtSubclass != null) try { stmtSubclass.close(); } catch(SQLException ignored) {}
		if (stmtUser != null) try { stmtUser.close(); } catch(SQLException ignored) {}
		if (con != null) try { con.close(); } catch(SQLException ignored) {}
	}
}
%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Create Account — SproutScout</title>
		<style>
		
		* { 
            box-sizing: border-box; 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; 
            letter-spacing: -0.01em;
        }
		
		body {
            background-color: #faf9f6; 
            color: #1e221f;
            display: flex; 
            justify-content: center; 
            align-items: center;
            min-height: 100vh; 
            margin: 0; 
            padding: 40px 20px;
        }
		
		.register-container {
            width: 100%; 
            max-width: 440px; 
            background-color: #ffffff;
            border-radius: 16px; 
            padding: 40px;
            box-shadow: 0 4px 24px rgba(26, 67, 41, 0.04), 0 1px 2px rgba(0, 0, 0, 0.02);
            border: 1px solid rgba(26, 67, 41, 0.08);
        }
		
		.title { 
            color: #1a4329; 
            text-align: center; 
            margin: 0 0 8px 0; 
            font-size: 1.75rem; 
            font-weight: 600;
        }
		
		.subtitle {
            text-align: center;
            color: #606862;
            font-size: 0.95rem;
            margin: 0 0 32px 0;
        }
		
		label { 
            display: block; 
            margin-bottom: 6px; 
            font-weight: 500; 
            color: #1a4329; 
            font-size: 0.85rem; 
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
		
		input[type="text"], input[type="email"], input[type="password"], select {
            width: 100%; 
            padding: 12px 16px; 
            margin-bottom: 20px;
            border: 1px solid #d1d5d2; 
            border-radius: 8px; 
            outline: none;
            font-size: 0.95rem; 
            background-color: #ffffff;
            color: #1e221f;
            transition: all 0.2s ease;
        }
		
		input[type="text"]:focus, input[type="email"]:focus, input[type="password"]:focus, select:focus {
            border-color: #1a4329;
            box-shadow: 0 0 0 3px rgba(26, 67, 41, 0.1);
        }
		
		.name-group { 
            display: flex; 
            gap: 16px; 
        }
		
		.name-group div { 
            flex: 1; 
        }
		
		.dynamic-field-box { 
            background-color: #f2f7f4; 
            padding: 20px; 
            border-radius: 10px; 
            margin-bottom: 20px; 
            border: 1px solid rgba(26, 67, 41, 0.06);
        }
		
		.dynamic-field-box input {
            margin-bottom: 0;
        }
		
		.btn-submit {
            width: 100%; 
            padding: 14px; 
            border: none;
            background-color: #1a4329;
            color: #ffffff; 
            border-radius: 8px; 
            font-size: 1rem; 
            font-weight: 600; 
            cursor: pointer;
            transition: background-color 0.15s ease;
            margin-top: 8px;
        }
		
		.btn-submit:hover { 
            background-color: #112d1b; 
        }
		
		.back-link { 
            display: block; 
            text-align: center; 
            margin-top: 20px; 
            color: #606862; 
            text-decoration: none; 
            font-size: 0.9rem; 
            transition: color 0.15s ease;
        }
		
		.back-link:hover { 
            color: #1a4329;
        }
		
		.error-banner { 
            background-color: #fdf2f2; 
            color: #9b1c1c; 
            border: 1px solid #fde8e8; 
            padding: 14px; 
            border-radius: 8px; 
            margin-bottom: 24px; 
            font-size: 0.9rem; 
            line-height: 1.4;
		}
		</style>
	</head>
	<body>
		<div class="register-container">
			<h2 class="title">Create your account</h2>
			<p class="subtitle">Join the SproutScout community</p>
			
			<% if (errorMsg != null) { %>
				<div class="error-banner">
					<strong>Error processing request:</strong> <%= errorMsg %>
				</div>
			<% } %>
			
			<form action="" method="post">
				
				<label for="userType">Account Type</label>
				<select name="userType" id="userType" required onchange="toggleSubclassField()">
					<option value="" disabled selected>Select your account type...</option>
					<option value="Customer">Customer</option>
					<option value="Vendor">Vendor</option>
					<option value="Supplier">Supplier</option>
				</select>
				
				<!-- Dynamic input field area controlled by JavaScript -->
				<div id="dynamicSubclassArea" class="dynamic-field-box" style="display: none;">
					<label id="dynamicLabel" for="subclassName">Custom Label</label>
					<input type="text" name="subclassName" id="subclassName" />
				</div>
				
				<div class="name-group">
					<div>
						<label for="firstName">First Name</label>
						<input type="text" name="firstName" id="firstName" placeholder="Jane" required />
					</div>
					<div>
						<label for="lastName">Last Name</label>
						<input type="text" name="lastName" id="lastName" placeholder="Doe" required />
					</div>
				</div>
				
				<label for="email">Email Address</label>
				<input type="email" name="email" id="email" placeholder="jane.doe@example.com" required />
				
				<label for="password">Password</label>
				<input type="password" name="password" id="password" placeholder="••••••••" required />
				
				<label for="address">Address</label>
				<input type="text" name="address" id="address" placeholder="123 Main St, San Jose, CA" required />
				
				<button type="submit" class="btn-submit">Register Account</button>
				
				<a href="sproutscout-home.jsp" class="back-link">Already have an account? Log in</a>
			</form>
		</div>
		<script>
		function toggleSubclassField() {
			var userTypeSelect = document.getElementById("userType");
			var dynamicArea = document.getElementById("dynamicSubclassArea");
			var dynamicLabel = document.getElementById("dynamicLabel");
			var subclassInput = document.getElementById("subclassName");
			var selectedValue = userTypeSelect.value;
			
			if (selectedValue === "Customer") {
				dynamicArea.style.display = "block";
				dynamicLabel.textContent = "Username";
				subclassInput.placeholder = "Enter a username";
				subclassInput.required = true;
			} else if (selectedValue === "Vendor" || selectedValue === "Supplier") {
				dynamicArea.style.display = "block";
				dynamicLabel.textContent = "Company Or Business Name";
				subclassInput.placeholder = "Enter a name";
				subclassInput.required = true;
			} else {
				dynamicArea.style.display = "none";
				subclassInput.required = false;
			}
		}
		</script>
	</body>
</html>