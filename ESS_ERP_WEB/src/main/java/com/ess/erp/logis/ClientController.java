package com.ess.erp.logis;

import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.ess.erp.domain.ClientDTO;

@Controller
@RequestMapping("/logis/client")
public class ClientController {

    private final ClientService clientService;

    // 생성자 주입: Lombok 에러 방지를 위해 직접 작성
    public ClientController(ClientService clientService) {
        this.clientService = clientService;
    }

    @GetMapping("/list")
    public String clientList(Model model) {
        List<ClientDTO> list = clientService.getClientList();
        model.addAttribute("clientList", list);
        return "logistics/clientList"; // JSP 경로
    }

    @PostMapping("/register")
    public String registerClient(ClientDTO clientDTO) {
        clientService.registerClient(clientDTO);
        return "redirect:/logis/client/list";
    }

    // 논리 삭제 처리 예시
    @PostMapping("/delete/{acctCd}")
    public String deleteClient(@PathVariable String acctCd) {
        clientService.removeClient(acctCd);
        return "redirect:/logis/client/list";
    }
}