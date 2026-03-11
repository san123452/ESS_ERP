package com.ess.erp.domain;
import lombok.Data;

@Data
public class ClientDTO {
    private String clientCode;  // 거래처코드
    private String clientName;  // 거래처명
    private String businessNo;  // 사업자번호
    private String clientType;  // 매출처/매입처
}
// test