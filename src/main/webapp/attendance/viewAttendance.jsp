<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证用户是否登录
    String role = (String) session.getAttribute("role");
    if (role == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取筛选参数
    String filterName = request.getParameter("filterName");
    String filterEmployeeId = request.getParameter("filterEmployeeId");
    String filterDepartment = request.getParameter("filterDepartment");

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    // 查询 SQL
    StringBuilder sql = new StringBuilder(
            "SELECT a.id AS attendance_id, u.employee_id, u.role AS employee_role, u.name AS employee_name, d.name AS department_name, " +
                    "a.date, a.check_in_time, a.check_out_time, a.status " +
                    "FROM attendance a " +
                    "JOIN users u ON a.employee_id = u.employee_id " +
                    "JOIN employee_department ed ON u.employee_id = ed.employee_id " +
                    "JOIN departments d ON ed.department_id = d.id " +
                    "WHERE 1=1 "
    );

    if (filterName != null && !filterName.trim().isEmpty()) {
        sql.append("AND u.name LIKE ? ");
    }
    if (filterEmployeeId != null && !filterEmployeeId.trim().isEmpty()) {
        sql.append("AND u.employee_id LIKE ? ");
    }
    if (filterDepartment != null && !filterDepartment.trim().isEmpty()) {
        sql.append("AND d.id = ? ");
    }

    sql.append("ORDER BY a.date DESC");

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        stmt = conn.prepareStatement(sql.toString());

        // 设置查询参数
        int index = 1;
        if (filterName != null && !filterName.trim().isEmpty()) {
            stmt.setString(index++, "%" + filterName + "%");
        }
        if (filterEmployeeId != null && !filterEmployeeId.trim().isEmpty()) {
            stmt.setString(index++, "%" + filterEmployeeId + "%");
        }
        if (filterDepartment != null && !filterDepartment.trim().isEmpty()) {
            stmt.setString(index++, filterDepartment);
        }

        rs = stmt.executeQuery();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>考勤记录管理</title>
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
    <h1>考勤记录管理</h1>
</header>
<nav>
    <a href="../employee/employee.jsp">员工管理</a>
    <a href="../department/department.jsp">部门管理</a>
    <a href="attendance.jsp">考勤管理</a>
    <a href="../salary/salary.jsp">工资管理</a>
    <a href="../userManagement/myUser.jsp">管理我的</a>
</nav>

<div class="container">
    <h2>查看所有考勤记录</h2>

    <!-- 筛选表单 -->
    <form method="get" action="viewAttendance.jsp">

        <div>
            <label for="filterName">姓名：</label>
            <input type="text" name="filterName" id="filterName" value="<%= filterName != null ? filterName : "" %>">
        </div>

        <div>
            <label for="filterEmployeeId">工号：</label>
            <input type="text" name="filterEmployeeId" id="filterEmployeeId" value="<%= filterEmployeeId != null ? filterEmployeeId : "" %>">
        </div>

        <div>
            <label for="filterDepartment">部门：</label>
            <select name="filterDepartment" id="filterDepartment">
                <option value="">全部部门</option>
                <%
                    // 查询所有部门
                    PreparedStatement deptStmt = conn.prepareStatement("SELECT id, name FROM departments");
                    ResultSet deptRs = deptStmt.executeQuery();
                    while (deptRs.next()) {
                        String deptId = deptRs.getString("id");
                        String deptName = deptRs.getString("name");
                %>
                <option value="<%= deptId %>" <%= deptId.equals(filterDepartment) ? "selected" : "" %>>
                    <%= deptName %>
                </option>
                <%
                    }
                    deptRs.close();
                    deptStmt.close();
                %>
            </select>
        </div>

        <button type="submit">筛选</button>
    </form>

    <!-- 考勤记录表格 -->
    <table>
        <thead>
        <tr>
            <th>工号</th>
            <th>姓名</th>
            <th>部门</th>
            <th>考勤日期</th>
            <th>签到时间</th>
            <th>签退时间</th>
            <th>考勤状态</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <%
            try {
                while (rs.next()) {
                    String attendanceId = rs.getString("attendance_id");
                    String employeeId = rs.getString("employee_id");
                    String employeeName = rs.getString("employee_name");
                    String employeeRole = rs.getString("employee_role");
                    String departmentName = rs.getString("department_name");
                    String attendanceDate = rs.getString("date");
                    String checkInTime = rs.getString("check_in_time");
                    String checkOutTime = rs.getString("check_out_time");
                    String attendanceStatus = rs.getString("status");
        %>
        <tr>
            <td><%= employeeId %></td>
            <td><%= employeeName %></td>
            <td><%= departmentName %></td>
            <td><%= attendanceDate %></td>
            <td><%= checkInTime != null ? checkInTime : "未签到" %></td>
            <td><%= checkOutTime != null ? checkOutTime : "未签退" %></td>
            <td>
                <%
                    if ("present".equals(attendanceStatus)) {
                        out.print("出勤");
                    } else if ("absent".equals(attendanceStatus)) {
                        out.print("缺勤");
                    } else if ("late".equals(attendanceStatus)) {
                        out.print("迟到");
                    } else if ("lease".equals(attendanceStatus)) {
                        out.print("请假");
                    } else {
                        out.print("未知状态");
                    }
                %>
            </td>

            <td>
                <%
                    if (!"admin".equals(employeeRole)) {
                %>
                <a href="editAttendance.jsp?attendanceId=<%= attendanceId %>" class="btn">修改</a>
                <a href="deleteAttendance.jsp?attendanceId=<%= attendanceId %>" class="btn" onclick="return confirm('确认要删除这条记录吗？');">删除</a>
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
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        %>
        </tbody>
    </table>

    <p>
        <a href="attendance.jsp" class="btn">返回</a>
    </p>
</div>
</body>
</html>
