package com.ess.erp.logis;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.OrderDTO;
import com.ess.erp.domain.OrderDetailDTO;
import com.ess.erp.domain.ItemDTO;
import com.ess.erp.mapper.OrderMapper;
import org.springframework.security.core.context.SecurityContextHolder; 
import com.ess.erp.CommonItemService;
import org.springframework.security.core.Authentication; 

@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private CommonItemService commonItemService; // 강산 님이 만든 공통 재고 서비스 주입

    @Transactional
    public void registerOrder(OrderDTO dto) {
    	
    	// 등록자 정보 추출
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUserId = (auth != null) ? auth.getName() : "SYSTEM";
        dto.setEmpId(currentUserId);
        
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int nextSeq = orderMapper.getOrderCountByDate(today) + 1;
        String orderNo = String.format("PO-%s-%03d", today, nextSeq);
        dto.setOrderNo(orderNo);
        dto.setOrderType("BUY");

        orderMapper.insertOrder(dto);

        if (dto.getDetails() != null) {
            for (OrderDetailDTO detail : dto.getDetails()) {
                detail.setOrderNo(orderNo);
                orderMapper.insertOrderDetail(detail);
            }
        }
    }

    // [추가] 수주(판매) 전표 등록 로직
    @Transactional
    public void registerSellOrder(OrderDTO dto) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUserId = (auth != null) ? auth.getName() : "SYSTEM";
        dto.setEmpId(currentUserId);
        
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int nextSeq = orderMapper.getSellOrderCountByDate(today) + 1;
        String orderNo = String.format("SO-%s-%03d", today, nextSeq); // 'SO-' 접두사 사용
        dto.setOrderNo(orderNo);
        dto.setOrderType("SELL");

        orderMapper.insertOrder(dto);

        if (dto.getDetails() != null) {
            for (OrderDetailDTO detail : dto.getDetails()) {
                detail.setOrderNo(orderNo);
                orderMapper.insertOrderDetail(detail);
            }
        }
    }

    public List<OrderDTO> getOrderList() {
        return orderMapper.getOrderList();
    }

    // [추가] 수주(판매) 목록 조회
    public List<OrderDTO> getOrderSellList() {
        return orderMapper.getOrderSellList();
    }

    public OrderDTO getOrderDetail(String orderNo) {
        return orderMapper.getOrderDetail(orderNo);
    }

    public List<ItemDTO> getItemList() {
        return orderMapper.getItemList();
    }
}