<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证是否登录及权限
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取筛选参数
    String filterName = request.getParameter("filterName");
    String filterEmployeeId = request.getParameter("filterEmployeeId");

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    StringBuilder sql = new StringBuilder(
            "SELECT s.id AS salary_id, u.employee_id, u.name AS employee_name, u.role AS employee_role, s.month, " +
                    "s.base_salary, s.attendance_bonus, s.total_salary, s.deductions " +
                    "FROM salary s " +
                    "JOIN users u ON s.employee_id = u.employee_id " +
                    "WHERE 1=1 "
    );

    if (filterName != null && !filterName.trim().isEmpty()) {
        sql.append("AND u.name LIKE ? ");
    }
    if (filterEmployeeId != null && !filterEmployeeId.trim().isEmpty()) {
        sql.append("AND u.employee_id LIKE ? ");
    }

    sql.append("ORDER BY s.month DESC");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        stmt = conn.prepareStatement(sql.toString());

        int index = 1;
        if (filterName != null && !filterName.trim().isEmpty()) {
            stmt.setString(index++, "%" + filterName + "%");
        }
        if (filterEmployeeId != null && !filterEmployeeId.trim().isEmpty()) {
            stmt.setString(index++, "%" + filterEmployeeId + "%");
        }

        rs = stmt.executeQuery();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>查看所有工资信息</title>
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
    <h1>查看所有工资信息</h1>
</header>
<nav>
    <a href="salary.jsp">返回工资管理</a>
</nav>

<div class="container">
    <form method="get" action="viewSalaries.jsp">
        <label for="filterName">姓名：</label>
        <input type="text" name="filterName" id="filterName" value="<%= filterName != null ? filterName : "" %>">

        <label for="filterEmployeeId">工号：</label>
        <input type="text" name="filterEmployeeId" id="filterEmployeeId" value="<%= filterEmployeeId != null ? filterEmployeeId : "" %>">

        <button type="submit" class="btn">筛选</button>
    </form>

    <table>
        <thead>
        <tr>
            <th>工号</th>
            <th>姓名</th>
            <th>工资月份</th>
            <th>基础工资</th>
            <th>考勤奖金</th>
            <th>总工资</th>
            <th>扣款</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <%
            try {
                while (rs.next()) {
                    String employeeId = rs.getString("employee_id");
                    String employeeName = rs.getString("employee_name");
                    String employeeRole = rs.getString("employee_role");
                    String salaryMonth = rs.getString("month");
                    double baseSalary = rs.getDouble("base_salary");
                    double attendanceBonus = rs.getDouble("attendance_bonus");
                    double totalSalary = rs.getDouble("total_salary");
                    double deductions = rs.getDouble("deductions");
        %>
        <tr>
            <td><%= employeeId %></td>
            <td><%= employeeName %></td>
            <td><%= salaryMonth %></td>
            <td><%= baseSalary %></td>
            <td><%= attendanceBonus %></td>
            <td><%= totalSalary %></td>
            <td><%= deductions %></td>
            <td>
                <%
                    if (!"admin".equals(employeeRole)) {
                %>

                <a href="editSalary.jsp?employeeId=<%= employeeId %>" class="btn">修改</a>
                <a href="deleteSalary.jsp?employeeId=<%= employeeId %>" class="btn" onclick="return confirm('确认要删除这条记录吗？');">删除</a>

                <%
                } else {
                %>

                <span>管理员不可修改或删除</span>

                <%
                    }
                %>
            </td>
        </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        %>
        </tbody>
    </table>

    <p>
        <a href="salary.jsp" class="btn">返回</a>
    </p>
</div>
</body>
</html>
