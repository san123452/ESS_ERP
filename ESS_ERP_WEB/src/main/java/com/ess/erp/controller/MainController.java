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

    // 3. 분석 요청 페이지 연결
    @GetMapping("/data/analyze")
    public String analysisPage() {
        return "data/analysisRequest"; // /WEB-INF/views/data/analysisRequest.jsp 호출 (JSP 파일명은 실제 파일에 맞게 수정)
    }

    // 4. 주희님이 작업하시는 재무/분석 리포트 페이지 연결
    @GetMapping("/finance/report")
    public String financeReport() {
        return "finance/report"; // /WEB-INF/views/finance/report.jsp 호출
    }
}