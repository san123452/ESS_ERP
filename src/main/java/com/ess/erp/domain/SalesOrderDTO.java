package com.ess.erp.domain;
import lombok.Data;

@Data
public class SalesOrderDTO {
    private String salesNo;     // 수주번호
    private String clientCode;  // 거래처코드
    private String itemCode;    // 품목코드
    private int salesQty;       // 수주수량
    private String deliveryDate;// 납기일자
}