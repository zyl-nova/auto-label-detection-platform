package com.idtserver.mrserver;

import com.idtserver.mrserver.components.videofilesdeal.VideoTaskListener;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

import javax.annotation.PostConstruct;

@SpringBootApplication
@EnableDiscoveryClient
public class AIApplication {


    public static void main(String[] args) {
        SpringApplication.run(AIApplication.class,args);
    }

    @PostConstruct
    public void init() {
        // 启动监听线程
        Thread listenerThread = new Thread(new VideoTaskListener());
        listenerThread.setDaemon(true); // 设置为守护线程
        listenerThread.start();
    }
}