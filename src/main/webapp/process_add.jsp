<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String studentCode = request.getParameter("student_code");
    String fullName = request.getParameter("full_name");
    String email = request.getParameter("email");
    String major = request.getParameter("major");
    
    if (studentCode == null || studentCode.trim().isEmpty() ||
        fullName == null || fullName.trim().isEmpty()) {
        response.sendRedirect("add_student.jsp?error=Required fields are missing");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "Ha15122003@"
        );
        
        String sql = "INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, studentCode);
        pstmt.setString(2, fullName);
        pstmt.setString(3, email);
        pstmt.setString(4, major);
        
        int rowsAffected = pstmt.executeUpdate();
        
        if (rowsAffected > 0) {
            response.sendRedirect("list_students.jsp?message=Student added successfully");
        } else {
            response.sendRedirect("add_student.jsp?error=Failed to add student");
        }
        
    } catch (ClassNotFoundException e) {
        response.sendRedirect("add_student.jsp?error=Driver not found");
        e.printStackTrace();
    } catch (SQLException e) {
        String errorMsg = e.getMessage();
        if (errorMsg.contains("Duplicate entry")) {
            response.sendRedirect("add_student.jsp?error=Student code already exists");
        } else {
            response.sendRedirect("add_student.jsp?error=Database error");
        }
        e.printStackTrace();
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
