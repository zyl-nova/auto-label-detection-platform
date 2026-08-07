package com.idtserver.mrserver.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.idtserver.mrserver.dto.DetectionResultPayload;
import com.idtserver.mrserver.result.Result;
import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("Detection")
public class DetectionController {

    @Value("${resources-path}")
    private String resourcesPath;

    @Value("${python-command:python}")
    private String pythonCommand;

    @Value("${yolo-model-path:}")
    private String defaultYoloModelPath;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final String RESULT_DIR = "D:/project3/auto-label-detection-platform-main/results/";

    @PostMapping("run")
    public Result<?> run(@RequestParam("file") MultipartFile file,
                         @RequestParam(value = "modelPath", required = false) String modelPath,
                         @RequestParam(value = "conf", required = false, defaultValue = "0.25") Double conf) {
        String finalModelPath = modelPath == null || modelPath.trim().isEmpty() ? defaultYoloModelPath : modelPath;
        if (finalModelPath == null || finalModelPath.trim().isEmpty()) {
            return Result.failure("请先配置 yolo-model-path，或在请求中传入 modelPath");
        }
        if (isExplicitFilePath(finalModelPath) && !new File(finalModelPath).exists()) {
            return Result.failure("YOLO模型文件不存在：" + finalModelPath);
        }
        if (file == null || file.isEmpty()) {
            return Result.failure("请选择需要识别的图片");
        }

        try {
            Path uploadDir = Paths.get(resourcesPath, "detectionUploads").toAbsolutePath();
            Files.createDirectories(uploadDir);
            String originalName = file.getOriginalFilename() == null ? "" : file.getOriginalFilename();
            String suffix = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : ".jpg";
            Path imagePath = uploadDir.resolve(UUID.randomUUID().toString() + suffix);
            file.transferTo(imagePath.toFile());

            Path scriptPath = prepareScript();
            ProcessOutput output = runPython(scriptPath, imagePath, Paths.get(finalModelPath).toAbsolutePath(), conf);
            if (output.exitCode != 0) {
                return Result.failure(output.stderr.isEmpty() ? "YOLO识别失败" : output.stderr);
            }

            DetectionResultPayload payload = objectMapper.readValue(output.stdout, DetectionResultPayload.class);
            return Result.success(payload);
        } catch (Exception e) {
            return Result.failure("YOLO识别异常：" + e.getMessage());
        }
    }

    @GetMapping("/latest")
    public Result<CameraResultVO> getLatestResult() {
        System.out.println("📡 收到 /Detection/latest 请求");

        File dir = new File(RESULT_DIR);
        if (!dir.exists() || !dir.isDirectory()) {
            System.out.println("❌ 目录不存在: " + RESULT_DIR);
            return Result.success(null);
        }

        // ========== 修改：支持 .jpg 和 .png ==========
        File[] detFiles = dir.listFiles((d, name) ->
                (name.toLowerCase().endsWith(".jpg") || name.toLowerCase().endsWith(".png"))
                        && name.toLowerCase().startsWith("det_"));

        if (detFiles == null || detFiles.length == 0) {
            System.out.println("⚠️ 没有检测结果图片");
            return Result.success(null);
        }

        File latestImage = Arrays.stream(detFiles)
                .filter(File::isFile)
                .max(Comparator.comparingLong(File::lastModified))
                .orElse(null);

        if (latestImage == null) {
            System.out.println("⚠️ 没有找到最新图片");
            return Result.success(null);
        }

        System.out.println("🖼️ 找到最新图片: " + latestImage.getName());

        CameraResultVO vo = new CameraResultVO();
        vo.setImageUrl("/results/" + latestImage.getName());
        vo.setTimestamp(latestImage.lastModified());

        // ========== 修改：支持 .jpg 和 .png 的 JSON 文件名匹配 ==========
        String baseName = latestImage.getName();
        // 替换任意图片后缀为 .json
        String jsonName = baseName.replaceFirst("\\.[a-zA-Z]+$", ".json");
        File jsonFile = new File(RESULT_DIR + jsonName);

        System.out.println("🔍 查找 JSON 文件: " + jsonFile.getAbsolutePath());
        System.out.println("🔍 JSON 文件是否存在: " + jsonFile.exists());

        if (jsonFile.exists()) {
            try {
                String jsonContent = new String(Files.readAllBytes(jsonFile.toPath()), StandardCharsets.UTF_8);
                vo.setJsonData(jsonContent);
                System.out.println("✅ 读取 JSON 成功，长度: " + jsonContent.length());
            } catch (IOException e) {
                System.out.println("❌ 读取 JSON 失败: " + e.getMessage());
                vo.setJsonData("{\"filename\":\"" + latestImage.getName() + "\",\"detections\":[]}");
            }
        } else {
            System.out.println("⚠️ JSON 文件不存在: " + jsonName);
            vo.setJsonData("{\"filename\":\"" + latestImage.getName() + "\",\"detections\":[]}");
        }

        // ========== 新增：设置原图路径 ==========
        String origName = baseName.replaceFirst("det_", "orig_");
        File origFile = new File(RESULT_DIR + origName);
        if (origFile.exists()) {
            vo.setOriginalImage("/results/" + origName);
            System.out.println("✅ 原图存在: " + origName);
        }

        return Result.success(vo);
    }

