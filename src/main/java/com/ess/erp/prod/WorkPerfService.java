package com.ess.erp.prod;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.context.SecurityContextHolder;
import com.ess.erp.mapper.WorkPerfMapper;
import com.ess.erp.CommonItemService;
import com.ess.erp.domain.BomDTO;

@Service
public class WorkPerfService {
    
    @Autowired
    private WorkPerfMapper workPerfMapper;
    
    @Autowired
    private CommonItemService commonItemService; // 공통 재고 서비스 주입

    // 하나의 로직이라도 실패(재고부족 등)하면 모두 롤백되도록 Transactional 필수
    @Transactional
    public void processWorkPerformance(String workNo, int goodQty, int badQty, String badReason) {
        // [Cross-Check 2] 시큐리티 컨텍스트에서 현재 로그인한 유저 ID(사번) 가져오기
        String empId = SecurityContextHolder.getContext().getAuthentication().getName();

        // 1. 실적 테이블(TB_WORK_PERF)에 INSERT
        Map<String, Object> param = new HashMap<>();
        param.put("workNo", workNo); param.put("goodQty", goodQty);
        param.put("badQty", badQty); param.put("badReason", badReason);
        param.put("empId", empId);
        workPerfMapper.insertWorkPerf(param);

        // 2. 완제품 품목코드 찾기 및 BOM 하위 부품 가져오기
        String parentItemCd = workPerfMapper.selectItemCdByWorkNo(workNo);
        List<BomDTO> children = workPerfMapper.selectBomChildren(parentItemCd);

        // 3. [핵심] 원자재 차감 루프 (BOM 연쇄 계산)
        for (BomDTO child : children) {
            int consumeQty = child.getReqQty() * (goodQty + badQty); // 양품+불량만큼 부품은 소모됨
            commonItemService.updateStockAndLog(child.getChildCd(), -consumeQty, "OUT", workNo, empId);
        }
        // 4. 완제품 입고 (IN) - 양품(goodQty)만큼만 입고
        commonItemService.updateStockAndLog(parentItemCd, goodQty, "IN", workNo, empId);
        // 5. 작업 지시서 상태 업데이트
        workPerfMapper.updateWorkOrderStatus(workNo, "DONE");
    }
}