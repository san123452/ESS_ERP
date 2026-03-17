package com.ess.erp.domain;

import lombok.Data;

/**
 * [DTO] 품목 마스터 및 현재고 정보
 * 테이블: TB_ITEM
 * 역할: 품목의 기본 정보와 실시간 재고(STOCK_QTY)를 관리합니다.
 */
@Data
public class ItemDTO {

    private String itemCd;      // 품목코드 (PK: R-/H-/F- 접두어)
    private String itemNm;      // 품목명
    private String itemType;    // 품목구분 (RAW:원자재, HALF:반제품, FIN:완제품)
    private String unit;        // 단위 (EA, KG, BOX 등)
    private int safeQty;        // 안전재고 (미달 시 알림 대상)
    private int stockQty;       // 현재고량 (입/출고 시 업데이트됨)
    private int price;          // 표준단가
    private String whLocation;  // 창고 보관 위치
    private String lotUseYn;    // LOT 관리 여부 (Y/N)
    private String acctCd;      // 주 매입 거래처 코드
    private String useYn;       // 사용 여부 (Y/N)
    private String regDt;       // 등록일시
    private String modDt;       // 수정일시

}