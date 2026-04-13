<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 재고 현황</title>
    <link rel="stylesheet" href="/css/common.css">
</head>
<body>
    <h2>📦 실시간 창고 재고 현황</h2>
    <table>
        <thead>
            <tr>
                <th>품목코드</th><th>품목명</th><th>구분</th><th>현재고</th><th>안전재고</th><th>보관위치</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="item" items="${stockList}">
                <tr>
                    <td><strong>${item.itemCd}</strong></td><td>${item.itemNm}</td><td>${item.itemType}</td>
                    <td style="color:${item.stockQty <= item.safeQty ? 'red' : 'green'}; font-weight:bold;">${item.stockQty}</td>
                    <td>${item.safeQty}</td><td>${item.whLocation}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>