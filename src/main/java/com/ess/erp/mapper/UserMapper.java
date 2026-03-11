package com.ess.erp.mapper;

import com.ess.erp.domain.UserDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
    // 사번으로 사용자 정보를 가져오는 리모컨 버튼
    UserDTO findByEmpId(String empId);
}