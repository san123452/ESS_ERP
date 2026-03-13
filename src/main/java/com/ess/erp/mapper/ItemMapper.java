package com.ess.erp.mapper;

import com.ess.erp.domain.ItemDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface ItemMapper {
    
    // 1. 품목 등록 (INSERT)
    // DB에 몇 행이 들어갔는지 숫자(int)로 반환합니다. (성공시 1)
    int insertItem(ItemDTO itemDTO);

    // 2. 품목 전체 목록 조회 (SELECT)
    // 결과가 여러 개니까 List<ItemDTO>로 받습니다.
    List<ItemDTO> selectItemList();
}