    @Data
    public static class CameraResultVO {
        private String imageUrl;
        private String originalImage;  // 新增原图字段
        private String jsonData;
        private long timestamp;
    }

    private Path prepareScript() throws IOException {
        ClassPathResource resource = new ClassPathResource("scripts/yolo_detect.py");
        Path scriptPath = Paths.get(resourcesPath, "scripts", "yolo_detect.py").toAbsolutePath();
        Files.createDirectories(scriptPath.getParent());
        try (InputStream inputStream = resource.getInputStream()) {
            Files.copy(inputStream, scriptPath, StandardCopyOption.REPLACE_EXISTING);
        }
        return scriptPath;
    }

    private ProcessOutput runPython(Path scriptPath, Path imagePath, Path modelPath, Double conf) throws Exception {
        List<String> command = new ArrayList<>();
        command.add(pythonCommand);
        command.add(scriptPath.toString());
        command.add("--image");
        command.add(imagePath.toString());
        command.add("--model");
        command.add(modelPath.toString());
        command.add("--conf");
        command.add(String.valueOf(conf == null ? 0.25 : conf));

        Process process = new ProcessBuilder(command).start();
        ByteArrayOutputStream stdout = new ByteArrayOutputStream();
        ByteArrayOutputStream stderr = new ByteArrayOutputStream();
        Thread outThread = new Thread(() -> copy(process.getInputStream(), stdout));
        Thread errThread = new Thread(() -> copy(process.getErrorStream(), stderr));
        outThread.start();
        errThread.start();

        boolean finished = process.waitFor(120, TimeUnit.SECONDS);
        if (!finished) {
            process.destroyForcibly();
            return new ProcessOutput(-1, "", "YOLO识别超时，请检查模型或图片大小");
        }
        outThread.join();
        errThread.join();

        return new ProcessOutput(
                process.exitValue(),
                stdout.toString(StandardCharsets.UTF_8.name()).trim(),
                extractError(stderr.toString(StandardCharsets.UTF_8.name()).trim())
        );
    }

    private void copy(InputStream inputStream, ByteArrayOutputStream outputStream) {
        try {
            byte[] buffer = new byte[8192];
            int length;
            while ((length = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, length);
            }
        } catch (IOException ignored) {
        }
    }

    private String extractError(String stderr) {
        if (stderr == null || stderr.isEmpty()) {
            return "";
        }
        try {
            JsonNode node = objectMapper.readTree(stderr);
            if (node.has("error")) {
                return node.get("error").asText();
            }
        } catch (Exception ignored) {
        }
        return stderr;
    }

    private boolean isExplicitFilePath(String modelPath) {
        return modelPath.contains("/") || modelPath.contains("\\") || modelPath.matches("^[A-Za-z]:.*");
    }

    private static class ProcessOutput {
        private final int exitCode;
        private final String stdout;
        private final String stderr;

        private ProcessOutput(int exitCode, String stdout, String stderr) {
            this.exitCode = exitCode;
            this.stdout = stdout;
            this.stderr = stderr;
        }
    }
}