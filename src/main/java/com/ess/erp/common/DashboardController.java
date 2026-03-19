package com.ess.erp.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import com.ess.erp.mapper.DashboardMapper;

@Controller
public class DashboardController {

    @Autowired
    private DashboardMapper dashboardMapper;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // 대시보드 위젯에 띄울 경고성 데이터 전달
        model.addAttribute("lowStockList", dashboardMapper.selectLowStockItems());
        model.addAttribute("delayedOrderList", dashboardMapper.selectDelayedOrders());
        return "dashboard"; // /WEB-INF/views/dashboard.jsp
    }
}