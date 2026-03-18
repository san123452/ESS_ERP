package com.ess.erp.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface CommonItemMapper {
    // 1. 현재 재고 조회
    int selectCurrentStock(@Param("itemCd") String itemCd);
    
    // 2. 재고 증감 업데이트 (양수면 +, 음수면 - 처리됨)
    void updateItemStock(@Param("itemCd") String itemCd, @Param("qty") int qty);
    
    // 3. 재고 수불 이력(블랙박스) 추가
    void insertItemLog(
        @Param("itemCd") String itemCd, @Param("inoutType") String inoutType, 
        @Param("qty") int qty, @Param("beforeQty") int beforeQty, 
        @Param("afterQty") int afterQty, @Param("refNo") String refNo, @Param("empId") String empId);
}