<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>발주 상세 내역</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: center; }
        th { background-color: #f4f4f4; }
        .master-info { background-color: #fafafa; margin-bottom: 20px; }
        .btn-area { margin-top: 20px; text-align: right; }
        .status-wait { color: orange; font-weight: bold; }
        .status-done { color: blue; font-weight: bold; }
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
                    ${order.status}
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
                <th>순번</th>
                <th>품목 코드</th>
                <th>수량</th>
                <th>단가</th>
                <th>합계 금액</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="item" items="${order.details}" varStatus="status">
                <tr>
                    <td>${status.count}</td>
                    <td>${item.itemCode}</td>
                    <td>${item.qty}</td>
                    <td>${item.unitPrice}</td>
                    <td>${item.amt}</td>
                </tr>
            </c:forEach>
            <c:if test="${empty order.details}">
                <tr>
                    <td colspan="5">등록된 상세 품목이 없습니다.</td>
                </tr>
            </c:if>
        </tbody>
    </table>

    <div class="btn-area">
        <c:if test="${order.status == 'WAIT'}">
            <button onclick="location.href='/logis/order/confirm?no=${order.orderNo}'">발주 확정</button>
        </c:if>
        <button onclick="location.href='/logis/order/list'">목록으로</button>
    </div>
</body>
</html>