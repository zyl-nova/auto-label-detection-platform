package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.Date;

@Data
public class InfoTaskCenterTrainInfo {
    String id;
    String taskName;
    String projId;
    String des;
    String preTrainModelId;
    String sampleUrl;
    String modelOutputUrl;
    String learningRate;
    String epoch;
    Integer batchSize;
    String testFilesUrl;
    Integer sort;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
    String modelId;
    Integer status;

}
