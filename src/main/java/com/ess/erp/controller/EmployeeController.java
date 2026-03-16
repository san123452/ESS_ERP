package com.ess.erp.controller;

import java.util.List;                                   
import org.springframework.stereotype.Controller;         
import org.springframework.ui.Model;                      
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.ess.erp.domain.EmployeeDTO;                   
import com.ess.erp.service.EmployeeService;              

// Spring에게 이 클래스가 Controller임을 알려줌
@Controller
@RequestMapping(value="/hr/employee")
public class EmployeeController {

    // EmployeeService.java와 연결
    private final EmployeeService employeeService;

    // (생성자)service.java 준비
    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }
    // 1. 목록조회
    @GetMapping("/list")
    public String empList(Model model) {

        // Service 호출해서 사원 목록 가져오기
        List<EmployeeDTO> list = employeeService.getEmpList();

        model.addAttribute("list", list);
        return "hr/employeeList";
    }
    // 2. 상세조회
    @GetMapping("/detail/{empId}")
    public String empDetail(@PathVariable String empId, Model model) {
        EmployeeDTO empid = employeeService.getEmpOne(empId);
        model.addAttribute("emp", empid);
        return "hr/employeeDetail";
    }
    // 3. 사원 등록 화면 보여주기
    @GetMapping("/add")
    public String empAdd() {
    	return "hr/employeeAdd";
    }
    // 4. 사원 등록 처리
    @PostMapping("/add")
    public String empAddPost(EmployeeDTO employeeDTO) {
    	employeeService.insertEmployee(employeeDTO);
    	return "redirect:/hr/employee/list";
    }
    // 5.사원 등록수정
    @PostMapping("/update")
    public String empUpdate(EmployeeDTO employeeDTO) {
    	employeeService.updateEmployee(employeeDTO);
    	return "redirect:/hr/employee/detail/"+ employeeDTO.getEmpId();
    }
    // 6.사원 목록삭제
    @PostMapping("/delete")
    public String empDelete(@RequestParam String empId) {
    	employeeService.deleteEmployee(empId);
    	return "redirect:/hr/employee/list";
    }
}