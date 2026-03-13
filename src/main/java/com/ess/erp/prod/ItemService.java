package com.ess.erp.prod;

import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.ItemDTO;
import com.ess.erp.mapper.ItemMapper;

@Service
public class ItemService {

    private final ItemMapper itemMapper;

    // 생성자 주입
    public ItemService(ItemMapper itemMapper) {
        this.itemMapper = itemMapper;
    }

    // 품목 목록 가져오기
    public List<ItemDTO> getItemList() {
        return itemMapper.selectItemList();
    }

    // 품목 등록하기
    @Transactional
    public void registerItem(ItemDTO itemDTO) {
        System.out.println("==> [Service] 품목 등록 요청: " + itemDTO.getItemNm());
        itemMapper.insertItem(itemDTO);
    }
}
