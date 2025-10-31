<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取部门信息
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    List<String> departments = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");
        String sql = "SELECT name FROM departments";
        stmt = conn.prepareStatement(sql);
        rs = stmt.executeQuery();

        while (rs.next()) {
            departments.add(rs.getString("name"));
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
    <title>添加员工</title>
    <link rel="stylesheet" href="../style/styles.css">
    <style>
        form p {
            margin-bottom: 15px;
        }
        label {
            display: inline-block;
            width: 100px;
            text-align: right;
        }
        input[type="text"],
        input[type="number"],
        select {
            width: 250px;
            padding: 8px;
            margin-left: 10px;
            font-size: 14px;
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
    <h1>员工管理系统</h1>
</header>
<nav>
    <a href="employee.jsp">员工管理</a>
    <a href="../department/department.jsp">部门管理</a>
    <a href="../attendance/attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
</nav>
<div class="container">
    <h1>添加员工</h1>
    <form action="addEmployeeHandler.jsp" method="post">
        <p>
            <label for="name">姓名：</label>
            <input type="text" id="name" name="name" required>
        </p>
        <p>
            <label for="department">部门：</label>
            <select id="department" name="department" required>
                <option value="">请选择部门</option>
                <%
                    for (String department : departments) {
                %>
                <option value="<%= department %>"><%= department %></option>
                <%
                    }
                %>
            </select>
        </p>
        <p>
            <label for="position">职位：</label>
            <input type="text" id="position" name="position" required>
        </p>
        <p>
            <label for="role">角色：</label>
            <select id="role" name="role" required>
                <option value="">请选择角色</option>
                <option value="user">普通用户</option>
                <option value="admin">管理员</option>
            </select>
        </p>
        <p>
            <label for="base_salary">基础工资：</label>
            <input type="number" id="base_salary" name="base_salary" min="0" required>
            <span id="salary-error" style="color: red; display: none;">工资不能为负数！</span>
        </p>
        <p>
            <label for="contact">联系电话：</label>
            <input
                    type="text"
                    id="contact"
                    name="contact"
                    pattern="\d{11}"
                    title="联系电话必须是11位数字"
                    required>
            <span id="contact-error" style="color: red; display: none;">联系电话必须是11位数字！</span>
        </p>
        <p>
            <button type="submit" id="submit-btn" class="btn">提交</button>
            <a href="employee.jsp" class="btn">返回</a>
        </p>
    </form>
</div>

<script>
    const baseSalaryInput = document.getElementById("base_salary");
    const errorSpan = document.getElementById("salary-error");
    const submitBtn = document.getElementById("submit-btn");

    baseSalaryInput.addEventListener("input", function () {
        const salary = parseFloat(this.value);

        if (salary < 0) {
        errorSpan.style.display = "inline";
        submitBtn.disabled = true;
        } else {
            errorSpan.style.display = "none";
            submitBtn.disabled = false;
        }
    });

    const contactInput = document.getElementById("contact");
    const contactErrorSpan = document.getElementById("contact-error");

    contactInput.addEventListener("input", function () {
        const contactValue = this.value;

        if (!/^\d{11}$/.test(contactValue)) {
            contactErrorSpan.style.display = "inline";
            submitBtn.disabled = true;
        } else {
            contactErrorSpan.style.display = "none";
            submitBtn.disabled = false;
        }
    });

    document.getElementById("username").addEventListener("input", function () {
        const username = this.value;
        const statusSpan = document.getElementById("username-status");

        if (username.length === 0) {
            statusSpan.textContent = ""; // 清空状态
            return;
        }

        // 发送 AJAX 请求
        const xhr = new XMLHttpRequest();
        xhr.open("GET", "../login/checkUsername.jsp?username=" + encodeURIComponent(username), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                const response = xhr.responseText.trim();
                if (response === "exists") {
                    statusSpan.textContent = "用户名已存在！";
                    statusSpan.style.color = "red";
                } else {
                    statusSpan.textContent = "用户名可用";
                    statusSpan.style.color = "green";
                }
            }
        };
        xhr.send();
    });
</script>
</body>
</html>
