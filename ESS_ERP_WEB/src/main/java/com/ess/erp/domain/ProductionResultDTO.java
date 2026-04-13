package com.ess.erp.domain;
import lombok.Data;

@Data
public class ProductionResultDTO {
    private String resultNo;    // 실적번호
    private String orderNo;     // 지시번호
    private int resultQty;      // 생산수량
    private String workDate;    // 작업일자
    private String workerId;    // 작업자사번
}