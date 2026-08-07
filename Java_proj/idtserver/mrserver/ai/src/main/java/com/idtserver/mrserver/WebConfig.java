package com.idtserver.mrserver; // 或者是 config 包

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 1. 虚拟路径：前端访问时的 URL 前缀
        registry.addResourceHandler("/results/**")

                // 2. 物理路径：【重点】这里必须填 Python 脚本中 OUTPUT_FOLDER 的路径
                // 也就是存放了画好框的图片(det_xxx.jpg)的那个文件夹
                .addResourceLocations("file:D:/project3/auto-label-detection-platform-main/results/");
    }
}