package com.ess.erp.domain;
import lombok.Data;

@Data
public class CommonCodeDTO {
    private String groupCode;   // 그룹코드 (예: DEPT00)
    private String code;        // 상세코드 (예: 01)
    private String codeName;    // 코드명 (예: 인사팀)
}