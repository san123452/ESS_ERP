<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>발주 상세 내역</title>
    <link rel="stylesheet" href="/css/common.css">
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background-color: #f4f7f6; }
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); max-width: 900px; margin: 0 auto; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #eee; padding: 12px; text-align: center; }
        th { background-color: #f8f9fa; width: 20%; color: #2c3e50; }
        .btn-confirm { background-color: #3498db; color: white; border: none; padding: 10px 25px; border-radius: 5px; cursor: pointer; font-weight: bold; }
        .status-wait { color: #e67e22; font-weight: bold; }
        .status-done { color: #27ae60; font-weight: bold; }
    </style>
</head>
<body>
<div class="card">
    <h2 style="border-bottom: 2px solid #2c3e50; padding-bottom: 10px;">📄 발주 상세 내역</h2>
    <table>
        <tr><th>발주 번호</th><td>${order.orderNo}</td><th>거래처</th><td>${order.acctCd}</td></tr>
        <tr><th>발주 일자</th><td>${order.orderDate}</td><th>상태</th>
            <td class="${order.status == 'WAIT' ? 'status-wait' : 'status-done'}">${order.status == 'WAIT' ? '대기' : '입고완료'}</td>
        </tr>
    </table>
    <h3>📦 품목 상세</h3>
    <table>
        <thead><tr><th>품목 코드</th><th>수량</th><th>단가</th><th>합계</th></tr></thead>
        <tbody>
            <c:forEach var="item" items="${order.details}">
                <tr>
                    <td>${item.itemCd}</td>
                    <td><fmt:formatNumber value="${item.qty}" pattern="#,###"/></td>
                    <td><fmt:formatNumber value="${item.unitPrice}" pattern="#,###"/>원</td>
                    <td><fmt:formatNumber value="${item.amt}" pattern="#,###"/>원</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <div style="text-align: right;">
        <c:if test="${order.status == 'WAIT'}"><button class="btn-confirm" onclick="location.href='/logis/stock/confirm?no=${order.orderNo}'">입고 확정</button></c:if>
        <a href="/logis/order/list" style="text-decoration: none; color: #7f8c8d; margin-left: 15px;">목록으로</a>
    </div>
</div>
</body>
</html>