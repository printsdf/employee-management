<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>管理我的</title>
    <link rel="stylesheet" href="../style/styles.css">
</head>
<body>
<header>
    <h1>管理我的</h1>
</header>
<nav>
    <%
        String role = (String) session.getAttribute("role");
        if ("admin".equals(role)) {
    %>
    <a href="../employee/employee.jsp">员工管理</a>
    <a href="../department/department.jsp">部门管理</a>
    <a href="../attendance/attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="myUser.jsp">管理我的</a>
    <% } else { %>
    <a href="../attendance/attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="myUser.jsp">管理我的</a>
    <% }%>
</nav>
<div class="container">
    <h1>管理我的</h1>
    <p>在这里，所有用户可以修改自己的用户名和密码。</p>
    <a href="editUser.jsp" class="btn">修改用户信息</a>
    <a href="../index.jsp" class="btn">返回首页</a>
</div>
</body>
</html>
