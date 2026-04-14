<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 메인 대시보드</title>
    <!-- Bootstrap 5 & FontAwesome -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; display: flex; height: 100vh; overflow: hidden; margin: 0; }
        .sidebar { width: 260px; background-color: #2c3e50; color: white; display: flex; flex-direction: column; }
        .sidebar .nav-link { color: rgba(255,255,255,.8); transition: 0.3s; padding: 10px 20px; display: flex; align-items: center; gap: 10px; }
        .sidebar .nav-link:hover { color: white; background-color: #34495e; }
        .sidebar .nav-item .submenu .nav-link { padding-left: 50px; font-size: 0.9em; }
        .main-content { flex-grow: 1; overflow-y: auto; padding: 30px; }
        .widget-card { transition: transform 0.2s; }
        .widget-card:hover { transform: translateY(-5px); }
        .icon-box { width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; }
    </style>
</head>
<body>
<!-- 사이드바 영역 -->
<div class="sidebar shadow">
    <div class="p-4 text-center border-bottom border-secondary">
        <h4 class="m-0 fw-bold"><i class="fas fa-industry text-primary"></i> ESS ERP</h4>
        <small class="text-white-50">Enterprise System</small>
    </div>
    
    <div class="flex-grow-1 overflow-auto py-3">
        <ul class="nav flex-column mb-auto">
            <!-- 권한별 동적 메뉴 렌더링 (TB_ROLE_MENU 연동) -->
            <c:forEach var="menu" items="${sidebarMenuList}" varStatus="vs">
                <c:if test="${empty menu.parentNo}">
                    
                    <!-- 하위 메뉴 존재 여부 확인 -->
                    <c:set var="hasSub" value="false"/>
                    <c:forEach var="checkSub" items="${sidebarMenuList}">
                        <c:if test="${checkSub.parentNo == menu.menuNo}"><c:set var="hasSub" value="true"/></c:if>
                    </c:forEach>

                    <li class="nav-item mt-2">
                        <c:choose>
                            <c:when test="${hasSub}">
                                <!-- 하위 메뉴가 있으면 아코디언 토글 적용 -->
                                <a class="nav-link text-white fw-bold d-flex justify-content-between align-items-center" 
                                   data-bs-toggle="collapse" href="#menuCollapse${vs.index}" role="button" aria-expanded="false">
                                    <span><i class="fas ${not empty menu.iconClass ? menu.iconClass : 'fa-folder'}"></i> ${menu.menuNm}</span>
                                    <i class="fas fa-chevron-down" style="font-size: 0.8em;"></i>
                                </a>
                                <div class="collapse show" id="menuCollapse${vs.index}">
                                    <ul class="nav flex-column submenu">
                                        <c:forEach var="sub" items="${sidebarMenuList}">
                                            <c:if test="${sub.parentNo == menu.menuNo}">
                                                <li class="nav-item"><a class="nav-link" href="${sub.menuUrl}">${sub.menuNm}</a></li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <!-- 하위 메뉴가 없는 단일 메뉴 (예: 대시보드) -->
                                <a class="nav-link text-white fw-bold" href="${not empty menu.menuUrl ? menu.menuUrl : '#'}">
                                    <i class="fas ${not empty menu.iconClass ? menu.iconClass : 'fa-folder'}"></i> ${menu.menuNm}
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </li>
                </c:if>
            </c:forEach>

            <!-- (임시) 분석 요청 페이지 바로가기 링크 -->
            <li class="nav-item mt-2">
                <a class="nav-link text-white fw-bold" href="/finance/report">
                    <i class="fas fa-chart-line"></i> AI 분석 요청
                </a>
            </li>
        </ul>
    </div>
</div>

<!-- 메인 컨텐츠 영역 -->
<div class="main-content bg-light">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0 text-dark">📊 시스템 현황 대시보드</h2>
        <div>
            <span class="badge bg-success px-3 py-2 fs-6 rounded-pill shadow-sm me-2">
                <i class="fas fa-user-shield"></i> 권한 및 보안 활성화됨
            </span>
            <a href="/logout" class="btn btn-outline-danger btn-sm fw-bold"><i class="fas fa-sign-out-alt"></i> 로그아웃</a>
        </div>
    </div>

    <!-- 1. 경고 위젯 영역 -->
    <div class="row g-4 mb-4">
        <div class="col-md-6">
            <div class="card widget-card shadow-sm border-0 border-start border-danger border-5">
                <div class="card-body d-flex align-items-center">
                    <div class="icon-box bg-danger bg-opacity-10 text-danger me-3"><i class="fas fa-exclamation-triangle"></i></div>
                    <div>
                        <h6 class="text-muted fw-bold mb-1">안전재고 미달 품목</h6>
                        <h3 class="mb-0 text-danger fw-bold">${not empty lowStockList ? lowStockList.size() : 0} <small class="fs-6 text-muted">건</small></h3>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card widget-card shadow-sm border-0 border-start border-warning border-5">
                <div class="card-body d-flex align-items-center">
                    <div class="icon-box bg-warning bg-opacity-10 text-warning me-3"><i class="fas fa-clock"></i></div>
                    <div>
                        <h6 class="text-muted fw-bold mb-1">납기 지연 전표</h6>
                        <h3 class="mb-0 text-warning fw-bold">${not empty delayedOrderList ? delayedOrderList.size() : 0} <small class="fs-6 text-muted">건</small></h3>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 2. 상세 내역 테이블 영역 -->
    <div class="row g-4">
        <!-- 좌측: 안전재고 미달 목록 -->
        <div class="col-lg-6">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white py-3"><h5 class="card-title mb-0 fw-bold text-danger"><i class="fas fa-box-open"></i> 안전재고 조치 필요 (발주요망)</h5></div>
                <div class="card-body p-0">
                    <table class="table table-hover mb-0 text-center align-middle">
                        <thead class="table-light"><tr><th>품목코드</th><th>품목명</th><th>현재고</th><th>안전재고</th></tr></thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty lowStockList}">
                                    <tr><td colspan="4" class="py-4 text-muted">모든 품목의 재고가 안전합니다.</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="item" items="${lowStockList}">
                                        <tr><td class="fw-bold text-primary">${item.itemCd}</td><td>${item.itemNm}</td><td class="text-danger fw-bold">${item.stockQty}</td><td class="text-muted">${item.safeQty}</td></tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- 우측: 납기 지연 목록 -->
        <div class="col-lg-6">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white py-3"><h5 class="card-title mb-0 fw-bold text-warning"><i class="fas fa-truck-loading"></i> 납기 지연 / 출촉 필요</h5></div>
                <div class="card-body p-0">
                    <table class="table table-hover mb-0 text-center align-middle">
                        <thead class="table-light"><tr><th>전표번호</th><th>유형</th><th>상태</th><th>납기일</th></tr></thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty delayedOrderList}">
                                    <tr><td colspan="4" class="py-4 text-muted">지연된 전표가 없습니다.</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="order" items="${delayedOrderList}">
                                        <tr><td class="fw-bold text-primary">${order.orderNo}</td><td>${order.orderType == 'BUY' ? '발주' : '수주'}</td><td><span class="badge bg-secondary">${order.status}</span></td><td class="text-danger fw-bold">${order.dueDate}</td></tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
</div>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>