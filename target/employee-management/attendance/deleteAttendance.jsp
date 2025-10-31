<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String attendanceId = request.getParameter("attendanceId");
    if (attendanceId == null || attendanceId.trim().isEmpty()) {
        out.println("<p>无效的考勤记录 ID！</p>");
        return;
    }

    // 数据库连接
    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 删除考勤记录
        String query = "DELETE FROM attendance WHERE id = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, attendanceId);
        int rowsAffected = stmt.executeUpdate();

        if (rowsAffected > 0) {
            out.println("<script>alert('删除成功！'); window.location='viewAttendance.jsp';</script>");
        } else {
            out.println("<script>alert('删除失败，未找到对应的考勤记录！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>数据库错误，请稍后再试！</p>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
