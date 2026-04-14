<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - 재무제표</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; display: flex; height: 100vh; overflow: hidden; margin: 0; }
        .sidebar { width: 260px; background-color: #2c3e50; color: white; display: flex; flex-direction: column; }
        .sidebar .nav-link { color: rgba(255,255,255,.8); transition: 0.3s; padding: 10px 20px; display: flex; align-items: center; gap: 10px; }
        .sidebar .nav-link:hover { color: white; background-color: #34495e; }
        .sidebar .nav-item .submenu .nav-link { padding-left: 50px; font-size: 0.9em; }
        .main-content { flex-grow: 1; overflow-y: auto; padding: 30px; }
    </style>
	<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<!-- 사이드바 -->
<div class="sidebar shadow">
    <div class="p-4 text-center border-bottom border-secondary">
        <h4 class="m-0 fw-bold"><i class="fas fa-industry text-primary"></i> ESS ERP</h4>
        <small class="text-white-50">Enterprise System</small>
    </div>
    <div class="flex-grow-1 overflow-auto py-3">
        <ul class="nav flex-column mb-auto">
            <c:forEach var="menu" items="${sidebarMenuList}" varStatus="vs">
                <c:if test="${empty menu.parentNo}">
                    <c:set var="hasSub" value="false"/>
                    <c:forEach var="checkSub" items="${sidebarMenuList}">
                        <c:if test="${checkSub.parentNo == menu.menuNo}"><c:set var="hasSub" value="true"/></c:if>
                    </c:forEach>
                    <li class="nav-item mt-2">
                        <c:choose>
                            <c:when test="${hasSub}">
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
                                <a class="nav-link text-white fw-bold" href="${not empty menu.menuUrl ? menu.menuUrl : '#'}">
                                    <i class="fas ${not empty menu.iconClass ? menu.iconClass : 'fa-folder'}"></i> ${menu.menuNm}
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </li>
                </c:if>
            </c:forEach>
        </ul>
    </div>
</div>

<!-- 메인 컨텐츠 -->
<div class="main-content bg-light">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0 text-dark">📈 재무제표 생성</h2>
        <a href="/logout" class="btn btn-outline-danger btn-sm fw-bold"><i class="fas fa-sign-out-alt"></i> 로그아웃</a>
    </div>

    <!-- 안내 카드 -->
    <div class="row g-4 mb-4">
        <div class="col-md-4">
            <div class="card shadow-sm border-0 border-start border-primary border-5">
                <div class="card-body">
                    <h6 class="text-muted fw-bold mb-1"><i class="fas fa-chart-line text-primary"></i> 매출 데이터</h6>
                    <p class="mb-0 text-muted small">수주 전표 기반 매출 집계</p>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card shadow-sm border-0 border-start border-success border-5">
                <div class="card-body">
                    <h6 class="text-muted fw-bold mb-1"><i class="fas fa-shopping-cart text-success"></i> 매입 데이터</h6>
                    <p class="mb-0 text-muted small">발주 전표 기반 매입 집계</p>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card shadow-sm border-0 border-start border-danger border-5">
                <div class="card-body">
                    <h6 class="text-muted fw-bold mb-1"><i class="fas fa-exclamation-triangle text-danger"></i> 불량 손실</h6>
                    <p class="mb-0 text-muted small">생산 실적 기반 손실액 집계</p>
                </div>
            </div>
        </div>
    </div>

    <!-- 요청 카드 -->
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white py-3">
            <h5 class="card-title mb-0 fw-bold"><i class="fas fa-file-excel text-success"></i> 재무제표 엑셀 생성</h5>
        </div>
        <div class="card-body text-center py-5">
            <p class="text-muted mb-4">DB 데이터를 분석하여 손익계산서(P&L) 형태의 엑셀 파일을 생성합니다.</p>
			<c:if test="${param.analyzed == 'true'}">
			    <script>alert('데이터 분석이 완료되었습니다!');</script>
			</c:if>
			<c:if test="${param.error == 'true'}">
			    <script>alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');</script>
			</c:if>
            <div class="d-flex justify-content-center gap-3 mb-4">
            <!-- 1단계: 분석 요청 -->
		    <form action="/finance/report/analyze" method="post">
		        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
		        <button type="submit" class="btn btn-primary btn-lg px-5">
		            <i class="fas fa-search me-2"></i> 1단계: 데이터 분석 요청
		        </button>
		    </form>
		    <!-- 2단계: 엑셀 다운로드 -->
		    <form action="/finance/report/download" method="post">
		        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
		        <button type="submit" class="btn btn-success btn-lg px-5">
		            <i class="fas fa-file-excel me-2"></i> 2단계: 엑셀 다운로드
		        </button>
		    </form>
		</div>
				<!-- 버튼 아래에 차트 표시 -->
				<c:if test="${result != null}">
				    <div class="row g-3">
				    <!-- 월별 손익 -->
					    <div class="col-md-6">
					        <div class="card border-0 shadow-sm">
					            <div class="card-header bg-white fw-bold">📊 월별 순이익 (억원 단위)</div>
					            <div class="card-body">
					                <canvas id="monthlyChart" height="150"></canvas>
					            </div>
					        </div>
					    </div>
					    <!-- AI 장기 예측 -->
					    <div class="col-md-6">
					        <div class="card border-0 shadow-sm">
					            <div class="card-header bg-white fw-bold">🔮 AI 장기 예측 매출 / 이익 (억원 단위)</div>
					            <div class="card-body">
					                <canvas id="forecastChart" height="150"></canvas>
					            </div>
					        </div>
					    </div>
					</div>
					<!-- 분기별 이익률 + ai예측 이익률 -->
					<div class="col-md-12 mt-3">
					    <div class="card border-0 shadow-sm">
					        <div class="card-header bg-white fw-bold">📊 분기별 실적 + AI 예측</div>
					        <div class="card-body">
					            <canvas id="quarterlyChart" height="80"></canvas>
					        </div>
					    </div>
					</div>
				    <script>
				    // 월별 손익
				    const monthly = [
				        <c:forEach var="m" items="${result.monthly_performance}" varStatus="vs">
				            { month: '${m.month}', profit: ${m.profit} }<c:if test="${!vs.last}">,</c:if>
				        </c:forEach>
				    ];
				    new Chart(document.getElementById('monthlyChart'), {
				        type: 'bar',
				        data: {
				            labels: monthly.map(d => d.month.substring(2).replace('-', '.')),
				            datasets: [{ 
				                label: '월별 이익 (원)', 
				                data: monthly.map(d => d.profit), // profit 매출이익률
				                backgroundColor: monthly.map(d => d.profit >= 0 ? 'rgba(54,162,235,0.6)' : 'rgba(255,99,132,0.6)')
				            }]
				        },
				        options: {
				            plugins: {
				                tooltip: {
				                    callbacks: {
				                        label: ctx => '이익: ' + (ctx.raw / 100000000).toFixed(1) + '억원'
				                    }
				                }
				            },
				            scales: {
				                y: {
				                    ticks: {
				                        callback: val => (val / 100000000).toFixed(0) + '억'
				                    }
				                }
				            }
				        }
				    });
				
				    // AI 장기 예측
				    const forecast = [
				        <c:forEach var="f" items="${result.long_term_forecast}" varStatus="vs">
				            { month: '${f.month}', revenue: ${f.predicted_revenue}, profit: ${f.predicted_profit} }<c:if test="${!vs.last}">,</c:if>
				        </c:forEach>
				    ];
				    new Chart(document.getElementById('forecastChart'), {
				        type: 'line',
				        data: {
				            labels: forecast.map(d => d.month.substring(2).replace('-', '.')),
				            datasets: [
				                { label: '예측 매출', data: forecast.map(d => d.revenue), borderColor: 'rgba(54,162,235,1)', tension: 0.3 },
				                { label: '예측 이익', data: forecast.map(d => d.profit), borderColor: 'rgba(75,192,192,1)', tension: 0.3 }
				            ]
				        },
				        options: {
				            scales: {
				                y: {
				                    ticks: {
				                        callback: val => (val / 100000000).toFixed(0) + '억'
				                    }
				                }
				            }
				        }
				    });
				    // 분기별 이익률 + AI예측
				    const quarterly = [
				        <c:forEach var="q" items="${result.quarterly_chart}" varStatus="vs">
				            { label: '${q.label}', profit: ${q.profit}}<c:if test="${!vs.last}">,</c:if>
				        </c:forEach>
				    ];

				    new Chart(document.getElementById('quarterlyChart'), {
				        type: 'bar',
				        data: {
				        	labels: quarterly.map(d => d.label.replace('2023년', '23년').replace('2024년', '24년').replace('2025년', '25년').replace('2026년', '26년')),
				            datasets: [
				                {
				                    label: '분기별 매출이익',
				                    data: quarterly.map(d => d.profit),
				                    backgroundColor: quarterly.map(d => 
				                    d.label.includes('예측') ? 'rgba(255,159,64,0.6)' :  // 예측 → 주황색
				                    d.profit >= 0 ? 'rgba(54,162,235,0.6)' :              // 이익 → 파란색
				                    'rgba(255,99,132,0.6)'                                 // 손실 → 빨간색
				                )
				                }
				            ]
				        },
				        options: {
				            scales: {
				                y: {
				                    ticks: {
				                        callback: val => (val / 100000000).toFixed(0) + '억'
				                    }
				                }
				            }
				        }
				    });
				    </script>
				</c:if>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>