<%@ page import="java.sql.*" %>
<%@ page import="java.text.ParseException" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String employeeId = request.getParameter("employeeId");
    String attendanceDate = request.getParameter("attendanceDate");

    // Get current datetime
    java.util.Date now = new java.util.Date();
    java.text.SimpleDateFormat dateTimeFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("HH:mm:ss");
    String checkInDateTime = dateTimeFormat.format(now);

    // 定义迟到时间（8:00 AM）
    java.util.Calendar calendar = java.util.Calendar.getInstance();
    calendar.setTime(now);
    calendar.set(java.util.Calendar.HOUR_OF_DAY, 8);
    calendar.set(java.util.Calendar.MINUTE, 0);
    calendar.set(java.util.Calendar.SECOND, 0);
    java.util.Date lateTime = calendar.getTime();

    String status = "present"; // 默认状态为正常
    if (now.after(lateTime)) {
        status = "late"; // 如果签到时间晚于 8:00，则为迟到
    }

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 检查是否已经签到
        String checkQuery = "SELECT check_in_time FROM attendance WHERE employee_id = ? AND date = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
        checkStmt.setString(1, employeeId);
        checkStmt.setString(2, attendanceDate);
        ResultSet rs = checkStmt.executeQuery();

        if (rs.next()) {
            out.println("<script>alert('今天已经签到过了！'); window.location='attendanceClock.jsp';</script>");
            return;
        }

        // 插入签到记录
        String query = "INSERT INTO attendance (employee_id, date, check_in_time, status) VALUES (?, ?, ?, ?)";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, employeeId);
        stmt.setString(2, attendanceDate);
        stmt.setString(3, checkInDateTime);  // 使用完整的日期时间格式
        stmt.setString(4, status);
        stmt.executeUpdate();

        response.sendRedirect("attendanceClock.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>签到失败，请稍后再试。错误信息：" + e.getMessage() + "</p>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>