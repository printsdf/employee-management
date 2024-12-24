<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 获取表单提交的数据
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String description = request.getParameter("description");

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        // 加载数据库驱动
        Class.forName("com.mysql.cj.jdbc.Driver");
        // 连接数据库
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 更新部门信息的SQL语句
        String sql = "UPDATE departments SET name = ?, description = ? WHERE id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, name);
        stmt.setString(2, description);
        stmt.setString(3, id);

        // 执行更新操作
        int rows = stmt.executeUpdate();
        if (rows > 0) {
            // 更新成功，跳转回部门列表页面
            out.println("<script>alert('部门修改成功！'); window.location='viewDepartments.jsp';</script>");
        } else {
            // 更新失败
            out.println("<script>alert('部门修改失败，请重试！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        // 出现异常时，显示错误提示
        out.println("<script>alert('发生错误，请检查输入！'); window.history.back();</script>");
    } finally {
        // 关闭数据库资源
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
