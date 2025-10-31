<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
    ResultSet rs = null;

    String date = "";
    String formattedCheckInTime = "";
    String formattedCheckOutTime = "";
    String status = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 查询考勤记录详情
        String query = "SELECT * FROM attendance WHERE id = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, attendanceId);
        rs = stmt.executeQuery();

        if (rs.next()) {
            date = rs.getString("date");
            Timestamp checkInTimestamp = rs.getTimestamp("check_in_time");
            Timestamp checkOutTimestamp = rs.getTimestamp("check_out_time");
            status = rs.getString("status");

            // 使用SimpleDateFormat来格式化时间
            SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

            if (checkInTimestamp != null) {
                formattedCheckInTime = dateTimeFormat.format(checkInTimestamp);
            }
            if (checkOutTimestamp != null) {
                formattedCheckOutTime = dateTimeFormat.format(checkOutTimestamp);
            }
        } else {
            out.println("<p>找不到对应的考勤记录！</p>");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>数据库错误，请稍后再试！</p>");
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>修改考勤记录</title>
    <link rel="stylesheet" href="../style/edit.css">
</head>
<body>
<header>
    <h1>修改考勤记录</h1>
</header>
<div class="container">
    <form action="updateAttendance.jsp" method="post">
        <input type="hidden" name="attendanceId" value="<%= attendanceId %>">

        <p>
            <label for="date">日期：</label>
            <input type="text" id="date" name="date" value="<%= date %>" readonly>
        </p>

        <p>
            <label for="checkInTime">签到时间：</label>
            <input type="datetime-local" id="checkInTime" name="checkInTime" value="<%= formattedCheckInTime %>">
        </p>

        <p>
            <label for="checkOutTime">签退时间：</label>
            <input type="datetime-local" id="checkOutTime" name="checkOutTime" value="<%= formattedCheckOutTime %>">
        </p>

        <p>
            <label for="status">状态：</label>
            <select id="status" name="status">
                <option value="present" <%= "present".equals(status) ? "selected" : "" %>>出勤</option>
                <option value="late" <%= "late".equals(status) ? "selected" : "" %>>迟到</option>
                <option value="absent" <%= "absent".equals(status) ? "selected" : "" %>>缺勤</option>
                <option value="leave" <%= "leave".equals(status) ? "selected" : "" %>>请假</option>
            </select>
        </p>

        <p>
            <button type="submit" class="btn">保存修改</button>
            <a href="attendance.jsp" class="btn">取消</a>
        </p>
    </form>
</div>
</body>
</html>