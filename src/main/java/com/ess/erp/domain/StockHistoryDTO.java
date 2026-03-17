package com.ess.erp.domain;

import lombok.Data;

/**
 * [DTO] 재고 수불 이력 (Stock History)
 * 테이블: TB_ITEM_LOG
 * 역할: 재고의 모든 변동 사항(입고, 출고, 조정)을 기록합니다.
 */
@Data
public class StockHistoryDTO {

    private Long logNo;         // 수불번호 (PK: Auto Increment)
    private String itemCd;      // 품목코드 (FK)
    private String lotNo;       // LOT 번호 (해당 품목 관리 시)
    private String inoutType;   // 수불구분 (IN:입고, OUT:출고, ADJ:조정)
    private int qty;            // 변동 수량 (양수)
    private int beforeQty;      // 변동 전 재고량
    private int afterQty;       // 변동 후 재고량
    private String refNo;       // 근거 전표 번호 (예: 발주번호 PO-...)
    private String empId;       // 처리자 사번
    private String regDt;       // 이력 등록 일시
    
    // 조인을 위한 추가 필드 (필요 시)
    private String itemNm;      // 품목명 (화면 표시용)
    private String empNm;       // 사원명 (화면 표시용)

}