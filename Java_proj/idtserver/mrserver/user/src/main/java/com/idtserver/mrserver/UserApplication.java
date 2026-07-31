package com.idtserver.mrserver;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import tk.mybatis.spring.annotation.MapperScan;

import java.util.stream.Collectors;

@SpringBootApplication
@EnableDiscoveryClient
@MapperScan(basePackages = {"com.idtserver.mrserver.mapper"})
public class UserApplication {
    public static void main(String[] args){
        SpringApplication.run(UserApplication.class,args);
    }


}
