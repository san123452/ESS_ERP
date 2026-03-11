package com.ess.erp.domain;
import lombok.Data;

@Data
public class BomDTO {
    private String parentItemCode; // 모품목 (완제품)
    private String childItemCode;  // 자품목 (원재료)
    private int quantity;          // 소요량
}