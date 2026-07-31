package com.idtserver.mrserver.utils;

import org.springframework.web.multipart.MultipartFile;

public class FileValidator {
    public boolean isZipFile(MultipartFile file) {
        String fileName = file.getOriginalFilename();
        if (fileName != null && !fileName.isEmpty()) {
            return fileName.toLowerCase().endsWith(".zip");
        }
        return false;
    }
}
