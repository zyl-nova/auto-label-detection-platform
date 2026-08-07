package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.Date;


@Data
public class FileManager {
    String id;
    String code;
    String eName;
    String cName;
    String projId;
    Integer sort;
    Integer originalFileType;
    Date createTime;
    Date updateTime;
    String des;
    Integer status; //0：正在上传原始文件 1：正在抽帧 2：完成
    Integer logicalDelete;
    String originalFileStoreUrl;
    String disposedFileStoreUrl;
    Integer imageCount;
    String projName;
    String createUserId;
    String createUserName;

}
