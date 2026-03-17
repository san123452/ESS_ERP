package com.ess.erp.mapper;

import java.util.List;
import com.ess.erp.domain.OrderDetailDTO;
import com.ess.erp.domain.OrderDTO;
import com.ess.erp.domain.ItemDTO; // ItemDTO 임포트 필요
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
    
    // 추가된 메서드
    List<ItemDTO> getItemList();
    void updateItemStock(@Param("itemCd") String itemCd, @Param("qty") int qty);
    void insertItemLog(
    		@Param("itemCd") String itemCd, 
    		@Param("qty") int qty, 
    		@Param("orderNo") String orderNo,
    		@Param("empId") String empId
    		);
}