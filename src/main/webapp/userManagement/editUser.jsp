<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Connection" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 获取当前用户的用户名
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String name = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 验证当前密码是否正确
        String query = "SELECT name FROM users WHERE username = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, username);
        rs = stmt.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
        }
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("message", "系统错误，请稍后重试！");
        request.getRequestDispatcher("updateUser.jsp").forward(request, response);
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>修改用户信息</title>
    <link rel="stylesheet" href="../style/edit.css">
    <style>
        .error {
            color: red;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .success {
            color: green;
            font-size: 14px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<header>
    <h1 style="text-align: center;">修改用户信息</h1>
</header>
<div class="container">
    <form action="updateUser.jsp" method="post">
        <!-- 消息显示区域 -->
        <% String message = (String) request.getAttribute("message"); %>
        <% if (message != null) { %>
        <p class="<%= message.startsWith("成功") ? "success" : "error" %>"><%= message %></p>
        <% } %>

        <p>
            <label for="currentUsername">当前用户名：</label>
            <input type="text" id="currentUsername" name="currentUsername" value="<%= username %>" readonly>
        </p>

        <p>
            <label for="newUsername">新用户名：</label>
            <input type="text" id="newUsername" name="newUsername">
        </p>

        <p>
            <label for="name">姓名：</label>
            <input type="text" id="name" name="name" value="<%= name%>">
        </p>

        <p>
            <label for="position">职位：</label>
            <input type="text" id="position" name="position">
        </p>

        <p>
            <label for="contact">联系方式：</label>
            <input type="text" id="contact" name="contact">
        </p>

        <p>
            <label for="currentPassword">当前密码：</label>
            <input type="password" id="currentPassword" name="currentPassword" required>
        </p>

        <p>
            <label for="newPassword">新密码：</label>
            <input type="password" id="newPassword" name="newPassword">
        </p>

        <p>
            <label for="confirmPassword">确认新密码：</label>
            <input type="password" id="confirmPassword" name="confirmPassword">
        </p>

        <p>
            <button type="submit">保存修改</button>
        </p>
    </form>
</div>
</body>
</html>
