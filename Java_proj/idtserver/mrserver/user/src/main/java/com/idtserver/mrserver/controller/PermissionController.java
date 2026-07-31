package com.idtserver.mrserver.controller;


import com.idtserver.mrserver.entity.SysMenu;
import com.idtserver.mrserver.service.PermissionService;
import com.idtserver.mrserver.vo.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.List;


@Slf4j
@RestController
@RequestMapping("permission")
public class PermissionController {
    @Resource
    private PermissionService permissionService;
    @GetMapping("getRolePermission/{roleId}")
    public Result getRolePermission(@PathVariable("roleId") Integer roleId){
        List<SysMenu> menuList = permissionService.getPermissionsByRoleId(roleId);
        return Result.ok().setData(menuList);
    }

}
