package com.ess.erp.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ess.erp.domain.ReceiptVO;
import com.ess.erp.mapper.ReceiptMapper;

@Service
public class ReceiptService {
	@Autowired
	private ReceiptMapper receiptMapper;
	
	// 영수증 저장
	public void insertReceipt(ReceiptVO receipt) {
		receiptMapper.insertReceipt(receipt);
	}
	// 영수증 목록 조회
	public List<ReceiptVO> selectReceiptList() {
		return receiptMapper.selectReceiptList();
	}
	// 영수증 상세 조회
	public ReceiptVO getReceiptDetail(int receiptNo) {
		ReceiptVO receipt = receiptMapper.selectReceiptDetail(receiptNo);
		return receipt;
	}
}
