package com.ess.erp.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
import com.ess.erp.domain.ItemDTO;
import com.ess.erp.domain.OrderDTO;

@Mapper
public interface DashboardMapper {
    List<ItemDTO> selectLowStockItems();
    
    List<OrderDTO> selectDelayedOrders();
    
    // [추가] 사용자의 권한 리스트를 기반으로 접근 가능한 메뉴 리스트를 조회
    List<Map<String, Object>> selectUserMenuList(@Param("roles") List<String> roles);
}