package com.idtserver.mrserver.dto;

import lombok.Data;

@Data
public class TrainingStartRequest {
    private Long labelTaskId;
    private String taskName;
    private Integer epochs;
    private Integer batchSize;
    private Double learningRate;
    private String modelPath;
}
