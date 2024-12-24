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
    <title>考勤管理</title>
    <link rel="stylesheet" href="../style/styles.css">
</head>
<body>
<header>
    <h1>考勤管理</h1>
</header>
<nav>
    <%
        String role = (String) session.getAttribute("role");
        if ("admin".equals(role)) {
    %>
    <a href="../employee/employee.jsp">员工管理</a>
    <a href="../department/department.jsp">部门管理</a>
    <a href="attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
    <% } else { %>
    <a href="attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
    <% }%>
</nav>
<div class="container">
    <h1>考勤管理</h1>
    <p>在这里，管理员和员工可以查看考勤记录。</p>
    <%if ("admin".equals((String)session.getAttribute("role"))) {%>
    <a href="viewAttendance.jsp" class="btn">查看所有考動记录</a>
    <a href="attendanceClock.jsp" class="btn">考勤打卡</a>
    <a href="../index.jsp" class="btn">返回首页</a>
    <% }else{%>
    <a href="viewMyAttendance.jsp" class="btn">查看我的考勤记录</a>
    <a href="attendanceClock.jsp" class="btn">考勤打卡</a>
    <a href="../index.jsp" class="btn">返回首页</a>
    <%}%>
</div>
</body>
</html>
