package com.ess.erp.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor  // 기본 생성자 추가
@AllArgsConstructor // 모든 필드 생성자 추가
public class ClientDTO {
    private String acctCd;      // ACCT_CD (PK)
    private String acctNm;      // ACCT_NM
    private String acctType;    // ACCT_TYPE (IN/OUT/BOTH)
    private String bizNo;       // BIZ_NO
    private String managerNm;   // MANAGER_NM
    private String phone;       // PHONE
    private String email;       // EMAIL
    private String useYn;       // USE_YN (기본값 'Y')
    private LocalDateTime regDt; // REG_DT
    private LocalDateTime modDt; // MOD_DT
    // DB의 TB_ACCOUNT 테이블과 1:1 매핑되도록 필드를 구성
	public String getAcctCd() {
		return acctCd;
	}
	public void setAcctCd(String acctCd) {
		this.acctCd = acctCd;
	}
	public String getAcctNm() {
		return acctNm;
	}
	public void setAcctNm(String acctNm) {
		this.acctNm = acctNm;
	}
	public String getAcctType() {
		return acctType;
	}
	public void setAcctType(String acctType) {
		this.acctType = acctType;
	}
	public String getBizNo() {
		return bizNo;
	}
	public void setBizNo(String bizNo) {
		this.bizNo = bizNo;
	}
	public String getManagerNm() {
		return managerNm;
	}
	public void setManagerNm(String managerNm) {
		this.managerNm = managerNm;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getUseYn() {
		return useYn;
	}
	public void setUseYn(String useYn) {
		this.useYn = useYn;
	}
	public LocalDateTime getRegDt() {
		return regDt;
	}
	public void setRegDt(LocalDateTime regDt) {
		this.regDt = regDt;
	}
	public LocalDateTime getModDt() {
		return modDt;
	}
	public void setModDt(LocalDateTime modDt) {
		this.modDt = modDt;
	}
}
