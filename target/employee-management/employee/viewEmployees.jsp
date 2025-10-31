<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 权限验证
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        // 数据库连接
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 获取筛选条件
        String filterName = request.getParameter("filterName");
        String filterId = request.getParameter("filterId");
        String filterDepartment = request.getParameter("filterDepartment");

        // 清理用户输入
        filterName = (filterName != null) ? filterName.trim() : "";
        filterId = (filterId != null) ? filterId.trim() : "";
        filterDepartment = (filterDepartment != null) ? filterDepartment.trim() : "";

        // 查询语句
        String sql = "SELECT DISTINCT u.employee_id, u.name, u.username, u.position, u.contact, u.role, " +
                "d.name AS department_name, s.base_salary " +
                "FROM users u " +
                "LEFT JOIN employee_department ed ON u.employee_id = ed.employee_id " +
                "LEFT JOIN departments d ON ed.department_id = d.id " +
                "LEFT JOIN salary s ON u.employee_id = s.employee_id " +
                "WHERE 1=1 ";

        // 构建查询条件
        if (!filterName.isEmpty()) {
            sql += " AND u.name LIKE ? ";
        }
        if (!filterId.isEmpty()) {
            sql += " AND u.employee_id LIKE ? ";
        }
        if (!filterDepartment.isEmpty()) {
            sql += " AND d.id = ? ";
        }

        // 准备语句
        stmt = conn.prepareStatement(sql);

        // 设置参数
        int paramIndex = 1;
        if (!filterName.isEmpty()) {
            stmt.setString(paramIndex++, "%" + filterName + "%");
        }
        if (!filterId.isEmpty()) {
            stmt.setString(paramIndex++, filterId);
        }
        if (!filterDepartment.isEmpty()) {
            stmt.setString(paramIndex++, "%" + filterDepartment + "%");
        }

        // 执行查询
        rs = stmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>员工列表</title>
    <link rel="stylesheet" href="../style/styles.css">
    <style>
        form {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        form label {
            font-weight: bold;
            margin-right: 10px;
            color: #333;
            display: inline-block;
            width: 100px;
            margin-bottom: 10px;
        }

        form input, form select {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 200px;
            margin-bottom: 10px;
        }

        form button {
            background-color: #0056b3;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        form button:hover {
            background-color: #004494;
        }

        td .btn {
            display: inline-block;
            background-color: #d9534f;
            color: white;
            padding: 8px 12px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            transition: background-color 0.3s;
            margin: 2px;
        }

        td .btn:hover {
            background-color: #c9302c;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f5f5f5;
        }

        .btn {
            background-color: #0056b3;
            color: white;
            padding: 0.5rem 1rem;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        .btn:hover {
            background-color: #004494;
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
    <h1>员工列表</h1>

    <!-- 筛选表单 -->
    <form action="viewEmployees.jsp" method="get">
        <div>
            <label for="filterName">姓名：</label>
            <input type="text" id="filterName" name="filterName" value="<%= filterName %>">
        </div>

        <div>
            <label for="filterId">工号：</label>
            <input type="text" id="filterId" name="filterId" value="<%= filterId %>">
        </div>

        <div>
            <label for="filterDepartment">部门：</label>
            <select id="filterDepartment" name="filterDepartment">
                <option value="">全部部门</option>
                <%
                    // 获取所有部门列表
                    PreparedStatement deptStmt = conn.prepareStatement("SELECT id, name FROM departments");
                    ResultSet deptRs = deptStmt.executeQuery();
                    while (deptRs.next()) {
                        String deptId = deptRs.getString("id");
                        String deptName = deptRs.getString("name");
                        boolean isSelected = deptId.equals(filterDepartment);
                %>
                <option value="<%= deptId %>" <%= isSelected ? "selected" : "" %>><%= deptName %></option>
                <%
                    }
                    deptRs.close();
                    deptStmt.close();
                %>
            </select>
        </div>

        <button type="submit">筛选</button>
    </form>

    <!-- 员工信息表 -->
    <table>
        <thead>
        <tr>
            <th>员工ID</th>
            <th>姓名</th>
            <th>用户名</th>
            <th>部门</th>
            <th>职位</th>
            <th>联系方式</th>
            <th>角色</th>
            <th>基础工资</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                String employeeId = rs.getString("employee_id");
                String name = rs.getString("name") != null ? rs.getString("name") : "";
                String username = rs.getString("username") != null ? rs.getString("username") : "";
                String departmentName = rs.getString("department_name") != null ? rs.getString("department_name") : "";
                String position = rs.getString("position") != null ? rs.getString("position") : "";
                String contact = rs.getString("contact") != null ? rs.getString("contact") : "";
                String employeeRole = rs.getString("role") != null ? rs.getString("role") : "";
                BigDecimal baseSalary = rs.getBigDecimal("base_salary");
        %>
        <tr>
            <td><%= employeeId %></td>
            <td><%= name %></td>
            <td><%= username %></td>
            <td><%= departmentName %></td>
            <td><%= position %></td>
            <td><%= contact %></td>
            <td><%= employeeRole %></td>
            <td><%= baseSalary != null ? baseSalary : "" %></td>
            <td>
                <%
                    if (!"admin".equals(employeeRole)) {
                %>
                <a href="editEmployee.jsp?employeeId=<%= employeeId %>" class="btn">修改</a>
                <form action="deleteEmployee.jsp" method="post" style="display:inline;">
                    <input type="hidden" name="employeeId" value="<%= employeeId %>">
                    <button type="submit" class="btn" onclick="return confirm('确定要删除该员工吗？');">删除</button>
                </form>
                <%
                } else {
                %>
                <span>管理员不可修改或删除</span>
                <%
                    }
                %>
            </td>

        </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <p>
        <a href="employee.jsp" class="btn">返回</a>
    </p>
</div>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>