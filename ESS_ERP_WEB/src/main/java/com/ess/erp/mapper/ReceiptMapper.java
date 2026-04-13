package com.ess.erp.mapper;

import com.ess.erp.domain.ReceiptVO;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ReceiptMapper {

    // 영수증 저장
    void insertReceipt(ReceiptVO receipt);

    // 영수증 전체 목록 조회
    List<ReceiptVO> selectReceiptList();

    // 영수증 상세 조회
    ReceiptVO selectReceiptDetail(int receiptNo);

}