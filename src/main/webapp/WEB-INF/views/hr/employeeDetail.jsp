<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 사원 상세</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; }
    .header { background: #2c3e50; color: white; padding: 10px; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }
    th { background-color: #f8f9fa; color: #333; width: 30%; }
</style>
</head>
<body>
    <div class="header">
        <h1>[인사] 사원 상세</h1>
    </div>
    <table>
        <tr>
            <th>사번</th>
            <td>${emp.empId}</td>
        </tr>
        <tr>
            <th>이름</th>
            <td>${emp.empName}</td>
        </tr>
        <tr>
            <th>소속부서</th>
            <td>${emp.deptCode}</td>
        </tr>
        <tr>
            <th>직급</th>
            <td>${emp.position}</td>
        </tr>
        <tr>
            <th>입사일</th>
            <td>${emp.hireDate}</td>
        </tr>
    </table>
    <br>
    <a href="/hr/employee/list">목록으로</a>
</body>
</html>