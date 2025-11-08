<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Student</title>
    <style>
        /* Same CSS as add_student.jsp */
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container {
            max-width: 600px; margin: 50px auto; background: white;
            padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="email"] {
            width: 100%; padding: 10px; border: 1px solid #ddd;
            border-radius: 5px; box-sizing: border-box;
        }
        .btn-submit {
            background: #ffc107; color: #333; padding: 12px 30px;
            border: none; border-radius: 5px; cursor: pointer;
        }
        .btn-cancel {
            background: #6c757d; color: white; padding: 12px 30px;
            text-decoration: none; display: inline-block; border-radius: 5px;
        }
        .error { background: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
<%
    String idParam = request.getParameter("id");
    
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("list_students.jsp?error=Invalid student ID");
        return;
    }
    
    int studentId = 0;
    try {
        studentId = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("list_students.jsp?error=Invalid ID format");
        return;
    }
    
    String studentCode = "";
    String fullName = "";
    String email = "";
    String major = "";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "Ha15122003@"
        );
        
        String sql = "SELECT * FROM students WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, studentId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            studentCode = rs.getString("student_code");
            fullName = rs.getString("full_name");
            email = rs.getString("email");
            major = rs.getString("major");
            
            if (email == null) email = "";
            if (major == null) major = "";
        } else {
            response.sendRedirect("list_students.jsp?error=Student not found");
            return;
        }
        
    } catch (Exception e) {
        out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
        return;
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
    <div class="container">
        <h2>✏️ Edit Student Information</h2>
        
        <% if (request.getParameter("error") != null) { %>
            <div class="error"><%= request.getParameter("error") %></div>
        <% } %>
        
        <form action="process_edit.jsp" method="POST">
            <input type="hidden" name="id" value="<%= studentId %>">
            
            <div class="form-group">
                <label>Student Code</label>
                <input type="text" name="student_code" value="<%= studentCode %>" readonly>
                <small style="color: #666;">Cannot be changed</small>
            </div>
            
            <div class="form-group">
                <label>Full Name *</label>
                <input type="text" name="full_name" value="<%= fullName %>" required>
            </div>
            
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" value="<%= email %>">
            </div>
            
            <div class="form-group">
                <label>Major</label>
                <input type="text" name="major" value="<%= major %>">
            </div>
            
            <button type="submit" class="btn-submit">💾 Update</button>
            <a href="list_students.jsp" class="btn-cancel">Cancel</a>
        </form>
    </div>
</body>
</html>
