<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS ERP - 사원 권한 관리</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; padding: 20px; background: #f5f5f5; }
    .form-wrap { max-width: 600px; margin: 0 auto; }
    .form-header { background: #2c3e50; color: white; padding: 14px 20px; border-radius: 8px 8px 0 0; }
    .form-header h2 { margin: 0; font-size: 16px; font-weight: 500; }
    .form-card { background: white; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 8px 8px; padding: 1.5rem; }

    /* 테이블 */
    table { width: 100%; border-collapse: collapse; margin-bottom: 1.25rem; }
    thead tr { background: #2c3e50; color: white; }
    th { padding: 10px 14px; font-size: 13px; font-weight: 500; text-align: center; }
    td { padding: 10px 14px; font-size: 14px; text-align: center; border-bottom: 1px solid #f0f0f0; }
    tbody tr:hover { background: #f9f9f9; }

    /* 기본 권한 행 */
    .default-row td { color: #aaa; background: #fafafa; }

    /* 기본 권한 뱃지 */
    .badge { font-size: 11px; background: #ecf0f1; color: #999; padding: 2px 8px; border-radius: 10px; margin-left: 6px; }

    /* 버튼 */
    .btn-row { display: flex; gap: 8px; justify-content: flex-end; }
    .btn-save { padding: 9px 24px; background: #2c3e50; color: white; border: none; border-radius: 6px; font-size: 14px; cursor: pointer; }
    .btn-cancel { padding: 9px 24px; background: #f5f5f5; color: #666; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; cursor: pointer; }

    /* 사원 ID */
    .emp-info { font-size: 13px; color: #666; margin-bottom: 1rem; }
</style>
</head>
<body>

<div class="form-wrap">
    <div class="form-header"><h2>[인사] 사원 권한 관리</h2></div>

    <form action="/hr/role/update" method="post">
    <input type="hidden" name="empId" value="${empId}" />

    <div class="form-card">

        <p class="emp-info">사원 ID : <strong>${empId}</strong></p>

        <table>
            <thead>
                <tr>
                    <th>역할코드</th>
                    <th>역할명</th>
                    <th>권한 보유</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="role" items="${roleList}">
                    <tr class="${role.IS_DEFAULT == 'Y' ? 'default-row' : ''}">
                        <td>${role.ROLE_CD}</td>
                        <td>
                            ${role.ROLE_NM}
                            <c:if test="${role.IS_DEFAULT == 'Y'}">
                                <span class="badge">기본 권한</span>
                            </c:if>
                        </td>
                        <td>
                            <input type="checkbox" name="roleCdList" value="${role.ROLE_CD}"
                                <c:if test="${role.HAS_ROLE == 'Y'}">checked</c:if>
                                <c:if test="${role.IS_DEFAULT == 'Y'}">disabled</c:if>
                            />
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div class="btn-row">
            <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
            <button type="submit" class="btn-save">저장</button>
        </div>

    </div>
    </form>
</div>

</body>
</html>