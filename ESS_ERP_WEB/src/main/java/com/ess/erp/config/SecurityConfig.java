package com.ess.erp.config;

import jakarta.servlet.DispatcherType; // ★★★ 이거 무조건 있어야 합니다!
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                // ★★★ [가장 중요] JSP로 화면을 넘겨주는(FORWARD) 내부 통신을 허용하라! ★★★
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                
                // 대문과 로그인 처리 경로는 무조건 통과!
                .requestMatchers("/", "/loginProc", "/css/**", "/js/**", "/images/**").permitAll()
                // 나머지는 로그인 필수
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/")               
                .loginProcessingUrl("/loginProc")
                .usernameParameter("empId")    // index.jsp의 name="empId"와 완벽 일치!
                .passwordParameter("empPw")    // index.jsp의 name="empPw"와 완벽 일치!
                .defaultSuccessUrl("/dashboard", true) 
                .permitAll()
            )
            .logout(logout -> logout
                .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))
                .logoutSuccessUrl("/")
                .permitAll()
            );

        return http.build();
    }
}