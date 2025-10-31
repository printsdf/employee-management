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
  <title>部门管理</title>
  <link rel="stylesheet" href="../style/styles.css">
</head>
<body>
<header>
  <h1>部门管理</h1>
</header>
<nav>
  <a href="../employee/employee.jsp">员工管理</a>
  <a href="department.jsp">部门管理</a>
  <a href="../attendance/attendance.jsp">考勤管理</a>
  <a href="../salary/salary.jsp">工资管理</a>
  <a href="../userManagement/myUser.jsp">管理我的</a>
</nav>
<div class="container">
  <h1>部门管理</h1>
  <p>在这里，管理员可以管理部门信息。</p>
  <a href="addDepartment.jsp" class="btn">添加部门</a>
  <a href="viewDepartments.jsp" class="btn">查看所有部门</a>
  <a href="../index.jsp" class="btn">返回首页</a>
</div>
</body>
</html>
