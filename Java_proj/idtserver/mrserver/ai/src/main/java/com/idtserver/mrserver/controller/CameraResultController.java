package com.idtserver.mrserver.controller;

import com.idtserver.mrserver.result.NotResultWrap;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

@RestController
public class CameraResultController {

    @Value("${camera-results-path:static/cameraResults}")
    private String cameraResultsPath;

    @GetMapping("/results/{filename:.+}")
    @NotResultWrap
    public ResponseEntity<Resource> getResult(@PathVariable("filename") String filename) throws IOException {
        Path resultDir = Paths.get(cameraResultsPath).toAbsolutePath().normalize();
        Path file = resultDir.resolve(filename).normalize();
        if (!file.getParent().equals(resultDir) || !Files.isRegularFile(file)) {
            return ResponseEntity.notFound().build();
        }

        String contentType = Files.probeContentType(file);
        MediaType mediaType = contentType == null
                ? MediaType.APPLICATION_OCTET_STREAM
                : MediaType.parseMediaType(contentType);
        Resource resource = new UrlResource(file.toUri());
        return ResponseEntity.ok()
                .contentType(mediaType)
                .contentLength(Files.size(file))
                .cacheControl(CacheControl.maxAge(1, TimeUnit.MINUTES).cachePublic())
                .body(resource);
    }
}
