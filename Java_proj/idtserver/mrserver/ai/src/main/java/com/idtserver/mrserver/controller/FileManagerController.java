package com.idtserver.mrserver.controller;


import com.alibaba.fastjson.JSON;
import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.mapper.FileManagerMapper;
import com.idtserver.mrserver.result.NotResultWrap;
import com.idtserver.mrserver.result.Result;
import com.idtserver.mrserver.service.FileManagerService;
import com.idtserver.mrserver.utils.StoreMutipartFile;
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
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;


@CrossOrigin
@RestController
@RequestMapping("FileManager")
public class FileManagerController {

    @Value("${original-file-path}")
    private  String orginalFilePath;

    @Value("${resources-path}")
    private  String prefix;

    @Value("${pics-path}")
    private String picsPath;


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
    public Result<String> uploadChunk(@RequestParam("file") MultipartFile file,
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
            Files.createDirectories(path);

            // The web client currently sends one complete file. Writing it directly
            // avoids a temporary 0.chunk directory that can disappear on Windows.
            if (totalChunks == 1) {
                Path targetFile = path.resolve(newFileName).toAbsolutePath();
                try (java.io.InputStream inputStream = file.getInputStream()) {
                    Files.copy(inputStream, targetFile, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                }
                if (!Files.isRegularFile(targetFile) || Files.size(targetFile) != file.getSize()) {
                    throw new IOException("Uploaded file was not written completely: " + targetFile);
                }
                String storePath = targetFile.toString();
                fileManager.setOriginalFileStoreUrl(storePath);
                fileManager.setCreateUserId(addFileUserId);
                fileManagerService.addNewFileManagerRecord(fileManager, storePath);
                return Result.success("File uploaded successfully.");
            }

            File dir = new File(path.toAbsolutePath().toString() + '/' + UUIDFileName);
            if (!dir.exists()) {
                Files.createDirectories(dir.toPath());
            }

            // 保存每个分片到临时文件夹中
            File chunkFile = new File(dir, String.format("%d.chunk", chunkNumber));
            file.transferTo(chunkFile);

            // 检查是否是最后一个分片，如果是，则合并文件
            if (chunkNumber == totalChunks - 1) {
                String storePath = mergeChunks(path.toAbsolutePath().toString(), UUIDFileName, newFileName, totalChunks);
                fileManager.setOriginalFileStoreUrl(storePath);
                fileManager.setCreateUserId(addFileUserId);
                fileManagerService.addNewFileManagerRecord(fileManager, storePath);

                return Result.success("File uploaded and merged successfully.");
            }

            return Result.success("Chunk " + (chunkNumber + 1) + " uploaded successfully.");
        } catch (IOException e) {
            e.printStackTrace();
            return Result.failure("Error uploading chunk: " + e.getMessage());
        }
    }

