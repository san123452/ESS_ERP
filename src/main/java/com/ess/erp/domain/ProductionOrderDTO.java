package com.ess.erp.domain;
import lombok.Data;

@Data
public class ProductionOrderDTO {
    private String orderNo;     // 지시번호
    private String itemCode;    // 품목코드
    private int orderQty;       // 지시수량
    private String orderDate;   // 지시일자
    private String status;      // 상태 (대기/진행/완료)
}