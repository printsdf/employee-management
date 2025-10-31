<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>员工管理</title>
    <link rel="stylesheet" href="../style/styles.css">
</head>
<body>
<header>
    <h1>员工管理系统</h1>
</header>
<nav>
    <a href="employee.jsp">员工管理</a>
    <a href="../department/department.jsp">部门管理</a>
    <a href="../attendance/attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
</nav>
<%
    String message = (String) session.getAttribute("message");
    if (message != null) {
%>
<div class="alert"><%= message %></div>
<%
        session.removeAttribute("message");
    }
%>

<div class="container">
    <h1>员工管理</h1>
    <p>在这里，管理员可以查看和管理员工信息。其中“查看所有员工”中可以对员工进行筛选和删除修改功能。</p>
    <a href="viewEmployees.jsp" class="btn">查看所有员工</a>
    <a href="addEmployee.jsp" class="btn">添加员工</a>
    <a href="../index.jsp" class="btn">返回首页</a>
</div>
</body>
</html>
