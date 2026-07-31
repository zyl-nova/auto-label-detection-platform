package com.idtserver.mrserver.domain;

import lombok.Data;

import java.util.Date;

@Data
public class ModelCenterTreeNodeChildren {
    String id;
    String code;
    String pCode;
    String pId;
    String name;
    Integer sort;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
}
