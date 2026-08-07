package com.idtserver.mrserver.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.dto.MapLabelTaskPicsToUser;
import com.idtserver.mrserver.dto.TrainingStartRequest;
import com.idtserver.mrserver.mapper.FileManagerMapper;
import com.idtserver.mrserver.mapper.ImageLabelMapper;
import com.idtserver.mrserver.result.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@RestController
@RequestMapping("Training")
public class TrainingController {

    @Value("${resources-path}")
    private String resourcesPath;

    @Value("${python-command:python}")
    private String pythonCommand;

    @Value("${yolo-model-path:yolov8n.pt}")
    private String defaultModelPath;

    @Resource
    private ImageLabelMapper imageLabelMapper;

    @Resource
    private FileManagerMapper fileManagerMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final Map<String, Process> processes = new ConcurrentHashMap<>();

    @PostMapping("start")
    public synchronized Result<?> start(@RequestBody TrainingStartRequest request) {
        boolean hasRunningJob = processes.values().stream().anyMatch(Process::isAlive);
        if (hasRunningJob) {
            return Result.failure("当前已有训练任务正在运行，请等待完成或先停止该任务");
        }
        if (request.getLabelTaskId() == null) {
            return Result.failure("样本没有关联标注任务，无法生成训练数据集");
        }
        int epochs = request.getEpochs() == null ? 100 : Math.max(1, request.getEpochs());
        int batchSize = request.getBatchSize() == null ? 16 : Math.max(1, request.getBatchSize());
        double learningRate = request.getLearningRate() == null ? 0.01 : request.getLearningRate();
        String configuredModel = request.getModelPath() == null || request.getModelPath().trim().isEmpty()
                ? defaultModelPath : request.getModelPath().trim();
        Path modelPath = Paths.get(configuredModel).toAbsolutePath().normalize();
        if (!Files.isRegularFile(modelPath)) {
            return Result.failure("预训练模型不存在：" + modelPath);
        }

        try {
            List<MapLabelTaskPicsToUser> annotations = imageLabelMapper.getAnnotationsForTask(request.getLabelTaskId());
            if (annotations == null || annotations.isEmpty()) {
                return Result.failure("该样本没有已保存的标注数据");
            }

            String jobId = UUID.randomUUID().toString();
            Path jobDir = Paths.get(resourcesPath, "trainingJobs", jobId).toAbsolutePath().normalize();
            Files.createDirectories(jobDir);
            Path manifestPath = jobDir.resolve("manifest.json");
            List<Map<String, Object>> manifestItems = buildManifest(annotations);
            if (manifestItems.isEmpty()) {
                return Result.failure("没有找到可读取的样本图片");
            }

            Map<String, Object> manifest = new LinkedHashMap<>();
            manifest.put("jobId", jobId);
            manifest.put("taskName", request.getTaskName() == null ? "YOLO训练任务" : request.getTaskName());
            manifest.put("items", manifestItems);
            objectMapper.writeValue(manifestPath.toFile(), manifest);

            Path scriptPath = prepareScript();
            Path statusPath = jobDir.resolve("status.json");
            writeInitialStatus(statusPath, jobId, epochs, manifestItems.size());
            Path logPath = jobDir.resolve("train.log");
            Path configDir = Paths.get(resourcesPath, "ultralytics-config").toAbsolutePath().normalize();
            Files.createDirectories(configDir.resolve("Ultralytics"));

            List<String> command = Arrays.asList(
                    pythonCommand,
                    scriptPath.toString(),
                    "--manifest", manifestPath.toString(),
                    "--job-dir", jobDir.toString(),
                    "--model", modelPath.toString(),
                    "--epochs", String.valueOf(epochs),
                    "--batch", String.valueOf(batchSize),
                    "--lr", String.valueOf(learningRate)
            );
            ProcessBuilder builder = new ProcessBuilder(command);
            builder.redirectErrorStream(true);
            builder.redirectOutput(ProcessBuilder.Redirect.appendTo(logPath.toFile()));
            builder.environment().put("PYTHONIOENCODING", "UTF-8");
            builder.environment().put("YOLO_CONFIG_DIR", configDir.toString());
            Process process = builder.start();
            processes.put(jobId, process);
            watchProcess(jobId, process, statusPath);

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("jobId", jobId);
            result.put("sampleCount", manifestItems.size());
            result.put("status", "preparing");
            return Result.success(result);
        } catch (Exception e) {
            return Result.failure("启动训练失败：" + e.getMessage());
        }
    }

    @GetMapping("status/{jobId}")
    public Result<?> status(@PathVariable String jobId) {
        Path jobDir = Paths.get(resourcesPath, "trainingJobs", jobId).toAbsolutePath().normalize();
        Path statusPath = jobDir.resolve("status.json");
        if (!Files.isRegularFile(statusPath)) {
            return Result.failure("训练任务不存在：" + jobId);
        }
        try {
            Map<String, Object> status = objectMapper.readValue(statusPath.toFile(), new TypeReference<Map<String, Object>>() {});
            status.put("jobId", jobId);
            status.put("logs", readLogTail(jobDir.resolve("train.log"), 80));
            Process process = processes.get(jobId);
            String state = String.valueOf(status.get("status"));
            if (("running".equals(state) || "preparing".equals(state)) && process == null) {
                status.put("status", "failed");
                status.put("message", "训练进程已中断，请重新创建训练任务");
                objectMapper.writeValue(statusPath.toFile(), status);
            }
            status.put("processAlive", process != null && process.isAlive());
            return Result.success(status);
        } catch (Exception e) {
            return Result.failure("读取训练状态失败：" + e.getMessage());
        }
    }

