package com.ess.erp.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface RoleMapper {
	// 사원별 권한 상태 목록 조회
	List<Map<String, Object>> selectEmpRoleStatus(String empId);

	// 수동 권한 부여
	int insertEmpRole(Map<String, Object> map);

	// 수동 권한 해제
	int deleteEmpRole(Map<String, Object> map);
}
