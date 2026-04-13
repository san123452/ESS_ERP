package com.ess.erp.domain;

import lombok.Data;

/**
 * [DTO: Data Transfer Object]
 * DB의 TB_BOM 테이블 데이터를 자바에서 다루기 위한 객체입니다.
 * 완제품(상위)을 만들기 위해 어떤 원자재(하위)가 얼마나 필요한지 정의합니다.
 */
@Data
public class BomDTO {
    // --- TB_BOM 테이블 기본 컬럼 ---
    private Integer bomNo;    // BOM 고유 번호 (PK)
    private String parentCd;  // 상위 품목 코드 (예: 완제품/반제품)
    private String childCd;   // 하위 품목 코드 (예: 원자재/반제품)
    private Integer reqQty;   // 소요량 (상위 1개당 필요한 하위 품목 수량)
    private String useYn;     // 사용 여부 (Y/N)
    private String regDt;     // 등록 일시

    // --- JOIN을 통해 가져올 추가 필드 (DB 테이블엔 없지만 화면 출력용으로 사용) ---
    private String parentNm;  // 상위 품목 이름 (TB_ITEM 조인 결과)
    private String childNm;   // 하위 품목 이름 (TB_ITEM 조인 결과)
}