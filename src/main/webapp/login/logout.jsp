<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    session.invalidate(); // 清除会话数据
    response.sendRedirect("../index.jsp"); // 重定向到首页
%>
