<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - Login</title>
<style>
    /* 간단하고 깔끔한 ERP 스타일 디자인 */
    body { font-family: 'Segoe UI', sans-serif; background-color: #f4f7f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
    .login-container { background-color: #fff; padding: 40px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); width: 350px; text-align: center; }
    h2 { color: #333; margin-bottom: 30px; }
    .input-group { margin-bottom: 20px; text-align: left; }
    .input-group label { display: block; margin-bottom: 5px; color: #666; font-size: 14px; }
    .input-group input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
    .login-btn { width: 100%; padding: 12px; background-color: #4A90E2; border: none; border-radius: 4px; color: white; font-size: 16px; cursor: pointer; transition: background 0.3s; }
    .login-btn:hover { background-color: #357ABD; }
    .footer { margin-top: 20px; font-size: 12px; color: #aaa; }
</style>
</head>
<body>

<div class="login-container">
    <h2>🏢 ESS ERP System</h2>
    
   <form action="/loginProc" method="post">
        
        <div class="input-group">
            <label for="empId">ID (사번)</label>
            <input type="text" id="empId" name="empId" placeholder="아이디를 입력하세요" required>
        </div>
        
        <div class="input-group">
            <label for="empPw">Password</label>
            <input type="password" id="empPw" name="empPw" placeholder="비밀번호를 입력하세요" required>
        </div>
        
        <button type="submit" class="login-btn">로그인</button>
    </form>

    <div class="footer">
        © 2026 ESS ERP Project Team. All Rights Reserved.
    </div>
</div>

</body>
</html>