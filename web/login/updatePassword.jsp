<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
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
%>
