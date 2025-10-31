<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    String employeeId = request.getParameter("employeeId");
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    String name = "", username = "", position = "", contact = "", role = "", department = "";
    BigDecimal baseSalary = null;

    // 保存所有部门的列表
    List<String> departmentList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 查询员工信息
        String sql = "SELECT u.name, u.username, u.position, u.contact, u.role, " +
                "MAX(d.name) AS department_name, MAX(s.base_salary) AS base_salary " +
                "FROM users u " +
                "LEFT JOIN employee_department ed ON u.employee_id = ed.employee_id " +
                "LEFT JOIN departments d ON ed.department_id = d.id " +
                "LEFT JOIN salary s ON u.employee_id = s.employee_id " +
                "WHERE u.employee_id = ? " +
                "GROUP BY u.name, u.username, u.position, u.contact, u.role;";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, employeeId);
        rs = stmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            username = rs.getString("username");
            position = rs.getString("position");
            contact = rs.getString("contact");
            role = rs.getString("role");
            department = rs.getString("department_name");
            baseSalary = rs.getBigDecimal("base_salary");
        }
        rs.close();
        stmt.close();

        // 查询所有部门
        sql = "SELECT name FROM departments";
        stmt = conn.prepareStatement(sql);
        rs = stmt.executeQuery();

        while (rs.next()) {
            departmentList.add(rs.getString("name"));
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
    <title>修改员工信息</title>
    <link rel="stylesheet" href="../style/edit.css">
</head>
<body>
<div class="container">
    <h1>修改员工信息</h1>
    <form action="updateEmployee.jsp" method="post">
        <input type="hidden" name="employeeId" value="<%= employeeId %>">
        <p>
            <label for="name">姓名：</label>
            <input type="text" id="name" name="name" value="<%= name %>" required>
        </p>

        <p>
            <label for="position">职位：</label>
            <input type="text" id="position" name="position" value="<%= position %>" required>
        </p>

        <p>
            <label for="contact">联系方式：</label>
            <input type="text" id="contact" name="contact" value="<%= contact %>" required>
        </p>

        <p>
            <label for="role">角色：</label>
            <input type="text" id="role" name="role" value="<%= role %>" required>
        </p>

        <p>
            <label for="department">部门：</label>
            <select id="department" name="department" required>
                <option value="" disabled selected>请选择部门</option>
                <% for (String dept : departmentList) { %>
                <option value="<%= dept %>" <%= department.equals(dept) ? "selected" : "" %>>
                    <%= dept %>
                </option>
                <% } %>
            </select>
        </p>

        <p>
            <label for="base_salary">基础工资：</label>
            <input type="number" id="base_salary" name="base_salary" min="0" value="<%= baseSalary %>" required>
            <span id="salary-error" style="color: red; display: none;">工资不能为负数！</span>
        </p>

        <p>
            <button type="submit" id="submit-btn" class="btn">提交修改</button>
            <a href="viewEmployees.jsp" class="btn">返回</a>
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
</script>
</body>
</html>
