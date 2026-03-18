package com.ess.erp.domain;

import lombok.Data;
import java.util.List;

@Data
public class OrderDTO {
	// TB_ORDER (마스터)
    private String orderNo;      // ORDER_NO (PK)
    private String orderType;    // ORDER_TYPE ('BUY' 또는 'SELL')
    private String acctCd;       // ACCT_CD
    private String empId;        // EMP_ID (담당자)
    private String orderDate;    // ORDER_DATE
    private String dueDate;      // DUE_DATE
    private String status;       // STATUS (WAIT, CONF, DONE, CANCEL)
    private String remark;       // REMARK
    
    private String acctNm;		 // 거래처명을 담기 위한 필드

    // TB_ORDER_DETAIL (상세 목록)
    private List<OrderDetailDTO> details; 
}