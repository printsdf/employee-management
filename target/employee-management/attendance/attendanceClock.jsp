<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证用户是否登录
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    String employeeId = null;
    String checkInTime = null;
    String checkOutTime = null;

    if (role == null || username == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 根据用户名获取员工编号
        String query = "SELECT employee_id FROM users WHERE username = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, username);
        rs = stmt.executeQuery();

        if (rs.next()) {
            employeeId = rs.getString("employee_id");
        } else {
            out.println("<p>无法找到您的员工信息，请联系管理员。</p>");
            return;
        }

        // 检查今天的考勤记录
        java.util.Date currentDate = new java.util.Date();
        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
        String todayDate = dateFormat.format(currentDate);

        query = "SELECT check_in_time, check_out_time, status FROM attendance WHERE employee_id = ? AND date = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, employeeId);
        stmt.setString(2, todayDate);
        rs = stmt.executeQuery();

        if (rs.next()) {
            checkInTime = rs.getString("check_in_time");
            checkOutTime = rs.getString("check_out_time");
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
    <title>考勤打卡</title>
    <link rel="stylesheet" href="../style/styles.css">
    <style>
        .container {
            max-width: 600px;
            margin: 50px auto;
            text-align: center;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
        button {
            padding: 10px 20px;
            font-size: 16px;
            margin: 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            background-color: #4CAF50;
            color: white;
        }
        button:hover {
            background-color: #45a049;
        }
        .status {
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            text-decoration: none;
            color: #333;
            background-color: #f0f0f0;
            border-radius: 4px;
        }
        .btn:hover {
            background-color: #e0e0e0;
        }
    </style>
</head>
<body>
<header>
    <h1>考勤打卡系统</h1>
</header>
<nav>
    <a href="attendanceClock.jsp">考勤打卡</a>
    <a href="attendance.jsp">查看考勤记录</a>
    <a href="../employee/employee.jsp">员工管理</a>
    <a href="../login/logout.jsp">退出登录</a>
</nav>

<div class="container">
    <h2>欢迎，<%= username %></h2>
    <h3>今天的日期：<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %></h3>

    <% if (checkInTime == null) { %>
    <!-- 签到按钮 -->
    <form method="post" action="attendanceClockIn.jsp">
        <input type="hidden" name="employeeId" value="<%= employeeId %>">
        <input type="hidden" name="attendanceDate" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
        <button type="submit">签到</button>
    </form>
    <% } else { %>
    <p>已签到，签到时间：<%= checkInTime %></p>
    <% } %>

    <% if (checkInTime != null && checkOutTime == null) { %>
    <!-- 签退按钮 -->
    <form method="post" action="attendanceClockOut.jsp">
        <input type="hidden" name="employeeId" value="<%= employeeId %>">
        <input type="hidden" name="attendanceDate" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
        <button type="submit">签退</button>
    </form>
    <% } else if (checkOutTime != null) { %>
    <p>已签退，签退时间：<%= checkOutTime %></p>
    <% } %>

    <p>
        <a href="attendance.jsp" class="btn">返回</a>
    </p>
</div>
</body>
</html>