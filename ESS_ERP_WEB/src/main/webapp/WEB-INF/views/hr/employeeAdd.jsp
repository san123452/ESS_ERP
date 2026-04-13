<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 사원 등록</title>
<link rel="stylesheet" href="/css/common.css">
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background: #f5f5f5; }
    .form-wrap { max-width: 600px; margin: 0 auto; }
    .form-header { background: #2c3e50; color: white; padding: 14px 20px; border-radius: 8px 8px 0 0; }
    .form-header h2 { margin: 0; font-size: 16px; font-weight: 500; }
    .form-card { background: white; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 8px 8px; padding: 1.5rem; }
    .form-row { display: grid; grid-template-columns: 140px 1fr; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
    .form-row:last-of-type { border-bottom: none; }
    .form-label { font-size: 13px; color: #666; font-weight: 500; }
    .form-input, .form-select { width: 100%; padding: 8px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; background: #fafafa; box-sizing: border-box; outline: none; }
    .form-input:focus, .form-select:focus { border-color: #2c3e50; background: white; }
    .btn-row { display: flex; gap: 8px; margin-top: 1.25rem; justify-content: flex-end; }
    .btn-save { padding: 9px 24px; background: #2c3e50; color: white; border: none; border-radius: 6px; font-size: 14px; cursor: pointer; }
    .btn-cancel { padding: 9px 24px; background: #f5f5f5; color: #666; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; cursor: pointer; }
</style>
</head>
<body>
<div class="form-wrap">
    <div class="form-header"><h2>[인사] 사원 등록</h2></div>
    <form action="/hr/employee/add" method="post">
    <div class="form-card">
        <div class="form-row">
            <span class="form-label">사번</span>
            <input class="form-input" type="text" name="empId" placeholder="사번을 입력하세요" />
        </div>
        <div class="form-row">
            <span class="form-label">이름</span>
            <input class="form-input" type="text" name="empName" placeholder="이름을 입력하세요" />
        </div>
        <div class="form-row">
            <span class="form-label">초기 비밀번호</span>
            <input class="form-input" type="password" name="empPw" placeholder="비밀번호를 입력하세요" />
        </div>
        <div class="form-row">
            <span class="form-label">부서</span>
            <select class="form-select" name="deptCode">
                <option value="">부서 선택</option>
                <option value="D001">인사팀</option>
                <option value="D002">생산팀</option>
                <option value="D003">영업팀</option>
                <option value="D004">물류팀</option>
            </select>
        </div>
        <div class="form-row">
            <span class="form-label">직급</span>
            <select class="form-select" name="position">
                <option value="">직급 선택</option>
                <option value="사원">사원</option>
                <option value="대리">대리</option>
                <option value="과장">과장</option>
                <option value="부장">부장</option>
            </select>
        </div>
        <div class="form-row">
            <span class="form-label">재직여부</span>
            <select class="form-select" name="useYn">
                <option value="Y">재직</option>
                <option value="N">퇴사</option>
            </select>
        </div>
        <div class="btn-row">
            <button type="button" class="btn-cancel" onclick="location.href='/hr/employee/list'">취소</button>
            <button type="submit" class="btn-save">등록</button>
        </div>
    </div>
    </form>
</div>
</body>
</html>