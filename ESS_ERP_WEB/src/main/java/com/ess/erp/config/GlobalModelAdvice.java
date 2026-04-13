package com.ess.erp.config;

import com.ess.erp.mapper.DashboardMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@ControllerAdvice
public class GlobalModelAdvice {

    @Autowired
    private DashboardMapper dashboardMapper;

    @ModelAttribute("sidebarMenuList")
    public List<Map<String, Object>> injectMenuItems() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !auth.getPrincipal().equals("anonymousUser")) {
            List<String> roles = auth.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.toList());
            if (!roles.isEmpty()) {
                return dashboardMapper.selectUserMenuList(roles);
            }
        }
        return null;
    }
}