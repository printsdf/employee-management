<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
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
    
    // 获取排序参数
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    
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

    // 数据库连接变量
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    ResultSet countRs = null;
    
    // 统计数据
    double totalBaseSalary = 0;
    double totalAttendanceBonus = 0;
    double totalTotalSalary = 0;
    double totalDeductions = 0;
    int totalRecords = 0;

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
    
    // 分页
    sql.append(" LIMIT ? OFFSET ?");
    
    // 统计总记录数
    StringBuilder countSql = new StringBuilder(
            "SELECT COUNT(*) AS total FROM salary s " +
                    "JOIN users u ON s.employee_id = u.employee_id " +
                    "WHERE 1=1 "
    );
    
    if (filterName != null && !filterName.trim().isEmpty()) {
        countSql.append("AND u.name LIKE ? ");
    }
    if (filterEmployeeId != null && !filterEmployeeId.trim().isEmpty()) {
        countSql.append("AND u.employee_id LIKE ? ");
    }
    if (filterMonth != null && !filterMonth.trim().isEmpty()) {
        countSql.append("AND s.month = ? ");
    }
    
    // 普通员工只能查看自己的工资
    if ("employee".equals(role) && currentEmployeeId != null) {
        countSql.append("AND u.employee_id = ? ");
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

        // 获取总记录数
        stmt = conn.prepareStatement(countSql.toString());
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
        countRs = stmt.executeQuery();
        if (countRs.next()) {
            totalRecords = countRs.getInt("total");
        }
        countRs.close();
        stmt.close();

        // 获取数据
        stmt = conn.prepareStatement(sql.toString());
        index = 1;
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
        stmt.setInt(index++, pageSize);
        stmt.setInt(index++, startIndex);

        rs = stmt.executeQuery();
        
        // 计算合计
        while (rs.next()) {
            totalBaseSalary += rs.getDouble("base_salary");
            totalAttendanceBonus += rs.getDouble("attendance_bonus");
            totalTotalSalary += rs.getDouble("total_salary");
            totalDeductions += rs.getDouble("deductions");
        }
        rs.beforeFirst();
    } catch (Exception e) {
        e.printStackTrace();
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

        rs = stmt.executeQuery();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>查看所有工资信息</title>
    <link rel="stylesheet" href="../style/styles.css">
    <style>
        form {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        form label {
            font-weight: bold;
            margin-right: 10px;
            color: #333;
            display: inline-block;
            width: 100px;
            margin-bottom: 10px;
        }

        form input, form select {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 200px;
            margin-bottom: 10px;
        }

        form button {
            background-color: #0056b3;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        form button:hover {
            background-color: #004494;
        }

        td .btn {
            display: inline-block;
            background-color: #d9534f;
            color: white;
            padding: 8px 12px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            transition: background-color 0.3s;
            margin: 2px;
        }

        td .btn:hover {
            background-color: #c9302c;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f5f5f5;
        }

        .btn {
            background-color: #0056b3;
            color: white;
            padding: 0.5rem 1rem;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        .btn:hover {
            background-color: #004494;
        }
    </style>
</head>
<body>
<header>
    <h1>查看所有工资信息</h1>
</header>
<nav>
    <a href="salary.jsp">返回工资管理</a>
</nav>

<div class="container">
    <form method="get" action="viewSalaries.jsp" id="filterForm">
        <label for="filterName">姓名：</label>
        <input type="text" name="filterName" id="filterName" value="<%= filterName != null ? filterName : "" %>">

        <label for="filterEmployeeId">工号：</label>
        <input type="text" name="filterEmployeeId" id="filterEmployeeId" value="<%= filterEmployeeId != null ? filterEmployeeId : "" %>">

        <label for="filterMonth">工资月份：</label>
        <select name="filterMonth" id="filterMonth">
            <option value="">全部</option>
            <% 
                // 生成最近12个月的选项
                Calendar calendar = Calendar.getInstance();
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM");
                for (int i = 0; i < 12; i++) {
                    String month = sdf.format(calendar.getTime());
                    boolean selected = month.equals(filterMonth);
            %>
            <option value="<%= month %>" <%= selected ? "selected" : "" %>><%= month %></option>
            <% 
                    calendar.add(Calendar.MONTH, -1);
                }
            %>
        </select>

        <button type="submit" class="btn">筛选</button>
        <button type="button" class="btn" onclick="exportCSV('current')">导出当前页</button>
        <button type="button" class="btn" onclick="exportCSV('all')">导出全部</button>
    </form>
    
    <input type="hidden" id="sortBy" name="sortBy" value="<%= sortBy != null ? sortBy : "" %>">
    <input type="hidden" id="sortOrder" name="sortOrder" value="<%= sortOrder != null ? sortOrder : "" %>">
    <input type="hidden" id="currentPage" name="currentPage" value="<%= currentPage %>">
    <input type="hidden" id="pageSize" name="pageSize" value="<%= pageSize %>">

    <table>
        <thead>
        <tr>
            <th onclick="sort('u.employee_id')">工号</th>
            <th onclick="sort('u.name')">姓名</th>
            <th onclick="sort('s.month')">工资月份</th>
            <th onclick="sort('s.base_salary')">基础工资</th>
            <th onclick="sort('s.attendance_bonus')">考勤奖金</th>
            <th onclick="sort('s.total_salary')">总工资</th>
            <th onclick="sort('s.deductions')">扣款</th>
            <% if ("admin".equals(role) || "manager".equals(role)) { %>
            <th>操作</th>
            <% } %>
        </tr>
        </thead>
        <tbody>
        <% 
            try { 
                while (rs.next()) { 
                    String employeeId = rs.getString("employee_id");
                    String employeeName = rs.getString("employee_name");
                    String employeeRole = rs.getString("employee_role");
                    String salaryMonth = rs.getString("month");
                    double baseSalary = rs.getDouble("base_salary");
                    double attendanceBonus = rs.getDouble("attendance_bonus");
                    double totalSalary = rs.getDouble("total_salary");
                    double deductions = rs.getDouble("deductions");
        %>
        <tr>
            <td><%= employeeId %></td>
            <td><%= employeeName %></td>
            <td><%= salaryMonth %></td>
            <td><%= baseSalary %></td>
            <td><%= attendanceBonus %></td>
            <td><%= totalSalary %></td>
            <td><%= deductions %></td>
            <% if ("admin".equals(role) || "manager".equals(role)) { %>
            <td>
                <% 
                    if (!"admin".equals(employeeRole)) { 
                %>

                <a href="editSalary.jsp?employeeId=<%= employeeId %>&salaryMonth=<%= salaryMonth %>" class="btn">修改</a>
                <a href="deleteSalary.jsp?employeeId=<%= employeeId %>&salaryMonth=<%= salaryMonth %>" class="btn" onclick="return confirm('确认要删除这条记录吗？');">删除</a>

                <% 
                } else { 
                %>

                <span>管理员不可修改或删除</span>

                <% 
                    } 
                %>
            </td>
            <% } %>
        </tr>
        <% 
                } 
            } catch (Exception e) { 
                e.printStackTrace(); 
            } finally { 
                if (rs != null) rs.close(); 
                if (stmt != null) stmt.close(); 
                if (conn != null) conn.close(); 
            } 
        %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="3" style="text-align: right; font-weight: bold;">合计：</td>
                <td><%= totalBaseSalary %></td>
                <td><%= totalAttendanceBonus %></td>
                <td><%= totalTotalSalary %></td>
                <td><%= totalDeductions %></td>
                <% if ("admin".equals(role) || "manager".equals(role)) { %>
                <td></td>
                <% } %>
            </tr>
        </tfoot>
    </table>

    <div class="pagination">
        <span>共 <%= totalRecords %> 条记录，第 <%= currentPage %> 页 / 共 <%= (int) Math.ceil((double) totalRecords / pageSize) %> 页</span>
        <select id="pageSizeSelect" onchange="changePageSize()">
            <option value="10" <%= pageSize == 10 ? "selected" : "" %>>10条/页</option>
            <option value="20" <%= pageSize == 20 ? "selected" : "" %>>20条/页</option>
            <option value="50" <%= pageSize == 50 ? "selected" : "" %>>50条/页</option>
            <option value="100" <%= pageSize == 100 ? "selected" : "" %>>100条/页</option>
        </select>
        <button onclick="goToPage(1)" <%= currentPage == 1 ? "disabled" : "" %>>首页</button>
        <button onclick="goToPage(<%= currentPage - 1 %>)" <%= currentPage == 1 ? "disabled" : "" %>>上一页</button>
        <button onclick="goToPage(<%= currentPage + 1 %>)" <%= currentPage >= (int) Math.ceil((double) totalRecords / pageSize) ? "disabled" : "" %>>下一页</button>
        <button onclick="goToPage(<%= (int) Math.ceil((double) totalRecords / pageSize) %>)" <%= currentPage >= (int) Math.ceil((double) totalRecords / pageSize) ? "disabled" : "" %>>末页</button>
        <input type="number" id="pageInput" placeholder="页码" min="1" max="<%= (int) Math.ceil((double) totalRecords / pageSize) %>" style="width: 60px; padding: 5px;">
        <button onclick="goToPageByInput()">跳转</button>
    </div>
    
    <p>
        <a href="salary.jsp" class="btn">返回</a>
    </p>
    
    <script>
        // 排序功能
        function sort(column) {
            var currentSortBy = document.getElementById('sortBy').value;
            var currentSortOrder = document.getElementById('sortOrder').value;
            
            var newSortOrder = 'ASC';
            if (currentSortBy == column && currentSortOrder == 'ASC') {
                newSortOrder = 'DESC';
            }
            
            document.getElementById('sortBy').value = column;
            document.getElementById('sortOrder').value = newSortOrder;
            document.getElementById('currentPage').value = 1; // 排序后回到第一页
            document.getElementById('filterForm').submit();
        }
        
        // 分页功能
        function goToPage(page) {
            document.getElementById('currentPage').value = page;
            document.getElementById('filterForm').submit();
        }
        
        function changePageSize() {
            document.getElementById('pageSize').value = document.getElementById('pageSizeSelect').value;
            document.getElementById('currentPage').value = 1; // 改变每页条数后回到第一页
            document.getElementById('filterForm').submit();
        }
        
        function goToPageByInput() {
            var pageInput = document.getElementById('pageInput');
            var page = parseInt(pageInput.value);
            var maxPage = <%= (int) Math.ceil((double) totalRecords / pageSize) %>;
            
            if (page >= 1 && page <= maxPage) {
                goToPage(page);
            } else {
                alert('请输入有效的页码');
            }
        }
        
        // 导出CSV功能
        function exportCSV(type) {
            var form = document.getElementById('filterForm');
            var action = form.action;
            
            // 添加导出参数
            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'export';
            input.value = type;
            form.appendChild(input);
            
            form.submit();
            form.removeChild(input);
        }
        
        // 保存筛选状态到Cookie
        function saveFilterState() {
            var filterName = document.getElementById('filterName').value;
            var filterEmployeeId = document.getElementById('filterEmployeeId').value;
            var filterMonth = document.getElementById('filterMonth').value;
            var sortBy = document.getElementById('sortBy').value;
            var sortOrder = document.getElementById('sortOrder').value;
            var pageSize = document.getElementById('pageSize').value;
            
            document.cookie = 'salary_filter_name=' + encodeURIComponent(filterName) + '; path=/';
            document.cookie = 'salary_filter_employee_id=' + encodeURIComponent(filterEmployeeId) + '; path=/';
            document.cookie = 'salary_filter_month=' + encodeURIComponent(filterMonth) + '; path=/';
            document.cookie = 'salary_sort_by=' + encodeURIComponent(sortBy) + '; path=/';
            document.cookie = 'salary_sort_order=' + encodeURIComponent(sortOrder) + '; path=/';
            document.cookie = 'salary_page_size=' + encodeURIComponent(pageSize) + '; path=/';
        }
        
        // 从Cookie加载筛选状态
        function loadFilterState() {
            var filterName = getCookie('salary_filter_name');
            var filterEmployeeId = getCookie('salary_filter_employee_id');
            var filterMonth = getCookie('salary_filter_month');
            var sortBy = getCookie('salary_sort_by');
            var sortOrder = getCookie('salary_sort_order');
            var pageSize = getCookie('salary_page_size');
            
            if (filterName) document.getElementById('filterName').value = decodeURIComponent(filterName);
            if (filterEmployeeId) document.getElementById('filterEmployeeId').value = decodeURIComponent(filterEmployeeId);
            if (filterMonth) document.getElementById('filterMonth').value = decodeURIComponent(filterMonth);
            if (sortBy) document.getElementById('sortBy').value = decodeURIComponent(sortBy);
            if (sortOrder) document.getElementById('sortOrder').value = decodeURIComponent(sortOrder);
            if (pageSize) document.getElementById('pageSize').value = decodeURIComponent(pageSize);
        }
        
        // 获取Cookie值
        function getCookie(name) {
            var value = '; ' + document.cookie;
            var parts = value.split('; ' + name + '=');
            if (parts.length == 2) return parts.pop().split(';').shift();
        }
        
        // 页面加载时加载筛选状态
        window.onload = function() {
            loadFilterState();
        };
        
        // 表单提交时保存筛选状态
        document.getElementById('filterForm').onsubmit = function() {
            saveFilterState();
        };
    </script>
</div>
</body>
</html>
