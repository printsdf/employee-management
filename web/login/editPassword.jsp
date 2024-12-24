<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
    String defaultPasswordWarning = (String) session.getAttribute("defaultPasswordWarning");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>修改密码</title>
    <link rel="stylesheet" href="../style/edit.css">
</head>
<body>
<header>
    <h1>修改默认密码</h1>
</header>

<div class="container">
    <% if (defaultPasswordWarning != null) { %>
    <p style="color: red;"><%= defaultPasswordWarning %></p>
    <% } %>
    <form action="updatePassword.jsp" method="post">
        <p>
            <label for="newPassword">新密码:</label>
            <input type="password" id="newPassword" name="newPassword" required>
        </p>
        <p>
            <label for="confirmPassword">确认新密码:</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required>
        </p>
        <p>
            <button type="submit">提交</button>
        </p>
    </form>
</div>

</body>
</html>
