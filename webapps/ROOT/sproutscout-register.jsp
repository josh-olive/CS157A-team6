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
		<link rel="stylesheet" href="styles.css">
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