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

    @Value("${camera-watch-path:cameraInbox}")
    private String cameraWatchPath;

    @Value("${camera-results-path:static/cameraResults}")
    private String cameraResultsPath;

    @Value("${camera-confidence:0.25}")
    private Double cameraConfidence;

    @Value("${camera-scan-interval:2}")
    private Double cameraScanInterval;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private Process cameraProcess;

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

    @PostMapping("camera/start")
    public synchronized Result<?> startCameraDetection() {
        if (cameraProcess != null && cameraProcess.isAlive()) {
            return Result.success(cameraState(true));
        }
        Path modelPath = Paths.get(defaultYoloModelPath).toAbsolutePath().normalize();
        if (!Files.isRegularFile(modelPath)) {
            return Result.failure("YOLO模型文件不存在：" + modelPath);
        }
        try {
            Path watchDir = Paths.get(cameraWatchPath).toAbsolutePath().normalize();
            Path resultDir = cameraResultDir();
            Files.createDirectories(watchDir);
            Files.createDirectories(resultDir);
            Path scriptPath = prepareCameraScript();
            Path logPath = resultDir.resolve("camera-watcher.log");

            List<String> command = Arrays.asList(
                    pythonCommand,
                    scriptPath.toString(),
                    "--watch-dir", watchDir.toString(),
                    "--output-dir", resultDir.toString(),
                    "--model", modelPath.toString(),
                    "--conf", String.valueOf(cameraConfidence),
                    "--interval", String.valueOf(cameraScanInterval)
            );
            ProcessBuilder builder = new ProcessBuilder(command);
            builder.redirectErrorStream(true);
            builder.redirectOutput(ProcessBuilder.Redirect.appendTo(logPath.toFile()));
            builder.environment().put("PYTHONIOENCODING", "UTF-8");
            builder.environment().put("YOLO_CONFIG_DIR",
                    Paths.get(resourcesPath, "ultralytics-config").toAbsolutePath().normalize().toString());
            cameraProcess = builder.start();
            return Result.success(cameraState(true));
        } catch (Exception e) {
            cameraProcess = null;
            return Result.failure("启动相机监听失败：" + e.getMessage());
        }
    }

    @PostMapping("camera/stop")
    public synchronized Result<?> stopCameraDetection() {
        if (cameraProcess != null && cameraProcess.isAlive()) {
            cameraProcess.destroyForcibly();
        }
        cameraProcess = null;
        return Result.success(cameraState(false));
    }

    @GetMapping("camera/status")
    public Result<?> cameraDetectionStatus() {
        return Result.success(cameraState(cameraProcess != null && cameraProcess.isAlive()));
    }

    @GetMapping("latest")
    public Result<CameraResultVO> getLatestResult() {
        Path resultDir = cameraResultDir();
        File dir = resultDir.toFile();
        if (!dir.exists() || !dir.isDirectory()) {
            return Result.success(null);
        }

        // ========== 修改：支持 .jpg 和 .png ==========
        File[] detFiles = dir.listFiles((d, name) ->
                (name.toLowerCase().endsWith(".jpg") || name.toLowerCase().endsWith(".png"))
                        && name.toLowerCase().startsWith("det_"));

        if (detFiles == null || detFiles.length == 0) {
            return Result.success(null);
        }

        File latestImage = Arrays.stream(detFiles)
                .filter(File::isFile)
                .max(Comparator.comparingLong(File::lastModified))
                .orElse(null);

        if (latestImage == null) {
            return Result.success(null);
        }

        CameraResultVO vo = new CameraResultVO();
        vo.setImageUrl("/results/" + latestImage.getName());
        vo.setTimestamp(latestImage.lastModified());

        // ========== 修改：支持 .jpg 和 .png 的 JSON 文件名匹配 ==========
        String baseName = latestImage.getName();
        // 替换任意图片后缀为 .json
        String jsonName = baseName.replaceFirst("\\.[a-zA-Z]+$", ".json");
        File jsonFile = resultDir.resolve(jsonName).toFile();

        if (jsonFile.exists()) {
            try {
                String jsonContent = new String(Files.readAllBytes(jsonFile.toPath()), StandardCharsets.UTF_8);
                vo.setJsonData(jsonContent);
            } catch (IOException e) {
                vo.setJsonData("{\"filename\":\"" + latestImage.getName() + "\",\"detections\":[]}");
            }
        } else {
            vo.setJsonData("{\"filename\":\"" + latestImage.getName() + "\",\"detections\":[]}");
        }

        // ========== 新增：设置原图路径 ==========
        String origName = baseName.replaceFirst("det_", "orig_");
        File origFile = resultDir.resolve(origName).toFile();
        if (origFile.exists()) {
            vo.setOriginalImage("/results/" + origName);
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

    private Path prepareCameraScript() throws IOException {
        ClassPathResource resource = new ClassPathResource("scripts/service1.py");
        Path scriptPath = Paths.get(resourcesPath, "scripts", "camera_watch.py").toAbsolutePath().normalize();
        Files.createDirectories(scriptPath.getParent());
        try (InputStream inputStream = resource.getInputStream()) {
            Files.copy(inputStream, scriptPath, StandardCopyOption.REPLACE_EXISTING);
        }
        return scriptPath;
    }

    private Path cameraResultDir() {
        return Paths.get(cameraResultsPath).toAbsolutePath().normalize();
    }

    private Map<String, Object> cameraState(boolean running) {
        Map<String, Object> state = new LinkedHashMap<>();
        state.put("running", running);
        state.put("watchPath", Paths.get(cameraWatchPath).toAbsolutePath().normalize().toString());
        state.put("resultsPath", cameraResultDir().toString());
        return state;
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
