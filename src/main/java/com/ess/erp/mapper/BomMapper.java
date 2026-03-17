package com.ess.erp.mapper;

import com.ess.erp.domain.BomDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * [Mapper 인터페이스]
 * MyBatis를 통해 DB의 TB_BOM 테이블과 직접 통신하는 역할입니다.
 * 메서드 이름이 BomMapper.xml의 쿼리 id와 매핑됩니다.
 */
@Mapper
public interface BomMapper {
    
    /**
     * 1. BOM 데이터 등록 (INSERT)
     * @param bomDTO 화면에서 넘겨받은 상위 품목, 하위 품목, 소요량 정보
     */
    int insertBom(BomDTO bomDTO);
    
    /**
     * 2. BOM 리스트 전체 조회 (SELECT)
     * TB_ITEM 테이블과 2번 LEFT JOIN하여 품목 코드뿐만 아니라 상/하위 품목명까지 함께 조회합니다.
     */
    List<BomDTO> selectBomList();
    
    /**
     * 3. BOM 중복 검사 (SELECT COUNT)
     * 특정 상위 품목과 하위 품목 조합이 이미 등록되어 있는지 확인합니다. (0이면 없음, 1 이상이면 중복)
     */
    int checkDuplicateBom(@Param("parentCd") String parentCd, @Param("childCd") String childCd);

}