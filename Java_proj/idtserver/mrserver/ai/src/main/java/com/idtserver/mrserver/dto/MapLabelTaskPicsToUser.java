package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.Date;

@Data
public class MapLabelTaskPicsToUser {
    String id;
    String infoFilesManagerInfoId;
    String infoLabelTaskId;
    String labelData;
    String labelList;
    String mapLabelTaskUserTabId;
    Integer reviewStatus;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
    String picStoreUrl;
}
