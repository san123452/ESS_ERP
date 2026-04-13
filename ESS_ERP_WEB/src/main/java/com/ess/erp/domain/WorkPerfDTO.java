package com.ess.erp.domain;

import lombok.Data;

@Data
public class WorkPerfDTO {
    private String workNo;      // 작업 지시 번호
    private int goodQty;        // 양품 수량 (실제 생산된 완제품 수)
    private int badQty;         // 불량 수량
    private String badReason;   // 불량 사유
    private String empId;       // 작업 등록자 사번
    private String perfDate;    // 실적 등록일
}