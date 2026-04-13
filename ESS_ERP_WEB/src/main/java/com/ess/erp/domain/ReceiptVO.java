package com.ess.erp.domain;

public class ReceiptVO {
	 private int receiptNo;
	 private String storeNm;
	 private String receiptDate;
	 private int totalAmt;
	 private String imagePath;
	 private String regDt;
	 public int getReceiptNo() {
		 return receiptNo;
	 }
	 public void setReceiptNo(int receiptNo) {
		 this.receiptNo = receiptNo;
	 }
	 public String getStoreNm() {
		 return storeNm;
	 }
	 public void setStoreNm(String storeNm) {
		 this.storeNm = storeNm;
	 }
	 public String getReceiptDate() {
		 return receiptDate;
	 }
	 public void setReceiptDate(String receiptDate) {
		 this.receiptDate = receiptDate;
	 }
	 public int getTotalAmt() {
		 return totalAmt;
	 }
	 public void setTotalAmt(int totalAmt) {
		 this.totalAmt = totalAmt;
	 }
	 public String getImagePath() {
		 return imagePath;
	 }
	 public void setImagePath(String imagePath) {
		 this.imagePath = imagePath;
	 }
	 public String getRegDt() {
		 return regDt;
	 }
	 public void setRegDt(String regDt) {
		 this.regDt = regDt;
	 }
}
