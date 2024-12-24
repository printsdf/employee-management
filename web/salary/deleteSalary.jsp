<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证管理员权限
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取 employeeId 参数
    String employeeId = request.getParameter("employeeId");

    if (employeeId == null || employeeId.trim().isEmpty()) {
        out.println("<script>alert('无效的工号！'); window.history.back();</script>");
        return;
    }

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 删除工资记录
        String query = "DELETE FROM salary WHERE employee_id = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, employeeId);

        int rowsDeleted = stmt.executeUpdate();
        if (rowsDeleted > 0) {
            out.println("<script>alert('工资记录删除成功！'); window.location='viewSalaries.jsp';</script>");
        } else {
            out.println("<script>alert('删除失败，请重试！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('系统错误，请稍后再试！'); window.history.back();</script>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
