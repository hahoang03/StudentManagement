<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Set CSV response headers
    response.setContentType("text/csv");
    response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

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

        String sql = "SELECT * FROM students ORDER BY id ASC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        // Print CSV header
        out.println("ID,Student Code,Full Name,Email,Major");

        // Loop through students and print each row
        while (rs.next()) {
            int id = rs.getInt("id");
            String code = rs.getString("student_code");
            String name = rs.getString("full_name");
            String email = rs.getString("email") != null ? rs.getString("email") : "";
            String major = rs.getString("major") != null ? rs.getString("major") : "";

            // Escape commas if needed
            code = "\"" + code.replace("\"", "\"\"") + "\"";
            name = "\"" + name.replace("\"", "\"\"") + "\"";
            email = "\"" + email.replace("\"", "\"\"") + "\"";
            major = "\"" + major.replace("\"", "\"\"") + "\"";

            out.println(id + "," + code + "," + name + "," + email + "," + major);
        }
    } catch (Exception e) {
        out.println("Error exporting CSV: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>
