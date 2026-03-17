package com.ess.erp.logis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.*;
import com.ess.erp.mapper.*;

@Service
public class StockService {

    @Autowired
    private StockMapper stockMapper;
    
    @Autowired
    private OrderMapper orderMapper;

    @Transactional
    public void processInbound(String orderNo, String empId) {
        // 1. 발주 전표 상세 내역(품목, 수량) 가져오기
        OrderDTO order = orderMapper.getOrderDetail(orderNo);
        
        for (OrderDetailDTO detail : order.getDetails()) {
            // 2. 입고 전 현재 재고 파악
            ItemDTO currentItem = stockMapper.getItemStockInfo(detail.getItemCd());
            int beforeQty = (currentItem != null) ? currentItem.getStockQty() : 0;
            int inQty = detail.getQty();
            int afterQty = beforeQty + inQty;

            // 3. 수불 이력(Log) 객체 생성 및 저장
            StockHistoryDTO history = new StockHistoryDTO();
            history.setItemCd(detail.getItemCd());
            history.setInoutType("IN"); // 입고
            history.setQty(inQty);
            history.setBeforeQty(beforeQty);
            history.setAfterQty(afterQty);
            history.setRefNo(orderNo);
            history.setEmpId(empId);

            stockMapper.insertItemLog(history);

            // 4. 실제 재고 테이블(TB_ITEM) 업데이트
            stockMapper.updateItemStock(detail.getItemCd(), inQty);
        }

        // 5. 전표 상태 완료(DONE) 처리
        stockMapper.updateOrderStatus(orderNo, "DONE");
    }
}