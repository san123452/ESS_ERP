package com.ess.erp.domain;
import lombok.Data;

@Data
public class StockDTO {
    private String itemCode;   // 품목코드
    private int quantity;      // 현재고량
    private String warehouse;  // 창고위치
}