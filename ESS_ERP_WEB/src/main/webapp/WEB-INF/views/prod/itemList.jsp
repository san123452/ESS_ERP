<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>품목 관리 - ESS ERP</title>
    <link rel="stylesheet" href="/css/common.css">
    <style>
        body { font-family: sans-serif; padding: 20px; }
        .form-box { background: #f0f0f0; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: center; }
        th { background-color: #333; color: white; }
    </style>
</head>
<body>
    <h2>📦 품목 관리 (Item Management)</h2>
    
    <!-- 품목 등록 폼 -->
    <div class="form-box">
        <h3>신규 품목 등록</h3>
        <!-- 컨트롤러의 @PostMapping("/add") 주소로 데이터를 보냅니다 -->
        <form action="/prod/item/add" method="post">
            <!-- [중요] 스프링 시큐리티를 쓴다면 이 CSRF 토큰이 필수입니다! 없으면 403 에러로 막힙니다. -->
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            
            <label>품목코드:</label>
            <input type="text" name="itemCd" placeholder="예: ITM-001" required>
            
            <label>품목명:</label>
            <input type="text" name="itemNm" placeholder="예: 강철 프레임" required>
            
            <label>구분:</label>
            <select name="itemType">
                <!-- DB 설계서 TB_CODE 기준: RAW/HALF/FIN -->
                <option value="RAW">원자재 (RAW)</option>
                <option value="HALF">반제품 (HALF)</option>
                <option value="FIN">완제품 (FIN)</option>
            </select>
            
            <label>단위:</label>
            <input type="text" name="unit" placeholder="EA, KG 등">
            
            <label>단가:</label>
            <input type="number" name="price" value="0">

            <label>안전재고:</label>
            <input type="number" name="safeQty" value="100">

            <label>위치:</label>
            <input type="text" name="whLocation" placeholder="A-01">
            
            <button type="submit">등록</button>
        </form>
    </div>

    <!-- 품목 목록 테이블 -->
    <h3>품목 목록</h3>
    <table>
        <thead>
            <tr>
                <th>품목코드</th><th>품목명</th><th>구분</th><th>단위</th><th>단가</th><th>현재고</th><th>안전재고</th><th>위치</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="item" items="${itemList}">
                <tr>
                    <td>${item.itemCd}</td>
                    <td>${item.itemNm}</td>
                    <td>${item.itemType}</td>
                    <td>${item.unit}</td>
                    <td>${item.price}원</td>
                    <td>${item.stockQty}</td>
                    <td>${item.safeQty}</td>
                    <td>${item.whLocation}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <br>
    <a href="/dashboard">🏠 메인으로 돌아가기</a>
</body>
</html>