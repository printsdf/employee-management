<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 权限验证
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    String name = request.getParameter("name");
    String departmentName = request.getParameter("department");
    String position = request.getParameter("position");
    String userRole = request.getParameter("role");
    String baseSalaryStr = request.getParameter("base_salary");
    String contact = request.getParameter("contact");

    // 数据验证
    if (name == null || departmentName == null || position == null || userRole == null || baseSalaryStr == null || contact == null) {
        session.setAttribute("message", "提交的数据不完整，请重新填写！");
        response.sendRedirect("employee.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmtUser = null;
    PreparedStatement stmtDepartment = null;
    PreparedStatement stmtEmployeeDepartment = null;
    PreparedStatement stmtSalary = null;
    PreparedStatement stmtGetLastEmployeeId = null;
    ResultSet rs = null;

    try {
        // 数据库连接
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");
        conn.setAutoCommit(false); // 开启事务

        // 获取最新的员工 ID
        String getLastEmployeeIdSql = "SELECT employee_id FROM users ORDER BY id DESC LIMIT 1";
        stmtGetLastEmployeeId = conn.prepareStatement(getLastEmployeeIdSql);
        rs = stmtGetLastEmployeeId.executeQuery();

        String newEmployeeId;
        if (rs.next()) {
            String lastEmployeeId = rs.getString("employee_id");
            int numericPart = Integer.parseInt(lastEmployeeId.substring(1));
            newEmployeeId = "E" + String.format("%03d", numericPart + 1);
        } else {
            newEmployeeId = "E001"; // 如果没有员工记录，从 E001 开始
        }

        // 1. 插入用户数据
        String insertUserSql = "INSERT INTO users (username, password, role, name, employee_id, position, contact) VALUES (?, ?, ?, ?, ?, ?, ?)";
        stmtUser = conn.prepareStatement(insertUserSql);
        stmtUser.setString(1, name); //默认用户名为姓名，用户可后续修改
        stmtUser.setString(2, "password123"); // 默认密码，可后续要求用户更改
        stmtUser.setString(3, userRole);
        stmtUser.setString(4, name);
        stmtUser.setString(5, newEmployeeId);
        stmtUser.setString(6, position);
        stmtUser.setString(7, contact);
        stmtUser.executeUpdate();

        // 2. 查找部门 ID
        String selectDepartmentSql = "SELECT id FROM departments WHERE name = ?";
        stmtDepartment = conn.prepareStatement(selectDepartmentSql);
        stmtDepartment.setString(1, departmentName);
        rs = stmtDepartment.executeQuery();

        int departmentId;
        if (rs.next()) {
            departmentId = rs.getInt("id");
        } else {
            throw new Exception("部门不存在，请联系管理员添加部门！");
        }

        // 3. 插入员工-部门关联数据
        String insertEmployeeDepartmentSql = "INSERT INTO employee_department (employee_id, department_id) VALUES (?, ?)";
        stmtEmployeeDepartment = conn.prepareStatement(insertEmployeeDepartmentSql);
        stmtEmployeeDepartment.setString(1, newEmployeeId);
        stmtEmployeeDepartment.setInt(2, departmentId);
        stmtEmployeeDepartment.executeUpdate();

        // 4. 插入工资表数据
        String insertSalarySql = "INSERT INTO salary (employee_id, month, base_salary, attendance_bonus, total_salary) VALUES (?, CURDATE(), ?, 0, ?)";
        stmtSalary = conn.prepareStatement(insertSalarySql);
        stmtSalary.setString(1, newEmployeeId);
        stmtSalary.setBigDecimal(2, new java.math.BigDecimal(baseSalaryStr));
        stmtSalary.setBigDecimal(3, new java.math.BigDecimal(baseSalaryStr)); // 初始总工资等于基础工资
        stmtSalary.executeUpdate();

        // 提交事务
        conn.commit();
        session.setAttribute("message", "员工添加成功！");
        response.sendRedirect("employee.jsp");

    } catch (Exception e) {
        if (conn != null) {
            try {
                conn.rollback(); // 回滚事务
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
        }
        e.printStackTrace();
        session.setAttribute("message", "系统错误，添加员工失败，请稍后重试！");
        response.sendRedirect("employee.jsp");

    } finally {
        // 释放资源
        if (rs != null) rs.close();
        if (stmtUser != null) stmtUser.close();
        if (stmtDepartment != null) stmtDepartment.close();
        if (stmtEmployeeDepartment != null) stmtEmployeeDepartment.close();
        if (stmtSalary != null) stmtSalary.close();
        if (stmtGetLastEmployeeId != null) stmtGetLastEmployeeId.close();
        if (conn != null) conn.close();
    }
%>
