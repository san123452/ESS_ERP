<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 물류 관리</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; }
    .header { background: #34495e; color: white; padding: 10px; margin-bottom: 20px; }
    .form-box { border: 2px solid #34495e; padding: 20px; margin-bottom: 30px; border-radius: 5px; }
    .form-box input, .form-box select { padding: 8px; margin-right: 10px; margin-bottom: 10px; }
    table { width: 100%; border-collapse: collapse; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }
    th { background-color: #f8f9fa; color: #333; }
    .btn-reg { background-color: #27ae60; color: white; border: none; padding: 10px 20px; cursor: pointer; font-weight: bold; }
</style>
</head>
<body>

    <div class="header">
        <h1>[물류/영업] 거래처 관리</h1>
    </div>

    <div class="form-box">
        <h3>신규 거래처 등록</h3>
        <form action="/logis/client/register" method="post">
            <input type="text" name="acctCd" placeholder="거래처코드 (예: AC001)" required>
            <input type="text" name="acctNm" placeholder="회사명" required>
            <select name="acctType">
                <option value="IN">매입처(IN)</option>
                <option value="OUT">매출처(OUT)</option>
                <option value="BOTH">겸용(BOTH)</option>
            </select>
            <input type="text" name="bizNo" placeholder="사업자번호">
            <input type="text" name="managerNm" placeholder="담당자명">
            <input type="text" name="phone" placeholder="연락처">
            <input type="text" name="email" placeholder="이메일">
            <button type="submit" class="btn-reg">거래처 등록</button>
        </form>
    </div>

    <h3>거래처 현황</h3>
    <table>
        <thead>
            <tr>
                <th>코드</th>
                <th>상호명</th>
                <th>구분</th>
                <th>사업자번호</th>
                <th>담당자</th>
                <th>연락처</th>
                <th>등록일자</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="client" items="${clientList}">
                <tr>
                    <td><strong>${client.acctCd}</strong></td>
                    <td>${client.acctNm}</td>
                    <td>${client.acctType}</td>
                    <td>${client.bizNo}</td>
                    <td>${client.managerNm}</td>
                    <td>${client.phone}</td>
                    <td>${fn:replace(fn:substring(client.regDt, 0, 16), 'T', ' ')}</td>
                </tr>
            </c:forEach>
            <c:if test="${empty clientList}">
                <tr><td colspan="7">등록된 거래처 정보가 없습니다.</td></tr>
            </c:if>
        </tbody>
    </table>

</body>
</html>