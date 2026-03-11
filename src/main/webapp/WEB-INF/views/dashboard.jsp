<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - Dashboard</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; background-color: #f0f2f5; margin: 0; display: flex; }
    .sidebar { width: 250px; height: 100vh; background-color: #2c3e50; color: white; padding: 20px; box-sizing: border-box; }
    .main-content { flex: 1; padding: 40px; }
    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    .welcome-msg { font-size: 24px; color: #333; font-weight: bold; }
    .status-badge { display: inline-block; padding: 5px 15px; background-color: #27ae60; color: white; border-radius: 20px; font-size: 14px; }
    .logout-btn { color: #e74c3c; text-decoration: none; font-weight: bold; }
</style>
</head>
<body>

<div class="sidebar">
    <h2>🏢 ESS ERP</h2>
    <hr>
    <p>생산/보안 관리 (강산)</p>
    <ul style="list-style: none; padding: 0; line-height: 2.5;">
        <li>📊 대시보드</li>
        <li>📦 품목 관리</li>
        <li>⚙️ BOM 관리</li>
        <li>🔒 권한 설정</li>
    </ul>
</div>

<div class="main-content">
    <div class="header">
        <div class="welcome-msg">
            안녕하세요, <span style="color: #4A90E2;">강산 조장님!</span> 👋
        </div>
        <a href="/logout" class="logout-btn">로그아웃</a>
    </div>

    <div class="card">
        <h3>🚀 시스템 상륙 성공!</h3>
        <p>현재 <span class="status-badge">보안 모드 활성화(Security OK)</span> 상태입니다.</p>
        <p>로그인 세션이 정상적으로 생성되어 <strong>/dashboard</strong> 경로로 진입하였습니다.</p>
        <hr>
        <p style="color: #666; font-size: 14px;">이제 팀원들이 올 수 있도록 깃허브에 마지막으로 푸시하고 퇴근하시면 됩니다.</p>
    </div>
</div>

</body>
</html>