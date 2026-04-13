package com.ess.erp.domain;
import lombok.Data;

@Data
public class EmployeeDTO {
    private String empId;      // 사번
    private String empPw;	   // 비밀번호
    private String empName;    // 이름
    private String deptCode;   // 부서코드
    private String position;   // 직급
    private String useYn;	   // 퇴사 시 
    private String hireDate;   // REG_DT(입사일)
    private String modDt;      // MOD_DT (수정일)
}