package com.ess.erp.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.ess.erp.domain.ItemDTO;
import com.ess.erp.domain.StockHistoryDTO;

@Mapper
public interface StockMapper {
    // 1. 특정 품목의 상세 정보 조회 (입/출고 전 BEFORE 재고 파악용)
    ItemDTO getItemStockInfo(String itemCd);

    // 2. [추가] 재고 검증용: 특정 품목의 현재고 수량만 조회
    int selectCurrentStock(String itemCd);

    // 3. 재고 수불 이력(로그) 등록
    void insertItemLog(StockHistoryDTO history);

    // 4. 품목 마스터의 현재고 수량 업데이트 (누적 합산 방식)
    // 입고 시: qty를 양수(+)로 전달 / 출고 시: qty를 음수(-)로 전달
    void updateItemStock(@Param("itemCd") String itemCd, @Param("qty") int qty);

    // 5. 전표 상태 변경 (발주 PO 또는 수주 SO 상태 변경)
    void updateOrderStatus(@Param("orderNo") String orderNo, @Param("status") String status);
}