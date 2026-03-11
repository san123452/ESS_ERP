package com.ess.erp.service;

import com.ess.erp.domain.UserDTO;
import com.ess.erp.mapper.UserMapper;
import jakarta.annotation.PostConstruct; // 추가
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate; // 추가
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private JdbcTemplate jdbcTemplate; // DB에 직접 꽂기 위한 도구

    // [필살기] 서버가 켜질 때 실행되는 메서드
    @PostConstruct
    public void initAccount() {
        System.out.println("====> [시스템 초기화] 2026001 계정 비번 강제 동기화 시작...");
        try {
            String encodedPw = passwordEncoder.encode("1234"); // 자바가 직접 암호화
            jdbcTemplate.update("UPDATE TB_EMP SET EMP_PW = ? WHERE EMP_ID = '2026001'", encodedPw);
            System.out.println("====> [성공] DB에 자바 표준 암호화 값이 저장되었습니다.");
        } catch (Exception e) {
            System.out.println("====> [실패] 초기화 중 에러: " + e.getMessage());
        }
    }

    @Override
    public UserDetails loadUserByUsername(String empId) throws UsernameNotFoundException {
        System.out.println("====> [Login 시도] 사번: " + empId);

        UserDTO user = userMapper.findByEmpId(empId);
        
        if (user == null) {
            System.out.println("====> [에러] DB에서 사원 정보를 찾을 수 없습니다.");
            throw new UsernameNotFoundException("존재하지 않는 사번입니다: " + empId);
        }

        String dbPw = user.getEmpPw();
        
        // 실제 일치 여부 테스트 로그
        boolean matches = passwordEncoder.matches("1234", dbPw);
        System.out.println("====> [최종 매칭 테스트]: " + (matches ? "성공(MATCH!)" : "실패(MISMATCH)"));

        String roleName = (user.getRole() != null) ? user.getRole() : "ROLE_USER";
        String cleanRole = roleName.replace("ROLE_", "");

        return User.withUsername(user.getEmpId())
                .password(dbPw)
                .roles(cleanRole)
                .build();
    }
}