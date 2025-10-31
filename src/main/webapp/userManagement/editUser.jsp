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
        .password-strength {
            height: 4px;
            margin-top: 4px;
            border-radius: 2px;
            background-color: #ddd;
            display: none;
        }
        .strength-bar {
            height: 100%;
            border-radius: 2px;
            transition: width 0.3s ease;
        }
        .strength-weak {
            width: 25%;
            background-color: #ff4444;
        }
        .strength-fair {
            width: 50%;
            background-color: #ffbb33;
        }
        .strength-good {
            width: 75%;
            background-color: #44b700;
        }
        .strength-strong {
            width: 100%;
            background-color: #00c851;
        }
        .strength-text {
            font-size: 12px;
            margin-top: 4px;
            color: #666;
            display: none;
        }
        .password-input-wrapper {
            position: relative;
        }
        .toggle-password {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #666;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: inline-block;
            width: 120px;
            text-align: right;
            margin-right: 10px;
            vertical-align: top;
        }
        .form-group input {
            padding: 5px;
            width: 200px;
        }
        .form-group .error-message {
            color: red;
            font-size: 12px;
            margin-left: 130px;
            margin-top: 5px;
            display: none;
        }
        .button-group {
            margin-left: 130px;
            margin-top: 20px;
        }
        .button-group button {
            margin-right: 10px;
            padding: 8px 15px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .button-group button:hover {
            background-color: #0056b3;
        }
        .button-group a {
            padding: 8px 15px;
            background-color: #6c757d;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .button-group a:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>
<header>
    <h1 style="text-align: center;">修改用户信息</h1>
</header>
<div class="container">
    <form id="userForm" action="updateUser.jsp" method="post">
        <!-- 消息显示区域 -->
        <% String message = (String) request.getAttribute("message"); %>
        <% if (message != null) { %>
        <p class="<%= message.startsWith("成功") ? "success" : "error" %>"><%= message %></p>
        <% } %>

        <div class="form-group">
            <label for="currentUsername">当前用户名：</label>
            <input type="text" id="currentUsername" name="currentUsername" value="<%= username %>" readonly>
        </div>

        <div class="form-group">
            <label for="newUsername">新用户名：</label>
            <input type="text" id="newUsername" name="newUsername">
            <div class="error-message" id="newUsernameError"></div>
        </div>

        <div class="form-group">
            <label for="name">姓名：</label>
            <input type="text" id="name" name="name" value="<%= name%>">
            <div class="error-message" id="nameError"></div>
        </div>

        <div class="form-group">
            <label for="position">职位：</label>
            <input type="text" id="position" name="position">
            <div class="error-message" id="positionError"></div>
        </div>

        <div class="form-group">
            <label for="contact">联系方式：</label>
            <input type="text" id="contact" name="contact">
            <div class="error-message" id="contactError"></div>
        </div>

        <div class="form-group">
            <label for="currentPassword">当前密码：</label>
            <div class="password-input-wrapper">
                <input type="password" id="currentPassword" name="currentPassword" required>
                <span class="toggle-password" onclick="togglePassword('currentPassword')">👁️</span>
            </div>
            <div class="error-message" id="currentPasswordError"></div>
        </div>

        <div class="form-group">
            <label for="newPassword">新密码：</label>
            <div class="password-input-wrapper">
                <input type="password" id="newPassword" name="newPassword">
                <span class="toggle-password" onclick="togglePassword('newPassword')">👁️</span>
            </div>
            <div class="password-strength" id="passwordStrength">
                <div class="strength-bar" id="strengthBar"></div>
            </div>
            <div class="strength-text" id="strengthText"></div>
            <div class="error-message" id="newPasswordError"></div>
        </div>

        <div class="form-group">
            <label for="confirmPassword">确认新密码：</label>
            <div class="password-input-wrapper">
                <input type="password" id="confirmPassword" name="confirmPassword">
                <span class="toggle-password" onclick="togglePassword('confirmPassword')">👁️</span>
            </div>
            <div class="error-message" id="confirmPasswordError"></div>
        </div>

        <div class="button-group">
            <button type="button" id="submitBtn">保存修改</button>
            <a href="myUser.jsp">返回</a>
        </div>
    </form>
</div>

<script>
    // 密码强度检测
    function checkPasswordStrength(password) {
        if (!password) {
            return { strength: 0, text: '' };
        }
        
        let strength = 0;
        
        // 长度检测
        if (password.length >= 8) strength++;
        if (password.length >= 12) strength++;
        
        // 字符类型检测
        if (/[a-z]/.test(password)) strength++;
        if (/[A-Z]/.test(password)) strength++;
        if (/[0-9]/.test(password)) strength++;
        if (/[^a-zA-Z0-9]/.test(password)) strength++;
        
        // 复杂度检测
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
        if (/[a-zA-Z]/.test(password) && /[0-9]/.test(password)) strength++;
        if (/[a-zA-Z0-9]/.test(password) && /[^a-zA-Z0-9]/.test(password)) strength++;
        
        // 重复字符检测
        if (!/(.)\1{2,}/.test(password)) strength++;
        
        // 连续字符检测
        if (!/abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz/i.test(password)) strength++;
        if (!/012|123|234|345|456|567|678|789|987|876|765|654|543|432|321|210/.test(password)) strength++;
        
        // 强度等级
        if (strength <= 3) {
            return { strength: 1, text: '弱' };
        } else if (strength <= 6) {
            return { strength: 2, text: '一般' };
        } else if (strength <= 9) {
            return { strength: 3, text: '强' };
        } else {
            return { strength: 4, text: '很强' };
        }
    }
    
    // 显示密码强度
    function showPasswordStrength(password) {
        const strength = checkPasswordStrength(password);
        const strengthBar = document.getElementById('strengthBar');
        const strengthText = document.getElementById('strengthText');
        const passwordStrength = document.getElementById('passwordStrength');
        
        if (password) {
            passwordStrength.style.display = 'block';
            strengthText.style.display = 'block';
            
            // 更新强度条
            strengthBar.className = 'strength-bar';
            switch (strength.strength) {
                case 1:
                    strengthBar.classList.add('strength-weak');
                    strengthText.textContent = '密码强度：弱';
                    strengthText.style.color = '#ff4444';
                    break;
                case 2:
                    strengthBar.classList.add('strength-fair');
                    strengthText.textContent = '密码强度：一般';
                    strengthText.style.color = '#ffbb33';
                    break;
                case 3:
                    strengthBar.classList.add('strength-good');
                    strengthText.textContent = '密码强度：强';
                    strengthText.style.color = '#44b700';
                    break;
                case 4:
                    strengthBar.classList.add('strength-strong');
                    strengthText.textContent = '密码强度：很强';
                    strengthText.style.color = '#00c851';
                    break;
            }
        } else {
            passwordStrength.style.display = 'none';
            strengthText.style.display = 'none';
        }
    }
    
    // 明文/密文切换
    function togglePassword(inputId) {
        const input = document.getElementById(inputId);
        if (input.type === 'password') {
            input.type = 'text';
        } else {
            input.type = 'password';
        }
    }
    
    // 表单验证
    function validateForm() {
        let isValid = true;
        const errorMessages = document.querySelectorAll('.error-message');
        errorMessages.forEach(msg => msg.style.display = 'none');
        
        // 验证当前密码
        const currentPassword = document.getElementById('currentPassword').value;
        if (!currentPassword) {
            document.getElementById('currentPasswordError').textContent = '当前密码不能为空';
            document.getElementById('currentPasswordError').style.display = 'block';
            isValid = false;
        }
        
        // 验证新密码
        const newPassword = document.getElementById('newPassword').value;
        if (newPassword) {
            const strength = checkPasswordStrength(newPassword);
            if (strength.strength <= 1) {
                document.getElementById('newPasswordError').textContent = '密码强度太弱，请使用更强的密码';
                document.getElementById('newPasswordError').style.display = 'block';
                isValid = false;
            }
            
            // 验证确认密码
            const confirmPassword = document.getElementById('confirmPassword').value;
            if (newPassword !== confirmPassword) {
                document.getElementById('confirmPasswordError').textContent = '两次输入的密码不一致';
                document.getElementById('confirmPasswordError').style.display = 'block';
                isValid = false;
            }
        }
        
        return isValid;
    }
    
    // 提交防抖
    let debounceTimer;
    function debounceSubmit() {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            if (validateForm()) {
                document.getElementById('userForm').submit();
            }
        }, 500);
    }
    
    // 事件监听
    document.addEventListener('DOMContentLoaded', () => {
        // 密码强度实时检测
        document.getElementById('newPassword').addEventListener('input', (e) => {
            showPasswordStrength(e.target.value);
        });
        
        // 提交按钮点击事件
        document.getElementById('submitBtn').addEventListener('click', debounceSubmit);
        
        // 表单提交事件
        document.getElementById('userForm').addEventListener('submit', (e) => {
            e.preventDefault();
            debounceSubmit();
        });
    });
</script>
</body>
</html>
