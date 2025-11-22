<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String[] ids = request.getParameterValues("ids");

    if(ids == null || ids.length==0){
        response.sendRedirect("list_students.jsp?error=No students selected");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_management","root","Ha15122003@");

        String placeholders = String.join(",", java.util.Collections.nCopies(ids.length, "?"));
        String sql = "DELETE FROM students WHERE id IN ("+placeholders+")";
        pstmt = conn.prepareStatement(sql);

        for(int i=0;i<ids.length;i++){
            pstmt.setInt(i+1,Integer.parseInt(ids[i]));
        }

        int rowsDeleted = pstmt.executeUpdate();
        response.sendRedirect("list_students.jsp?message="+rowsDeleted+" students deleted");

    }catch(Exception e){
        e.printStackTrace();
        response.sendRedirect("list_students.jsp?error=Error during bulk delete");
    }finally{
        try{if(pstmt!=null)pstmt.close();}catch(Exception e){}
        try{if(conn!=null)conn.close();}catch(Exception e){}
    }
%>
