<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String idParam = request.getParameter("id");
    
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("list_students.jsp?error=Invalid ID");
        return;
    }
    
    int studentId = Integer.parseInt(idParam);
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "Ha15122003@"
        );
        
        String sql = "DELETE FROM students WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, studentId);
        
        int rowsAffected = pstmt.executeUpdate();
        
        if (rowsAffected > 0) {
            response.sendRedirect("list_students.jsp?message=Student deleted successfully");
        } else {
            response.sendRedirect("list_students.jsp?error=Student not found");
        }
        
    } catch (SQLException e) {
        if (e.getMessage().contains("foreign key constraint")) {
            response.sendRedirect("list_students.jsp?error=Cannot delete: has related records");
        } else {
            response.sendRedirect("list_students.jsp?error=Database error");
        }
        e.printStackTrace();
    } catch (Exception e) {
        response.sendRedirect("list_students.jsp?error=Error occurred");
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
