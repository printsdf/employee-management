<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.regex.*" %}
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (!newPassword.equals(confirmPassword)) {
        request.setAttribute("errorMessage", "两次输入的密码不一致！");
        request.getRequestDispatcher("editPassword.jsp").forward(request, response);
        return;
    }
    
    // 验证密码强度
    int strength = checkPasswordStrength(newPassword);
    if (strength <= 1) {
        request.setAttribute("errorMessage", "密码强度太弱，请使用更强的密码！");
        request.getRequestDispatcher("editPassword.jsp").forward(request, response);
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");
        String sql = "UPDATE users SET password = ? WHERE username = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, newPassword);
        ps.setString(2, username);
        int rowsUpdated = ps.executeUpdate();

        if (rowsUpdated > 0) {
            session.removeAttribute("defaultPasswordWarning"); // 移除默认密码提示
            String encodedMessage = java.net.URLEncoder.encode("密码修改成功，请重新登录！", StandardCharsets.UTF_8);
            response.sendRedirect("login.jsp?message=" + encodedMessage);

        } else {
            request.setAttribute("errorMessage", "修改密码失败，请稍后重试！");
            request.getRequestDispatcher("editPassword.jsp").forward(request, response);
        }
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("errorMessage", "系统异常，请稍后重试！");
        request.getRequestDispatcher("editPassword.jsp").forward(request, response);
    } finally {
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }

// 密码强度检测函数
<%!
    public int checkPasswordStrength(String password) {
        if (password == null || password.isEmpty()) {
            return 0;
        }
        
        int strength = 0;
        
        // 长度检测
        if (password.length() >= 8) strength++;
        if (password.length() >= 12) strength++;
        
        // 字符类型检测
        if (Pattern.compile("[a-z]").matcher(password).find()) strength++;
        if (Pattern.compile("[A-Z]").matcher(password).find()) strength++;
        if (Pattern.compile("[0-9]").matcher(password).find()) strength++;
        if (Pattern.compile("[^a-zA-Z0-9]").matcher(password).find()) strength++;
        
        // 复杂度检测
        if (Pattern.compile("[a-z]").matcher(password).find() && 
            Pattern.compile("[A-Z]").matcher(password).find()) strength++;
        if (Pattern.compile("[a-zA-Z]").matcher(password).find() && 
            Pattern.compile("[0-9]").matcher(password).find()) strength++;
        if (Pattern.compile("[a-zA-Z0-9]").matcher(password).find() && 
            Pattern.compile("[^a-zA-Z0-9]").matcher(password).find()) strength++;
        
        // 重复字符检测
        if (!Pattern.compile("(.)\\1{2,}").matcher(password).find()) strength++;
        
        // 连续字符检测
        if (!Pattern.compile("abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz", Pattern.CASE_INSENSITIVE).matcher(password).find()) strength++;
        if (!Pattern.compile("012|123|234|345|456|567|678|789|987|876|765|654|543|432|321|210").matcher(password).find()) strength++;
        
        return strength;
    }
%>
