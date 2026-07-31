package com.idtserver.mrserver.components.videofilesdeal;

import org.springframework.stereotype.Component;

@Component
public class VideoTaskListener implements Runnable {
    @Override
    public void run() {
        while (true) {
            try {
                // 从队列中获取任务，并执行
                Runnable task = VideoTaskQueue.getTaskQueue().take();
                task.run();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
}
