package com.idtserver.mrserver.controller;

import com.idtserver.mrserver.entity.SysUser;
import com.idtserver.mrserver.service.UserService;
import com.idtserver.mrserver.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("user")
public class UserController {
    @Autowired
    private UserService userService;

    @GetMapping("findByUsername/{username}")
    public Result findByUsername(@PathVariable("username") String username){
        SysUser user = userService.findByUsername(username);
        if (user == null){
            return Result.failure(100,"用户不存在");
        }
        return Result.ok().setData(user);
    }

    //验证通过后，可以通过该接口返回对应的用户名和id
    @PostMapping("getUserName")
    public Result getUserName(@RequestHeader("X-User-Id") String userId,
                              @RequestHeader("X-User-Name") String userName){
        SysUser user = new SysUser();
        SysUser userTmp = userService.findByUsername(userName);
        user.setUsername(userName);
        user.setId(userTmp.getId());
        return Result.ok().setData(user);

    }
}
