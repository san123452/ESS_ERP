<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>발주 상세 내역</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }
        th { background-color: #f4f4f4; width: 15%; }
        .master-info { margin-bottom: 30px; }
        .btn-confirm { background-color: #3498db; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .btn-list { background-color: #7f8c8d; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; font-size: 13px; }
        .status-wait { color: #f39c12; font-weight: bold; }
        .status-done { color: #3498db; font-weight: bold; }
    </style>
</head>
<body>
    <h2>📄 발주 상세 내역</h2>
    <div class="master-info">
        <table>
            <tr>
                <th>발주 번호</th><td>${order.orderNo}</td>
                <th>거래처 코드</th><td>${order.acctCd}</td>
            </tr>
            <tr>
                <th>발주 일자</th><td>${order.orderDate}</td>
                <th>현재 상태</th>
                <td class="${order.status == 'WAIT' ? 'status-wait' : 'status-done'}">
                    <c:choose>
                        <c:when test="${order.status == 'WAIT'}">대기</c:when>
                        <c:when test="${order.status == 'DONE'}">입고완료</c:when>
                        <c:otherwise>${order.status}</c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>비고</th><td colspan="3">${order.remark}</td>
            </tr>
        </table>
    </div>

    <h3>📦 발주 품목 상세</h3>
    <table>
        <thead>
            <tr>
                <th>순번</th><th>품목 코드</th><th>수량</th><th>단가</th><th>합계 금액</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="item" items="${order.details}" varStatus="vs">
                <tr>
                    <td>${vs.count}</td>
                    <td>${item.itemCd}</td>
                    <td><fmt:formatNumber value="${item.qty}" pattern="#,###"/></td>
                    <td><fmt:formatNumber value="${item.unitPrice}" pattern="#,###"/>원</td>
                    <td><fmt:formatNumber value="${item.amt}" pattern="#,###"/>원</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <div style="margin-top: 20px; text-align: right;">
        <c:if test="${order.status == 'WAIT'}">
            <button class="btn-confirm" onclick="if(confirm('입고 확정하시겠습니까?')) location.href='/logis/order/confirm?no=${order.orderNo}'">발주 확정(입고)</button>
        </c:if>
        <a href="/logis/order/list" class="btn-list">목록으로</a>
    </div>
</body>
</html>