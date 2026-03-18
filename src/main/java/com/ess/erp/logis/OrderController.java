package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.ess.erp.domain.OrderDTO;
import java.util.List;

@Controller
@RequestMapping("/logis/order")
public class OrderController {

    @Autowired
    private OrderService orderService;
    @Autowired
    private ClientService clientService; 

    /* =================================================================
     * 발주(구매/입고) 관련 매핑
     * ================================================================= */
    /** 발주 전표 등록 폼 이동 */
    @GetMapping("/add")
    public String addForm(Model model) {
        model.addAttribute("clientList", clientService.getClientListByType("IN"));
        model.addAttribute("itemList", orderService.getItemList()); 
        return "logistics/orderAdd";
        }
    /** 발주 전표 저장 처리 */
    @PostMapping("/add")
    public String addProcess(@ModelAttribute OrderDTO dto) {
        orderService.registerOrder(dto);
        return "redirect:/logis/order/list";
    }
    /** 발주(구매) 전표 목록 조회 */
    @GetMapping("/list")
    public String list(Model model) {
        model.addAttribute("orderList", orderService.getOrderList());
        return "logistics/orderList";
    }
    /** 입고 확정 처리 (실재고 반영) */
    @GetMapping("/confirm")
    public String inboundConfirm(@RequestParam("no") String orderNo, RedirectAttributes rttr) {
        orderService.confirmOrder(orderNo);
        rttr.addFlashAttribute("msg", "입고 처리가 완료되었습니다.");
        return "redirect:/logis/order/list";
    }

    /* =================================================================
     * 수주(판매/출고) 관련 매핑
     * ================================================================= */
    
    /** 수주(판매) 전표 등록 폼 이동 */
    @GetMapping("/sell/add")
    public String sellAddForm(Model model) {
        // 거래처 목록과 품목 목록을 뷰에 전달
    	model.addAttribute("clientList", clientService.getClientListByType("OUT"));
        model.addAttribute("itemList", orderService.getItemList()); 
        return "logistics/orderSellAdd";
    }

    /** 수주(판매) 전표 저장 처리 */
    @PostMapping("/sell/add")
    public String sellAddProcess(@ModelAttribute OrderDTO dto) {
        // Service 내에서 TYPE을 'SELL'로 처리하는 로직 호출
        orderService.registerSellOrder(dto);
        return "redirect:/logis/order/sell/list";
    }
    /** 수주(판매) 전표 상세보기 매핑 */
    @GetMapping("/sell/detail")
    public String sellOrderDetail(@RequestParam("no") String orderNo, Model model) {
        // 기존에 만들어둔 getOrderDetail 재활용 (XML에서 ResultMap으로 상세 품목까지 가져옴)
        OrderDTO order = orderService.getOrderDetail(orderNo);
        model.addAttribute("order", order);
        return "logistics/orderSellDetail";
    }

    /** 수주(판매) 전표 목록 조회 */
    @GetMapping("/sell/list")
    public String sellList(Model model) {
        // 서비스에서 ORDER_TYPE = 'SELL'인 내역만 가져옴
        model.addAttribute("orderSellList", orderService.getOrderSellList());
        return "logistics/orderSellList";
    }
    /** 출고 확정 처리 (재고 부족 검증 포함) */
    @PostMapping("/outbound")
    public String outboundConfirm(@RequestParam("no") String orderNo, RedirectAttributes rttr) {
        try {
            // 서비스에서 재고 부족 시 RuntimeException을 던짐
            orderService.processOutbound(orderNo);
            rttr.addFlashAttribute("msg", "출고 처리가 정상적으로 완료되었습니다.");
            
        } catch (RuntimeException e) {
            // 재고 부족 에러 메시지를 가로채서 JSP의 alert으로 전달
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/logis/order/sell/list";
    }
    /* =================================================================
     * 공통 기능
     * ================================================================= */
    /** 전표 상세 조회 (입고/출고 공용) */
    @GetMapping("/detail")
    public String detail(@RequestParam("no") String orderNo, Model model) {
        model.addAttribute("order", orderService.getOrderDetail(orderNo));
        return "logistics/orderDetail";
    }
}