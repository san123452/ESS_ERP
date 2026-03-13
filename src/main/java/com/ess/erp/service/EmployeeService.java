package com.ess.erp.service;

import com.ess.erp.domain.EmployeeDTO;   // 사원 데이터 담는 그릇
import com.ess.erp.mapper.EmployeeMapper; // DB 조회 담당 Mapper

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service; // Service 어노테이션
import java.util.List; // 여러개 담는 자료형

@Service
public class EmployeeService {

    // Mapper.java 사용 선언
    private final EmployeeMapper employeeMapper;
    private final BCryptPasswordEncoder passwordEncoder;
    //Mapper를 Service에 연결해주는 준비 작업
    public EmployeeService(EmployeeMapper employeeMapper, BCryptPasswordEncoder passwordEncoder) {
        this.employeeMapper = employeeMapper;
        this.passwordEncoder = passwordEncoder;
    }
    // 사원 목록 조회 메서드 (Service -> Mapper한테 데이터 꺼내달라고 시킴)
    public List<EmployeeDTO> getEmpList() {
    	 return employeeMapper.selectEmpList();
    }
    
    // 사원 상세 조회 
    public EmployeeDTO getEmpOne(String empId) {
    	EmployeeDTO est = employeeMapper.selectEmpOne(empId);
    	System.out.println("조회결과"+ est);
    	return est;
    }
    // 사원 등록
    public int insertEmployee(EmployeeDTO employeeDTO) {

        // 비밀번호 암호화
        String emcodedPw = passwordEncoder.encode(employeeDTO.getEmpPw());
        employeeDTO.setEmpPw(emcodedPw);

        // DB에 저장
        return employeeMapper.insertEmployee(employeeDTO);
    }
    
    
}