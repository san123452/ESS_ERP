package com.ess.erp.service;

import com.ess.erp.domain.EmployeeDTO;   // 사원 데이터 담는 그릇
import com.ess.erp.mapper.EmployeeMapper; // DB 조회 담당 Mapper
import org.springframework.stereotype.Service; // Service 어노테이션
import java.util.List; // 여러개 담는 자료형

// Spring에게 이 클래스가 Service임을 알려줌
@Service
public class EmployeeService {

    // Mapper 사용 선언
    // EmployeeMapper.java와 연결
    private final EmployeeMapper employeeMapper;

    // 생성자
    // Spring이 자동으로 EmployeeMapper 연결해줌
    public EmployeeService(EmployeeMapper employeeMapper) {
        this.employeeMapper = employeeMapper;
    }

    // 사원 목록 조회 메서드
    // Controller에서 이 메서드를 호출함
    // List = 사원 여러명을 묶어서 반환
    public List<EmployeeDTO> getEmpList() {
        // EmployeeMapper.xml의 selectEmpList SQL 실행
        // DB에서 사원 목록 가져와서 반환
        return employeeMapper.selectEmpList();
    }
}