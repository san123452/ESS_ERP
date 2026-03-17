package com.ess.erp.prod;

import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.BomDTO;
import com.ess.erp.mapper.BomMapper;

/**
 * [Service 클래스]
 * 컨트롤러와 DB(Mapper) 사이에서 비즈니스 로직(데이터 검증, 예외 처리 등)을 담당합니다.
 */
@Service
public class BomService {

    private final BomMapper bomMapper;

    // 생성자 주입 방식 (Spring이 자동으로 매퍼를 연결해 줌)
    public BomService(BomMapper bomMapper) {
        this.bomMapper = bomMapper;
    }

    /**
     * BOM 등록 로직
     * @Transactional: 실행 도중 에러가 나면 DB에 잘못 반영되는 걸 막아줍니다 (자동 롤백).
     */
    @Transactional
    public void insertBom(BomDTO bomDTO) {
        // [검증 1] 자기 참조 방지
        // 완제품을 만드는데 재료로 동일한 완제품이 들어갈 순 없으므로 예외를 발생시킵니다.
        if (bomDTO.getParentCd() != null && bomDTO.getParentCd().equals(bomDTO.getChildCd())) {
            throw new IllegalArgumentException("상위 품목과 하위 품목은 같을 수 없습니다.");
        }
        
        // [검증 2] 중복 등록 방지
        // DB를 조회하여 이미 똑같은 상위/하위 조합이 등록되어 있는지 검사합니다.
        int duplicateCount = bomMapper.checkDuplicateBom(bomDTO.getParentCd(), bomDTO.getChildCd());
        if (duplicateCount > 0) {
            throw new IllegalStateException("이미 동일한 상위/하위 품목 조합이 존재합니다.");
        }
        
        // 검증을 모두 통과하면 실제 DB에 INSERT 합니다.
        bomMapper.insertBom(bomDTO);
    }

    // BOM 전체 목록 조회
    public List<BomDTO> selectBomList() {
        return bomMapper.selectBomList();
    }
}