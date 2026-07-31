package com.idtserver.mrserver.controller;

import com.idtserver.mrserver.entity.SysRole;
import com.idtserver.mrserver.service.RoleService;
import com.idtserver.mrserver.vo.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("role")
public class RoleController {
    @Resource
    private RoleService roleService;
    @GetMapping("getRoleByUserId/{userId}")
    public Result getRoleByUserId(@PathVariable("userId") Integer userId){
        List<SysRole> roleList = roleService.getRoleByUserId(userId);
        return Result.ok().setData(roleList);
    }

}
