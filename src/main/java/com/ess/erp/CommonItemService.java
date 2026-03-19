package com.ess.erp;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.mapper.CommonItemMapper;

@Service
public class CommonItemService {

    @Autowired
    private CommonItemMapper commonItemMapper;

    /**
     * 공통 재고 증감 및 이력 저장 메서드 (강산, 준 님 공동 사용)
     * @param itemCd    품목코드
     * @param qty       변동수량 (입고는 양수, 출고는 음수로 넘김)
     * @param inoutType 수불구분 (IN/OUT/ADJ)
     * @param refNo     근거 전표/작업번호
     * @param empId     처리자 사번
     */
    @Transactional
    public void updateStockAndLog(String itemCd, int qty, String inoutType, String refNo, String empId) {
        // 1. 현재 재고 조회
        int beforeQty = commonItemMapper.selectCurrentStock(itemCd);
        int afterQty = beforeQty + qty;
        
        // [중요 검증] 마이너스 출고 시 재고가 부족하면 트랜잭션 롤백
        if (afterQty < 0) {
            throw new RuntimeException("재고가 부족합니다. 품목코드: " + itemCd + " (현재고: " + beforeQty + ", 요청: " + Math.abs(qty) + ")");
        }
        
        // 2. 재고 증감 업데이트
        // [수정] 변동량(qty) 대신, 자바에서 확실하게 계산을 끝낸 최종 재고(afterQty)를 덮어씌웁니다.
        commonItemMapper.updateItemStock(itemCd, afterQty);
        // 3. 수불 이력 저장 (이력에는 QTY를 절대값으로 기록하여 가독성 확보)
        commonItemMapper.insertItemLog(itemCd, inoutType, Math.abs(qty), beforeQty, afterQty, refNo, empId);
    }
}