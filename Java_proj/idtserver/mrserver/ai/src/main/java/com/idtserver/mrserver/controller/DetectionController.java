package com.idtserver.mrserver.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.idtserver.mrserver.dto.DetectionResultPayload;
import com.idtserver.mrserver.result.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
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

    private Path prepareScript() throws IOException {
        ClassPathResource resource = new ClassPathResource("scripts/yolo_detect.py");
        Path scriptPath = Paths.get(resourcesPath, "scripts", "yolo_detect.py").toAbsolutePath();
        Files.createDirectories(scriptPath.getParent());
        try (InputStream inputStream = resource.getInputStream()) {
            Files.copy(inputStream, scriptPath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
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
