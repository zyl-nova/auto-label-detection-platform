package com.idtserver.mrserver.dto;

import lombok.Data;

import java.math.BigInteger;
import java.util.Date;

@Data
public class InfoModelCenterModelBaseInfo {
    String id;
    String code;
    String eName;
    String cName;
    String projId;
    String projName;
    Integer sort;
    String modelDirUrl;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
    Integer status;
    String des;
}
