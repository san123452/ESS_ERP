<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 발주 전표 등록</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background-color: #f4f7f6; }
        .container { max-width: 600px; margin: 0 auto; }
        .header { background: #2c3e50; color: white; padding: 15px 20px; border-radius: 8px 8px 0 0; }
        .form-card { background: white; padding: 30px; border-radius: 0 0 8px 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 5px; }
        .form-group select, .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .btn-submit { width: 100%; background-color: #3498db; color: white; border: none; padding: 12px; font-size: 16px; font-weight: bold; cursor: pointer; border-radius: 4px; margin-top: 10px; }
        .btn-back { display: block; text-align: center; margin-top: 15px; color: #7f8c8d; text-decoration: none; }
    </style>
    <script>
        function updatePrice() {
            const select = document.getElementById('itemSelect');
            const price = select.options[select.selectedIndex].getAttribute('data-price');
            document.getElementById('unitPrice').value = price || '';
        }
    </script>
</head>
<body>
<div class="container">
    <div class="header"><h1>📦 발주 전표 등록</h1></div>
    <div class="form-card">
        <form action="/logis/order/add" method="post">
            <div class="form-group">
                <label>거래처 선택</label>
                <select name="acctCd" required>
                    <c:forEach var="client" items="${clientList}"><option value="${client.acctCd}">${client.acctNm}</option></c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>품목 선택</label>
                <select name="details[0].itemCd" id="itemSelect" onchange="updatePrice()" required>
                    <option value="">-- 품목 선택 --</option>
                    <c:forEach var="item" items="${itemList}"><option value="${item.itemCd}" data-price="${item.price}">${item.itemNm}</option></c:forEach>
                </select>
            </div>
            <div class="form-group"><label>발주 수량</label><input type="number" name="details[0].qty" required></div>
            <div class="form-group"><label>단가</label><input type="number" name="details[0].unitPrice" id="unitPrice" required></div>
            <button type="submit" class="btn-submit">발주 등록</button>
        </form>
        <a href="/logis/order/list" class="btn-back">목록으로</a>
    </div>
</div>
</body>
</html>