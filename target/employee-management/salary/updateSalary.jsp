<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证管理员权限
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取表单参数
    String employeeId = request.getParameter("employeeId");
    String salaryMonth = request.getParameter("salaryMonth");
    double baseSalary = Double.parseDouble(request.getParameter("baseSalary"));
    double attendanceBonus = Double.parseDouble(request.getParameter("attendanceBonus"));
    double deductions = Double.parseDouble(request.getParameter("deductions"));
    double totalSalary = baseSalary + attendanceBonus - deductions;

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 更新工资信息
        String query = "UPDATE salary SET base_salary = ?, attendance_bonus = ?, deductions = ?, total_salary = ? WHERE employee_id = ? AND month = ?";
        stmt = conn.prepareStatement(query);
        stmt.setDouble(1, baseSalary);
        stmt.setDouble(2, attendanceBonus);
        stmt.setDouble(3, deductions);
        stmt.setDouble(4, totalSalary);
        stmt.setString(5, employeeId);
        stmt.setString(6, salaryMonth);

        int rowsUpdated = stmt.executeUpdate();
        if (rowsUpdated > 0) {
            out.println("<script>alert('工资信息修改成功！'); window.location='viewSalaries.jsp';</script>");
        } else {
            out.println("<script>alert('修改失败，请重试！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('系统错误，请稍后再试！'); window.history.back();</script>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
