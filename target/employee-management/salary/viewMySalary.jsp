<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证是否登录
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    String employeeId = null; // 用于存储根据 username 查询到的 employeeId

    try {
        // 加载数据库驱动
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 查询 employee_id
        String employeeIdQuery = "SELECT employee_id FROM users WHERE username = ?";
        stmt = conn.prepareStatement(employeeIdQuery);
        stmt.setString(1, username);

        ResultSet userRs = stmt.executeQuery();
        if (userRs.next()) {
            employeeId = userRs.getString("employee_id");
        } else {
            out.println("<p>未找到与用户名关联的员工信息，请联系管理员。</p>");
            return;
        }
        userRs.close();
        stmt.close();

        // 查询工资信息
        String salaryQuery = "SELECT month, base_salary, attendance_bonus, total_salary, deductions " +
                "FROM salary WHERE employee_id = ? ORDER BY month DESC";
        stmt = conn.prepareStatement(salaryQuery);
        stmt.setString(1, employeeId);

        rs = stmt.executeQuery();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>系统错误，请稍后再试。</p>");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>查看我的工资信息</title>
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
    <h1>我的工资信息</h1>
</header>
<nav>
    <a href="salary.jsp">返回工资管理</a>
</nav>

<div class="container">
    <table>
        <thead>
        <tr>
            <th>工资月份</th>
            <th>基础工资</th>
            <th>考勤奖金</th>
            <th>总工资</th>
            <th>扣款</th>
        </tr>
        </thead>
        <tbody>
        <%
            try {
                while (rs.next()) {
                    String salaryMonth = rs.getString("month");
                    double baseSalary = rs.getDouble("base_salary");
                    double attendanceBonus = rs.getDouble("attendance_bonus");
                    double totalSalary = rs.getDouble("total_salary");
                    double deductions = rs.getDouble("deductions");
        %>
        <tr>
            <td><%= salaryMonth %></td>
            <td><%= baseSalary %></td>
            <td><%= attendanceBonus %></td>
            <td><%= totalSalary %></td>
            <td><%= deductions %></td>
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
