package com.ess.erp.domain;

public class UserDTO {
    private String empId;
    private String empPw;
    private String empName;
    private String role;

    // 롬복 없이 직접 만드는 Getter / Setter
    public String getEmpId() { return empId; }
    public void setEmpId(String empId) { this.empId = empId; }
    public String getEmpPw() { return empPw; }
    public void setEmpPw(String empPw) { this.empPw = empPw; }
    public String getEmpName() { return empName; }
    public void setEmpName(String empName) { this.empName = empName; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}