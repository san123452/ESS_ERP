package com.ess.erp.prod;

import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import com.ess.erp.domain.ItemDTO;

@Controller
@RequestMapping("/prod/item") // 이 컨트롤러는 '/prod/item'으로 시작하는 주소만 처리합니다.
public class ItemController {

    private final ItemService itemService;

    // 생성자 주입
    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    // 1. 목록 화면 보여주기 (GET 방식)
    // 주소: localhost:8080/prod/item/list
    @GetMapping("/list")
    public String itemList(Model model) {
        // [디버깅] 이 로그가 콘솔에 찍히면 자바는 정상, JSP 경로 문제임
        System.out.println("==> ItemController 도착! 화면을 찾으러 갑니다.");

        // 서비스에게 목록 좀 달라고 요청
        List<ItemDTO> list = itemService.getItemList();
        
        // 화면(JSP)으로 'itemList'라는 이름으로 데이터를 보냄
        model.addAttribute("itemList", list);
        
        return "prod/itemList"; // WEB-INF/views/prod/itemList.jsp 로 이동
    }

    // 2. 품목 등록 처리 (POST 방식)
    @PostMapping("/add")
    public String addItem(ItemDTO itemDTO) {
        itemService.registerItem(itemDTO); // 등록 시키고
        return "redirect:/prod/item/list"; // 목록 화면으로 다시 돌아가기(새로고침)
    }
}