<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String name = request.getParameter("name");
    String description = request.getParameter("description");

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        String sql = "INSERT INTO departments (name, description) VALUES (?, ?)";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, name);
        stmt.setString(2, description);

        int rows = stmt.executeUpdate();
        if (rows > 0) {
            out.println("<script>alert('部门添加成功！'); window.location='viewDepartments.jsp';</script>");
        } else {
            out.println("<script>alert('部门添加失败！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('发生错误，请检查输入！'); window.history.back();</script>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
