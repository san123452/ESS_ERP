package com.ess.erp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainController {

    // 1. 루트 주소(/)로 접속하면 로그인 페이지(index.jsp)를 보여줌
    @GetMapping("/")
    public String login() {
        return "index"; // src/main/webapp/WEB-INF/views/index.jsp를 호출
    }

}