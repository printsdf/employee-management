<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 员工管理系统</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
        }
        .login-container {
            max-width: 400px;
            margin: 5rem auto;
            padding: 2rem;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .login-container h1 {
            text-align: center;
            margin-bottom: 1.5rem;
        }
        .form-group {
            margin-bottom: 1rem;
        }
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: bold;
        }
        .form-group input {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1rem;
        }
        .captcha-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .captcha-group img {
            border: 1px solid #ccc;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn {
            display: block;
            width: 100%;
            padding: 0.75rem;
            margin-top: 1rem;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 1rem;
            cursor: pointer;
        }
        .btn:hover {
            background-color: #0056b3;
        }
        .error {
            color: red;
            font-size: 0.875rem;
            margin-top: 0.5rem;
            text-align: center;
        }
        .success {
            color: green;
            font-size: 0.875rem;
            margin-top: 0.5rem;
            text-align: center;
        }
    </style>
    <script>
        function refreshCaptcha() {
            const captchaImg = document.getElementById("captchaImg");
            captchaImg.src = "captchaGenerator.jsp?" + new Date().getTime(); // 刷新验证码
        }
    </script>
</head>
<body>
<div class="login-container">
    <h1>登录</h1>

    <!-- 消息显示 -->
    <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
    <% String successMessage = request.getParameter("message"); %>
    <% if (errorMessage != null) { %>
    <div class="error"><%= errorMessage %></div>
    <% } else if (successMessage != null) { %>
    <div class="success"><%= java.net.URLDecoder.decode(successMessage, "UTF-8") %></div>
    <% } %>

    <form action="loginHandler.jsp" method="post">
        <div class="form-group">
            <label for="username">用户名：</label>
            <input type="text" id="username" name="username" required value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>">
        </div>
        <div class="form-group">
            <label for="password">密码：</label>
            <input type="password" id="password" name="password" required>
        </div>
        <div class="form-group">
            <label for="captcha">验证码：</label>
            <div class="captcha-group">
                <input type="text" id="captcha" name="captcha" required placeholder="请输入验证码">
                <img src="captchaGenerator.jsp" id="captchaImg" alt="验证码" onclick="refreshCaptcha()" title="点击刷新验证码">
            </div>
        </div>
        <button type="submit" class="btn">登录</button>
    </form>
</div>
</body>
</html>
