<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>企业员工管理系统</title>
    <link rel="stylesheet" href="style/index.css">
</head>
<body>
<header>
    <h1>员工管理系统</h1>
</header>
<nav>
    <%
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        if (username != null && "admin".equals(role)) {
    %>
    <a href="employee/employee.jsp">员工管理</a>
    <a href="department/department.jsp">部门管理</a>
    <a href="attendance/attendance.jsp">考勤管理</a>
    <a href="salary/salary.jsp">工资管理</a>
    <a href="userManagement/myUser.jsp">管理我的</a>
    <% } else if (username != null) { %>
    <a href="attendance/attendance.jsp">考勤管理</a>
    <a href="salary/salary.jsp">工资管理</a>
    <% } else { %>
    <a href="login/login.jsp">登录</a>
    <% } %>
</nav>
<div class="container">
    <h1>欢迎使用员工管理系统</h1>
    <div class="login-status">
        <%
            if (username == null) {
        %>
        <p>您尚未登录，请先<a href="login/login.jsp">登录</a>。</p>
        <% } else { %>
        <p>欢迎，<%= username %>!</p>
        <a href="login/logout.jsp" >退出登录</a>
        <% } %>
    </div>
    <% if (username != null) { %>
    <div class="text-center">
        <% if ("admin".equals(role)) { %>
        <a href="employee/employee.jsp" class="btn">管理员工</a>
        <a href="department/department.jsp" class="btn">管理部门</a>
        <a href="attendance/attendance.jsp" class="btn">查看考勤</a>
        <a href="salary/salary.jsp" class="btn">查看工资</a>
        <a href="userManagement/myUser.jsp" class="btn">管理我的</a>
        <% } else { %>
        <a href="attendance/attendance.jsp" class="btn">查看考勤</a>
        <a href="salary/salary.jsp" class="btn">查看工资</a>
            <% } %>
    </div>
    <% } %>
</div>
</body>
</html>
