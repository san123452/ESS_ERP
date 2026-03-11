<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 인사 관리</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; }
    .header { background: #2c3e50; color: white; padding: 10px; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }
    th { background-color: #f8f9fa; color: #333; }
</style>
</head>
<body>
    <div class="header">
        <h1>[인사] 사원 목록</h1>
    </div>
    <table>
        <thead>
            <tr>
                <th>사번</th>
                <th>이름</th>
                <th>부서</th>
                <th>직급</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="emp" items="${list}">
            <tr>
                <td><strong>${emp.empId}</strong></td>
                <td>${emp.empName}</td>
                <td>${emp.deptCode}</td>
                <td>${emp.position}</td>
            </tr>
            </c:forEach>
            <c:if test="${empty list}">
                <tr><td colspan="4">등록된 사원 정보가 없습니다.</td></tr>
            </c:if>
        </tbody>
    </table>
</body>
</html>