package com.ess.erp.controller;

import com.ess.erp.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {
    @Autowired
    private DashboardService dashboardService;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("safeStockList", dashboardService.getSafeStockAlert());
        model.addAttribute("delayedOrderList", dashboardService.getDelayedOrderAlert());
        return "dashboard";
    }
}