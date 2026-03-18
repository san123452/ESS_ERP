package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.ui.Model;
import com.ess.erp.mapper.StockMapper;

/**
 * [물류/재고 관리 컨트롤러]
 * 발주 입고 확정 및 수주 출고 처리를 담당합니다.
 */
@Controller
public class StockController {

    @Autowired
    private StockService stockService;
    
    @Autowired
    private StockMapper stockMapper;

    /**
     * 발주 전표 입고 확정 처리
     * URL: /logis/order/confirm?no=PO-2026...
     * JSP에서 location.href(GET방식)로 호출하므로 @GetMapping 사용
     */
    @GetMapping("/logis/stock/confirm")
    public String inboundConfirm(@RequestParam("no") String orderNo, RedirectAttributes rttr) {
        // 1. [보안] : 시큐리티 세션에서 현재 로그인한 사원번호(ID) 추출
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String empId = null;
        if (auth != null && auth.isAuthenticated() && !auth.getName().equals("anonymousUser")) {
            empId = auth.getName();
        }
        
        // 2. 서비스 호출: 재고 증가 + 수불 로그 기록 + 전표 완료 처리
        stockService.processInbound(orderNo, empId);
        // 3. 알림 메시지 전달 (일회성 메시지)
        rttr.addFlashAttribute("msg", "성공적으로 입고 처리가 완료되었습니다.");
        // 4. 리다이렉트: 다시 발주 목록 페이지로 이동
        return "redirect:/logis/order/list";
    }

    /**
     * 수주 전표 출고 확정 처리
     * URL: /logis/stock/outbound
     * 보안 및 데이터 변경을 위해 <form> 태그의 POST 방식으로 수신 권장
     */
    @PostMapping("/logis/stock/outbound")
    public String outboundConfirm(@RequestParam("orderNo") String orderNo, RedirectAttributes rttr) {
        // 1. [보안] 현재 처리 중인 담당자 ID 추출
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String empId = null;
        if (auth != null && auth.isAuthenticated() && !auth.getName().equals("anonymousUser")) {
            empId = auth.getName();
        }
        
        try {
            // 2. 서비스 호출: 재고 검증 + 재고 차감 + 수불 로그 + 전표 완료
            stockService.processOutbound(orderNo, empId);
            // 3. 성공 시 메시지
            rttr.addFlashAttribute("msg", "출고 처리가 완료되었습니다."); 
        } catch (RuntimeException e) {
            // 4. [에러 처리] 서비스에서 "재고 부족" 예외가 발생하면 메시지를 가로채서 화면에 전달
            // e.getMessage()에는 "재고가 부족합니다..." 라는 문자열이 담겨 있음
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        // 5. 리다이렉트: 영업팀 수주 목록 페이지로 이동
        return "redirect:/logis/order/sell/list";
    }

    @GetMapping("/stock/list")
    public String stockList(Model model) {
        model.addAttribute("stockList", stockMapper.selectStockList());
        return "logistics/stockList";
    }

    @GetMapping("/stock/log/list")
    public String stockLogList(Model model) {
        model.addAttribute("logList", stockMapper.selectStockLogList());
        return "logistics/stockLogList";
    }
}