    // 合并分片文件
    private String mergeChunks(String storePath, String chunkDirName, String fileName, int totalChunks) throws IOException {
        File dir = new File(storePath + '/' + chunkDirName);
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
    @NotResultWrap
    public ResponseEntity<FileSystemResource> preview(@RequestParam("id") Long id) throws IOException {
        FileManager fileManager = fileManagerMapper.getFileManagerRecordById(id);
        if (fileManager == null || fileManager.getOriginalFileStoreUrl() == null) {
            return ResponseEntity.notFound().build();
        }
        File file = resolvePreviewFile(fileManager);
        if (!file.exists() || !file.isFile()) {
            return ResponseEntity.notFound().build();
        }
        String contentType = resolveContentType(file);
        MediaType mediaType = contentType == null ? MediaType.APPLICATION_OCTET_STREAM : MediaType.parseMediaType(contentType);
        return ResponseEntity.ok()
                .contentType(mediaType)
                .contentLength(file.length())
                .body(new FileSystemResource(file));
    }

    @GetMapping("previewImages")
    public Result<List<String>> previewImages(@RequestParam("id") Long id) throws IOException {
        FileManager fileManager = fileManagerMapper.getFileManagerRecordById(id);
        if (fileManager == null || fileManager.getOriginalFileStoreUrl() == null) {
            return Result.success(Collections.emptyList());
        }
        List<Path> images = getPreviewImages(fileManager);
        Path rootPath = fileManager.getDisposedFileStoreUrl() == null ? null : Paths.get(fileManager.getDisposedFileStoreUrl());
        List<String> names = images.stream()
                .map(path -> rootPath == null ? path.getFileName().toString() : rootPath.relativize(path).toString())
                .collect(Collectors.toList());
        return Result.success(names);
    }

    @GetMapping("previewImage")
    @NotResultWrap
    public ResponseEntity<byte[]> previewImage(@RequestParam("id") Long id,
                                               @RequestParam("index") int index) throws IOException {
        FileManager fileManager = fileManagerMapper.getFileManagerRecordById(id);
        if (fileManager == null || fileManager.getOriginalFileStoreUrl() == null) {
            return ResponseEntity.notFound().build();
        }
        List<Path> images = getPreviewImages(fileManager);
        if (images.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        int currentIndex = Math.max(0, Math.min(index, images.size() - 1));
        File file = images.get(currentIndex).toFile();
        String contentType = resolveContentTypeByName(file);
        MediaType mediaType = contentType == null ? MediaType.APPLICATION_OCTET_STREAM : MediaType.parseMediaType(contentType);
        return ResponseEntity.ok()
                .contentType(mediaType)
                .contentLength(file.length())
                .body(Files.readAllBytes(file.toPath()));
    }

    private File resolvePreviewFile(FileManager fileManager) throws IOException {
        List<Path> images = getPreviewImages(fileManager);
        return images.isEmpty() ? new File(fileManager.getOriginalFileStoreUrl()) : images.get(0).toFile();
    }

    private List<Path> getPreviewImages(FileManager fileManager) throws IOException {
        File originalFile = new File(fileManager.getOriginalFileStoreUrl());
        if (!originalFile.getName().toLowerCase().endsWith(".zip")) {
            return isImageName(originalFile.getName()) ? Collections.singletonList(originalFile.toPath()) : Collections.emptyList();
        }
        Path disposedPath = resolveZipPreviewDir(fileManager, originalFile);
        if (disposedPath == null || !Files.exists(disposedPath)) {
            return Collections.emptyList();
        }
        try (Stream<Path> paths = Files.walk(disposedPath)) {
            return paths
                    .filter(Files::isRegularFile)
                    .filter(path -> isImageName(path.getFileName().toString()))
                    .sorted()
                    .collect(Collectors.toList());
        }
    }

    private Path resolveZipPreviewDir(FileManager fileManager, File originalFile) throws IOException {
        Path disposedPath = null;
        if (fileManager.getDisposedFileStoreUrl() != null && !fileManager.getDisposedFileStoreUrl().trim().isEmpty()) {
            disposedPath = Paths.get(fileManager.getDisposedFileStoreUrl());
        }
        StoreMutipartFile storeMutipartFile = new StoreMutipartFile();
        if (disposedPath != null && Files.exists(disposedPath) && storeMutipartFile.countImages(disposedPath.toString()) > 0) {
            return disposedPath;
        }
        if (!originalFile.exists() || !originalFile.isFile()) {
            return disposedPath;
        }
        String fileName = originalFile.getName();
        String baseName = fileName.contains(".") ? fileName.substring(0, fileName.lastIndexOf(".")) : fileName;
        Path inferredPath = Paths.get(prefix, picsPath, baseName + "_o").toAbsolutePath().normalize();
        storeMutipartFile.unzip(originalFile.getAbsolutePath(), inferredPath.toString());
        int imageCount = storeMutipartFile.countImages(inferredPath.toString());
        fileManager.setDisposedFileStoreUrl(inferredPath.toString());
        fileManager.setImageCount(imageCount);
        fileManagerMapper.updateFileManagerRecord(fileManager);
        return inferredPath;
    }

    private boolean isImageName(String fileName) {
        String name = fileName.toLowerCase();
        return name.endsWith(".jpg")
                || name.endsWith(".jpeg")
                || name.endsWith(".png")
                || name.endsWith(".gif")
                || name.endsWith(".bmp")
                || name.endsWith(".webp");
    }

    private String resolveContentType(File file) throws IOException {
        String contentType = Files.probeContentType(file.toPath());
        if (contentType != null) {
            return contentType;
        }
        return resolveContentTypeByName(file);
    }

    private String resolveContentTypeByName(File file) {
        String name = file.getName().toLowerCase();
        if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
            return "image/jpeg";
        }
        if (name.endsWith(".png")) {
            return "image/png";
        }
        if (name.endsWith(".gif")) {
            return "image/gif";
        }
        if (name.endsWith(".bmp")) {
            return "image/bmp";
        }
        if (name.endsWith(".webp")) {
            return "image/webp";
        }
        if (name.endsWith(".mp4")) {
            return "video/mp4";
        }
        if (name.endsWith(".avi")) {
            return "video/x-msvideo";
        }
        if (name.endsWith(".mov")) {
            return "video/quicktime";
        }
        return null;
    }

}
