<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证用户是否登录
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    String employeeId = null;

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 查询当前用户的 employeeId
        String employeeIdQuery = "SELECT employee_id FROM users WHERE username = ?";
        stmt = conn.prepareStatement(employeeIdQuery);
        stmt.setString(1, username);
        ResultSet userRs = stmt.executeQuery();

        if (userRs.next()) {
            employeeId = userRs.getString("employee_id");
        } else {
            out.println("未找到用户对应的工号！");
            return;
        }
        userRs.close();
        stmt.close();

        // 查询考勤记录
        String attendanceQuery = "SELECT date, check_in_time, check_out_time, status " +
                "FROM attendance WHERE employee_id = ? ORDER BY date DESC";
        stmt = conn.prepareStatement(attendanceQuery);
        stmt.setString(1, employeeId);
        rs = stmt.executeQuery();

    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>我的考勤记录</title>
    <link rel="stylesheet" href="../style/styles.css">
    <style>
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
    <h1>我的考勤记录</h1>
</header>
<nav>
    <a href="attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
</nav>

<div class="container">
    <h2>我的考勤记录</h2>

    <table>
        <thead>
        <tr>
            <th>考勤日期</th>
            <th>签到时间</th>
            <th>签退时间</th>
            <th>考勤状态</th>
        </tr>
        </thead>
        <tbody>
        <%
            try {
                while (rs.next()) {
                    String attendanceDate = rs.getString("date");
                    String checkInTime = rs.getString("check_in_time");
                    String checkOutTime = rs.getString("check_out_time");
                    String attendanceStatus = rs.getString("status");
        %>
        <tr>
            <td><%= attendanceDate %></td>
            <td><%= checkInTime != null ? checkInTime : "未签到" %></td>
            <td><%= checkOutTime != null ? checkOutTime : "未签退" %></td>
            <td>
                <%
                    if ("present".equals(attendanceStatus)) {
                        out.print("出勤");
                    } else if ("absent".equals(attendanceStatus)) {
                        out.print("缺勤");
                    } else if ("late".equals(attendanceStatus)) {
                        out.print("迟到");
                    } else if ("leave".equals(attendanceStatus)) {
                        out.print("请假");
                    } else {
                        out.print("未知状态");
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
        <a href="attendance.jsp" class="btn">返回</a>
    </p>
</div>
</body>
</html>
