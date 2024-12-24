<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String employeeId = request.getParameter("employeeId");
    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        String sql = "DELETE FROM users WHERE employee_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, employeeId);

        int rows = stmt.executeUpdate();
        if (rows > 0) {
            out.println("<script>alert('删除成功！'); window.location='viewEmployees.jsp';</script>");
        } else {
            out.println("<script>alert('删除失败！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('操作失败：" + e.getMessage() + "');</script>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
