package com.idtserver.mrserver.components.videofilesdeal;

import lombok.Getter;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class VideoTaskQueue {
    // 获取任务的方法
    // 静态队列
    @Getter
    private static final BlockingQueue<Runnable> taskQueue = new LinkedBlockingQueue<>();

    // 提供添加任务的方法
    public static void addTask(Runnable task) {
        taskQueue.offer(task);
    }

}
