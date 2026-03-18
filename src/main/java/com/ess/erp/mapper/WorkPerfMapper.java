package com.ess.erp.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.ess.erp.domain.BomDTO;

@Mapper
public interface WorkPerfMapper {
    // 1. 생산 실적 INSERT
    void insertWorkPerf(Map<String, Object> paramMap);
    
    // 2. 완제품에 대한 하위 부품(BOM) 목록 및 소요량 조회
    List<BomDTO> selectBomChildren(@Param("parentCd") String parentCd);
    
    // 3. 작업 지시 상태 DONE 변경
    void updateWorkOrderStatus(@Param("workNo") String workNo, @Param("status") String status);
    
    // 4. 작업 지시 대상 품목(완제품) 코드 가져오기
    String selectItemCdByWorkNo(@Param("workNo") String workNo);
}