package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.Date;


@Data
public class LabelTask {
    String id;
    String projId;
    String eName;
    String cName;
    Date deadLine;
    Integer status;
    Integer sort;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
    String desc;
    String infoFilesManagerInfoId;
}
