package com.ess.erp.domain;
import lombok.Data;

@Data
public class UserDTO {
    private String userId;      // 로그인ID
    private String userPw;      // 비밀번호
    private String empId;       // 사번 (Employee 연동)
    private String role;        // 권한 (ADMIN/USER)
}