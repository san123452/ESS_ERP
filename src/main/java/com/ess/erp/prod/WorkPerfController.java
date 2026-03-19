package com.ess.erp.prod;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.ui.Model;
import com.ess.erp.domain.WorkPerfDTO;

@Controller
public class WorkPerfController {

    @Autowired
    private WorkPerfService workPerfService;

    // 1. 실적 등록 폼 화면 보여주기 (GET) - 주소창으로 접속할 때 이 메서드가 실행됨
    @GetMapping("/prod/work/perf/add")
    public String showWorkPerfAddForm() {
        return "prod/workPerfAdd"; // WEB-INF/views/prod/workPerfAdd.jsp 화면을 띄움
    }

    // 실적 등록 요청 처리
    @PostMapping("/prod/work/perf/add")
    public String addWorkPerformance(@ModelAttribute WorkPerfDTO perfDTO, RedirectAttributes rttr) {
        
        // [추가] 시큐리티 세션에서 현재 로그인한 작업자 사번 추출해서 DTO에 넣기
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !auth.getName().equals("anonymousUser")) {
            perfDTO.setEmpId(auth.getName());
        } else {
            perfDTO.setEmpId("SYSTEM"); // 테스트용 기본값
        }

        try {
            // 개별 파라미터가 아니라 DTO 바구니 하나를 통째로 넘김
            workPerfService.processWorkPerformance(perfDTO);
            rttr.addFlashAttribute("msg", "실적 등록 및 재고 변동이 완료되었습니다.");
        } catch (RuntimeException e) {
            // 재고 부족 등의 에러 발생 시 처리
            rttr.addFlashAttribute("error", e.getMessage());
        }
        // 실적 등록이 완료되면 다시 작업지시 목록으로 돌아갑니다.
        return "redirect:/prod/work/order/list"; 
    }

    // 3. 생산 실적 목록 화면 (임시 더미 페이지 연결)
    @GetMapping("/prod/work/perf/list")
    public String workPerfList() {
        return "prod/workPerfList"; 
    }
}