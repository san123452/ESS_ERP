package com.ess.erp.domain;
import lombok.Data;

@Data
public class PurchaseOrderDTO {
    private String purchaseNo;  // 발주번호
    private String clientCode;  // 거래처코드
    private String itemCode;    // 품목코드
    private int purchaseQty;    // 발주수량
    private String purchaseDate;// 발주일자
}