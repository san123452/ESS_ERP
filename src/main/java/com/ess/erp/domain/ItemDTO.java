package com.ess.erp.domain;
import lombok.Data;

@Data
public class ItemDTO {
    private String itemCode;   // 품목코드
    private String itemName;   // 품목명
    private String itemType;   // 구분 (제품/원재료)
    private int unitPrice;     // 단가
}
