<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 사원 상세</title>
<link rel="stylesheet" href="/css/common.css">
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; }
    .header { background: #2c3e50; color: white; padding: 10px; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }
    th { background-color: #f8f9fa; color: #333; width: 30%; }
    .btn { padding: 9px 24px; border-radius: 6px; font-size: 14px; cursor: pointer; text-decoration: none; display: inline-block; }
    .btn-update { background: #2c3e50; color: white; border: none; }
    .btn-delete { background: #e74c3c; color: white; border: none; }
    .btn-list { background: #f8f9fa; color: #333; border: 1px solid #ddd; }
    input[type=text], select { width: 100%; padding: 6px; border: 1px solid #ddd; border-radius: 4px; }
</style>
</head>
<body>
    <div class="header">
        <h1>[인사] 사원 상세</h1>
    </div>

    <!-- 상세조회 테이블 -->
    <div id="viewMode">
        <table>
            <tr>
                <th>사번</th>
                <td>${emp.empId}</td>
            </tr>
            <tr>
                <th>이름</th>
                <td>${emp.empName}</td>
            </tr>
            <tr>
                <th>소속부서</th>
                <td>
                    <c:choose>
                        <c:when test="${emp.deptCode == 'D001'}">인사팀</c:when>
                        <c:when test="${emp.deptCode == 'D002'}">생산팀</c:when>
                        <c:when test="${emp.deptCode == 'D003'}">영업팀</c:when>
                        <c:when test="${emp.deptCode == 'D004'}">물류팀</c:when>
                        <c:otherwise>${emp.deptCode}</c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>직급</th>
                <td>${emp.position}</td>
            </tr>
            <tr>
                <th>입사일</th>
                <td>${emp.hireDate}</td>
            </tr>
        </table>
        <br>
        <button class="btn btn-update" onclick="enableEdit()">수정</button>
        <button class="btn btn-delete" onclick="enableDelete()">퇴사처리</button>
        <a class="btn btn-update" href="/hr/role/manage?empId=${emp.empId}">권한 관리</a>
        <a class="btn btn-list" href="/hr/employee/list">목록으로</a>
    </div>

    <!-- 수정 폼 -->
    <div id="editMode" style="display:none;">
        <form action="/hr/employee/update" method="post">
            <input type="hidden" name="empId" value="${emp.empId}"/>
            <table>
                <tr>
                    <th>사번</th>
                    <td>${emp.empId}</td>
                </tr>
                <tr>
                    <th>이름</th>
                    <td><input type="text" name="empName" value="${emp.empName}"/></td>
                </tr>
                <tr>
                    <th>비밀번호 변경</th>
                    <td><input type="password" name="empPw" placeholder="변경 시에만 입력 (미입력시 유지)"/></td>
                </tr>
                <tr>
                    <th>소속부서</th>
                    <td>
                        <select name="deptCode">
                            <option value="">부서 선택</option>
                            <option value="D001" ${emp.deptCode == 'D001' ? 'selected' : ''}>인사팀</option>
                            <option value="D002" ${emp.deptCode == 'D002' ? 'selected' : ''}>생산팀</option>
                            <option value="D003" ${emp.deptCode == 'D003' ? 'selected' : ''}>영업팀</option>
                            <option value="D004" ${emp.deptCode == 'D004' ? 'selected' : ''}>물류팀</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th>직급</th>
                    <td>
                        <select name="position">
                            <option value="">직급 선택</option>
                            <option value="사원" ${emp.position == '사원' ? 'selected' : ''}>사원</option>
                            <option value="대리" ${emp.position == '대리' ? 'selected' : ''}>대리</option>
                            <option value="과장" ${emp.position == '과장' ? 'selected' : ''}>과장</option>
                            <option value="부장" ${emp.position == '부장' ? 'selected' : ''}>부장</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th>재직여부</th>
                    <td>
                        <select name="useYn">
                            <option value="Y" ${emp.useYn == 'Y' ? 'selected' : ''}>재직</option>
                            <option value="N" ${emp.useYn == 'N' ? 'selected' : ''}>퇴사</option>
                        </select>
                    </td>
                </tr>
            </table>
            <br>
            <button type="submit" class="btn btn-update">저장</button>
            <button type="button" class="btn btn-list" onclick="disableEdit()">취소</button>
        </form>
    </div>

    <!-- 퇴사처리 폼 -->
    <form id="deleteForm" action="/hr/employee/delete" method="post">
        <input type="hidden" name="empId" value="${emp.empId}"/>
    </form>

    <script>
    function enableEdit() {
        document.getElementById('viewMode').style.display = 'none';
        document.getElementById('editMode').style.display = 'block';
    }
    function disableEdit() {
        document.getElementById('editMode').style.display = 'none';
        document.getElementById('viewMode').style.display = 'block';
    }
    function enableDelete() {
        if(confirm("정말 퇴사처리 하시겠습니까?")) {
            document.getElementById('deleteForm').submit();
        }
    }
    </script>
</body>
</html>
