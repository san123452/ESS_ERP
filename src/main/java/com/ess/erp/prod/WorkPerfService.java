package com.ess.erp.prod;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.mapper.WorkPerfMapper;
import com.ess.erp.domain.WorkPerfDTO;
import com.ess.erp.domain.BomDTO;
import com.ess.erp.CommonItemService;
import com.ess.erp.mapper.CommonItemMapper;
import java.util.List;

@Service
public class WorkPerfService {

    @Autowired
    private WorkPerfMapper workPerfMapper;
    
    @Autowired
    private CommonItemService commonItemService; // 강산 님이 만든 공통 재고 서비스
    
    @Autowired
    private CommonItemMapper commonItemMapper; // 재고 검증용 매퍼 추가

    @Transactional // 하나라도 실패하면 전체 롤백
    public void processWorkPerformance(WorkPerfDTO perfDTO) {
        // 1. 생산 실적 등록 (TB_WORK_PERF)
        workPerfMapper.insertWorkPerf(perfDTO);

        // 2. 해당 작업지시(WORK_NO)가 어떤 완제품(ITEM_CD)을 만드는지 조회
        String itemCd = workPerfMapper.selectItemCdByWorkNo(perfDTO.getWorkNo());

        // 3. BOM을 참조하여 해당 완제품의 하위 원자재 목록과 소요량(REQ_QTY) 조회
        List<BomDTO> children = workPerfMapper.selectBomChildren(itemCd);

        // 4. [핵심] 원자재 연쇄 차감 (원자재 소모량 = BOM 소요량 * 생산된 양품 수량)
        if (children != null) {
            for(BomDTO child : children) {
                int deductQty = child.getReqQty() * perfDTO.getGoodQty();
                
                // [추가] 원자재 재고 검증 로직 (마이너스 재고 방지)
                int currentStock = commonItemMapper.selectCurrentStock(child.getChildCd());
                if (currentStock < deductQty) {
                    throw new RuntimeException("원자재 재고가 부족하여 생산을 진행할 수 없습니다. (필요 부품: " + child.getChildCd() + ", 현재고: " + currentStock + "개, 필요수량: " + deductQty + "개)");
                }
                
                // 공통 서비스를 활용해 재고 마이너스 처리 및 OUT 이력 기록
                commonItemService.updateStockAndLog(child.getChildCd(), -deductQty, "OUT", perfDTO.getWorkNo(), perfDTO.getEmpId());
            }
        }

        // 5. 완제품 입고 처리 (생산된 양품 수량만큼 재고 플러스 및 IN 이력 기록)
        commonItemService.updateStockAndLog(itemCd, perfDTO.getGoodQty(), "IN", perfDTO.getWorkNo(), perfDTO.getEmpId());

        // 6. 작업 지시 상태를 '완료(DONE)'로 업데이트
        workPerfMapper.updateWorkOrderStatus(perfDTO.getWorkNo(), "DONE");
    }
}