package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class StockController {

    @Autowired
    private StockService stockService;

    // 입고 확정 처리 (재고 반영 및 수불 로그 기록)
    @GetMapping("/logis/order/confirm")
    public String inbound(@RequestParam("no") String orderNo) {
        
        // 스프링 시큐리티 Principal 추출 (현재 로그인한 사원 ID)
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String empId = (auth != null) ? auth.getName() : "SYSTEM";

        // 재고 수불 및 상태 변경 서비스 호출
        stockService.processInbound(orderNo, empId);
        
        // 처리 완료 후 발주 목록으로 이동
        return "redirect:/logis/order/list";
    }
}