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
import org.springframework.security.core.Authentication; 

@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;

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

    public List<OrderDTO> getOrderList() {
        return orderMapper.getOrderList();
    }

    public OrderDTO getOrderDetail(String orderNo) {
        return orderMapper.getOrderDetail(orderNo);
    }

    public List<ItemDTO> getItemList() {
        return orderMapper.getItemList();
    }

    @Transactional
    public void confirmOrder(String orderNo) {
    	// [추가] 현재 로그인한 사용자 ID 가져오기
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUserId = (auth != null) ? auth.getName() : "SYSTEM";
        
        // 1. 상태를 DONE으로 업데이트 (JSP와 일치)
        orderMapper.updateOrderStatus(orderNo, "DONE");
        
        // 2. 재고 반영 및 로그 기록 (프로젝트 규칙 준수)
        OrderDTO order = orderMapper.getOrderDetail(orderNo);
        if (order != null && order.getDetails() != null) {
            for (OrderDetailDTO detail : order.getDetails()) {
                orderMapper.updateItemStock(detail.getItemCd(), detail.getQty());
                orderMapper.insertItemLog(detail.getItemCd(), detail.getQty(), orderNo, currentUserId);
            }
        }
    }
}