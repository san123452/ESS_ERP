package com.ess.erp.prod;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.ess.erp.domain.BomDTO;
import com.ess.erp.mapper.ItemMapper;

/**
 * [Controller 클래스]
 * 사용자의 웹 요청(URL)을 받아 서비스 로직을 호출하고, 그 결과를 화면(JSP)으로 넘겨줍니다.
 */
@Controller
@RequestMapping("/prod/bom")
public class BomController {

    private final BomService bomService;
    private final ItemMapper itemMapper; 

    public BomController(BomService bomService, ItemMapper itemMapper) {
        this.bomService = bomService;
        this.itemMapper = itemMapper;
    }

    /**
     * 1. BOM 목록 및 등록 화면 띄우기 (GET 방식)
     * URL: http://localhost:8080/prod/bom/list
     */
    @GetMapping("/list")
    public String bomList(Model model) {
        // 상단 Select 박스에 뿌려줄 전체 품목 리스트를 JSP로 전달 (USE_YN='Y' 기준)
        model.addAttribute("itemList", itemMapper.selectItemList());
        // 하단 테이블에 뿌려줄 BOM 리스트(조인 완료된 데이터)를 JSP로 전달
        model.addAttribute("bomList", bomService.selectBomList());
        
        return "prod/bomList";
    }

    /**
     * 2. BOM 등록 처리하기 (POST 방식)
     * URL: http://localhost:8080/prod/bom/add
     */
    @PostMapping("/add")
    public String addBomProcess(@ModelAttribute BomDTO bomDTO, RedirectAttributes rttr) {
        try {
            bomService.insertBom(bomDTO);
            // 성공 시 한 번만 띄워줄 메시지 (RedirectAttributes의 FlashAttribute 활용)
            rttr.addFlashAttribute("msg", "BOM이 성공적으로 등록되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            // 자기 참조나 중복 에러가 발생한 경우, Service에서 던진 메시지를 꺼내서 화면에 에러로 표시
            rttr.addFlashAttribute("error", e.getMessage());
        } catch (Exception e) {
            // 그 외 알 수 없는 DB 등 시스템 오류 대비
            rttr.addFlashAttribute("error", "BOM 등록 중 시스템 오류가 발생했습니다.");
        }
        
        // 작업이 끝나면 다시 리스트 화면으로 돌아감 (새로고침)
        return "redirect:/prod/bom/list";
    }
}