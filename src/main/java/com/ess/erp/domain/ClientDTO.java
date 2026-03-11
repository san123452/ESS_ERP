package com.ess.erp.domain;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ClientDTO {
    private String acctCd;      // ACCT_CD (PK)
    private String acctNm;      // ACCT_NM
    private String acctType;    // ACCT_TYPE (IN/OUT/BOTH)
    private String bizNo;       // BIZ_NO
    private String managerNm;   // MANAGER_NM
    private String phone;       // PHONE
    private String email;       // EMAIL
    private String useYn;       // USE_YN (기본값 'Y')
    private LocalDateTime regDt; // REG_DT
    private LocalDateTime modDt; // MOD_DT
    // DB의 TB_ACCOUNT 테이블과 1:1 매핑되도록 필드를 구성
}