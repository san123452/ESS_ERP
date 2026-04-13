<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 발주 전표 현황</title>
    <link rel="stylesheet" href="/css/common.css">
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background-color: #f4f7f6; }
        .header { background: #2c3e50; color: white; padding: 20px; display: flex; justify-content: space-between; align-items: center; border-radius: 8px; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        th, td { border: 1px solid #eee; padding: 15px; text-align: center; }
        th { background-color: #f8f9fa; border-bottom: 2px solid #2c3e50; }
        .btn-add { background-color: #3498db; color: white; text-decoration: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; }
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
        .status-wait { background: #fff3e0; color: #e67e22; }
        .status-done { background: #e8f5e9; color: #27ae60; }
    </style>
</head>
<body>
    <div class="header"><h1>📦 발주 전표 목록</h1><a href="/logis/order/add" class="btn-add">+ 신규 발주 등록</a></div>
    <table>
        <thead><tr><th>발주 번호</th><th>거래처</th><th>상태</th><th>발주 일자</th><th>작업</th></tr></thead>
        <tbody>
            <c:forEach var="order" items="${orderList}">
                <tr>
                    <td><a href="/logis/order/detail?no=${order.orderNo}">${order.orderNo}</a></td>
                    <td>${order.acctCd}</td>
                    <td><span class="badge ${order.status == 'WAIT' ? 'status-wait' : 'status-done'}">${order.status == 'WAIT' ? '대기' : '입고완료'}</span></td>
                    <td>${order.orderDate}</td>
                    <td><c:if test="${order.status == 'WAIT'}"><button onclick="location.href='/logis/stock/confirm?no=${order.orderNo}'">입고 처리</button></c:if></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>