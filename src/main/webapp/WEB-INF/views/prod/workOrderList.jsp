<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 작업 지시 관리</title>
    <link rel="stylesheet" href="/css/common.css">
    <style>
        .status-PROG { color: #3498db; font-weight: bold; }
        .status-DONE { color: #27ae60; font-weight: bold; }
        .status-WAIT { color: #e67e22; font-weight: bold; }
        .btn-perf { background-color: #e74c3c; padding: 6px 12px; font-size: 12px; }
        .btn-perf:hover { background-color: #c0392b; }
    </style>
</head>
<body>
    <h2>📋 생산 작업 지시 목록</h2>
    <table>
        <thead>
            <tr>
                <th>지시 번호</th>
                <th>품목명 (코드)</th>
                <th>지시 수량</th>
                <th>상태</th>
                <th>등록일</th>
                <th>작업</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="order" items="${workOrderList}">
                <tr>
                    <td><strong>${order.workNo}</strong></td>
                    <td>${order.itemNm} (${order.itemCd})</td>
                    <td>${order.workQty}</td>
                    <td class="status-${order.status}">${order.status}</td>
                    <td>${order.workDate}</td>
                    <td>
                        <c:choose>
                            <c:when test="${order.status != 'DONE'}">
                                <!-- 진행중일 때만 실적 등록 폼으로 지시번호를 들고 이동합니다! -->
                                <a href="/prod/work/perf/add?workNo=${order.workNo}" class="btn btn-perf">실적 등록</a>
                            </c:when>
                            <c:otherwise><span style="color:#aaa;">등록 완료</span></c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>