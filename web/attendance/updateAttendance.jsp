<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 获取表单参数
    String date = request.getParameter("date");
    String attendanceId = request.getParameter("attendanceId");
    String status = request.getParameter("status");
    String checkInTime = request.getParameter("checkInTime");
    String checkOutTime = request.getParameter("checkOutTime");

    // 截取时间部分（HH:MM）
    if (checkInTime != null && checkInTime.contains("T")) {
        checkInTime = checkInTime.split("T")[1];
    }
    if (checkOutTime != null && checkOutTime.contains("T")) {
        checkOutTime = checkOutTime.split("T")[1];
    }

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

        // 更新考勤记录
        String updateQuery = "UPDATE attendance SET check_in_time = ?, check_out_time = ?, status = ? WHERE id = ? AND date = ?";
        stmt = conn.prepareStatement(updateQuery);

        // 设置 check_in_time
        if (checkInTime == null || checkInTime.trim().isEmpty() || checkInTime.equalsIgnoreCase("null")) {
            stmt.setNull(1, Types.TIMESTAMP);
        } else {
            stmt.setString(1, checkInTime);
        }

        // 设置 check_out_time
        if (checkOutTime == null || checkOutTime.trim().isEmpty() || checkOutTime.equalsIgnoreCase("null")) {
            stmt.setNull(2, Types.TIMESTAMP);
        } else {
            stmt.setString(2, checkOutTime);
        }

        // 设置其他参数
        stmt.setString(3, status);
        stmt.setString(4, attendanceId);
        stmt.setString(5, date);

        int rows = stmt.executeUpdate();

        if (rows > 0) {
            out.println("<script>alert('考勤记录更新成功！'); window.location='viewAttendance.jsp';</script>");
        } else {
            out.println("<script>alert('更新失败，未找到对应的考勤记录！'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('操作失败：" + e.getMessage() + "');</script>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
