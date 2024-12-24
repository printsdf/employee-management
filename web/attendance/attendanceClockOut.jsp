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
    String checkOutDateTime = dateTimeFormat.format(now);

    // 定义早退时间（17:00）
    java.util.Calendar calendar = java.util.Calendar.getInstance();
    calendar.setTime(now);
    calendar.set(java.util.Calendar.HOUR_OF_DAY, 17);
    calendar.set(java.util.Calendar.MINUTE, 0);
    calendar.set(java.util.Calendar.SECOND, 0);
    java.util.Date earlyLeaveTime = calendar.getTime();

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 检查签到记录是否存在
        String checkQuery = "SELECT check_in_time, status FROM attendance WHERE employee_id = ? AND date = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
        checkStmt.setString(1, employeeId);
        checkStmt.setString(2, attendanceDate);
        ResultSet rs = checkStmt.executeQuery();

        if (!rs.next()) {
            out.println("<script>alert('您还没有签到，无法签退！'); window.location='attendanceClock.jsp';</script>");
            return;
        }

        // 检查是否已经签退
        String checkOutQuery = "SELECT check_out_time FROM attendance WHERE employee_id = ? AND date = ?";
        PreparedStatement checkOutStmt = conn.prepareStatement(checkOutQuery);
        checkOutStmt.setString(1, employeeId);
        checkOutStmt.setString(2, attendanceDate);
        ResultSet outRs = checkOutStmt.executeQuery();

        if (outRs.next() && outRs.getString("check_out_time") != null) {
            out.println("<script>alert('今天已经签退过了！'); window.location='attendanceClock.jsp';</script>");
            return;
        }

        // 获取当前状态
        String currentStatus = rs.getString("status");

        // 如果已经是迟到状态，保持迟到状态
        // 如果是正常状态，检查是否早退
        if (!"late".equals(currentStatus) && now.before(earlyLeaveTime)) {
            currentStatus = "absent";
        }

        // 更新签退记录和状态
        String query = "UPDATE attendance SET check_out_time = ?, status = ? WHERE employee_id = ? AND date = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, checkOutDateTime);  // 使用完整的日期时间格式
        stmt.setString(2, currentStatus);
        stmt.setString(3, employeeId);
        stmt.setString(4, attendanceDate);
        stmt.executeUpdate();

        response.sendRedirect("attendanceClock.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>签退失败，请稍后再试。错误信息：" + e.getMessage() + "</p>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>