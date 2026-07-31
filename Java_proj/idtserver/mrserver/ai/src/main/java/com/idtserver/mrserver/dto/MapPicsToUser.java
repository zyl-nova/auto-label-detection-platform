package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.Date;


@Data
public class MapPicsToUser {
    String id;
    String infoFilesManagerInfoId;
    String labelData;
    String labelList;
    String userId;
    Integer reviewStatus;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
    String picStoreUrl;

}
