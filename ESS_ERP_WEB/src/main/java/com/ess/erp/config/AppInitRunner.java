package com.ess.erp.config;

import com.ess.erp.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class AppInitRunner implements CommandLineRunner {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("====> [시스템 초기화] 계정 생성 로직 시작...");

        String empId = "2026001";
        String rawPw = "1234"; // 우리가 쓸 비번
        String encodedPw = passwordEncoder.encode(rawPw); // 자바가 직접 암호화!

        // 혹시 모르니 DB에서 기존 유저 삭제 후 깔끔하게 다시 넣기
        // (주의: UserMapper에 deleteByEmpId와 insertUser가 있어야 합니다. 
        // 만약 없다면 아래 SQL 주석을 참고해서 수동으로 처리하거나 알려주세요!)
        
        System.out.println("====> [암호화 완료] 생성된 해시값: " + encodedPw);
        System.out.println("====> 이 값을 메모장에 복사해두세요! 나중에 DB랑 비교해봅시다.");
        
        // 조장님, 만약 Mapper에 등록/수정 메서드 만들기 번거로우시면 
        // 그냥 콘솔에 찍힌 'encodedPw' 값을 복사해서 HeidiSQL에 한 번만 더 넣어보세요.
        // 자바가 직접 만든 값이라 이번엔 무조건 일치할 겁니다.
    }
}