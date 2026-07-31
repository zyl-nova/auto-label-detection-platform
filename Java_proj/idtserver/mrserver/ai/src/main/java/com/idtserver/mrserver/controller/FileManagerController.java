package com.idtserver.mrserver.controller;


import com.alibaba.fastjson.JSON;
import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.mapper.FileManagerMapper;
import com.idtserver.mrserver.result.Result;
import com.idtserver.mrserver.service.FileManagerService;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Nullable;
import javax.annotation.Resource;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;


@CrossOrigin
@RestController
@RequestMapping("FileManager")
public class FileManagerController {

    @Value("${original-file-path}")
    private  String orginalFilePath;

    @Value("${resources-path}")
    private  String prefix;


    @Resource
    private FileManagerService fileManagerService;

    @Resource
    private FileManagerMapper fileManagerMapper;

    @PostMapping("list")
    public Result<PageInfo<FileManager>> list(@RequestParam("startPage") int startPage,
                                                @RequestParam("pageSize") int pageSize,
                                                @Nullable @RequestParam("projId") String projId,
                                                @Nullable @RequestParam("mainInfo") String mainInfo,
                                                @Nullable @RequestParam("isDesc") Boolean isDesc,
                                                @Nullable @RequestParam("fileType") int fileType) {
        PageInfo<FileManager> results = fileManagerService.getFileManagerList(projId, mainInfo, isDesc, startPage, pageSize, fileType);
        return Result.success(results);
    }

    // 用于处理每个分片的上传
    @PostMapping("addFile")
    public String uploadChunk(@RequestParam("file") MultipartFile file,
                              @RequestParam("fileManager") String fileManagerJson,
                              @RequestParam("chunkNumber") String chunkNumberStr,
                              @RequestParam("totalChunks") String totalChunksStr,
                              @RequestParam("addFileUserId") String addFileUserId) {

        FileManager fileManager = JSON.parseObject(fileManagerJson, FileManager.class);
        int totalChunks = Integer.parseInt(totalChunksStr);
        int chunkNumber = Integer.parseInt(chunkNumberStr);
        try {
            //使用UUID，避免重复且能根据系统自身进行命名
            String UUIDFileName = UUID.randomUUID().toString();
            String originalName = file.getOriginalFilename() == null ? "" : file.getOriginalFilename();
            String suffix = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
            String newFileName = UUIDFileName + suffix;

            // 为每个文件创建一个单独的临时文件夹
            //原始文件存储文件夹
            String originalFIlesStorePath = prefix + "/" + orginalFilePath;

            Path path = Paths.get(originalFIlesStorePath);
            File dir = new File(path.toAbsolutePath().toString() + '/' + newFileName);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            // 保存每个分片到临时文件夹中
            File chunkFile = new File(dir, String.format("%d.chunk", chunkNumber));
            file.transferTo(chunkFile);

            // 检查是否是最后一个分片，如果是，则合并文件
            if (chunkNumber == totalChunks - 1) {
                String storePath = mergeChunks(path.toAbsolutePath().toString(), newFileName, totalChunks);
                fileManager.setOriginalFileStoreUrl(storePath);
                fileManager.setCreateUserId(addFileUserId);
                fileManagerService.addNewFileManagerRecord(fileManager, storePath);

                return "File uploaded and merged successfully.";
            }

            return "Chunk " + (chunkNumber + 1) + " uploaded successfully.";
        } catch (IOException e) {
            e.printStackTrace();
            return "Error uploading chunk: " + e.getMessage();
        }
    }

    // 合并分片文件
    private String mergeChunks(String storePath, String fileName, int totalChunks) throws IOException {
        File dir = new File(storePath + '/' + fileName );
        File mergedFile = new File(storePath + '/' + fileName);

        try (FileOutputStream fos = new FileOutputStream(mergedFile)) {
            for (int i = 0; i < totalChunks; i++) {
                File chunkFile = new File(dir, String.format("%d.chunk", i));
                Files.copy(chunkFile.toPath(), fos);
                chunkFile.delete(); // 合并后删除分片文件
            }
        }

        // 删除临时文件夹
        dir.delete();

        return mergedFile.getAbsolutePath();
    }


    @PostMapping("updateFile")
    public Result<Integer> updateFile(@RequestBody FileManager fileManager){
        int result = fileManagerService.updateFileManagerRecord(fileManager);
        return Result.success(result);
    }

    @PostMapping("deleteFile")
    public Result<Integer> deleteFile(@RequestParam("id") Long id){
        int result = fileManagerService.deleteFileManagerRecord(id);
        return Result.success(result);
    }

    @GetMapping("preview")
    public ResponseEntity<FileSystemResource> preview(@RequestParam("id") Long id) throws IOException {
        FileManager fileManager = fileManagerMapper.getFileManagerRecordById(id);
        if (fileManager == null || fileManager.getOriginalFileStoreUrl() == null) {
            return ResponseEntity.notFound().build();
        }
        File file = new File(fileManager.getOriginalFileStoreUrl());
        if (!file.exists() || !file.isFile()) {
            return ResponseEntity.notFound().build();
        }
        String contentType = Files.probeContentType(file.toPath());
        MediaType mediaType = contentType == null ? MediaType.APPLICATION_OCTET_STREAM : MediaType.parseMediaType(contentType);
        return ResponseEntity.ok()
                .contentType(mediaType)
                .body(new FileSystemResource(file));
    }

}
