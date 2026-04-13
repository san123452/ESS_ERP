<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 수주 전표 관리</title>
    <link rel="stylesheet" href="/css/common.css">
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background-color: #f4f7f6; color: #333; }
        .header { background: #2c3e50; color: white; padding: 20px; display: flex; justify-content: space-between; align-items: center; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .header h1 { margin: 0; font-size: 22px; }
        .btn-add { background-color: #27ae60; color: white; text-decoration: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; transition: 0.3s; }
        .btn-add:hover { background-color: #219150; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        th, td { border: 1px solid #eee; padding: 15px; text-align: center; }
        th { background-color: #f8f9fa; border-bottom: 2px solid #2c3e50; font-weight: bold; }
        
        /* 수주 번호 링크 스타일 */
        .order-link { color: #2980b9; text-decoration: none; font-weight: bold; }
        .order-link:hover { text-decoration: underline; color: #1a5276; }
        
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
        .status-wait { background: #fff3e0; color: #e67e22; border: 1px solid #e67e22; }
        .status-done { background: #e8f5e9; color: #27ae60; border: 1px solid #27ae60; }
        .btn-outbound { background-color: #e74c3c; color: white; border: none; padding: 8px 15px; border-radius: 5px; cursor: pointer; font-weight: bold; transition: 0.3s; }
        .btn-outbound:hover { background-color: #c0392b; }
    </style>
    <script>
        window.onload = function() {
            var errorMsg = "${errorMsg}";
            var msg = "${msg}";
            if (errorMsg) alert("⚠️ 출고 실패\n" + errorMsg);
            if (msg) alert("✅ 알림\n" + msg);
        };
    </script>
</head>
<body>
    <div class="header">
        <h1>📑 수주(판매) 전표 현황</h1>
        <a href="/logis/order/sell/add" class="btn-add">+ 신규 수주 등록</a>
    </div>
    <table>
        <thead>
            <tr>
                <th>수주 번호</th><th>거래처명</th><th>상태</th><th>주문 일자</th><th>납기 일자</th><th>작업</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty orderSellList}">
                    <tr><td colspan="6">조회된 수주 내역이 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="order" items="${orderSellList}">
                        <tr>
                            <td>
                                <a href="/logis/order/sell/detail?no=${order.orderNo}" class="order-link">
                                    ${order.orderNo}
                                </a>
                            </td>
                            <td>${order.acctNm}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${order.status == 'WAIT'}"><span class="badge status-wait">출고대기</span></c:when>
                                    <c:when test="${order.status == 'DONE'}"><span class="badge status-done">출고완료</span></c:when>
                                    <c:otherwise><span class="badge">${order.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>${order.orderDate}</td>
                            <td style="color: #d35400; font-weight: bold;">${order.dueDate}</td>
                            <td>
                                <c:if test="${order.status == 'WAIT'}">
                                    <form action="/logis/stock/outbound" method="post" onsubmit="return confirm('출고 처리하시겠습니까?');">
                                        <input type="hidden" name="orderNo" value="${order.orderNo}">
                                        <button type="submit" class="btn-outbound">출고 확정</button>
                                    </form>
                                </c:if>
                                <c:if test="${order.status == 'DONE'}"><span style="color: #bdc3c7;">처리 완료</span></c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</body>
</html>