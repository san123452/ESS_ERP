package com.ess.erp.domain;
import lombok.Data;

@Data
public class StockHistoryDTO {
    private int historyNo;      // 이력순번
    private String itemCode;    // 품목코드
    private String type;        // 구분 (입고/출고/반품)
    private int qty;            // 수량
    private String regDate;     // 등록일시
}