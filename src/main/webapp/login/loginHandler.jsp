<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
  String username = request.getParameter("username");
  String password = request.getParameter("password");
  String inputCaptcha = request.getParameter("captcha");
  String sessionCaptcha = (String) session.getAttribute("captcha");

  final String DEFAULT_PASSWORD = "password123";

  if (!inputCaptcha.equalsIgnoreCase(sessionCaptcha)) {
    request.setAttribute("errorMessage", "验证码错误！");
    request.setAttribute("username", username); // 保留用户名
    request.getRequestDispatcher("login.jsp").forward(request, response);
    return;
  }

  // 验证用户名和密码（假设你有一个连接数据库的工具类 DBUtils）
  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");
    String sql = "SELECT role FROM users WHERE username = ? AND password = ?";
    ps = conn.prepareStatement(sql);
    ps.setString(1, username);
    ps.setString(2, password);
    rs = ps.executeQuery();

    if (rs.next()) {
      String role = rs.getString("role");
      session.setAttribute("username", username);
      session.setAttribute("role", role);

      // 检查是否为默认密码
      if (DEFAULT_PASSWORD.equals(password)) {
        session.setAttribute("defaultPasswordWarning", "请尽快修改默认密码！");
        response.sendRedirect("editPassword.jsp");
        return;
      }

      if ("admin".equals(role)) {
        response.sendRedirect("../Dashboard/adminDashboard.jsp");
      } else {
        response.sendRedirect("../Dashboard/userDashboard.jsp");
      }
    } else {
      request.setAttribute("errorMessage", "用户名或密码错误！");
      request.setAttribute("username", username); // 保留用户名
      request.getRequestDispatcher("login.jsp").forward(request, response);
    }
  } catch (Exception e) {
    e.printStackTrace();
    request.setAttribute("errorMessage", "系统异常，请稍后重试！");
    request.getRequestDispatcher("login.jsp").forward(request, response);
  } finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
    if (conn != null) conn.close();
  }
%>
