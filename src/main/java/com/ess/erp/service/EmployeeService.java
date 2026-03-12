package com.ess.erp.service;

import com.ess.erp.domain.EmployeeDTO;   // 사원 데이터 담는 그릇
import com.ess.erp.mapper.EmployeeMapper; // DB 조회 담당 Mapper
import org.springframework.stereotype.Service; // Service 어노테이션
import java.util.List; // 여러개 담는 자료형

// Spring에게 이 클래스가 Service임을 알려줌
@Service
public class EmployeeService {

    // Mapper.java 사용 선언

    private final EmployeeMapper employeeMapper;

    //Mapper를 Service에 연결해주는 준비 작업
    public EmployeeService(EmployeeMapper employeeMapper) {
        this.employeeMapper = employeeMapper;
    }

    // 사원 목록 조회 메서드 (Service -> Mapper한테 데이터 꺼내달라고 시킴)
    public List<EmployeeDTO> getEmpList() {
    	
        // DB에서 사원 목록 가져와서 반환
        return employeeMapper.selectEmpList();
    }
}