package com.ess.erp.domain;

import lombok.Data;

/**
 * [DTO: Data Transfer Object]
 * 데이터베이스의 TB_ITEM 테이블의 데이터를 자바에서 다루기 위한 그릇입니다.
 * 롬복(@Data)을 써서 Getter/Setter를 자동 생성합니다.
 */
@Data
public class ItemDTO {
    private String itemCd;    // 품목 코드 (PK) - 예: ITM-001
    private String itemNm;    // 품목명 - 예: 강철 프레임
    private String itemType;  // 품목 유형 (RAW/HALF/FIN)
    private String unit;      // 단위 (EA, KG 등) - 신규 추가
    private int price;        // 표준 단가 (UNIT_PRICE -> PRICE 변경)
    private int stockQty;     // 현재 재고 (STOCK -> STOCK_QTY 변경)
    private int safeQty;      // 안전 재고 - 신규 추가
    private String whLocation;// 보관 위치 - 신규 추가
    private String lotUseYn;  // LOT 관리 여부 - 신규 추가
    private String useYn;     // 사용 여부 (Y/N)
    private String acctCd;    // 주 거래처 코드

    // 롬복이 없으면 아래처럼 Getter/Setter를 직접 만들어야 합니다.
    // public String getItemCd() { return itemCd; }
    // public void setItemCd(String itemCd) { this.itemCd = itemCd; }
}