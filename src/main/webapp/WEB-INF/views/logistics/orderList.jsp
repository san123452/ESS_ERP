<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 발주 전표 현황</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; color: #333; }
    .header { background: #34495e; color: white; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-radius: 5px; }
    .header h1 { margin: 0; font-size: 24px; }
    .btn-add { background-color: #27ae60; color: white; text-decoration: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; }
    .btn-add:hover { background-color: #219150; }
    
    table { width: 100%; border-collapse: collapse; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    th, td { border: 1px solid #ddd; padding: 15px; text-align: center; }
    th { background-color: #f8f9fa; font-weight: bold; border-bottom: 2px solid #34495e; }
    tr:hover { background-color: #f9f9f9; }
    
    .order-link { color: #2980b9; text-decoration: none; font-weight: bold; }
    .order-link:hover { text-decoration: underline; color: #1a5276; }
    
    .badge { padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; display: inline-block; }
    .status-wait { background-color: #fef9e7; color: #f39c12; border: 1px solid #f39c12; }
    .status-complete { background-color: #ebf5fb; color: #3498db; border: 1px solid #3498db; }
    .no-data { padding: 50px; color: #999; }
</style>
</head>
<body>

    <div class="header">
        <h1>📦 발주 전표 목록</h1>
        <a href="/logis/order/add" class="btn-add">+ 신규 발주 등록</a>
    </div>

    <table>
        <thead>
            <tr>
                <th>발주 번호</th>
                <th>거래처 코드</th>
                <th>상태</th>
                <th>발주 일자</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty orderList}">
                    <tr>
                        <td colspan="4" class="no-data">등록된 발주 내역이 없습니다.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="order" items="${orderList}">
                        <tr>
                            <td>
                                <a href="/logis/order/detail?no=${order.orderNo}" class="order-link">
                                    ${order.orderNo}
                                </a>
                            </td>
                            <td>${order.acctCd}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${order.status == 'WAIT'}">
                                        <span class="badge status-wait">대기</span>
                                    </c:when>
                                    <c:when test="${order.status == 'COMPLETE'}">
                                        <span class="badge status-complete">완료</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge">${order.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${order.orderDate}</td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

</body>
</html>