package com.ess.erp.domain;

import java.util.List;

public class UserDTO {
    private String empId;
    private String empPw;
    private String empName;
    private List<String> roles; // 다중 권한 저장을 위해 List로 변경

    // 롬복 없이 직접 만드는 Getter / Setter
    public String getEmpId() { return empId; }
    public void setEmpId(String empId) { this.empId = empId; }
    public String getEmpPw() { return empPw; }
    public void setEmpPw(String empPw) { this.empPw = empPw; }
    public String getEmpName() { return empName; }
    public void setEmpName(String empName) { this.empName = empName; }
    public List<String> getRoles() { return roles; }
    public void setRoles(List<String> roles) { this.roles = roles; }
}