package com.ess.erp.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.ess.erp.service.RoleService;


@Controller
@RequestMapping("/hr/role")
public class RoleController {
	
	@Autowired // roleService 연결
	private RoleService roleService;
	
	// 1. 사원별 권한 관리 화면 보여주기
	@GetMapping("/manage")
	public String manage(@RequestParam String empId, Model model) {
		List<Map<String, Object>> roleList = roleService.getEmpRoleStatus(empId);
		// 만든 변수
		model.addAttribute("roleList", roleList);
		model.addAttribute("empId",empId);
		return "hr/roleManage";
		
	}
	
	// 2. 사원별 권한 수정 처리
	@PostMapping("/update")
	public String manage(@RequestParam String empId,
			@RequestParam(required = false) List<String> roleCdList) {
		roleService.updateEmpRoles(empId,roleCdList);
		return "redirect:/hr/employee/detail/"+empId;
		
	}
}
