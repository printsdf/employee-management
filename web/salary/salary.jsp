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
    <title>工资管理</title>
    <link rel="stylesheet" href="../style/styles.css">
</head>
<body>
<header>
    <h1>工资管理</h1>
</header>
<nav>
    <%
        String role = (String) session.getAttribute("role");
        if ("admin".equals(role)) {
    %>
    <a href="../employee/employee.jsp">员工管理</a>
    <a href="../department/department.jsp">部门管理</a>
    <a href="../attendance/attendance.jsp">考勤管理</a>
    <a href="salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
    <% } else { %>
    <a href="../attendance/attendance.jsp">考勤管理</a>
    <a href="salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
    <% }%>
</nav>
<div class="container">
    <h1>工资管理</h1>
    <p>在这里，管理员可以管理工资，员工可以查看自己的工资信息。</p>
    <% if ("admin".equals(session.getAttribute("role"))) { %>
    <a href="viewSalaries.jsp" class="btn">查看所有工资信息</a>
    <a href="../index.jsp" class="btn">返回首页</a>
    <% } else { %>
    <a href="viewMySalary.jsp" class="btn">查看我的工资信息</a>
    <a href="../index.jsp" class="btn">返回首页</a>
    <% } %>
</div>
</body>
</html>
