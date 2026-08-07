package com.idtserver.mrserver;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${camera-results-path:static/cameraResults}")
    private String cameraResultsPath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/results/**")
                .addResourceLocations(Paths.get(cameraResultsPath).toAbsolutePath().normalize().toUri().toString());
    }
}
