package com.ess.erp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CodeController {

    @GetMapping("/code/list")
    public String codeList() {
        return "system/codeList";
    }
}