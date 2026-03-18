package com.ess.erp.logis;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.OrderDTO;
import com.ess.erp.domain.OrderDetailDTO;
import com.ess.erp.domain.ItemDTO;
import com.ess.erp.mapper.OrderMapper;
import org.springframework.security.core.context.SecurityContextHolder; 
import org.springframework.security.core.Authentication; 

@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;
    /* =================================================================
     * 발주(구매) 관련 로직
     * ================================================================= */
    /** 1. 발주 전표 등록 (입고 예정 데이터 생성) */
    @Transactional
    public void registerOrder(OrderDTO dto) {
        // 현재 로그인한 사용자(작성자) 사번 추출
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUserId = (auth != null) ? auth.getName() : "SYSTEM";
        dto.setEmpId(currentUserId);
        // 날짜 기반 전표 번호 생성 (PO-yyyyMMdd-001 형식)
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int nextSeq = orderMapper.getOrderCountByDate(today) + 1;
        String orderNo = String.format("PO-%s-%03d", today, nextSeq);
        dto.setOrderNo(orderNo);
        dto.setOrderType("BUY"); // 구매/입고 타입 고정
        orderMapper.insertOrder(dto);
        // 상세 품목 등록
        if (dto.getDetails() != null) {
            for (OrderDetailDTO detail : dto.getDetails()) {
                detail.setOrderNo(orderNo);
                orderMapper.insertOrderDetail(detail);
            }
        }
    }
    /** 2. 입고 확정 처리 (실재고 증가 + 입고 로그 기록) */
    @Transactional
    public void confirmOrder(String orderNo) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUserId = (auth != null) ? auth.getName() : "SYSTEM";
        // 전표 상태 'DONE'으로 업데이트
        orderMapper.updateOrderStatus(orderNo, "DONE");
        // 전표 상세 품목들을 순회하며 재고 증가
        OrderDTO order = orderMapper.getOrderDetail(orderNo);
        if (order != null && order.getDetails() != null) {
            for (OrderDetailDTO detail : order.getDetails()) {
                // 실재고 증가 (+)
                orderMapper.updateItemStock(detail.getItemCd(), detail.getQty());
                // 입고 로그(IN) 기록
                orderMapper.insertItemLog(detail.getItemCd(), detail.getQty(), orderNo, currentUserId);
            }
        }
    }
    /* =================================================================
     * 수주(판매) 관련 로직 (출고 및 재고 검증)
     * ================================================================= */
    /** 1. 수주(판매) 전표 목록 조회 */
    public List<OrderDTO> getOrderSellList() {
        return orderMapper.getOrderSellList();
    }

    /** 2. 수주 전표 출고 확정 처리 (재고 검증 필수) */
    @Transactional
    public void processOutbound(String orderNo) {
        // 현재 로그인한 사용자(처리자) 사번 추출
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUserId = (auth != null) ? auth.getName() : "SYSTEM";
        // 전표 정보 및 상세 품목 조회
        OrderDTO order = orderMapper.getOrderDetail(orderNo);
        if (order != null && order.getDetails() != null) {
            for (OrderDetailDTO detail : order.getDetails()) {
                // [핵심 로직] 재고 검증: 현재 창고의 실재고 조회
                int currentStock = orderMapper.getItemStockQty(detail.getItemCd());
                // 주문 수량보다 재고가 적으면 예외 발생 -> 트랜잭션 롤백(모든 작업 취소)
                if (currentStock < detail.getQty()) {
                    throw new RuntimeException("재고 부족 에러: [" + detail.getItemCd() + "] " +
                                               "(현재고: " + currentStock + ", 요청수량: " + detail.getQty() + ")");
                }
                // 검증 통과 시: 실재고 차감 (-)
                orderMapper.updateItemStock(detail.getItemCd(), -detail.getQty());
                // 출고 로그(OUT) 기록
                orderMapper.insertOutboundLog(detail.getItemCd(), detail.getQty(), orderNo, currentUserId);
            }
        }
        // 전표 상태 완료('DONE') 처리
        orderMapper.updateOrderStatus(orderNo, "DONE");
    }

    /** 3. 수주(판매) 전표 등록 (출고 예정 데이터 생성) */
    @Transactional
    public void registerSellOrder(OrderDTO dto) {
        // 현재 로그인한 사용자 사번 추출
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUserId = (auth != null) ? auth.getName() : "SYSTEM";
        dto.setEmpId(currentUserId);

        // 수주 전표 번호 생성 (SO-yyyyMMdd-001 형식)
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int nextSeq = orderMapper.getOrderCountByDate(today) + 1;
        String orderNo = String.format("SO-%s-%03d", today, nextSeq);

        dto.setOrderNo(orderNo);
        dto.setOrderType("SELL"); // ★ 판매/출고 타입 설정
        dto.setStatus("WAIT");    // 대기 상태로 시작

        orderMapper.insertOrder(dto);

        // 상세 품목 등록
        if (dto.getDetails() != null) {
            for (OrderDetailDTO detail : dto.getDetails()) {
                detail.setOrderNo(orderNo);
                orderMapper.insertOrderDetail(detail);
            }
        }
    }

    /* =================================================================
     * 공통 조회 메서드
     * ================================================================= */

    public List<OrderDTO> getOrderList() {
        return orderMapper.getOrderList();
    }

    public OrderDTO getOrderDetail(String orderNo) {
        return orderMapper.getOrderDetail(orderNo);
    }

    public List<ItemDTO> getItemList() {
        return orderMapper.getItemList();
    }
}