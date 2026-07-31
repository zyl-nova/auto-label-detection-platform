package com.idtserver.mrserver.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.idtserver.mrserver.vo.Result;
import javax.servlet.http.HttpServletRequest;
import java.security.Principal;

@RestController
public class UserController {
    @RequestMapping("/getUser")
    public Principal user(Principal user) {
        return user;
    }

    @RequestMapping("checkToken")
    public Result checkToken(HttpServletRequest request){
        return Result.ok("token有效");
    }
}
