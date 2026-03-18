package com.ess.erp.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface WorkOrderMapper {
    // 작업 지시 목록 전체 조회 (품목명 JOIN)
    List<Map<String, Object>> selectWorkOrderList();
}