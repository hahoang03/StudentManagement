<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Student</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 600px;
            margin: 50px auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h2 { color: #333; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        input:focus {
            outline: none;
            border-color: #007bff;
        }
        .btn-submit {
            background-color: #28a745;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
        }
        .btn-cancel {
            background-color: #6c757d;
            color: white;
            padding: 12px 30px;
            text-decoration: none;
            display: inline-block;
            border-radius: 5px;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .required { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <h2>➕ Add New Student</h2>
        
        <% if (request.getParameter("error") != null) { %>
            <div class="error">
                <%= request.getParameter("error") %>
            </div>
        <% } %>
        
        <form action="process_add.jsp" method="POST">
            <div class="form-group">
                <label for="student_code">Student Code <span class="required">*</span></label>
                <input type="text" id="student_code" name="student_code" 
                       placeholder="e.g., SV001" required 
                       pattern="[A-Z]{2}[0-9]{3,}"
                       title="Format: 2 uppercase letters + 3+ digits">
            </div>
            
            <div class="form-group">
                <label for="full_name">Full Name <span class="required">*</span></label>
                <input type="text" id="full_name" name="full_name" 
                       placeholder="Enter full name" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" 
                       placeholder="student@email.com">
            </div>
            
            <div class="form-group">
                <label for="major">Major</label>
                <input type="text" id="major" name="major" 
                       placeholder="e.g., Computer Science">
            </div>
            
            <button type="submit" class="btn-submit">💾 Save Student</button>
            <a href="list_students.jsp" class="btn-cancel">Cancel</a>
        </form>
    </div>
</body>
</html>
