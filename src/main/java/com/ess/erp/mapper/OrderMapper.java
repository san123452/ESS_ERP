package com.ess.erp.mapper;

import java.util.List;
import com.ess.erp.domain.OrderDetailDTO;
import com.ess.erp.domain.OrderDTO;
import com.ess.erp.domain.ItemDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface OrderMapper {

    /* =================================================================
     * 1. 전표(Order) 관련 메서드
     * ================================================================= */
    /** 전표 마스터 정보 등록 (발주/수주 공용) */
    void insertOrder(OrderDTO dto);
    /** 전표 상세 품목 정보 등록 */
    void insertOrderDetail(OrderDetailDTO detail);
    /** 일자별 전표 생성 개수 조회 (자동 채번 PO-2026... 생성용) */
    int getOrderCountByDate(@Param("dateStr") String dateStr);

    /** 발주(구매/입고) 전표 목록 조회 */
    List<OrderDTO> getOrderList();
    /** 수주(판매/출고) 전표 목록 조회 */
    List<OrderDTO> getOrderSellList();
    /** 특정 전표의 마스터 및 상세 내역 조회 (ResultMap 활용) */
    OrderDTO getOrderDetail(String orderNo);
    /** 전표 상태 변경 (WAIT -> DONE 등) */
    void updateOrderStatus(@Param("orderNo") String orderNo, @Param("status") String status);


    /* =================================================================
     * 2. 재고(Stock) 및 품목 관련 메서드
     * ================================================================= */
    /** 판매 가능한 품목 리스트 조회 (ITEM_NM, PRICE 등) */
    List<ItemDTO> getItemList();
    /** 재고 검증용: 특정 품목의 현재 실재고 수량만 조회 */
    int getItemStockQty(@Param("itemCd") String itemCd);
    /** 실제 재고 테이블(TB_ITEM) 수량 업데이트 (입고 시 +, 출고 시 -) */
    void updateItemStock(@Param("itemCd") String itemCd, @Param("qty") int qty);
    /** 입고(IN) 로그 기록 (TB_ITEM_LOG) */
    void insertItemLog(
        @Param("itemCd") String itemCd, 
        @Param("qty") int qty, 
        @Param("orderNo") String orderNo,
        @Param("empId") String empId
    );
    /** 출고(OUT) 로그 기록 (TB_ITEM_LOG) */
    void insertOutboundLog(
        @Param("itemCd") String itemCd, 
        @Param("qty") int qty, 
        @Param("orderNo") String orderNo,
        @Param("empId") String empId
    );
}