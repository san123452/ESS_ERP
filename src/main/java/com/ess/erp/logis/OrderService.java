package com.ess.erp.logis;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.OrderDTO;
import com.ess.erp.domain.OrderDetailDTO;
import com.ess.erp.mapper.OrderMapper;

@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Transactional
    public void registerOrder(OrderDTO dto) {
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

    @Transactional
    public void confirmOrder(String orderNo) {
        orderMapper.updateOrderStatus(orderNo, "COMPLETE");
    }
}