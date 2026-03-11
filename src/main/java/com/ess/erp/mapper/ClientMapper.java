package com.ess.erp.mapper;

import com.ess.erp.domain.ClientDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface ClientMapper {
    // 거래처 등록 (TB_ACCOUNT)
    int insertClient(ClientDTO clientDTO);
    
    // 거래처 전체 목록 조회 (USE_YN 상관없이 혹은 Y만 선택 가능 - 여기선 Y 기준)
    List<ClientDTO> selectClientList();
    
    // 거래처 논리 삭제 (프로젝트 규칙: USE_YN = 'N')
    int deleteClient(String acctCd);
}