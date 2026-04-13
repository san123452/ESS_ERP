package com.ess.erp.domain;

import lombok.Data;

@Data
public class OrderDetailDTO {
	private int detailNo;       // DETAIL_NO (PK)
    private String orderNo;     // ORDER_NO (FK)
    private String itemCd;      // ITEM_CD
    private int qty;            // QTY (수량)
    private int unitPrice;      // UNIT_PRICE (단가)
    private int supplyAmt;      // SUPPLY_AMT (공급가액)
    private int vatAmt;         // VAT_AMT (부가세)
    private long amt;           // AMT (합계금액)
}