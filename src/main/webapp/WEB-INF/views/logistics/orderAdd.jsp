<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 발주 전표 등록</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background-color: #f4f7f6; }
    .header { background: #34495e; color: white; padding: 10px 20px; margin-bottom: 20px; border-radius: 5px; }
    .container { max-width: 600px; margin: 0 auto; }
    .form-card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-top: 5px solid #34495e; }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; font-weight: bold; margin-bottom: 5px; color: #333; }
    .form-group select, .form-group input { 
        width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; 
    }
    .btn-submit { 
        width: 100%; background-color: #27ae60; color: white; border: none; padding: 12px; 
        font-size: 16px; font-weight: bold; cursor: pointer; border-radius: 4px; margin-top: 10px;
    }
    .btn-submit:hover { background-color: #219150; }
    .btn-back { display: block; text-align: center; margin-top: 15px; color: #7f8c8d; text-decoration: none; font-size: 14px; }
</style>
<script>
    // 품목 선택 시 단가 자동 입력 함수
    function updatePrice() {
        const select = document.getElementById('itemSelect');
        const selectedOption = select.options[select.selectedIndex];
        const price = selectedOption.getAttribute('data-price');
        
        if(price) {
            document.getElementById('unitPrice').value = price;
        } else {
            document.getElementById('unitPrice').value = '';
        }
    }
</script>
</head>
<body>

<div class="container">
    <div class="header">
        <h1>📦 발주 전표 등록</h1>
    </div>

    <div class="form-card">
        <form action="/logis/order/add" method="post">
            <div class="form-group">
                <label>거래처 선택</label>
                <select name="acctCd" required>
                    <option value="">-- 거래처를 선택하세요 --</option>
                    <c:forEach var="client" items="${clientList}">
                        <option value="${client.acctCd}">${client.acctNm} (${client.acctCd})</option>
                    </c:forEach>
                </select>
            </div>
            
            <div class="form-group">
                <label>품목 선택</label>
                <select name="details[0].itemCd" id="itemSelect" onchange="updatePrice()" required>
                    <option value="" data-price="">-- 품목을 선택하세요 --</option>
                    <c:forEach var="item" items="${itemList}">
                        <option value="${item.itemCd}" data-price="${item.price}">
                            ${item.itemNm} (${item.itemCd})
                        </option>
                    </c:forEach>
                </select>
            </div>
            
            <div class="form-group">
                <label>발주 수량</label>
                <input type="number" name="details[0].qty" min="1" placeholder="수량을 입력하세요" required>
            </div>
            
            <div class="form-group">
                <label>단가 (품목 선택 시 자동입력)</label>
                <input type="number" name="details[0].unitPrice" id="unitPrice" placeholder="단가를 입력하세요" required>
            </div>
            
            <div class="form-group">
                <label>비고</label>
                <input type="text" name="remark" placeholder="특이사항 입력">
            </div>
            
            <button type="submit" class="btn-submit">발주 전표 등록하기</button>
        </form>
        <a href="/logis/order/list" class="btn-back">목록으로 돌아가기</a>
    </div>
</div>

</body>
</html>