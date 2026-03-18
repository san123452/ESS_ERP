<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 수주 등록</title>
    <link rel="stylesheet" href="/css/common.css">
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background-color: #f4f7f6; color: #333; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #2c3e50; color: white; padding: 15px 20px; border-radius: 8px 8px 0 0; margin-bottom: 0; }
        .form-card { background: white; padding: 30px; border-radius: 0 0 8px 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 8px; color: #2c3e50; }
        .form-group input, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; border-top: 2px solid #2c3e50; }
        th, td { border: 1px solid #eee; padding: 12px; text-align: center; }
        th { background-color: #f8f9fa; font-weight: bold; }
        .btn-submit { width: 100%; background-color: #27ae60; color: white; border: none; padding: 15px; font-size: 16px; font-weight: bold; cursor: pointer; border-radius: 5px; margin-top: 20px; transition: 0.3s; }
        .btn-submit:hover { background-color: #219150; }
        .btn-back { display: block; text-align: center; margin-top: 15px; color: #7f8c8d; text-decoration: none; font-size: 14px; }
    </style>
    <script>
        function updatePrice() {
            const select = document.getElementById('itemSelect');
            const selectedOption = select.options[select.selectedIndex];
            const price = selectedOption.getAttribute('data-price');
            document.getElementById('unitPrice').value = price ? price : '';
        }
    </script>
</head>
<body>
<div class="container">
    <div class="header"><h1>📦 수주(판매) 전표 등록</h1></div>
    <div class="form-card">
        <form action="/logis/order/sell/add" method="post">
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
                <label>납기 일자</label>
                <input type="date" name="dueDate" required>
            </div>
            <div class="form-group">
                <label>비고(Remark)</label>
                <input type="text" name="remark" placeholder="특이사항을 입력하세요">
            </div>

            <h3 style="margin-top: 30px; border-left: 5px solid #2c3e50; padding-left: 10px;">📝 판매 품목 내역</h3>
            <table>
                <thead>
                    <tr>
                        <th style="width: 50%;">품목명 (현재고)</th>
                        <th>판매 수량</th>
                        <th>판매 단가</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <select name="details[0].itemCd" id="itemSelect" onchange="updatePrice()" required>
                                <option value="" data-price="">-- 품목 선택 --</option>
                                <c:forEach var="item" items="${itemList}">
                                    <option value="${item.itemCd}" data-price="${item.price}">
                                        ${item.itemNm} (재고: ${item.stockQty} ${item.unit})
                                    </option>
                                </c:forEach>
                            </select>
                        </td>
                        <td><input type="number" name="details[0].qty" min="1" placeholder="수량" required></td>
                        <td><input type="number" name="details[0].unitPrice" id="unitPrice" min="0" placeholder="단가" required></td>
                    </tr>
                </tbody>
            </table>
            <button type="submit" class="btn-submit">수주 전표 저장하기</button>
        </form>
        <a href="/logis/order/sell/list" class="btn-back">취소 및 목록으로</a>
    </div>
</div>
</body>
</html>