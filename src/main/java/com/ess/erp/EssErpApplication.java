package com.ess.erp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class EssErpApplication {

	public static void main(String[] args) {
		// [추가] XML 보안 정책을 완화해서 MyBatis DTO 로딩 에러를 해결합니다.
		System.setProperty("javax.xml.accessExternalDTD", "all"); 
		
		SpringApplication.run(EssErpApplication.class, args);
	}

}