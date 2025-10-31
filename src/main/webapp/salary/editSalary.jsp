<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 验证管理员权限
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取 employeeId 和 salaryMonth 参数
    String employeeId = request.getParameter("employeeId");
    String salaryMonth = request.getParameter("salaryMonth");
    if (employeeId == null || employeeId.trim().isEmpty() || salaryMonth == null || salaryMonth.trim().isEmpty()) {
        out.println("<p>无效的参数！</p>");
        return;
    }

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    // 工资信息变量
    String salaryMonth = "";
    double baseSalary = 0.0;
    double attendanceBonus = 0.0;
    double totalSalary = 0.0;
    double deductions = 0.0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 查询工资信息
        String query = "SELECT month, base_salary, attendance_bonus, total_salary, deductions FROM salary WHERE employee_id = ? AND month = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, employeeId);
        stmt.setString(2, salaryMonth);
        rs = stmt.executeQuery();

        if (rs.next()) {
            salaryMonth = rs.getString("month");
            baseSalary = rs.getDouble("base_salary");
            attendanceBonus = rs.getDouble("attendance_bonus");
            totalSalary = rs.getDouble("total_salary");
            deductions = rs.getDouble("deductions");
        } else {
            out.println("<p>找不到对应的工资记录！</p>");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>修改工资信息</title>
    <link rel="stylesheet" href="../style/edit.css">
    <script>
        function calculateTotalSalary() {
            // 获取输入的基础工资、奖金和扣款值
            let baseSalary = parseFloat(document.getElementById("baseSalary").value) || 0;
            let attendanceBonus = parseFloat(document.getElementById("attendanceBonus").value) || 0;
            let deductions = parseFloat(document.getElementById("deductions").value) || 0;

            // 计算总工资
            let totalSalary = baseSalary + attendanceBonus - deductions;

            // 将总工资显示在输入框中
            document.getElementById("totalSalary").value = totalSalary.toFixed(2);
        }
    </script>
</head>
<body>
<header>
    <h1>修改工资信息</h1>
</header>
<div class="container">
    <form action="updateSalary.jsp" method="post">
        <input type="hidden" name="employeeId" value="<%= employeeId %>">

        <p>
            <label for="salaryMonth">工资月份：</label>
            <input type="text" id="salaryMonth" name="salaryMonth" value="<%= salaryMonth %>" readonly>
        </p>

        <p>
            <label for="baseSalary">基础工资：</label>
            <input type="number" id="baseSalary" name="baseSalary" value="<%= baseSalary %>" step="0.01" oninput="calculateTotalSalary()">
        </p>

        <p>
            <label for="attendanceBonus">考勤奖金：</label>
            <input type="number" id="attendanceBonus" name="attendanceBonus" value="<%= attendanceBonus %>" step="0.01" oninput="calculateTotalSalary()">
        </p>

        <p>
            <label for="deductions">扣款：</label>
            <input type="number" id="deductions" name="deductions" value="<%= deductions %>" step="0.01" oninput="calculateTotalSalary()">
        </p>

        <p>
            <label for="totalSalary">总工资：</label>
            <input type="number" id="totalSalary" name="totalSalary" value="<%= totalSalary %>" step="0.01" readonly>
        </p>

        <p>
            <button type="submit" class="btn">保存修改</button>
            <a href="viewSalaries.jsp" class="btn">取消</a>
        </p>
    </form>
</div>
</body>
</html>
