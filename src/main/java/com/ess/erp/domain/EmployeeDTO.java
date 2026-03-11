package com.ess.erp.domain;
import lombok.Data;

@Data
public class EmployeeDTO {
    private String empId;      // 사번
    private String empName;    // 이름
    private String deptCode;   // 부서코드
    private String position;   // 직급
    private String hireDate;   // 입사일
    private String phone;      // 연락처
}