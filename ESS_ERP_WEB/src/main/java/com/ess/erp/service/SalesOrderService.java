package com.ess.erp.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ess.erp.mapper.OrderMapper;

@Service
public class SalesOrderService {
	@Autowired
	private OrderMapper orderMapper;
	
	//매출 데이터
	public List<Map<String, Object>> getSalesData() {
		return orderMapper.getSalesData();
	}
	//매입 데이터
	public List<Map<String, Object>> getPurchaseData() {
		return orderMapper.getPurchaseData();
	}
	//불량 손실 데이터
	public List<Map<String, Object>> getBadLossData() {
		return orderMapper.getBadLossData();
	}
	public List<Map<String, Object>> getProductionData() {
	    return orderMapper.getProductionData();
	}
	public List<Map<String, Object>> getItemMasterData() {
	    return orderMapper.getItemMasterData();
	}
	public List<Map<String, Object>> getBomCostData() {
	    return orderMapper.getBomCostListData();
	}
	
}
