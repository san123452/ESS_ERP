package com.ess.erp.mapper;

import com.ess.erp.domain.EmployeeDTO;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface EmployeeMapper {
    // 사원 목록 조회
    List<EmployeeDTO> selectEmpList();
    // 사원 상세 조회
    EmployeeDTO selectEmpOne(String empId);
    // 사원 등록
    int insertEmployee(EmployeeDTO employeeDTO);
}
