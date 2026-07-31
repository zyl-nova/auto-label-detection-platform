package com.idtserver.mrserver.utils;

import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.dto.MapLabelTaskPicsToUser;
import com.idtserver.mrserver.mapper.FileManagerMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class VideoFilesExtractor implements Runnable{

    String videoFilePath;
    String outputFolderPath;
    int threadCount;
    FileManager fileManager;
    FileManagerMapper fileManagerMapper;



    /**
     *
     * @param videoFilePath 上传的原始视频文件的存储路径
     * @param outputFolderPath 输出抽帧图片的存储路径
     * @param threadCount  抽帧线程数量
     */
    public VideoFilesExtractor(FileManager fileManager,
                               String videoFilePath,
                               String outputFolderPath,
                               int threadCount,
                               FileManagerMapper fileManagerMapper){
        this.outputFolderPath = outputFolderPath;
        this.videoFilePath = videoFilePath;
        this.threadCount = threadCount;
        this.fileManager = fileManager;
        this.fileManagerMapper = fileManagerMapper;
    }

    /**
     * 使用固定数量线程池并行抽取视频帧
     *
     * @param videoFilePath 视频文件路径
     * @param outputFolderPath 抽帧图像存放路径
     * @param threadCount 线程池中的线程数量
     */
    public void extractFramesWithThreadPool(String videoFilePath, String outputFolderPath, int threadCount) {
        ExecutorService executorService = Executors.newFixedThreadPool(threadCount);
        List<MapLabelTaskPicsToUser> picsToInsert = Collections.synchronizedList(new ArrayList<>());
        try {
            Files.createDirectories(Paths.get(outputFolderPath)); // 确保输出目录存在

            int totalFrames = getTotalFrames(videoFilePath);  // 获取视频的总帧数
            System.out.println("Total frames: " + totalFrames);

            // 每个任务处理一定范围的帧
            for (int i = 0; i < totalFrames; i++) {
                final int frameIndex = i;
                executorService.submit(() -> {
                    extractSingleFrame(videoFilePath, outputFolderPath, frameIndex, totalFrames, picsToInsert);
                });
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            executorService.shutdown();
        }

    }

    /**
     * 抽取指定的单帧
     *
     * @param videoFilePath 视频文件路径
     * @param outputFolderPath 抽帧图像存放路径
     * @param frameIndex 要抽取的帧的索引
     */
    @Transactional
    public  void extractSingleFrame(String videoFilePath,
                                     String outputFolderPath,
                                     int frameIndex,
                                     int totalFrames,
                                     List<MapLabelTaskPicsToUser> picsToInsert) {
        String outputFilePath = String.format("%s/frame_%05d.png", outputFolderPath, frameIndex);
        String ffmpegCommand = String.format("ffmpeg -i %s -vf \"select=eq(n\\,%d)\" -vsync vfr %s", videoFilePath, frameIndex, outputFilePath);
        MapLabelTaskPicsToUser m = new MapLabelTaskPicsToUser();
        m.setPicStoreUrl(outputFilePath);
        m.setInfoFilesManagerInfoId(this.fileManager.getId());
        m.setLogicalDelete(0);
        picsToInsert.add(m);
        try {
            ProcessBuilder processBuilder = new ProcessBuilder(ffmpegCommand.split(" "));
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;

            // 打印 FFmpeg 命令输出（调试时可用）
            while ((line = reader.readLine()) != null) {
//                System.out.println(line);
            }

            process.waitFor();
//            System.out.println("Extracted frame: " + frameIndex);
            if(totalFrames == (frameIndex+1) ){
                fileManager.setStatus(2);
                fileManagerMapper.updateFileManagerRecord(fileManager);
                fileManagerMapper.createPicsForLabeling(picsToInsert);

            }

        } catch (IOException | InterruptedException e) {
//            System.err.println("Failed to extract frame: " + frameIndex);
            e.printStackTrace();
        }
    }

    /**
     * 使用 ffprobe 获取视频的总帧数
     *
     * @param videoFilePath 视频文件路径
     * @return 视频总帧数
     */
    private  int getTotalFrames(String videoFilePath) {
        String ffprobeCommand = String.format("ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of csv=p=0 %s", videoFilePath);
        int totalFrames = 0;

        try {
            ProcessBuilder processBuilder = new ProcessBuilder(ffprobeCommand.split(" "));
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;

            while ((line = reader.readLine()) != null) {
                totalFrames = Integer.parseInt(line.trim());  // 读取帧数
            }

            process.waitFor();

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }

        return totalFrames;
    }

    @Override
    public void run() {
        extractFramesWithThreadPool(videoFilePath, outputFolderPath, threadCount);
    }
}
