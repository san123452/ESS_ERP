package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.*;
import com.ess.erp.mapper.*;

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
            // 2. [입고 전] 현재 창고 재고 확인
            ItemDTO currentItem = stockMapper.getItemStockInfo(detail.getItemCd());
            int beforeQty = (currentItem != null) ? currentItem.getStockQty() : 0; // 데이터 없으면 0개
            // 3. [계산] 입고 후 수량 = 현재고 + 입고수량
            int inQty = detail.getQty();
            int afterQty = beforeQty + inQty;
            // 4. [수불 로그 생성] '누가, 언제, 무엇을, 얼마나'에 대한 기록
            StockHistoryDTO history = new StockHistoryDTO();
            history.setItemCd(detail.getItemCd());
            history.setInoutType("IN");     // 입고 타입 설정
            history.setQty(inQty);          // 입고된 수량
            history.setBeforeQty(beforeQty); // 변동 전 수량
            history.setAfterQty(afterQty);   // 변동 후 수량
            history.setRefNo(orderNo);      // 근거 전표 번호
            history.setEmpId(empId);        // 처리자 사번
            // 5. DB 반영: 수불 이력 Insert -> 품목 마스터의 실재고 Update
            stockMapper.insertItemLog(history);
            stockMapper.updateItemStock(detail.getItemCd(), inQty); // 덧셈(+) 처리
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
            // 2. [재고 검증] 창고에 실제로 물건이 있는지 수량만 체크
            int currentStock = stockMapper.selectCurrentStock(detail.getItemCd());
            int outQty = detail.getQty(); // 고객이 주문한 수량
            // 3. [에러 처리] 주문 수량이 재고보다 많으면 프로세스 강제 중단
            if (currentStock < outQty) {
                // 이 예외가 던져지면 @Transactional에 의해 앞선 모든 DB 작업이 취소됨
                throw new RuntimeException("재고 부족: " + detail.getItemCd() + 
                                           " (현재고: " + currentStock + ", 요청: " + outQty + ")");
            }
            // 4. [수불 로그 생성] 출고 기록 준비
            StockHistoryDTO history = new StockHistoryDTO();
            history.setItemCd(detail.getItemCd());
            history.setInoutType("OUT");    // 출고 타입 설정
            history.setQty(outQty);         // 나가는 수량
            history.setBeforeQty(currentStock); 
            history.setAfterQty(currentStock - outQty); // 마이너스 계산
            history.setRefNo(orderNo);
            history.setEmpId(empId);
            // 5. DB 반영: 수불 이력 Insert -> 실재고 차감 Update
            stockMapper.insertItemLog(history);
            // 수량 파라미터에 마이너스(-)를 붙여서 쿼리상에서 '기존재고 + (-수량)' 즉, 차감이 되게 함
            stockMapper.updateItemStock(detail.getItemCd(), -outQty); 
        }
        // 6. 전표 마감: 수주 상태를 '완료(DONE)'로 변경
        stockMapper.updateOrderStatus(orderNo, "DONE");
    }
}