package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.ess.erp.domain.OrderDTO;

@Controller
@RequestMapping("/logis/order")
public class OrderController {

    @Autowired
    private OrderService orderService;
    
    @Autowired
    private ClientService clientService; 

    @GetMapping("/add")
    public String addForm(Model model) {
        model.addAttribute("clientList", clientService.getClientList());
        model.addAttribute("itemList", orderService.getItemList()); 
        return "logistics/orderAdd";
    }

    @PostMapping("/add")
    public String addProcess(@ModelAttribute OrderDTO dto) {
        orderService.registerOrder(dto);
        return "redirect:/logis/order/list";
    }
    
    @GetMapping("/list")
    public String list(Model model) {
        model.addAttribute("orderList", orderService.getOrderList());
        return "logistics/orderList";
    }

    @GetMapping("/detail")
    public String detail(@RequestParam("no") String orderNo, Model model) {
        model.addAttribute("order", orderService.getOrderDetail(orderNo));
        return "logistics/orderDetail";
    }

   
}