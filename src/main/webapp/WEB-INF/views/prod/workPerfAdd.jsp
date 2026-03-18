<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>생산 실적 등록</title>
    <link rel="stylesheet" href="/css/common.css">
</head>
<body>
    <h2>실적 등록 폼 (모달 또는 새창용)</h2>
    <!-- 에러 발생 시 alert 띄우기 -->
    <c:if test="${not empty error}">
        <script>alert('${error}');</script>
    </c:if>
    <!-- 성공 메시지 발생 시 alert 띄우기 -->
    <c:if test="${not empty msg}">
        <script>alert('${msg}');</script>
    </c:if>
    
    <form action="/prod/work/perf/add" method="post">
        <!-- 실제로는 화면의 목록에서 선택한 작업지시번호를 hidden이나 텍스트로 가져옵니다 -->
        <label>작업지시 번호: </label>
        <input type="text" name="workNo" value="WK-20260318-001" readonly/><br/><br/>
        
        <label>양품 수량 (완제품 입고): </label>
        <input type="number" name="goodQty" required min="1" /><br/><br/>
        
        <label>불량 수량 (부품만 소모): </label>
        <input type="number" name="badQty" value="0" min="0"/><br/><br/>
        
        <button type="submit">실적 등록 및 재고 반영</button>
    </form>
</body>
</html>