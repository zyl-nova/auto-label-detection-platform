package com.idtserver.mrserver.service;


import com.idtserver.mrserver.service.impl.UpmsServiceFallbackFactory;
import com.idtserver.mrserver.vo.MenuVo;
import com.idtserver.mrserver.vo.Result;
import com.idtserver.mrserver.vo.RoleVo;
import com.idtserver.mrserver.vo.UserVo;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;


@FeignClient(name = "UserServer",fallbackFactory = UpmsServiceFallbackFactory.class)
public interface UpmsService {
    @GetMapping("user/findByUsername/{username}")
    Result<UserVo> findByUsername(@PathVariable("username") String username);

    @GetMapping("role/getRoleByUserId/{userId}")
    Result<List<RoleVo>> getRoleByUserId(@PathVariable("userId") Integer userId);

    @GetMapping("permission/getRolePermission/{roleId}")
    Result<List<MenuVo>> getRolePermission(@PathVariable("roleId") Integer roleId);
}
