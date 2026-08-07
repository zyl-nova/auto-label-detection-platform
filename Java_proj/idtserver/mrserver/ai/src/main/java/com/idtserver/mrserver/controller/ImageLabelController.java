package com.idtserver.mrserver.controller;

import com.idtserver.mrserver.dto.LabelAnnotationPayload;
import com.idtserver.mrserver.dto.MapLabelTaskPicsToUser;
import com.idtserver.mrserver.mapper.ImageLabelMapper;
import com.idtserver.mrserver.result.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.Date;

@RestController
@RequestMapping("/ImageLabel")
public class ImageLabelController {

    @Resource
    private ImageLabelMapper imageLabelMapper;

    @PostMapping("saveAnnotation")
    public Result<?> saveAnnotation(@RequestBody LabelAnnotationPayload payload) {
        if (payload.getTaskId() == null || payload.getFileId() == null) {
            return Result.failure("taskId and fileId are required");
        }

        Date now = new Date();
        String labelData = payload.getLabelData() == null || payload.getLabelData().trim().isEmpty()
                ? "[]"
                : payload.getLabelData();
        String labelList = payload.getLabelList() == null || payload.getLabelList().trim().isEmpty()
                ? "[]"
                : payload.getLabelList();

        int imageIndex = payload.getImageIndex() == null ? 0 : Math.max(payload.getImageIndex(), 0);
        MapLabelTaskPicsToUser current = imageLabelMapper.getSavedAnnotation(payload.getTaskId(), payload.getFileId(), imageIndex);
        MapLabelTaskPicsToUser annotation = new MapLabelTaskPicsToUser();
        annotation.setInfoFilesManagerInfoId(String.valueOf(payload.getFileId()));
        annotation.setInfoLabelTaskId(String.valueOf(payload.getTaskId()));
        annotation.setImageIndex(imageIndex);
        annotation.setLabelData(labelData);
        annotation.setLabelList(labelList);
        annotation.setMapLabelTaskUserTabId("48");
        annotation.setReviewStatus(1);
        annotation.setUpdateTime(now);
        annotation.setLogicalDelete(0);
        annotation.setPicStoreUrl(payload.getPicStoreUrl());

        if (current == null) {
            annotation.setCreateTime(now);
            return Result.success(imageLabelMapper.createAnnotation(annotation));
        }

        annotation.setId(current.getId());
        return Result.success(imageLabelMapper.updateAnnotation(annotation));
    }

    @GetMapping("annotation")
    public Result<MapLabelTaskPicsToUser> annotation(@RequestParam("taskId") Long taskId,
                                                    @RequestParam("fileId") Long fileId,
                                                    @RequestParam(value = "imageIndex", defaultValue = "0") Integer imageIndex) {
        return Result.success(imageLabelMapper.getSavedAnnotation(taskId, fileId, Math.max(imageIndex, 0)));
    }
}
