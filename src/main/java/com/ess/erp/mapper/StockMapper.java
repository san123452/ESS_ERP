package com.ess.erp.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.ess.erp.domain.ItemDTO;
import com.ess.erp.domain.StockHistoryDTO;

@Mapper
public interface StockMapper {
    // 1. 특정 품목의 현재 재고 정보 조회 (ItemDTO 활용)
    ItemDTO getItemStockInfo(String itemCd);

    // 2. 재고 수불 이력(로그) 등록 (StockHistoryDTO 활용)
    void insertItemLog(StockHistoryDTO history);

    // 3. 품목 마스터의 현재고 수량 업데이트
    void updateItemStock(@Param("itemCd") String itemCd, @Param("qty") int qty);

    // 4. 발주 전표 상태 변경 (WAIT -> DONE)
    void updateOrderStatus(@Param("orderNo") String orderNo, @Param("status") String status);
}