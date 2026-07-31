package com.idtserver.mrserver.domain;

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
}
