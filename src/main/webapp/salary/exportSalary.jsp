<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.io.*" %>
<%@ page contentType="text/csv; charset=UTF-8" language="java" %>
<%
    // 验证是否登录及权限
    String role = (String) session.getAttribute("role");
    if (role == null || (!"admin".equals(role) && !"manager".equals(role) && !"employee".equals(role))) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 获取当前登录用户的员工ID
    String currentEmployeeId = null;
    if ("employee".equals(role)) {
        currentEmployeeId = (String) session.getAttribute("employeeId");
    }

    // 获取筛选参数
    String filterName = request.getParameter("filterName");
    String filterEmployeeId = request.getParameter("filterEmployeeId");
    String filterMonth = request.getParameter("filterMonth");
    String exportType = request.getParameter("export");
    
    // 获取排序参数
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    StringBuilder sql = new StringBuilder(
            "SELECT s.id AS salary_id, u.employee_id, u.name AS employee_name, u.role AS employee_role, s.month, " +
                    "s.base_salary, s.attendance_bonus, s.total_salary, s.deductions " +
                    "FROM salary s " +
                    "JOIN users u ON s.employee_id = u.employee_id " +
                    "WHERE 1=1 "
    );

    if (filterName != null && !filterName.trim().isEmpty()) {
        sql.append("AND u.name LIKE ? ");
    }
    if (filterEmployeeId != null && !filterEmployeeId.trim().isEmpty()) {
        sql.append("AND u.employee_id LIKE ? ");
    }
    if (filterMonth != null && !filterMonth.trim().isEmpty()) {
        sql.append("AND s.month = ? ");
    }
    
    // 普通员工只能查看自己的工资
    if ("employee".equals(role) && currentEmployeeId != null) {
        sql.append("AND u.employee_id = ? ");
    }

    // 排序
    String orderBy = "s.month DESC";
    if (sortBy != null && !sortBy.isEmpty()) {
        orderBy = sortBy;
        if (sortOrder != null && !sortOrder.isEmpty()) {
            orderBy += " " + sortOrder;
        }
    }
    sql.append("ORDER BY " + orderBy);
    
    // 如果是导出当前页，添加分页
    if ("current".equals(exportType)) {
        // 获取分页参数
        int pageSize = 10;
        String pageSizeStr = request.getParameter("pageSize");
        if (pageSizeStr != null && !pageSizeStr.isEmpty()) {
            pageSize = Integer.parseInt(pageSizeStr);
        }
        
        int currentPage = 1;
        String currentPageStr = request.getParameter("currentPage");
        if (currentPageStr != null && !currentPageStr.isEmpty()) {
            currentPage = Integer.parseInt(currentPageStr);
        }
        
        int startIndex = (currentPage - 1) * pageSize;
        sql.append(" LIMIT ? OFFSET ?");
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        stmt = conn.prepareStatement(sql.toString());

        int index = 1;
        if (filterName != null && !filterName.trim().isEmpty()) {
            stmt.setString(index++, "%" + filterName + "%");
        }
        if (filterEmployeeId != null && !filterEmployeeId.trim().isEmpty()) {
            stmt.setString(index++, "%" + filterEmployeeId + "%");
        }
        if (filterMonth != null && !filterMonth.trim().isEmpty()) {
            stmt.setString(index++, filterMonth);
        }
        if ("employee".equals(role) && currentEmployeeId != null) {
            stmt.setString(index++, currentEmployeeId);
        }
        
        // 如果是导出当前页，添加分页参数
        if ("current".equals(exportType)) {
            int pageSize = 10;
            String pageSizeStr = request.getParameter("pageSize");
            if (pageSizeStr != null && !pageSizeStr.isEmpty()) {
                pageSize = Integer.parseInt(pageSizeStr);
            }
            
            int currentPage = 1;
            String currentPageStr = request.getParameter("currentPage");
            if (currentPageStr != null && !currentPageStr.isEmpty()) {
                currentPage = Integer.parseInt(currentPageStr);
            }
            
            stmt.setInt(index++, pageSize);
            stmt.setInt(index++, (currentPage - 1) * pageSize);
        }

        rs = stmt.executeQuery();
        
        // 设置响应头
        String filename = "salary_records_" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".csv";
        response.setHeader("Content-Disposition", "attachment; filename=" + filename);
        
        // 获取输出流
        PrintWriter out = response.getWriter();
        
        // 设置CSV编码
        out.write(new String(new byte[] { (byte) 0xEF, (byte) 0xBB, (byte) 0xBF }));
        
        // 写入CSV表头
        out.println("工号,姓名,工资月份,基础工资,考勤奖金,总工资,扣款");
        
        // 写入CSV数据
        while (rs.next()) {
            String employeeId = rs.getString("employee_id");
            String employeeName = rs.getString("employee_name");
            String salaryMonth = rs.getString("month");
            double baseSalary = rs.getDouble("base_salary");
            double attendanceBonus = rs.getDouble("attendance_bonus");
            double totalSalary = rs.getDouble("total_salary");
            double deductions = rs.getDouble("deductions");
            
            // 写入一行数据
            out.print(employeeId + ",");
            out.print(employeeName + ",");
            out.print(salaryMonth + ",");
            out.print(baseSalary + ",");
            out.print(attendanceBonus + ",");
            out.print(totalSalary + ",");
            out.println(deductions);
        }
        
        out.flush();
        out.close();
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>