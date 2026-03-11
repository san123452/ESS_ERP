package com.ess.erp.service;

import com.ess.erp.domain.UserDTO;
import com.ess.erp.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.core.userdetails.User; // 시큐리티 전용 User 임포트
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String empId) throws UsernameNotFoundException {
        // 1. DB에서 사용자 정보 가져오기
        UserDTO user = userMapper.findByEmpId(empId);
        
        if (user == null) {
            throw new UsernameNotFoundException("존재하지 않는 사번입니다: " + empId);
        }

        // 2. 시큐리티 전용 User 객체 생성 (가장 안전한 문법)
        return User.withUsername(user.getEmpId())
                .password(user.getEmpPw()) // DB에 저장된 암호화된 비번
                .roles(user.getRole().replace("ROLE_", "")) // 'ROLE_' 접두어 제거
                .build();
    }
}