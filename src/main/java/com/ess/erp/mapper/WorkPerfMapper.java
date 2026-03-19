package com.ess.erp.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import com.ess.erp.domain.BomDTO;
import com.ess.erp.domain.WorkPerfDTO;

@Mapper
public interface WorkPerfMapper {
    int insertWorkPerf(WorkPerfDTO dto);
    
    List<BomDTO> selectBomChildren(String parentCd);
    
    int updateWorkOrderStatus(@Param("workNo") String workNo, @Param("status") String status);
    
    String selectItemCdByWorkNo(String workNo);
}