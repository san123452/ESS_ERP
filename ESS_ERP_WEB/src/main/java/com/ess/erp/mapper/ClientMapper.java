package com.ess.erp.mapper;

import com.ess.erp.domain.ClientDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param; // @Param 추가 필수
import java.util.List;

@Mapper
public interface ClientMapper {
    // 거래처 등록 (TB_ACCOUNT)
    int insertClient(ClientDTO clientDTO);
    
    // 거래처 전체 목록 조회
    List<ClientDTO> selectClientList();
    
    /** [추가] 거래처 타입별 필터링 조회 (IN, OUT, BOTH 대응) */
    List<ClientDTO> getClientListByType(@Param("type") String type);
    
    // 거래처 논리 삭제 (프로젝트 규칙: USE_YN = 'N')
    int deleteClient(String acctCd);
}