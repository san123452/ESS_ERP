<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESS ERP - AI 데이터 분석 요청</title>
    <!-- Bootstrap 5 & FontAwesome -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Chart.js (주희님이 사용하실 라이브러리) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background-color: #f0f2f5; }
        .content-container { max-width: 1200px; margin: 40px auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .header-title { margin-bottom: 30px; padding-bottom: 10px; border-bottom: 2px solid #2c3e50; color: #2c3e50; }
    </style>
</head>
<body>
    <div class="content-container">
        <div class="d-flex justify-content-between align-items-center header-title">
            <h2 class="fw-bold m-0"><i class="fas fa-chart-line"></i> AI 데이터 분석 요청</h2>
            <!-- 대시보드로 돌아가는 버튼 -->
            <a href="/dashboard" class="btn btn-outline-secondary"><i class="fas fa-arrow-left"></i> 대시보드로 돌아가기</a>
        </div>

        <div class="row mb-4">
            <!-- 분석 요청(파일 업로드) 영역: 파이썬(FastAPI)과 연결될 부분 -->
            <div class="col-md-12">
                <div class="card shadow-sm border-0">
                    <div class="card-body">
                        <h5 class="card-title fw-bold mb-3">데이터 분석 실행</h5>
                        <p class="text-muted mb-3">버튼을 클릭하면 AI 서버가 실시간 DB 데이터를 바탕으로 분석을 수행합니다.</p>
                        <button class="btn btn-primary btn-lg" type="button" onclick="requestAnalysis()">
                            <i class="fas fa-robot"></i> AI 분석 요청하기
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- 주희님이 작업하실 차트 영역 -->
            <div class="col-md-12">
                <div class="card shadow-sm border-0">
                    <div class="card-body">
                        <h5 class="card-title fw-bold mb-3">분석 결과 차트</h5>
                        <!-- 차트가 그려질 캔버스 -->
                        <canvas id="analysisChart" height="100"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 주희님이 작업하실 Chart.js 기본 뼈대 코드
        const ctx = document.getElementById('analysisChart').getContext('2d');
        let analysisChart = new Chart(ctx, {
            type: 'bar',
            data: { labels: ['A', 'B', 'C'], datasets: [{ label: '샘플 데이터', data: [10, 20, 30] }] }
        });

        // 파이썬 FastAPI 서버와 통신하는 Fetch API 코드
        function requestAnalysis() {
            console.log('파이썬 서버에 분석 요청 중...');
            
            // 본인(파이썬 담당)이 설정한 분석 API 주소로 요청 (예: /analyze)
            fetch('http://localhost:8000/analyze', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({}) // 필요한 조건(예: 날짜 범위 등)이 있다면 여기에 넣어서 보냅니다.
            })
            .then(response => response.json())
            .then(data => {
                console.log('분석 결과:', data);
                alert('AI 분석이 완료되었습니다!');
                
                // 👉 [주희님 작업 구간] 파이썬에서 넘겨준 데이터를 변수에 담아 차트 업데이트
                // (아래 코드는 파이썬에서 {"labels": ["A","B"], "values": [100, 200]} 형태로 보냈다고 가정한 예시입니다)
                
                /*
                analysisChart.data.labels = data.labels; // X축 라벨 갱신
                analysisChart.data.datasets[0].data = data.values; // Y축 데이터 갱신
                analysisChart.update(); // 차트 새로고침 (애니메이션과 함께 스르륵 바뀜!)
                */
                
            })
            .catch(error => {
                console.error('Error:', error);
                alert('파이썬(FastAPI) 서버와 연결할 수 없습니다. 서버가 켜져 있는지 확인해 주세요.');
            });
        }
    </script>
    
    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>