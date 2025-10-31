<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    List<Map<String, String>> departments = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        String sql = "SELECT * FROM departments";
        stmt = conn.prepareStatement(sql);
        rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, String> department = new HashMap<>();
            department.put("id", String.valueOf(rs.getInt("id")));
            department.put("name", rs.getString("name"));
            department.put("description", rs.getString("description"));
            departments.add(department);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>查看所有部门</title>
    <link rel="stylesheet" href="../style/styles.css">
    <style>
        form {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        form label {
            font-weight: bold;
            margin-right: 10px;
            color: #333;
            display: inline-block;
            width: 100px;
            margin-bottom: 10px;
        }

        form input, form select {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 200px;
            margin-bottom: 10px;
        }

        form button {
            background-color: #0056b3;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        form button:hover {
            background-color: #004494;
        }

        td .btn {
            display: inline-block;
            background-color: #d9534f;
            color: white;
            padding: 8px 12px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            transition: background-color 0.3s;
            margin: 2px;
        }

        td .btn:hover {
            background-color: #c9302c;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f5f5f5;
        }

        .btn {
            background-color: #0056b3;
            color: white;
            padding: 0.5rem 1rem;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        .btn:hover {
            background-color: #004494;
        }
    </style>
</head>
<body>
<header>
    <h1>部门管理系统</h1>
</header>
<nav>
    <a href="addDepartment.jsp">部门列表</a>
</nav>
<div class="container">
    <h1>所有部门</h1>
    <table>
        <thead>
        <tr>
            <th>ID</th>
            <th>部门名称</th>
            <th>描述</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <%
            for (Map<String, String> department : departments) {
        %>
        <tr>
            <td><%= department.get("id") %></td>
            <td><%= department.get("name") %></td>
            <td><%= department.get("description") %></td>
            <td>
                <a href="editDepartment.jsp?id=<%= department.get("id") %>" class="btn">修改</a>
                <a href="deleteDepartment.jsp?id=<%= department.get("id") %>" class="btn" onclick="return confirm('确定要删除该部门吗？');">删除</a>
            </td>
        </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <p>
        <a href="department.jsp" class="btn">返回</a>
    </p>
</div>
</body>
</html>
