<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>添加部门</title>
    <link rel="stylesheet" href="../style/styles.css">
    <style>
        form p {
            margin-bottom: 15px;
        }
        label {
            display: inline-block;
            width: 100px;
            text-align: right;
            margin-bottom: 5px;
        }
        input[type="text"],
        input[type="number"],
        select,
        textarea {
            width: 250px;
            padding: 8px;
            margin-left: 10px;
            font-size: 16px;
            vertical-align: top;
            box-sizing: border-box;
        }
        textarea {
            width: 400px; /* 增加宽度 */
            height: 100px;
        }
        button,
        .btn {
            display: inline-block;
            padding: 0.75rem 1.5rem;
            font-size: 16px;
            text-align: center;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            text-decoration: none;
        }
        button {
            background-color: #5cb85c;
            color: white;
            border: none;
        }
        button:hover {
            background-color: #4cae4c;
        }
        .btn {
            background-color: #0056b3;
            color: white;
        }
        .btn:hover {
            background-color: #004494;
        }
        .btn, button {
            margin: 1rem 0.5rem;
        }
    </style>
</head>
<body>
<header>
    <h1>部门管理系统</h1>
</header>
<nav>
    <a href="../employee/employee.jsp">员工管理</a>
    <a href="department.jsp">部门管理</a>
    <a href="../attendance/attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
</nav>
<div class="container">
    <h1>添加部门</h1>
    <form action="addDepartmentHandler.jsp" method="post">
        <p>
            <label for="name">部门名称：</label>
            <input type="text" id="name" name="name" required>
        </p>
        <p>
            <label for="description">部门描述：</label>
            <textarea id="description" name="description" rows="4" cols="50"></textarea>
        </p>
        <p>
            <button type="submit" class="btn">提交</button>
            <a href="department.jsp" class="btn">返回</a>
        </p>
    </form>
</div>
</body>
</html>
