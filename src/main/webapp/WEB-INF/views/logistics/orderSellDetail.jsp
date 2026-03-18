<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 수주 상세 내역</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background-color: #f4f7f6; color: #333; }
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); max-width: 900px; margin: 0 auto; border-top: 5px solid #2c3e50; }
        h2 { color: #2c3e50; margin-top: 0; padding-bottom: 10px; border-bottom: 2px solid #eee; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #eee; padding: 12px; text-align: center; }
        th { background-color: #f8f9fa; width: 20%; color: #2c3e50; font-weight: bold; }
        .status-wait { color: #e67e22; font-weight: bold; }
        .status-done { color: #27ae60; font-weight: bold; }
        .btn-outbound { background-color: #e74c3c; color: white; border: none; padding: 12px 25px; border-radius: 5px; cursor: pointer; font-weight: bold; transition: 0.3s; }
        .btn-outbound:hover { background-color: #c0392b; }
        .btn-list { text-decoration: none; color: #7f8c8d; margin-left: 15px; font-size: 14px; }
    </style>
</head>
<body>
<div class="card">
    <h2>📑 수주(판매) 상세 내역</h2>
    
    <table>
        <tr>
            <th>수주 번호</th><td>${order.orderNo}</td>
            <th>거래처</th><td>${order.acctNm} (${order.acctCd})</td>
        </tr>
        <tr>
            <th>주문 일자</th><td>${order.orderDate}</td>
            <th>납기 일자</th><td style="color: #d35400; font-weight: bold;">${order.dueDate}</td>
        </tr>
        <tr>
            <th>현재 상태</th>
            <td class="${order.status == 'WAIT' ? 'status-wait' : 'status-done'}">
                <c:choose>
                    <c:when test="${order.status == 'WAIT'}">출고대기</c:when>
                    <c:when test="${order.status == 'DONE'}">출고완료</c:when>
                    <c:otherwise>${order.status}</c:otherwise>
                </c:choose>
            </td>
            <th>비고</th><td>${order.remark}</td>
        </tr>
    </table>

    <h3 style="margin-top: 30px; border-left: 5px solid #2c3e50; padding-left: 10px;">📦 판매 품목 상세</h3>
    <table>
        <thead>
            <tr>
                <th>순번</th><th>품목 코드</th><th>수량</th><th>판매 단가</th><th>합계 금액</th>
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

    <div style="text-align: right; margin-top: 20px;">
        <c:if test="${order.status == 'WAIT'}">
            <form action="/logis/stock/outbound" method="post" style="display: inline;" onsubmit="return confirm('이 내역대로 출고를 확정하시겠습니까?');">
                <input type="hidden" name="orderNo" value="${order.orderNo}">
                <button type="submit" class="btn-outbound">즉시 출고 확정</button>
            </form>
        </c:if>
        <a href="/logis/order/sell/list" class="btn-list">목록으로 돌아가기</a>
    </div>
</div>
</body>
</html>