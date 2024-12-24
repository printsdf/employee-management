<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    String employeeId = request.getParameter("employeeId");
    String name = request.getParameter("name");
    String username = request.getParameter("username");
    String position = request.getParameter("position");
    String contact = request.getParameter("contact");
    String role = request.getParameter("role");
    String department = request.getParameter("department");
    BigDecimal baseSalary = new BigDecimal(request.getParameter("baseSalary"));

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 更新员工信息
        String sql = "UPDATE users SET name = ?, username = ?, position = ?, contact = ?, role = ? WHERE employee_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, name);
        stmt.setString(2, username);
        stmt.setString(3, position);
        stmt.setString(4, contact);
        stmt.setString(5, role);
        stmt.setString(6, employeeId);
        stmt.executeUpdate();

        // 更新部门信息
        sql = "UPDATE employee_department SET department_id = (SELECT id FROM departments WHERE name = ?) WHERE employee_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, department);
        stmt.setString(2, employeeId);
        stmt.executeUpdate();

        // 更新工资信息
        sql = "UPDATE salary SET base_salary = ? WHERE employee_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setBigDecimal(1, baseSalary);
        stmt.setString(2, employeeId);

        int rows = stmt.executeUpdate();

        if (rows > 0) {
            out.println("<script>alert('用户修改成功！'); window.location='viewEmployees.jsp';</script>");
        } else {
            out.println("<script>alert('用户修改失败，请重试！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('操作失败：" + e.getMessage() + "');</script>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
