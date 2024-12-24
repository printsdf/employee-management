<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // 获取当前用户的用户名
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取表单数据
    String newUsername = request.getParameter("newUsername");
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");
    String name = request.getParameter("name");
    String position = request.getParameter("position");
    String contact = request.getParameter("contact");

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 验证当前密码是否正确
        String query = "SELECT * FROM users WHERE username = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, username);
        rs = stmt.executeQuery();

        if (rs.next()) {
            String dbPassword = rs.getString("password");
            if (!dbPassword.equals(currentPassword)) {
                request.setAttribute("message", "当前密码不正确！");
                request.getRequestDispatcher("updateUser.jsp").forward(request, response);
                return;
            }
        } else {
            request.setAttribute("message", "用户不存在！");
            request.getRequestDispatcher("updateUser.jsp").forward(request, response);
            return;
        }

        // 验证新密码是否一致
        if (newPassword != null && !newPassword.isEmpty() && !newPassword.equals(confirmPassword)) {
            request.setAttribute("message", "新密码和确认密码不一致！");
            request.getRequestDispatcher("updateUser.jsp").forward(request, response);
            return;
        }

        // 更新用户信息
        String updateQuery = "UPDATE users SET username = COALESCE(?, username), " +
                "password = COALESCE(?, password), name = COALESCE(?, name), " +
                "position = COALESCE(?, position), contact = COALESCE(?, contact) " +
                "WHERE username = ?";
        stmt = conn.prepareStatement(updateQuery);

        stmt.setString(1, (newUsername != null && !newUsername.isEmpty()) ? newUsername : null); // 更新用户名
        stmt.setString(2, (newPassword != null && !newPassword.isEmpty()) ? newPassword : null); // 更新密码
        stmt.setString(3, (name != null && !name.isEmpty()) ? name : null); // 更新姓名
        stmt.setString(4, (position != null && !position.isEmpty()) ? position : null); // 更新职位
        stmt.setString(5, (contact != null && !contact.isEmpty()) ? contact : null); // 更新联系方式
        stmt.setString(6, username); // 条件：原用户名

        int rowsUpdated = stmt.executeUpdate();
        if (rowsUpdated > 0) {
            session.setAttribute("username", (newUsername != null && !newUsername.isEmpty()) ? newUsername : username); // 更新 session 用户名
            request.setAttribute("message", "用户信息修改成功！");
            request.getRequestDispatcher("updateUser.jsp").forward(request, response);
        } else {
            request.setAttribute("message", "修改失败，请重试！");
            request.getRequestDispatcher("updateUser.jsp").forward(request, response);
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
