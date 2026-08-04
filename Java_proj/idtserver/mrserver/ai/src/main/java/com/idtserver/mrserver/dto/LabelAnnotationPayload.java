package com.idtserver.mrserver.dto;

public class LabelAnnotationPayload {
    private Long taskId;
    private Long fileId;
    private String labelData;
    private String labelList;
    private String picStoreUrl;

    public Long getTaskId() {
        return taskId;
    }

    public void setTaskId(Long taskId) {
        this.taskId = taskId;
    }

    public Long getFileId() {
        return fileId;
    }

    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public String getLabelData() {
        return labelData;
    }

    public void setLabelData(String labelData) {
        this.labelData = labelData;
    }

    public String getLabelList() {
        return labelList;
    }

    public void setLabelList(String labelList) {
        this.labelList = labelList;
    }

    public String getPicStoreUrl() {
        return picStoreUrl;
    }

    public void setPicStoreUrl(String picStoreUrl) {
        this.picStoreUrl = picStoreUrl;
    }
}
