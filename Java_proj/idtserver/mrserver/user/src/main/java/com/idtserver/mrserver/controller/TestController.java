package com.idtserver.mrserver.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("order")
public class TestController {

    @GetMapping("list")
    public String orderList(){
        return "order list";
    }
    @GetMapping("detail")
    public String orderDetail(){
        return "order detail";
    }
}
