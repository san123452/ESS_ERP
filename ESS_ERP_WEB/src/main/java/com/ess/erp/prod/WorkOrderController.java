package com.ess.erp.prod;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import com.ess.erp.mapper.WorkOrderMapper;

@Controller
public class WorkOrderController {

    @Autowired
    private WorkOrderMapper workOrderMapper;

    @GetMapping("/prod/work/order/list")
    public String workOrderList(Model model) {
        model.addAttribute("workOrderList", workOrderMapper.selectWorkOrderList());
        return "prod/workOrderList";
    }
}