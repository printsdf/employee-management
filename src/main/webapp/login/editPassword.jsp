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
    <h1>修改默认密码</h1>
</header>

<div class="container">
    <% if (defaultPasswordWarning != null) { %>
    <p style="color: red;"><%= defaultPasswordWarning %></p>
    <% } %>
    <form id="passwordForm" action="updatePassword.jsp" method="post">
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (errorMessage != null) { %>
        <p class="error"><%= errorMessage %></p>
        <% } %>
        
        <div class="form-group">
            <label for="newPassword">新密码:</label>
            <div class="password-input-wrapper">
                <input type="password" id="newPassword" name="newPassword" required>
                <span class="toggle-password" onclick="togglePassword('newPassword')">👁️</span>
            </div>
            <div class="password-strength" id="passwordStrength">
                <div class="strength-bar" id="strengthBar"></div>
            </div>
            <div class="strength-text" id="strengthText"></div>
            <div class="error-message" id="newPasswordError"></div>
        </div>

        <div class="form-group">
            <label for="confirmPassword">确认新密码:</label>
            <div class="password-input-wrapper">
                <input type="password" id="confirmPassword" name="confirmPassword" required>
                <span class="toggle-password" onclick="togglePassword('confirmPassword')">👁️</span>
            </div>
            <div class="error-message" id="confirmPasswordError"></div>
        </div>

        <div class="button-group">
            <button type="button" id="submitBtn">提交</button>
            <a href="../index.jsp">返回首页</a>
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
                document.getElementById('passwordForm').submit();
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
        document.getElementById('passwordForm').addEventListener('submit', (e) => {
            e.preventDefault();
            debounceSubmit();
        });
    });
</script>

</body>
</html>
