package com.ess.erp.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.ess.erp.mapper.RoleMapper;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
public class RoleService {

    private final RoleMapper roleMapper;

    // 롬복 에러 방지를 위해 직접 생성자 주입 코드를 작성합니다.
    public RoleService(RoleMapper roleMapper) {
        this.roleMapper = roleMapper;
    }

    // 사원별 권한 상태 목록 조회
    public List<Map<String, Object>> getEmpRoleStatus(String empId) {
        return roleMapper.selectEmpRoleStatus(empId);
    }

    // 권한 수정 (IS_DEFAULT='N'인 것만 삭제 후 재등록)
    @Transactional
    public void updateEmpRoles(String empId, List<String> roleCdList) {

        // 1. 기존 수동 권한 전체 삭제
        Map<String, Object> map = new HashMap<>();
        map.put("empId", empId);
        roleMapper.deleteEmpRole(map);

        // 2. 새로운 권한 목록 INSERT
        if (roleCdList != null) {
            for (String roleCd : roleCdList) {
                map.put("roleCd", roleCd);
                roleMapper.insertEmpRole(map);
            }
        }
    }
}