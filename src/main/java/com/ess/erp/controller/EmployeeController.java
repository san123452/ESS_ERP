package com.ess.erp.controller;

import java.util.List;                                    // 여러개 담는 자료형
import org.springframework.stereotype.Controller;         // Controller 어노테이션
import org.springframework.ui.Model;                      // JSP로 데이터 전달하는 그릇
import org.springframework.web.bind.annotation.GetMapping;// URL 연결 어노테이션
import com.ess.erp.domain.EmployeeDTO;                   // 사원 데이터 담는 그릇
import com.ess.erp.service.EmployeeService;              // Service 연결

// Spring에게 이 클래스가 Controller임을 알려줌
@Controller
public class EmployeeController {

    // EmployeeService.java와 연결
    private final EmployeeService employeeService;

    // (생성자)service.java 준비
    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping("/hr/employee/list")
    public String empList(Model model) {

        // Service 호출해서 사원 목록 가져오기
        List<EmployeeDTO> list = employeeService.getEmpList();

        // JSP로 데이터 전달
        // list 라는 이름으로 JSP에서 사용 가능
        model.addAttribute("list", list);

        return "hr/employeeList";
    }
}