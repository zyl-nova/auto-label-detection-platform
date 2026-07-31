package com.idtserver.mrserver.controller;


import com.idtserver.mrserver.result.Result;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.annotation.Resource;

@RequestMapping("/ImageLabel")
public class ImageLabelController {

    @Resource


    @PostMapping("list")
    public Result<String> listFilesRoute() {

        return Result.success("success");
    }

    @PostMapping("list")
    public Result<String> list() {

        return Result.success("success");
    }
}
