<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 재고 수불 이력</title>
    <link rel="stylesheet" href="/css/common.css">
</head>
<body>
    <h2>🔍 재고 수불(입/출고) 이력 블랙박스</h2>
    <table>
        <thead>
            <tr>
                <th>로그번호</th><th>품목코드</th><th>구분(IN/OUT)</th><th>변동수량</th>
                <th>이전재고</th><th>변경후재고</th><th>근거전표</th><th>처리자</th><th>처리일시</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="log" items="${logList}">
                <tr>
                    <td>${log.logNo}</td><td><strong>${log.itemCd}</strong></td>
                    <td style="color:${log.inoutType == 'IN' ? 'blue' : 'red'};">${log.inoutType}</td>
                    <td><strong>${log.qty}</strong></td><td>${log.beforeQty}</td><td>${log.afterQty}</td>
                    <td>${log.refNo}</td><td>${log.empId}</td><td>${log.regDt}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>