    @PostMapping("cancel/{jobId}")
    public Result<?> cancel(@PathVariable String jobId) {
        Process process = processes.remove(jobId);
        if (process != null && process.isAlive()) {
            process.destroyForcibly();
        }
        Path statusPath = Paths.get(resourcesPath, "trainingJobs", jobId, "status.json").toAbsolutePath().normalize();
        try {
            Map<String, Object> status = Files.isRegularFile(statusPath)
                    ? objectMapper.readValue(statusPath.toFile(), new TypeReference<Map<String, Object>>() {})
                    : new LinkedHashMap<>();
            status.put("status", "cancelled");
            status.put("message", "训练已停止");
            objectMapper.writeValue(statusPath.toFile(), status);
            return Result.success("训练已停止");
        } catch (Exception e) {
            return Result.failure("停止训练失败：" + e.getMessage());
        }
    }

    private List<Map<String, Object>> buildManifest(List<MapLabelTaskPicsToUser> annotations) throws IOException {
        List<Map<String, Object>> items = new ArrayList<>();
        Map<String, List<Path>> imageCache = new HashMap<>();
        for (MapLabelTaskPicsToUser annotation : annotations) {
            String fileId = annotation.getInfoFilesManagerInfoId();
            if (fileId == null || annotation.getLabelData() == null) continue;
            List<Path> images = imageCache.get(fileId);
            if (images == null) {
                FileManager file = fileManagerMapper.getFileManagerRecordById(Long.valueOf(fileId));
                images = resolveImages(file);
                imageCache.put(fileId, images);
            }
            int index = annotation.getImageIndex() == null ? 0 : annotation.getImageIndex();
            if (index < 0 || index >= images.size()) continue;
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("fileId", fileId);
            item.put("imageIndex", index);
            item.put("imagePath", images.get(index).toAbsolutePath().normalize().toString());
            item.put("labelData", objectMapper.readTree(annotation.getLabelData()));
            items.add(item);
        }
        return items;
    }

    private List<Path> resolveImages(FileManager file) throws IOException {
        if (file == null) return Collections.emptyList();
        if (file.getDisposedFileStoreUrl() != null && !file.getDisposedFileStoreUrl().trim().isEmpty()) {
            Path disposed = Paths.get(file.getDisposedFileStoreUrl());
            if (Files.isDirectory(disposed)) {
                try (Stream<Path> stream = Files.walk(disposed)) {
                    List<Path> images = stream.filter(Files::isRegularFile)
                            .filter(this::isImage)
                            .sorted()
                            .collect(Collectors.toList());
                    if (!images.isEmpty()) return images;
                }
            }
        }
        if (file.getOriginalFileStoreUrl() == null) return Collections.emptyList();
        Path original = Paths.get(file.getOriginalFileStoreUrl());
        return Files.isRegularFile(original) && isImage(original)
                ? Collections.singletonList(original) : Collections.emptyList();
    }

    private boolean isImage(Path path) {
        String name = path.getFileName().toString().toLowerCase(Locale.ROOT);
        return name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png")
                || name.endsWith(".bmp") || name.endsWith(".webp");
    }

    private Path prepareScript() throws IOException {
        ClassPathResource resource = new ClassPathResource("scripts/yolo_train.py");
        Path scriptPath = Paths.get(resourcesPath, "scripts", "yolo_train.py").toAbsolutePath().normalize();
        Files.createDirectories(scriptPath.getParent());
        try (InputStream inputStream = resource.getInputStream()) {
            Files.copy(inputStream, scriptPath, StandardCopyOption.REPLACE_EXISTING);
        }
        return scriptPath;
    }

    private void writeInitialStatus(Path path, String jobId, int epochs, int sampleCount) throws IOException {
        Map<String, Object> status = new LinkedHashMap<>();
        status.put("jobId", jobId);
        status.put("status", "preparing");
        status.put("progress", 0);
        status.put("currentEpoch", 0);
        status.put("totalEpochs", epochs);
        status.put("sampleCount", sampleCount);
        status.put("message", "正在生成YOLO数据集");
        objectMapper.writeValue(path.toFile(), status);
    }

    private void watchProcess(String jobId, Process process, Path statusPath) {
        Thread watcher = new Thread(() -> {
            try {
                int exitCode = process.waitFor();
                Map<String, Object> status = objectMapper.readValue(statusPath.toFile(), new TypeReference<Map<String, Object>>() {});
                String currentStatus = String.valueOf(status.get("status"));
                if (exitCode != 0 && !"failed".equals(currentStatus) && !"cancelled".equals(currentStatus)) {
                    status.put("status", "failed");
                    status.put("message", "训练进程异常退出，退出码：" + exitCode);
                    objectMapper.writeValue(statusPath.toFile(), status);
                }
            } catch (Exception ignored) {
            } finally {
                processes.remove(jobId);
            }
        }, "yolo-training-" + jobId);
        watcher.setDaemon(true);
        watcher.start();
    }

    private String readLogTail(Path path, int maxLines) throws IOException {
        if (!Files.isRegularFile(path)) return "";
        List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_8);
        int from = Math.max(0, lines.size() - maxLines);
        return String.join(System.lineSeparator(), lines.subList(from, lines.size()));
    }
}
