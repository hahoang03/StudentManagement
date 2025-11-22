<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Student List</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            h1 {
                color: #333;
            }
            .message {
                padding: 10px;
                margin-bottom: 20px;
                border-radius: 5px;
            }
            .success {
                background-color: #d4edda;
                color: green;
                border: 1px solid #c3e6cb;
            }
            .error {
                background-color: #f8d7da;
                color: red;
                border: 1px solid #f5c6cb;
            }
            .btn {
                display: inline-block;
                padding: 10px 20px;
                margin-bottom: 20px;
                background-color: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 5px;
                cursor: pointer;
            }
            .btn-black {
                background-color: black;
                color: white;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background-color: white;
            }
            th {
                background-color: #007bff;
                color: white;
                padding: 12px;
                text-align: left;
            }
            td {
                padding: 10px;
                border-bottom: 1px solid #ddd;
            }
            tr:hover {
                background-color: #f8f9fa;
            }
            .action-link {
                color: #007bff;
                text-decoration: none;
                margin-right: 10px;
            }
            .delete-link {
                color: #dc3545;
            }
            .search-box input[name="keyword"] {
                padding: 8px 12px;
                width: 250px;
                border: 1px solid #ccc;
                border-radius: 4px;
                font-size: 14px;
            }
            .search-box button {
                padding: 9px 20px;
                background-color: #007bff;
                color: white;
                border-radius: 5px;
                cursor: pointer;
            }
            .highlight {
                color: red;
                font-weight: bold;
            }
            .pagination a, .pagination strong {
                margin: 0 5px;
                text-decoration: none;
                font-size: 16px;
            }
            .table-responsive {
                overflow-x: auto;
            }
        </style>
    </head>
    <body>

        <h1>📚 Student Management System</h1>

        <!-- Messages -->
        <% if (request.getParameter("message") != null) {%>
        <div class="message success">✓ <%= request.getParameter("message")%></div>
        <% } %>
        <% if (request.getParameter("error") != null) {%>
        <div class="message error">✗ <%= request.getParameter("error")%></div>
        <% }%>

        <!-- Search -->
        <div class="search-box">
            <form action="list_students.jsp" method="GET">
                <input type="text" name="keyword" placeholder="Search by name or code..."
                       value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : ""%>">
                <button type="submit">Search</button>
                <a href="list_students.jsp" class="btn">Clear</a>
            </form>
        </div>

        <!-- Toolbar: Add, Export, Delete Selected -->
        <a href="add_student.jsp" class="btn">➕ Add New Student</a>
        <a href="export_csv.jsp" class="btn">Export to CSV</a>
        <form id="bulkDeleteForm" action="bulk_delete.jsp" method="POST" onsubmit="return confirm('Are you sure to delete selected students?');" style="display:inline;">
            <button type="submit" class="btn">Delete Selected</button>

            <%
                // Pagination & sorting
                String pageParam = request.getParameter("page");
                int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
                int recordsPerPage = 10;
                int offset = (currentPage - 1) * recordsPerPage;

                String keyword = request.getParameter("keyword");
                if (keyword == null || keyword.equals("null")) {
                    keyword = "";
                }
                boolean hasKeyword = !keyword.trim().isEmpty();

                String sortBy = request.getParameter("sort");
                String order = request.getParameter("order");
                if (sortBy == null || !(sortBy.equals("id") || sortBy.equals("full_name") || sortBy.equals("student_code") || sortBy.equals("created_at"))) {
                    sortBy = "id";
                }
                if (order == null || !(order.equalsIgnoreCase("asc") || order.equalsIgnoreCase("desc"))) {
                    order = "desc";
                }
                String nextOrder = order.equals("asc") ? "desc" : "asc";

                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                int totalRecords = 0;
                int totalPages = 1;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_management", "root", "Ha15122003@");

                    // Count total records
                    if (hasKeyword) {
                        String countSQL = "SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ?";
                        pstmt = conn.prepareStatement(countSQL);
                        String kw = "%" + keyword + "%";
                        pstmt.setString(1, kw);
                        pstmt.setString(2, kw);
                    } else {
                        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM students");
                    }
                    ResultSet countRS = pstmt.executeQuery();
                    if (countRS.next()) {
                        totalRecords = countRS.getInt(1);
                    }
                    totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
                    pstmt.close();

                    // Main query
                    String sql;
                    if (hasKeyword) {
                        sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
                        pstmt = conn.prepareStatement(sql);
                        String kw = "%" + keyword + "%";
                        pstmt.setString(1, kw);
                        pstmt.setString(2, kw);
                        pstmt.setInt(3, recordsPerPage);
                        pstmt.setInt(4, offset);
                    } else {
                        sql = "SELECT * FROM students ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, recordsPerPage);
                        pstmt.setInt(2, offset);
                    }
                    rs = pstmt.executeQuery();
            %>

            <!-- Student Table -->
            <table>
                <thead>
                    <tr>
                        <th><input type="checkbox" id="selectAll" onclick="toggleAll(this)"></th>
                        <th><a href="list_students.jsp?sort=id&order=<%=nextOrder%>&keyword=<%=keyword%>&page=<%=currentPage%>" style="color:white;text-decoration:none;">ID <% if ("id".equals(sortBy)) {%><%= order.equals("asc") ? "▲" : "▼"%><% }%></a></th>
                        <th><a href="list_students.jsp?sort=student_code&order=<%=nextOrder%>&keyword=<%=keyword%>&page=<%=currentPage%>" style="color:white;text-decoration:none;">Student Code <% if ("student_code".equals(sortBy)) {%><%= order.equals("asc") ? "▲" : "▼"%><% }%></a></th>
                        <th><a href="list_students.jsp?sort=full_name&order=<%=nextOrder%>&keyword=<%=keyword%>&page=<%=currentPage%>" style="color:white;text-decoration:none;">Full Name <% if ("full_name".equals(sortBy)) {%><%= order.equals("asc") ? "▲" : "▼"%><% }%></a></th>
                        <th>Email</th>
                        <th>Major</th>
                        <th><a href="list_students.jsp?sort=created_at&order=<%=nextOrder%>&keyword=<%=keyword%>&page=<%=currentPage%>" style="color:white;text-decoration:none;">Created At <% if ("created_at".equals(sortBy)) {%><%= order.equals("asc") ? "▲" : "▼"%><% } %></a></th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String studentCode = rs.getString("student_code");
                            String fullName = rs.getString("full_name");
                            String email = rs.getString("email");
                            String major = rs.getString("major");
                            Timestamp createdAt = rs.getTimestamp("created_at");

                            String kw = keyword.toLowerCase();
                            String studentCodeHL = studentCode.replaceAll("(?i)(" + kw + ")", "<span class='highlight'>$1</span>");
                            String fullNameHL = fullName.replaceAll("(?i)(" + kw + ")", "<span class='highlight'>$1</span>");
                    %>
                    <tr>
                        <td><input type="checkbox" name="ids" value="<%=id%>"></td>
                        <td><%=id%></td>
                        <td><%=studentCodeHL%></td>
                        <td><%=fullNameHL%></td>
                        <td><%=email != null ? email : "N/A"%></td>
                        <td><%=major != null ? major : "N/A"%></td>
                        <td><%=createdAt%></td>
                        <td>
                            <a href="edit_student.jsp?id=<%=id%>" class="action-link">✏️ Edit</a>
                            <a href="delete_student.jsp?id=<%=id%>" class="action-link delete-link" onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </form> <!-- end bulkDeleteForm -->

        <% } catch (Exception e) {
        out.println("<tr><td colspan='8'>Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (Exception e) {
        }
        try {
            if (pstmt != null) {
                pstmt.close();
            }
        } catch (Exception e) {
        }
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (Exception e) {
        }
    } %>

        <!-- Pagination -->
        <div class="pagination" style="margin-top:20px;">
            <% if (currentPage > 1) {%><a href="list_students.jsp?page=<%=currentPage - 1%>&keyword=<%=keyword%>&sort=<%=sortBy%>&order=<%=order%>">Previous</a><% } %>
            <% for (int i = 1; i <= totalPages; i++) {
        if (i == currentPage) {%><strong><%=i%></strong><% } else {%><a href="list_students.jsp?page=<%=i%>&keyword=<%=keyword%>&sort=<%=sortBy%>&order=<%=order%>"><%=i%></a><% }
    } %>
            <% if (currentPage < totalPages) {%><a href="list_students.jsp?page=<%=currentPage + 1%>&keyword=<%=keyword%>&sort=<%=sortBy%>&order=<%=order%>">Next</a><% }%>
        </div>

        <script>
            function toggleAll(source) {
                let checkboxes = document.getElementsByName('ids');
                checkboxes.forEach(cb => cb.checked = source.checked);
            }
            setTimeout(function () {
                document.querySelectorAll('.message').forEach(msg => {
                    msg.style.transition = "opacity 300ms";
                    msg.style.opacity = 0;
                    setTimeout(() => msg.style.display = 'none', 300);
                });
            }, 3000);
        </script>

    </body>
</html>
