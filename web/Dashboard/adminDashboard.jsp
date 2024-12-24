<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理员控制台</title>
    <link rel="stylesheet" href="../style/index.css">
</head>
<body>
<header>
    <h1>管理员控制台</h1>
</header>
<% String username = (String) session.getAttribute("username"); %>
<div class="container">
    <h1>欢迎，管理员 <%=username%></h1>
    <p>您可以管理以下模块：</p>
    <a href="../employee/employee.jsp" class="btn">管理员工</a>
    <a href="../department/department.jsp" class="btn">管理部门</a>
    <a href="../attendance/attendance.jsp" class="btn">查看考勤</a>
    <a href="../salary/salary.jsp" class="btn">查看工资</a>
    <a href="../userManagement/myUser.jsp" class="btn">管理我的</a>
    <a href="../index.jsp" class="btn">返回首页</a>
</div>
</body>
</html>
