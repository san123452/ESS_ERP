package com.ess.erp.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface DashboardMapper {
    // 1. 안전재고 미달 품목 조회
    List<Map<String, Object>> selectSafeStockAlert();
    // 2. 납기 지연 전표 조회
    List<Map<String, Object>> selectDelayedOrderAlert();
    // 3. 권한별 접근 가능 메뉴 조회
    List<Map<String, Object>> selectUserMenuList(@Param("roles") List<String> roles);
}