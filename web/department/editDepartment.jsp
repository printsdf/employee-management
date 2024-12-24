<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String id = request.getParameter("id");
    String name = "";
    String description = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        String sql = "SELECT * FROM departments WHERE id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, id);
        rs = stmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            description = rs.getString("description");
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
    <title>修改部门</title>
    <link rel="stylesheet" href="../style/edit.css">
</head>
<body>
<div class="container">
    <h1>修改部门</h1>
    <form action="updateDepartmentHandler.jsp" method="post">
        <input type="hidden" name="id" value="<%= id %>">
        <p>
            <label for="name">部门名称：</label>
            <input type="text" id="name" name="name" value="<%= name %>" required>
        </p>
        <p>
            <label for="description">部门描述：</label>
            <textarea id="description" name="description" rows="4" cols="50"><%= description %></textarea>
        </p>
        <p>
            <button type="submit" class="btn">提交</button>
            <a href="viewDepartments.jsp" class="btn">返回</a>
        </p>
    </form>
</div>
</body>
</html>
