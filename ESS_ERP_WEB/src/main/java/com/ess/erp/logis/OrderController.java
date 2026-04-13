package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.ess.erp.domain.OrderDTO;
import com.ess.erp.domain.ItemDTO;
import java.util.List;
import java.util.stream.Collectors;

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
        
        List<ItemDTO> allItems = orderService.getItemList();
        
        // [안전 로직 추가] itemType이 null이 아닐 때만 필터링
        List<ItemDTO> buyItems = allItems.stream()
                .filter(item -> item.getItemType() != null && !"FIN".equalsIgnoreCase(item.getItemType()))
                .collect(Collectors.toList());
                
        if (buyItems.isEmpty() && !allItems.isEmpty()) {
            System.out.println("🚨 [발주 에러 방어] ITEM_TYPE 값이 없어 필터링 실패! 임시로 전체 목록을 보여줍니다.");
            model.addAttribute("itemList", allItems);
        } else {
            model.addAttribute("itemList", buyItems); 
        }
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

    /* =================================================================
     * 수주(판매/출고) 관련 매핑
     * ================================================================= */
    
    /** 수주(판매) 전표 등록 폼 이동 */
    @GetMapping("/sell/add")
    public String sellAddForm(Model model) {
        // 거래처 목록과 품목 목록을 뷰에 전달
    	model.addAttribute("clientList", clientService.getClientListByType("OUT"));
        
        List<ItemDTO> allItems = orderService.getItemList();
        
        // [안전 로직 추가] itemType이 null이 아닐 때만 필터링
        List<ItemDTO> sellItems = allItems.stream()
                .filter(item -> item.getItemType() != null && "FIN".equalsIgnoreCase(item.getItemType()))
                .collect(Collectors.toList());
                
        if (sellItems.isEmpty() && !allItems.isEmpty()) {
            System.out.println("🚨 [수주 에러 방어] ITEM_TYPE 값이 없어 필터링 실패! 임시로 전체 목록을 보여줍니다.");
            model.addAttribute("itemList", allItems);
        } else {
            model.addAttribute("itemList", sellItems); 
        }
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