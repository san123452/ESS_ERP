<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>BOM 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4">BOM (부품 명세서) 관리</h2>

    <%-- Controller에서 보내준 에러(error)나 성공(msg) 메시지가 있을 경우에만 화면 상단에 경고창 형태로 출력합니다. --%>
    <c:if test="${not empty error}">
        <div class="alert alert-danger" role="alert">
            ${error}
        </div>
    </c:if>
    <c:if test="${not empty msg}">
        <div class="alert alert-success" role="alert">
            ${msg}
        </div>
    </c:if>

    <!-- [상단 영역] 새로운 BOM을 등록하는 폼 -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-light">
            <strong>새 BOM 등록</strong>
        </div>
        <div class="card-body">
            <form action="/prod/bom/add" method="post" id="bomForm" class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label for="parentCd" class="form-label">상위 품목</label>
                    <select id="parentCd" name="parentCd" class="form-select" required>
                        <option value="">선택하세요</option>
                        <%-- Model에 담긴 itemList를 반복문을 돌며 Select 옵션으로 만들어줍니다. --%>
                        <c:forEach var="item" items="${itemList}">
                            <option value="${item.itemCd}">${item.itemCd} [${item.itemNm}]</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="childCd" class="form-label">하위 품목</label>
                    <select id="childCd" name="childCd" class="form-select" required>
                        <option value="">선택하세요</option>
                        <c:forEach var="item" items="${itemList}">
                            <option value="${item.itemCd}">${item.itemCd} [${item.itemNm}]</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="reqQty" class="form-label">소요량</label>
                    <input type="number" id="reqQty" name="reqQty" class="form-control" min="1" required>
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-primary w-100">등록</button>
                </div>
            </form>
        </div>
    </div>

    <!-- [하단 영역] 등록된 BOM 리스트를 보여주는 테이블 -->
    <div class="card shadow-sm">
        <div class="card-header bg-light">
            <strong>BOM 목록</strong>
        </div>
        <div class="card-body p-0">
            <table class="table table-hover table-bordered mb-0 text-center align-middle">
                <thead class="table-secondary">
                    <tr>
                        <th>상위품목코드</th>
                        <th>상위품목명</th>
                        <th>하위품목코드</th>
                        <th>하위품목명</th>
                        <th>소요량</th>
                    </tr>
                </thead>
                <tbody>
                    <%-- selectBomList() 쿼리로 가져온 데이터를 반복문으로 표에 출력합니다. --%>
                    <c:forEach var="bom" items="${bomList}">
                        <tr>
                            <td>${bom.parentCd}</td>
                            <td>${bom.parentNm}</td>
                            <td>${bom.childCd}</td>
                            <td>${bom.childNm}</td>
                            <td>${bom.reqQty}</td>
                        </tr>
                    </c:forEach>
                    <%-- 등록된 데이터가 1건도 없을 때 보여줄 문구 --%>
                    <c:if test="${empty bomList}">
                        <tr>
                            <td colspan="5" class="py-4 text-muted">등록된 BOM 데이터가 없습니다.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // [클라이언트 단 검증] 
    // 서버(Service)로 넘어가기 전 화면단(브라우저)에서 1차적으로 자기 참조 방지를 체크하여 빠르고 부드러운 사용자 경험(UX)을 제공합니다.
    document.getElementById('bomForm').addEventListener('submit', function(e) {
        var parentCd = document.getElementById('parentCd').value;
        var childCd = document.getElementById('childCd').value;
        
        if(parentCd === childCd) {
            e.preventDefault(); // 폼 제출(서버로 전송)을 막습니다.
            alert('상위 품목과 하위 품목은 동일할 수 없습니다.');
        }
    });
</script>
</body>
</html>