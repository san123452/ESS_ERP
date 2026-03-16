package com.ess.erp.mapper;

import java.util.List;
import com.ess.erp.domain.OrderDetailDTO;
import com.ess.erp.domain.OrderDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface OrderMapper {
    void insertOrder(OrderDTO dto);
    void insertOrderDetail(OrderDetailDTO detail);
    int getOrderCountByDate(String dateStr);
    List<OrderDTO> getOrderList();
    OrderDTO getOrderDetail(String orderNo);
    void updateOrderStatus(@Param("orderNo") String orderNo, @Param("status") String status);
}