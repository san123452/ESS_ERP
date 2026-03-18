package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.*;
import com.ess.erp.mapper.*;
import com.ess.erp.CommonItemService;

/**
 * [물류/영업 파트] 재고 수불 관리 서비스
 * 입고(Inbound)와 출고(Outbound) 시 재고 수량을 조절하고 이력을 남깁니다.
 */
@Service
public class StockService {

    @Autowired
    private StockMapper stockMapper;
    @Autowired
    private OrderMapper orderMapper;
    
    @Autowired
    private CommonItemService commonItemService; // 강산 님이 만든 공통 재고 서비스 주입

    /**
     * 발주 전표 입고 처리 (Purchase Order Inbound)
     * @param orderNo 발주 번호 (PO-...)
     * @param empId   처리 담당자 사번
     */
    @Transactional // 하나라도 실패하면 전체 롤백 (재고 데이터 무결성 보장)
    public void processInbound(String orderNo, String empId) {
        
        // 1. 발주 전표의 상세 품목 리스트를 가져옴 (ITEM_CD, QTY 등)
        OrderDTO order = orderMapper.getOrderDetail(orderNo);
        for (OrderDetailDTO detail : order.getDetails()) {
            // [리팩토링] 강산 님의 공통 모듈 호출 한 줄로 재고 증가 및 수불 이력 완벽 처리!
            commonItemService.updateStockAndLog(detail.getItemCd(), detail.getQty(), "IN", orderNo, empId);
        }
        // 6. 전표 마감: 발주 상태를 '대기(WAIT)'에서 '완료(DONE)'로 변경
        stockMapper.updateOrderStatus(orderNo, "DONE");
    }
    /**
     * 수주 전표 출고 처리 (Sales Order Outbound)
     * @param orderNo 수주 번호 (SO-...)
     * @param empId   처리 담당자 사번
     * @throws RuntimeException 재고 부족 시 발생 (트랜잭션 롤백 트리거)
     */
    @Transactional
    public void processOutbound(String orderNo, String empId) {
    
        // 1. 수주(판매) 전표 상세 내역 조회
        OrderDTO order = orderMapper.getOrderDetail(orderNo);
        for (OrderDetailDTO detail : order.getDetails()) {
            // [리팩토링] 강산 님의 공통 모듈 호출! 출고는 수량을 음수(-)로 넘겨줍니다.
            // 재고 부족 시 RuntimeException 롤백 방어막까지 CommonItemService에서 자동으로 작동합니다.
            commonItemService.updateStockAndLog(detail.getItemCd(), -detail.getQty(), "OUT", orderNo, empId);
        }
        // 6. 전표 마감: 수주 상태를 '완료(DONE)'로 변경
        stockMapper.updateOrderStatus(orderNo, "DONE");
    }
}