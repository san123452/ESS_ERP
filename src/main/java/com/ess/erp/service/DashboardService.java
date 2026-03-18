package com.ess.erp.service;

import com.ess.erp.mapper.DashboardMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;

@Service
public class DashboardService {
    @Autowired
    private DashboardMapper dashboardMapper;

    public List<Map<String, Object>> getSafeStockAlert() {
        return dashboardMapper.selectSafeStockAlert();
    }

    public List<Map<String, Object>> getDelayedOrderAlert() {
        return dashboardMapper.selectDelayedOrderAlert();
    }
}